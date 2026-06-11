# lib/security_extras.sh — easy-wins pack.
# Exposes:
#   security_extras_run            — read-only audit pass: takeovers, cookies, exposure probe, security.txt presence.
#   security_extras_fix <subaction>— security-txt | cookies | takeovers | all.
# Side effects:
#   - cf_get on DNS records.
#   - curl HEAD/GET against deployed hostnames (rate-limited 1/sec).
#   - Emits stdout File-writes for security.txt; never modifies cwd.

# Embedded fallbacks (used only if templates are missing).
_SE_TAKEOVER_DEFAULTS='[
  "*.s3.amazonaws.com",
  "*.s3-website-*",
  "*.github.io",
  "*.herokuapp.com",
  "*.azurewebsites.net",
  "*.cloudfront.net",
  "*.fastly.net",
  "*.netlify.app",
  "*.vercel.app",
  "*.surge.sh",
  "*.firebaseapp.com",
  "*.statuspage.io",
  "*.helpscoutdocs.com",
  "*.tumblr.com",
  "*.zendesk.com"
]'

_SE_PROBE_DEFAULTS='/.git/HEAD
/.env
/.env.local
/.env.production
/.aws/credentials
/wp-admin/
/wp-login.php
/wp-config.php
/phpmyadmin/
/server-status
/.DS_Store
/Dockerfile
/docker-compose.yml
/package.json
/composer.json
/CHANGELOG.txt'

# Known fingerprint substrings indicating the resource is unclaimed.
_SE_TAKEOVER_FINGERPRINTS=(
  "NoSuchBucket"
  "There isn't a GitHub Pages site here"
  "no such app"
  "Repository not found"
  "Heroku | No such app"
  "404 Not Found: Requested route"
  "The specified bucket does not exist"
  "Sorry, this shop is currently unavailable"
  "The page you were looking for doesn't exist"
  "Do you want to register"
  "Project not found"
  "Site Not Found"
  "Whoops! That page is gone"
  "is not a registered InCloud user"
  "This domain is successfully pointed at WP Engine, but is not configured"
)

# _se_load_takeover_patterns -> emits one fnmatch-style pattern per line.
_se_load_takeover_patterns() {
  local f="${TPL_DIR}/takeover-providers.json"
  local body
  if [[ -f "$f" ]]; then
    body="$(cat "$f")"
  else
    body="$_SE_TAKEOVER_DEFAULTS"
  fi
  jq -r '.[]' <<<"$body" 2>/dev/null
}

# _se_load_probe_paths -> emits one path per line.
_se_load_probe_paths() {
  local f="${TPL_DIR}/exposure-probe-paths.txt"
  if [[ -f "$f" ]]; then
    grep -v '^[[:space:]]*$' "$f" | grep -v '^[[:space:]]*#'
  else
    printf '%s\n' "$_SE_PROBE_DEFAULTS"
  fi
}

# _se_match_pattern <hostname> <pattern>
# Returns 0 if hostname matches the fnmatch-style pattern.
_se_match_pattern() {
  local host="$1" pat="$2"
  # shellcheck disable=SC2053
  [[ "$host" == $pat ]]
}

# _se_canonical_hostname -> echo zone.name (best-effort canonical).
_se_canonical_hostname() {
  local zone_id="$1"
  local body
  body="$(cf_get "/zones/${zone_id}")" || { printf ''; return 3; }
  jq -r '.result.name // empty' <<<"$body" 2>/dev/null
}

