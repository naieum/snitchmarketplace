# lib/score.sh — external validators (SSL Labs, Mozilla Observatory, securityheaders, hstspreload).
# Exports: run_score [hosts...]

_score_hosts() {
  local h
  if [[ $# -gt 0 ]]; then
    for h in "$@"; do printf '%s\n' "$h"; done
    return 0
  fi
  if [[ -f "${STATE_DIR}/hostnames.txt" ]]; then
    cat "${STATE_DIR}/hostnames.txt"
  fi
  # Fallback: derive from .vercel/project.json + vercel.json alias[].
  if [[ -f "vercel.json" ]]; then
    jq -r '.alias // [] | .[]' vercel.json 2>/dev/null
  fi
}

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

_score_ssllabs() {
  local host="$1"
  local cache="${STATE_DIR}/score-ssllabs-${host}.json"
  if _score_cache_fresh "$cache" 3600; then
    log_info "ssllabs ${host}: cached"
  else
    curl -sS -o "$cache.tmp" \
      -X POST "https://api.ssllabs.com/api/v3/analyze?host=${host}&startNew=on&all=done" >/dev/null 2>&1 || true
    local i status
    for i in $(seq 1 40); do
      sleep 6
      curl -sS -o "$cache.tmp" \
        "https://api.ssllabs.com/api/v3/analyze?host=${host}&all=done" >/dev/null 2>&1 || true
      status="$(jq -r '.status // ""' "$cache.tmp" 2>/dev/null)"
      [[ "$status" == "READY" || "$status" == "ERROR" ]] && break
    done
    mv "$cache.tmp" "$cache" 2>/dev/null || true
  fi
  if [[ ! -s "$cache" ]]; then
    log_warn "score" "ssllabs/${host}" "no body"
    return 0
  fi
  local status; status="$(jq -r '.status // "?"' "$cache" 2>/dev/null)"
  if [[ "$status" != "READY" ]]; then
    log_warn "score" "ssllabs/${host}" "status=${status}"
    return 0
  fi
  local grades; grades="$(jq -r '.endpoints[]? | "\(.ipAddress)\t\(.grade // .statusMessage // "?")"' "$cache" 2>/dev/null)"
  if [[ -z "$grades" ]]; then
    log_warn "score" "ssllabs/${host}" "no endpoints"
    return 0
  fi
  printf '%s\n' "$grades" | while IFS=$'\t' read -r ip grade; do
    log_ok "score" "ssllabs/${host}" "endpoint ${ip} → ${grade}"
  done
}

_score_observatory() {
  local host="$1"
  local cache="${STATE_DIR}/score-observatory-${host}.json"
  curl -sS -o "$cache" \
    -X POST "https://http-observatory.security.mozilla.org/api/v1/analyze?host=${host}" >/dev/null 2>&1 || true
  local i state
  for i in $(seq 1 30); do
    sleep 4
    curl -sS -o "$cache" \
      "https://http-observatory.security.mozilla.org/api/v1/analyze?host=${host}" >/dev/null 2>&1 || true
    state="$(jq -r '.state // ""' "$cache" 2>/dev/null)"
    [[ "$state" == "FINISHED" || "$state" == "FAILED" || "$state" == "ABORTED" ]] && break
  done
  if [[ ! -s "$cache" ]]; then
    log_warn "score" "observatory/${host}" "no body"
    return 0
  fi
  local grade score
  grade="$(jq -r '.grade // "?"' "$cache" 2>/dev/null)"
  score="$(jq -r '.score // "?"' "$cache" 2>/dev/null)"
  log_ok "score" "observatory/${host}" "grade ${grade} (score ${score})"
}

_score_hsts_preload() {
  local host="$1"
  local cache="${STATE_DIR}/score-hstspreload-${host}.json"
  curl -sS -o "$cache" "https://hstspreload.org/api/v2/status?domain=${host}" >/dev/null 2>&1 || true
  if [[ ! -s "$cache" ]]; then
    log_warn "score" "hsts-preload/${host}" "no body"
    return 0
  fi
  local status; status="$(jq -r '.status // "?"' "$cache" 2>/dev/null)"
  log_ok "score" "hsts-preload/${host}" "status=${status}"
}

_score_security_headers() {
  local host="$1"
  local cache="${STATE_DIR}/score-secheaders-${host}.html"
  curl -sS -A "snitch-vercel-skill" -o "$cache" \
    "https://securityheaders.com/?q=${host}&followRedirects=on&hide=on" >/dev/null 2>&1 || true
  if [[ ! -s "$cache" ]]; then
    log_warn "score" "secheaders/${host}" "no body"
    return 0
  fi
  local grade
  grade="$(grep -E -o 'class="score_lite[A-F][+-]?"' "$cache" 2>/dev/null \
    | head -n 1 | sed -E 's/.*score_lite([A-F][+-]?).*/\1/')"
  if [[ -z "$grade" ]]; then
    log_warn "score" "secheaders/${host}" "could not parse grade"
    return 0
  fi
  log_ok "score" "secheaders/${host}" "grade ${grade}"
}

_score_one_host() {
  local host="$1"
  log_subsection "host: ${host}"
  _score_ssllabs          "$host"
  _score_observatory      "$host"
  _score_hsts_preload     "$host"
  _score_security_headers "$host"
}

run_score() {
  local hosts; hosts="$(_score_hosts "$@")"
  if [[ -z "$hosts" ]]; then
    log_warn "score" "hosts" "no hostnames in scope. Pass them as args or write them to ${STATE_DIR}/hostnames.txt."
    return 0
  fi
  log_section "external validators"
  log_info "this can take 60-120s per host (SSL Labs is slow)"

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
  printf '| host | ssllabs | observatory | hsts-preload | secheaders |\n'
  printf '|------|---------|-------------|--------------|------------|\n'
  while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    local ssl obs hsts sec
    ssl="$(jq -r '[.endpoints[]?.grade] | join(",") // "?"' "${STATE_DIR}/score-ssllabs-${host}.json" 2>/dev/null || printf '?')"
    obs="$(jq -r '.grade // "?"' "${STATE_DIR}/score-observatory-${host}.json" 2>/dev/null || printf '?')"
    hsts="$(jq -r '.status // "?"' "${STATE_DIR}/score-hstspreload-${host}.json" 2>/dev/null || printf '?')"
    sec="$(grep -E -o 'class="score_lite[A-F][+-]?"' "${STATE_DIR}/score-secheaders-${host}.html" 2>/dev/null \
      | head -n 1 | sed -E 's/.*score_lite([A-F][+-]?).*/\1/')"
    [[ -z "$sec" ]] && sec="?"
    printf '| %s | %s | %s | %s | %s |\n' "$host" "$ssl" "$obs" "$hsts" "$sec"
  done <<<"$hosts"
}
