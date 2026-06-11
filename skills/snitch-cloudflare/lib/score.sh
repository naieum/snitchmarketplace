# lib/score.sh — external validator scoring (read-only).
# Runs SSL Labs, the MDN HTTP Observatory (Mozilla's Observatory moved to MDN),
# the HSTS preload list, a local security-header grade (securityheaders.com now
# sits behind an anti-bot challenge and can't be scraped), and optionally HIBP
# domains, against each in-scope hostname. Caches results where the upstream
# supports it, runs in parallel where safe, and pretty-prints a markdown grading
# sheet.
#
# Exports: run_score

# _score_hosts
# Echoes a newline-separated list of in-scope hostnames. Sources, in order:
#   1. The arguments passed to run_score.
#   2. The cached zone (api_pick_zone) — top-level zone name.
#   3. ${STATE_DIR}/hostnames.txt if it exists.
_score_hosts() {
  local h
  if [[ $# -gt 0 ]]; then
    for h in "$@"; do printf '%s\n' "$h"; done
    return 0
  fi
  local zone_id; zone_id="$(api_pick_zone 2>/dev/null)"
  if [[ -n "$zone_id" ]]; then
    cf_get "/zones/${zone_id}" \
      | jq -r '.result.name // empty' 2>/dev/null
  fi
  if [[ -f "${STATE_DIR}/hostnames.txt" ]]; then
    cat "${STATE_DIR}/hostnames.txt"
  fi
}

# _score_cache_fresh <path> <max_age_seconds>
# Returns 0 if file exists and is younger than max_age_seconds.
_score_cache_fresh() {
  local path="$1" max="$2"
  [[ -f "$path" ]] || return 1
  local now mtime
  now=$(date +%s)
  if stat -f %m "$path" >/dev/null 2>&1; then
    mtime=$(stat -f %m "$path")
  else
    mtime=$(stat -c %Y "$path")
  fi
  (( now - mtime < max ))
}

# _score_ssllabs <host>
# Kicks off a scan and polls until READY (or hard timeout). Caches 1h.
_score_ssllabs() {
  local host="$1"
  local cache="${STATE_DIR}/score-ssllabs-${host}.json"
  if _score_cache_fresh "$cache" 3600; then
    log_info "ssllabs ${host}: using cached result (<1h old)"
  else
    curl -sS -o "$cache.tmp" \
      -X POST "https://api.ssllabs.com/api/v3/analyze?host=${host}&startNew=on&all=done" \
      >/dev/null 2>&1 || true
    local i status
    for i in $(seq 1 40); do
      sleep 6
      curl -sS -o "$cache.tmp" \
        "https://api.ssllabs.com/api/v3/analyze?host=${host}&all=done" \
        >/dev/null 2>&1 || true
      status="$(jq -r '.status // ""' "$cache.tmp" 2>/dev/null)"
      [[ "$status" == "READY" || "$status" == "ERROR" ]] && break
    done
    mv "$cache.tmp" "$cache" 2>/dev/null || true
  fi
  if [[ ! -s "$cache" ]]; then
    log_warn "score" "ssllabs/${host}" "ssllabs returned no body"
    return 0
  fi
  local status; status="$(jq -r '.status // "?"' "$cache" 2>/dev/null)"
  if [[ "$status" != "READY" ]]; then
    log_warn "score" "ssllabs/${host}" "ssllabs status=${status} (try again later)"
    return 0
  fi
  local grades
  grades="$(jq -r '.endpoints[]? | "\(.ipAddress)\t\(.grade // .statusMessage // "?")"' "$cache" 2>/dev/null)"
  if [[ -z "$grades" ]]; then
    log_warn "score" "ssllabs/${host}" "no endpoints in response"
    return 0
  fi
  printf '%s\n' "$grades" | while IFS=$'\t' read -r ip grade; do
    log_ok "score" "ssllabs/${host}" "endpoint ${ip} → ${grade}"
  done
}

# _score_observatory <host>
# Mozilla retired http-observatory.security.mozilla.org (the old v1 analyze API
# now returns a 502 HTML page). The HTTP Observatory lives at MDN and its v2 API
# scans synchronously — one POST, no polling. Caches 1h. Only a parseable result
# (a grade, or a structured {"error":...}) is promoted to cache so a transient
# 502 never poisons a prior good result.
_score_observatory() {
  local host="$1"
  local cache="${STATE_DIR}/score-observatory-${host}.json"
  if _score_cache_fresh "$cache" 3600; then
    log_info "observatory ${host}: using cached result (<1h old)"
  else
    curl -sS -m 30 -o "$cache.tmp" \
      -A "snitch-cloudflare-skill/1.0 (observatory)" \
      -X POST "https://observatory-api.mdn.mozilla.net/api/v2/scan?host=${host}" \
      >/dev/null 2>&1 || true
    if jq -e '.grade // .error' "$cache.tmp" >/dev/null 2>&1; then
      mv "$cache.tmp" "$cache" 2>/dev/null || true
    else
      rm -f "$cache.tmp" 2>/dev/null || true
    fi
  fi
  if [[ ! -s "$cache" ]]; then
    log_warn "score" "observatory/${host}" "MDN HTTP Observatory returned no parseable body"
    return 0
  fi
  local err; err="$(jq -r '.error // empty' "$cache" 2>/dev/null)"
  if [[ -n "$err" ]]; then
    log_warn "score" "observatory/${host}" "MDN Observatory error: $(jq -r '.message // .error' "$cache" 2>/dev/null)"
    return 0
  fi
  local grade score passed failed url
  grade="$(jq -r '.grade // empty' "$cache" 2>/dev/null)"
  score="$(jq -r '.score // "?"' "$cache" 2>/dev/null)"
  passed="$(jq -r '.tests_passed // "?"' "$cache" 2>/dev/null)"
  failed="$(jq -r '.tests_failed // "?"' "$cache" 2>/dev/null)"
  url="$(jq -r '.details_url // empty' "$cache" 2>/dev/null)"
  [[ -z "$url" ]] && url="https://developer.mozilla.org/en-US/observatory/analyze?host=${host}"
  if [[ -z "$grade" ]]; then
    log_warn "score" "observatory/${host}" "MDN Observatory returned no grade (unparseable response)"
    return 0
  fi
  if [[ "$failed" != "0" && "$failed" != "?" ]]; then
    log_warn "score" "observatory/${host}" "grade ${grade} (score ${score}; ${passed} passed, ${failed} failed)" "$url"
  else
    log_ok "score" "observatory/${host}" "grade ${grade} (score ${score}; ${passed} tests passed)" "$url"
  fi
}

# _score_hsts_preload <host>
# A bare status="unknown" from hstspreload.org is not "all clear" — it just means
# the domain isn't on the submission-based preload list. Whether that's a real
# finding depends on the live header, so we cross-reference the two:
#   - preloaded                                          → OK
#   - not preloaded, but header is already preload-eligible → WARN (just submit it)
#   - not preloaded, header present but not yet eligible    → WARN (what to fix)
#   - not preloaded, no HSTS header at all                  → WARN (enable HSTS first)
# (Chrome also hard-codes a handful of domains like google.com/apple.com outside
# the list — those read "unknown" here too; the submission tool will say so.)
_score_hsts_preload() {
  local host="$1"
  local cache="${STATE_DIR}/score-hstspreload-${host}.json"
  curl -sS -m 20 -o "$cache" \
    -A "snitch-cloudflare-skill/1.0 (hsts-preload)" \
    "https://hstspreload.org/api/v2/status?domain=${host}" \
    >/dev/null 2>&1 || true
  local status="?"
  if [[ -s "$cache" ]]; then
    status="$(jq -r '.status // "?"' "$cache" 2>/dev/null)"
  else
    log_warn "score" "hsts-preload/${host}" "hstspreload.org returned no body"
  fi

  if [[ "$status" == "preloaded" ]]; then
    log_ok "score" "hsts-preload/${host}" "on the HSTS preload list (browsers hard-pin HTTPS)"
    return 0
  fi

  # Not on the list — inspect the live header to make the finding actionable.
  local hdr maxage has_sub has_pre doc="https://hstspreload.org/?domain=${host}"
  hdr="$(curl -sS -m 15 -I -L \
    -A "snitch-cloudflare-skill/1.0 (hsts-preload)" \
    "https://${host}/" 2>/dev/null \
    | grep -i '^strict-transport-security:' | head -n 1 || true)"

  if [[ -z "$hdr" ]]; then
    log_warn "score" "hsts-preload/${host}" \
      "status=${status}; no Strict-Transport-Security header on https://${host}/ — enable HSTS first (Cloudflare SSL/TLS → Edge Certificates → HSTS)" \
      "$doc"
    return 0
  fi

  maxage="$(printf '%s' "$hdr" | grep -oiE 'max-age=[0-9]+' | head -n1 | grep -oE '[0-9]+' || echo 0)"
  [[ -z "$maxage" ]] && maxage=0
  if printf '%s' "$hdr" | grep -qi 'includeSubDomains'; then has_sub=1; else has_sub=0; fi
  if printf '%s' "$hdr" | grep -qi 'preload'; then has_pre=1; else has_pre=0; fi

  # hstspreload.org eligibility: max-age >= 31536000 (1y) + includeSubDomains + preload.
  if [[ "$has_pre" == "1" && "$has_sub" == "1" && "$maxage" -ge 31536000 ]]; then
    log_warn "score" "hsts-preload/${host}" \
      "status=${status}, but the live header is already preload-eligible — submit ${host} at hstspreload.org so browsers hard-pin HTTPS" \
      "$doc"
    return 0
  fi

  local missing=()
  [[ "$maxage" -lt 31536000 ]] && missing+=("max-age must be >= 31536000 (currently ${maxage})")
  [[ "$has_sub" != "1" ]] && missing+=("add includeSubDomains")
  [[ "$has_pre" != "1" ]] && missing+=("add the preload directive")
  local joined; joined="$(printf '%s, ' "${missing[@]}")"; joined="${joined%, }"
  log_warn "score" "hsts-preload/${host}" \
    "status=${status}; HSTS present but not preload-eligible — ${joined}, then submit at hstspreload.org" \
    "$doc"
}

# _score_security_headers <host>
# securityheaders.com now sits behind a Cloudflare anti-bot challenge, so the old
# HTML scrape only ever saw a "Just a moment..." page — there is no grade in the
# markup to parse anymore. Rather than fake one, we compute a transparent LOCAL
# grade from the site's own response headers: the same six headers the public
# tool inspects. Labeled "local" everywhere so it's never mistaken for
# securityheaders.com's own score. The short grade is written to a .grade file
# for the grading sheet.
_score_security_headers() {
  local host="$1"
  local gradefile="${STATE_DIR}/score-secheaders-${host}.grade"
  : > "$gradefile" 2>/dev/null || true
  local hdrs
  hdrs="$(curl -sS -m 15 -I -L \
    -A "snitch-cloudflare-skill/1.0 (header-grade)" \
    "https://${host}/" 2>/dev/null || true)"
  if [[ -z "$hdrs" ]]; then
    log_warn "score" "secheaders/${host}" "could not fetch headers from https://${host}/ — skipping rather than guess a grade"
    return 0
  fi

  local present=0 missing=()
  if printf '%s\n' "$hdrs" | grep -qi '^strict-transport-security:'; then
    present=$((present+1)); else missing+=("Strict-Transport-Security"); fi
  if printf '%s\n' "$hdrs" | grep -qi '^content-security-policy:'; then
    present=$((present+1)); else missing+=("Content-Security-Policy"); fi
  # X-Frame-Options OR a CSP frame-ancestors directive satisfies clickjacking cover.
  if printf '%s\n' "$hdrs" | grep -qi '^x-frame-options:' || printf '%s\n' "$hdrs" | grep -qi 'frame-ancestors'; then
    present=$((present+1)); else missing+=("X-Frame-Options/frame-ancestors"); fi
  if printf '%s\n' "$hdrs" | grep -qiE '^x-content-type-options:[[:space:]]*nosniff'; then
    present=$((present+1)); else missing+=("X-Content-Type-Options: nosniff"); fi
  if printf '%s\n' "$hdrs" | grep -qi '^referrer-policy:'; then
    present=$((present+1)); else missing+=("Referrer-Policy"); fi
  if printf '%s\n' "$hdrs" | grep -qi '^permissions-policy:'; then
    present=$((present+1)); else missing+=("Permissions-Policy"); fi

  local grade
  case "$present" in
    6) grade="A" ;; 5) grade="B" ;; 4) grade="C" ;;
    3) grade="D" ;; 2) grade="E" ;; *) grade="F" ;;
  esac
  printf '%s (%d/6)\n' "$grade" "$present" > "$gradefile" 2>/dev/null || true

  local doc="https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers"
  if [[ "$present" -eq 6 ]]; then
    log_ok "score" "secheaders/${host}" "local header grade ${grade} (${present}/6 present)" "$doc"
  else
    local joined; joined="$(printf '%s, ' "${missing[@]}")"; joined="${joined%, }"
    log_warn "score" "secheaders/${host}" "local header grade ${grade} (${present}/6) — missing: ${joined}" "$doc"
  fi
}