# scan_takeovers <zone_id>
# Lists DNS records, flags dangling CNAME/ALIAS to known providers.
scan_takeovers() {
  local zone_id="$1"
  local body
  body="$(cf_get "/zones/${zone_id}/dns_records?per_page=1000")" || {
    log_warn "takeovers" "list" "Could not list DNS records for zone." "https://developers.cloudflare.com/dns/manage-dns-records/"
    return 0
  }
  local count_checked=0
  local count_matched=0
  local count_dangling=0

  local patterns
  patterns="$(_se_load_takeover_patterns)"

  # Iterate CNAME / ALIAS records.
  local record
  while IFS=$'\t' read -r rname rtype rcontent; do
    [[ -z "$rname" ]] && continue
    [[ "$rtype" != "CNAME" && "$rtype" != "ALIAS" ]] && continue
    count_checked=$((count_checked + 1))

    local target_lc
    target_lc="$(printf '%s' "$rcontent" | tr '[:upper:]' '[:lower:]')"

    local matched_pattern=""
    while IFS= read -r pat; do
      [[ -z "$pat" ]] && continue
      if _se_match_pattern "$target_lc" "$pat"; then
        matched_pattern="$pat"
        break
      fi
    done <<<"$patterns"

    if [[ -z "$matched_pattern" ]]; then
      continue
    fi
    count_matched=$((count_matched + 1))

    # Probe the target for fingerprints. Use HTTPS and HTTP.
    local probe_body=""
    local fp
    local found=0
    for scheme in https http; do
      probe_body="$(curl -sS -m 10 -L \
        -A "snitch-cloudflare-skill/1.0 (takeover-scan)" \
        "${scheme}://${target_lc}/" 2>/dev/null || true)"
      [[ -z "$probe_body" ]] && continue
      for fp in "${_SE_TAKEOVER_FINGERPRINTS[@]}"; do
        if printf '%s' "$probe_body" | grep -qF "$fp"; then
          found=1
          log_fail "takeovers" "$rname" \
            "Possible subdomain takeover: ${rname} -> ${rcontent} (matched ${matched_pattern}). Provider response contains '${fp}'. Either re-claim the resource at the provider or remove the DNS record." \
            "https://developers.cloudflare.com/dns/manage-dns-records/"
          break
        fi
      done
      [[ "$found" -eq 1 ]] && break
      sleep 1
    done

    if [[ "$found" -eq 1 ]]; then
      count_dangling=$((count_dangling + 1))
    else
      log_warn "takeovers" "$rname" \
        "${rname} -> ${rcontent} points to a managed provider (${matched_pattern}). Verify the resource is claimed and active." \
        "https://developers.cloudflare.com/dns/manage-dns-records/"
    fi
    sleep 1
  done < <(jq -r '.result[] | [.name, .type, .content] | @tsv' <<<"$body" 2>/dev/null)

  if [[ "$count_dangling" -eq 0 && "$count_matched" -gt 0 ]]; then
    log_ok "takeovers" "summary" "Checked ${count_checked} CNAME/ALIAS record(s); ${count_matched} pointed at managed providers; no dangling fingerprints detected."
  elif [[ "$count_matched" -eq 0 ]]; then
    log_ok "takeovers" "summary" "Checked ${count_checked} CNAME/ALIAS record(s); none point at known managed providers."
  fi
}

# audit_cookies <zone_id?>
# Static grep + runtime curl pass.
audit_cookies() {
  local zone_id="${1:-}"

  log_subsection "cookie audit (static)"
  local hits
  hits="$(grep -REn --include='*.js' --include='*.ts' --include='*.tsx' --include='*.jsx' \
    --include='*.mjs' --include='*.cjs' --include='*.py' --include='*.php' \
    --include='*.rb' --include='*.go' --include='*.java' --include='*.kt' \
    -e 'Set-Cookie' \
    -e 'cookie\.set(' \
    -e 'res\.cookie(' \
    -e 'setcookie(' \
    -e 'Cookies\.set(' \
    -e 'cookies\.set(' \
    -e 'Astro\.cookies' \
    -e 'cookies\(\)' \
    . 2>/dev/null | head -200 || true)"

  if [[ -z "$hits" ]]; then
    log_ok "cookies" "static" "No cookie-set call sites found in cwd source."
  else
    local lines_total
    lines_total="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
    log_info "cookie call sites: ${lines_total} (showing first 200)"

    local issues=0
    local auth_issues=0
    local line is_auth
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      is_auth=0
      if printf '%s' "$line" | grep -Eqi 'session|auth|token|jwt|sid|sess'; then
        is_auth=1
      fi

      local missing=()
      printf '%s' "$line" | grep -qi 'Secure'                  || missing+=("Secure")
      printf '%s' "$line" | grep -qi 'HttpOnly\|httpOnly\|http_only' || missing+=("HttpOnly")
      printf '%s' "$line" | grep -qi 'SameSite\|sameSite\|same_site' || missing+=("SameSite")

      if [[ "${#missing[@]}" -gt 0 ]]; then
        local file_loc
        file_loc="$(printf '%s' "$line" | cut -d: -f1-2)"
        if [[ "$is_auth" -eq 1 ]]; then
          auth_issues=$((auth_issues + 1))
          log_fail "cookies" "auth-flags" \
            "Auth-pattern cookie at ${file_loc} missing: ${missing[*]}. Auth cookies require Secure + HttpOnly + SameSite." \
            "https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies"
        else
          issues=$((issues + 1))
          log_warn "cookies" "flags" \
            "Cookie at ${file_loc} missing: ${missing[*]}." \
            "https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies"
        fi
      fi
    done <<<"$hits"

    if [[ "$issues" -eq 0 && "$auth_issues" -eq 0 ]]; then
      log_ok "cookies" "static" "Cookie call sites appear to set Secure + HttpOnly + SameSite."
    fi
  fi

  log_subsection "cookie audit (runtime)"
  local host=""
  if [[ -n "$zone_id" ]]; then
    host="$(_se_canonical_hostname "$zone_id")"
  fi
  if [[ -z "$host" ]]; then
    log_info "no canonical hostname; skipping runtime cookie probe."
    return 0
  fi

  local hdrs
  hdrs="$(curl -sS -m 15 -I -L \
    -A "snitch-cloudflare-skill/1.0 (cookie-audit)" \
    "https://${host}/" 2>/dev/null || true)"

  if [[ -z "$hdrs" ]]; then
    log_warn "cookies" "runtime" "Could not fetch https://${host}/ to inspect Set-Cookie headers."
    return 0
  fi

  local cookie_lines
  cookie_lines="$(printf '%s\n' "$hdrs" | grep -i '^set-cookie:' || true)"
  if [[ -z "$cookie_lines" ]]; then
    log_ok "cookies" "runtime" "No Set-Cookie headers from https://${host}/."
    return 0
  fi

  local rline
  while IFS= read -r rline; do
    [[ -z "$rline" ]] && continue
    local cookie_name
    cookie_name="$(printf '%s' "$rline" | sed -E 's/^[Ss]et-[Cc]ookie:[[:space:]]*([^=]+)=.*/\1/')"
    local missing=()
    printf '%s' "$rline" | grep -qi 'Secure'   || missing+=("Secure")
    printf '%s' "$rline" | grep -qi 'HttpOnly' || missing+=("HttpOnly")
    printf '%s' "$rline" | grep -qi 'SameSite' || missing+=("SameSite")

    if [[ "${#missing[@]}" -eq 0 ]]; then
      log_ok "cookies" "runtime/${cookie_name}" "Cookie ${cookie_name} from https://${host}/ has Secure + HttpOnly + SameSite."
    else
      log_fail "cookies" "runtime/${cookie_name}" \
        "Cookie ${cookie_name} from https://${host}/ missing: ${missing[*]}. Patch the source that sets it (often a 3rd-party widget)." \
        "https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies"
    fi
  done <<<"$cookie_lines"
}

# probe_exposure <zone_id>
# Checks the deployed canonical hostname for known sensitive paths.
# Skipped if the foreign-tech WAF rule is not detected as applied.
probe_exposure() {
  local zone_id="$1"

  # Heuristic: foreign-tech rule applied if ${STATE_DIR}/waf-foreign-tech.applied exists,
  # or a custom ruleset with description containing "foreign-tech" exists.
  local applied=0
  if [[ -f "${STATE_DIR}/waf-foreign-tech.applied" ]]; then
    applied=1
  else
    local rs
    rs="$(cf_get "/zones/${zone_id}/rulesets" 2>/dev/null || true)"
    if [[ -n "$rs" ]] && printf '%s' "$rs" | grep -qi 'foreign-tech'; then
      applied=1
    fi
  fi

  if [[ "$applied" -eq 0 ]]; then
    log_info "skipping exposure-probe: foreign-tech WAF rule not yet applied. Run 'fix waf' first."
    return 0
  fi

  local host
  host="$(_se_canonical_hostname "$zone_id")"
  if [[ -z "$host" ]]; then
    log_warn "exposure-probe" "host" "No canonical hostname; skipping."
    return 0
  fi

  log_info "probing https://${host}/ for sensitive paths (1 req/sec)..."
  local p code
  local total=0
  local fails=0
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    total=$((total + 1))
    code="$(curl -sS -o /dev/null -m 10 \
      -A "snitch-cloudflare-skill/1.0 (exposure-probe)" \
      -w '%{http_code}' -I "https://${host}${p}" 2>/dev/null || echo "000")"
    case "$code" in
      403|404|451)
        log_ok "exposure-probe" "$p" "https://${host}${p} -> ${code} (blocked or absent)."
        ;;
      200)
        fails=$((fails + 1))
        log_fail "exposure-probe" "$p" \
          "https://${host}${p} returned 200 — sensitive path is reachable. Check WAF foreign-tech rule and origin path filters." \
          "https://developers.cloudflare.com/waf/"
        ;;
      301|302|307|308)
        # 301 to login/landing is fine; 301 to a real index page reading the file body would be bad.
        # Without bodies, treat redirects as soft warning.
        log_warn "exposure-probe" "$p" "https://${host}${p} returned ${code} (redirect). Verify destination doesn't expose the resource."
        ;;
      5*)
        fails=$((fails + 1))
        log_fail "exposure-probe" "$p" \
          "https://${host}${p} returned ${code}. 5xx on a sensitive path can indicate the origin processed the request — investigate." \
          "https://developers.cloudflare.com/waf/"
        ;;
      *)
        log_warn "exposure-probe" "$p" "https://${host}${p} returned ${code}."
        ;;
    esac
    sleep 1
  done < <(_se_load_probe_paths)

  if [[ "$fails" -eq 0 ]]; then
    log_ok "exposure-probe" "summary" "All ${total} sensitive-path probes returned 403/404/451 (good)."
  fi
}