# _score_hibp <host>
_score_hibp() {
  local host="$1"
  if [[ -z "${HIBP_API_KEY:-}" ]]; then
    return 0
  fi
  local cache="${STATE_DIR}/score-hibp-${host}.json"
  curl -sS -o "$cache" \
    -H "hibp-api-key: ${HIBP_API_KEY}" \
    -H "user-agent: snitch-cloudflare-skill" \
    "https://haveibeenpwned.com/api/v3/breaches?domain=${host}" \
    >/dev/null 2>&1 || true
  if [[ ! -s "$cache" ]]; then
    log_warn "score" "hibp/${host}" "hibp returned no body"
    return 0
  fi
  local n; n="$(jq -r 'length // 0' "$cache" 2>/dev/null)"
  if [[ "$n" == "0" ]]; then
    log_ok "score" "hibp/${host}" "no breaches recorded"
  else
    log_warn "score" "hibp/${host}" "${n} breach(es) recorded for this domain"
  fi
}

# _score_one_host <host>
# Runs all validators for one host. Designed to be safe to background.
_score_one_host() {
  local host="$1"
  log_subsection "host: ${host}"
  _score_ssllabs          "$host"
  _score_observatory      "$host"
  _score_hsts_preload     "$host"
  _score_security_headers "$host"
  _score_hibp             "$host"
}

# run_score [hosts...]
run_score() {
  local hosts; hosts="$(_score_hosts "$@")"
  if [[ -z "$hosts" ]]; then
    log_warn "score" "hosts" "no hostnames in scope. Pass them as args or write them to ${STATE_DIR}/hostnames.txt."
    return 0
  fi
  log_section "external validators"
  log_info "this can take 60-120s per host (SSL Labs is slow)"

  # Run hosts in parallel; cap concurrency to avoid hammering upstreams.
  local pids=() max=4 host
  while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    _score_one_host "$host" &
    pids+=("$!")
    if (( ${#pids[@]} >= max )); then
      wait "${pids[0]}" 2>/dev/null || true
      pids=("${pids[@]:1}")
    fi
  done <<<"$hosts"
  for p in "${pids[@]}"; do
    wait "$p" 2>/dev/null || true
  done

  log_subsection "grading sheet"
  printf '| host | ssllabs | observatory | hsts-preload | headers (local) |\n'
  printf '|------|---------|-------------|--------------|-----------------|\n'
  while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    local ssl obs hsts sec
    ssl="$(jq -r '[.endpoints[]?.grade] | join(",") // "?"' "${STATE_DIR}/score-ssllabs-${host}.json" 2>/dev/null || printf '?')"
    obs="$(jq -r '.grade // "?"' "${STATE_DIR}/score-observatory-${host}.json" 2>/dev/null || printf '?')"
    hsts="$(jq -r '.status // "?"' "${STATE_DIR}/score-hstspreload-${host}.json" 2>/dev/null || printf '?')"
    sec="$(cat "${STATE_DIR}/score-secheaders-${host}.grade" 2>/dev/null)"
    [[ -z "$ssl" ]] && ssl="?"
    [[ -z "$obs" || "$obs" == "null" ]] && obs="?"
    [[ -z "$hsts" ]] && hsts="?"
    [[ -z "$sec" ]] && sec="?"
    printf '| %s | %s | %s | %s | %s |\n' "$host" "$ssl" "$obs" "$hsts" "$sec"
  done <<<"$hosts"
}