# _se_security_txt_present <zone_id>
# Returns 0 if security.txt is reachable.
_se_security_txt_present() {
  local zone_id="$1"
  local host
  host="$(_se_canonical_hostname "$zone_id")"
  [[ -z "$host" ]] && return 1
  local code
  code="$(curl -sS -o /dev/null -m 10 -w '%{http_code}' \
    -A "snitch-cloudflare-skill/1.0 (security-txt-probe)" \
    "https://${host}/.well-known/security.txt" 2>/dev/null || echo "000")"
  [[ "$code" == "200" ]]
}

# security_txt <zone_id?>
# Read-only check: is /.well-known/security.txt reachable?
security_txt() {
  local zone_id="${1:-}"
  if [[ -z "$zone_id" ]]; then
    log_info "security.txt: no zone selected; skipping live check."
    return 0
  fi
  if _se_security_txt_present "$zone_id"; then
    log_ok "security-txt" "present" "/.well-known/security.txt is reachable." "https://www.rfc-editor.org/rfc/rfc9116"
  else
    log_warn "security-txt" "missing" "/.well-known/security.txt not reachable. Run: snitch-cloudflare.sh fix security-txt." "https://www.rfc-editor.org/rfc/rfc9116"
  fi
}

# _se_render_security_txt <contact> <expires_iso> -> stdout file body
_se_render_security_txt() {
  local contact="$1" expires="$2"
  local f="${TPL_DIR}/security-txt.example"
  local body
  if [[ -f "$f" ]]; then
    body="$(cat "$f")"
  else
    body="Contact: __CONTACT__
Expires: __EXPIRES__
Preferred-Languages: en
Canonical: __CANONICAL__"
  fi
  body="${body//__CONTACT__/$contact}"
  body="${body//__EXPIRES__/$expires}"
  printf '%s\n' "$body"
}

# _se_security_txt_emit_pages <body>
_se_security_txt_emit_pages() {
  local body="$1"
  printf '\n=== FILE: public/.well-known/security.txt ===\n'
  printf '=== DIFF ===\n'
  printf -- '--- /dev/null\n+++ public/.well-known/security.txt\n'
  printf '%s\n' "$body" | sed 's/^/+/'
  printf '=== CONTENT ===\n'
  printf '%s\n' "$body"
  printf '=== END ===\n'
}

# _se_security_txt_emit_worker <body>
_se_security_txt_emit_worker() {
  local body="$1"
  local snippet
  snippet="$(cat <<'WORKER_EOF'
// security-txt route handler — drop into your Worker.
// Mounts /.well-known/security.txt and returns the static body.
const SECURITY_TXT = `__BODY__`;

export default {
  async fetch(req, env, ctx) {
    const url = new URL(req.url);
    if (url.pathname === "/.well-known/security.txt") {
      return new Response(SECURITY_TXT, {
        status: 200,
        headers: {
          "content-type": "text/plain; charset=utf-8",
          "cache-control": "public, max-age=86400"
        }
      });
    }
    // Fall through to your existing handler.
    return fetch(req);
  }
};
WORKER_EOF
)"
  snippet="${snippet//__BODY__/$body}"

  printf '\n=== FILE: src/security-txt-route.ts ===\n'
  printf '=== DIFF ===\n'
  printf -- '--- /dev/null\n+++ src/security-txt-route.ts\n'
  printf '%s\n' "$snippet" | sed 's/^/+/'
  printf '=== CONTENT ===\n'
  printf '%s\n' "$snippet"
  printf '=== END ===\n'
}

# security_txt_fix
# Writes /.well-known/security.txt for Pages, or emits a Workers route handler for Workers.
security_txt_fix() {
  local zone_id
  zone_id="$(api_pick_zone 2>/dev/null || true)"

  # Idempotency: if already present and matching, no-op.
  if [[ -n "$zone_id" ]] && _se_security_txt_present "$zone_id"; then
    log_ok "security-txt" "present" "/.well-known/security.txt already reachable; no changes."
    return 0
  fi

  # Read contact from cached account.json or prompt-by-stdout.
  local contact=""
  local cached="${STATE_DIR}/account.json"
  if [[ -f "$cached" ]]; then
    contact="$(jq -r '.security_contact // empty' "$cached" 2>/dev/null)"
  fi
  if [[ -z "$contact" ]]; then
    contact="security@$( _se_canonical_hostname "${zone_id:-}" 2>/dev/null || echo example.com)"
    log_info "no security contact cached; defaulting to ${contact}. Edit \${STATE_DIR}/account.json key 'security_contact' to override."
  fi

  local expires
  if date -u -v+1y +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
    expires="$(date -u -v+1y +%Y-%m-%dT%H:%M:%SZ)"
  else
    expires="$(date -u -d '+1 year' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)"
  fi

  local body
  body="$(_se_render_security_txt "$contact" "$expires")"

  # Pick stack from project-type.txt.
  local pt=""
  [[ -f "${STATE_DIR}/project-type.txt" ]] && pt="$(cat "${STATE_DIR}/project-type.txt")"

  if [[ "$pt" == *"workers"* || "$pt" == *"wrangler"* ]] || [[ -f "wrangler.toml" || -f "wrangler.jsonc" ]]; then
    _se_security_txt_emit_worker "$body"
  else
    _se_security_txt_emit_pages "$body"
  fi
  log_ok "security-txt" "emit" "Emitted security.txt content. Apply via Edit/Write."
}

# cookies_fix
# No source modifications — emit a per-cookie patch suggestion based on static findings.
cookies_fix() {
  log_info "cookies fix is advisory only — emits one-line patches per offending cookie."
  audit_cookies "$(api_pick_zone 2>/dev/null || true)"
  log_info "for each FAIL/WARN above, append '; Secure; HttpOnly; SameSite=Lax' (or 'Strict' for auth cookies) at the call site."
}

# takeovers_fix
# Walks the user through findings — does not auto-delete records.
takeovers_fix() {
  local zone_id
  zone_id="$(api_pick_zone 2>/dev/null)" || {
    log_warn "takeovers" "zone" "Could not pick a zone."
    return 0
  }
  log_info "takeovers fix is interactive — flagged records are not auto-deleted."
  scan_takeovers "$zone_id"
  log_info "for each FAIL above: re-claim the resource at the upstream provider, or remove the DNS record at https://dash.cloudflare.com."
}

# security_extras_run — read-only audit.
security_extras_run() {
  log_section "security extras"
  local zone_id
  zone_id="$(api_pick_zone 2>/dev/null || true)"
  if [[ -n "$zone_id" ]]; then
    log_subsection "subdomain takeover scan"
    scan_takeovers "$zone_id"
    log_subsection "live exposure probe"
    probe_exposure "$zone_id"
    log_subsection "security.txt"
    security_txt "$zone_id"
  else
    log_warn "security-extras" "zone" "No zone selected; skipping zone-scoped checks."
  fi
  log_subsection "cookie audit"
  audit_cookies "$zone_id"
}

# security_extras_fix <subaction>
security_extras_fix() {
  local sub="${1:-all}"
  case "$sub" in
    security-txt) security_txt_fix ;;
    cookies)      cookies_fix ;;
    takeovers)    takeovers_fix ;;
    all)
      security_txt_fix
      takeovers_fix
      cookies_fix
      ;;
    *)
      log_warn "security-extras" "subaction" "Unknown subaction '${sub}'. Use: security-txt | cookies | takeovers | all."
      return 1
      ;;
  esac
}
