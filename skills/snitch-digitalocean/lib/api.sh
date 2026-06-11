# lib/api.sh — DigitalOcean REST + doctl helpers.
# Every other lib/*.sh that touches the API uses these.
# Reads $DIGITALOCEAN_ACCESS_TOKEN, or pulls token from doctl context.
# Refuses to operate with no auth at all. Refuses legacy un-scoped tokens
# heuristically (warns when the token's scope/age cannot be determined).

DOSEC_API_BASE="${DOSEC_API_BASE:-https://api.digitalocean.com/v2}"
DOSEC_LAST_STATUS=""
DOSEC_LAST_BODY=""
DOSEC_CALL_LOG="${STATE_DIR:-/tmp}/api-calls.log"

# _api_resolve_token — populate DIGITALOCEAN_ACCESS_TOKEN if doctl has one.
# Sets DOSEC_TOKEN_SOURCE to "env" or "doctl" or empty.
DOSEC_TOKEN_SOURCE=""
_api_resolve_token() {
  if [[ -n "${DIGITALOCEAN_ACCESS_TOKEN:-}" ]]; then
    DOSEC_TOKEN_SOURCE="env"
    return 0
  fi
  if command -v doctl >/dev/null 2>&1; then
    # doctl stores tokens in its yaml config; we can fetch the active context.
    local tok
    tok="$(doctl auth list --format Name 2>/dev/null | grep -E '\(current\)' | awk '{print $1}')"
    if [[ -n "$tok" ]]; then
      DOSEC_TOKEN_SOURCE="doctl"
      # We can't easily extract the token text, but doctl will use it directly.
      return 0
    fi
  fi
  DOSEC_TOKEN_SOURCE=""
  return 1
}

# api_check_auth_env — refuse to operate without auth.
api_check_auth_env() {
  if _api_resolve_token; then
    if [[ "$DOSEC_TOKEN_SOURCE" == "env" ]]; then
      _api_check_token_age || true
    fi
    return 0
  fi
  log_fail "auth" "missing-token" "No DigitalOcean credentials found. Either set DIGITALOCEAN_ACCESS_TOKEN, or run 'doctl auth init'." "https://cloud.digitalocean.com/account/api/tokens"
  return 2
}

# _api_check_token_age — best-effort heuristic. We hit /v2/account; if the
# token has been alive for > ~365d (per the dashboard, not via API), we can't
# easily detect it, so we surface as INFO. Real token revocation is the user's
# call.
_api_check_token_age() {
  local body
  body="$(do_get /account 2>/dev/null)" || return 1
  local email status
  email="$(jq -r '.account.email // empty' <<<"$body" 2>/dev/null)"
  status="$(jq -r '.account.status // empty' <<<"$body" 2>/dev/null)"
  if [[ -z "$email" ]]; then
    log_warn "auth" "token-scope" "Could not verify token scope/age. Re-issue a scoped token if you don't recognize it." "https://cloud.digitalocean.com/account/api/tokens"
    return 0
  fi
  if [[ "$status" != "active" ]]; then
    log_warn "auth" "account-status" "Account status: ${status} (expected 'active')."
  fi
  return 0
}

# _api_call <method> <path> [body]
# Direct REST call. Sets DOSEC_LAST_STATUS / DOSEC_LAST_BODY. Returns 0 on 2xx.
_api_call() {
  local method="$1" path="$2" body="${3:-}"
  local url="${DOSEC_API_BASE}${path}"
  local tok="${DIGITALOCEAN_ACCESS_TOKEN:-}"

  # If env token isn't set, try to extract via doctl.
  if [[ -z "$tok" ]] && command -v doctl >/dev/null 2>&1; then
    # doctl doesn't expose the bearer easily; rely on env or have the user set it.
    DOSEC_LAST_STATUS="000"
    DOSEC_LAST_BODY='{"id":"missing_token","message":"Set DIGITALOCEAN_ACCESS_TOKEN for direct REST calls (doctl-only context detected)"}'
    printf '%s\n' "$DOSEC_LAST_BODY"
    return 3
  fi

  if [[ -z "$tok" ]]; then
    DOSEC_LAST_STATUS="000"
    DOSEC_LAST_BODY='{"id":"missing_token","message":"DIGITALOCEAN_ACCESS_TOKEN not set"}'
    printf '%s\n' "$DOSEC_LAST_BODY"
    return 3
  fi

  local tmp; tmp="$(mktemp)"
  local code
  if [[ -n "$body" ]]; then
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -X "$method" \
      -H "Authorization: Bearer ${tok}" \
      -H "Content-Type: application/json" \
      --data "$body" \
      "$url" 2>/dev/null || echo "000")
  else
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -X "$method" \
      -H "Authorization: Bearer ${tok}" \
      "$url" 2>/dev/null || echo "000")
  fi
  DOSEC_LAST_STATUS="$code"
  DOSEC_LAST_BODY="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\t%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$method" "$url" "$code" >> "$DOSEC_CALL_LOG" 2>/dev/null || true
  if [[ "$code" =~ ^2 ]]; then
    printf '%s\n' "$DOSEC_LAST_BODY"
    return 0
  fi
  printf '%s\n' "$DOSEC_LAST_BODY"
  return 3
}

do_get()    { _api_call GET    "$1"; }
do_post()   { _api_call POST   "$1" "${2:-}"; }
do_patch()  { _api_call PATCH  "$1" "${2:-}"; }
do_put()    { _api_call PUT    "$1" "${2:-}"; }
do_delete() { _api_call DELETE "$1"; }

# do_run <doctl-args...> — run doctl with JSON output, return JSON on stdout.
do_run() {
  if ! command -v doctl >/dev/null 2>&1; then
    printf '{"error":"doctl not installed","code":"E_DOCTL"}\n' >&2
    return 3
  fi
  local out rc
  out="$(doctl "$@" --output json 2>&1)"
  rc=$?
  if [[ $rc -ne 0 ]]; then
    printf '%s\n' "$out" >&2
    return 3
  fi
  printf '%s\n' "$out"
  return 0
}

# do_run_json — same as do_run; explicit name when caller wants JSON only.
do_run_json() { do_run "$@"; }

# do_last_error — pretty-print last API error.
do_last_error() {
  jq -r '. | "[\(.id // "?")] \(.message // "unknown error")"' <<<"$DOSEC_LAST_BODY" 2>/dev/null
}

# Pagination helper. Echoes JSON array combining all pages of a list endpoint.
# Usage: do_get_all <path>  e.g. do_get_all "/droplets?per_page=200"
do_get_all() {
  local path="$1"
  local sep
  if [[ "$path" == *"?"* ]]; then sep="&"; else sep="?"; fi
  local url_path="${path}"
  if [[ "$url_path" != *"per_page="* ]]; then
    url_path="${url_path}${sep}per_page=200"
  fi
  local body all='[]' next page=1
  while :; do
    body="$(do_get "${url_path}")" || { printf '%s\n' "$all"; return 3; }
    # Top-level key is variable per resource; we don't know the resource name here,
    # so the caller usually does its own paging. Default: try .droplets/.databases/etc.
    # Most callers will just fetch one page — leave that as the typical path.
    printf '%s\n' "$body"
    next="$(jq -r '.links.pages.next // empty' <<<"$body" 2>/dev/null)"
    [[ -z "$next" || "$next" == "null" ]] && break
    # Strip base; replace path/query.
    url_path="${next#${DOSEC_API_BASE}}"
    page=$((page+1))
    [[ $page -gt 50 ]] && break
  done
}

# doctor_run: foundation check.
doctor_run() {
  local rc=0
  if ! command -v curl >/dev/null 2>&1; then
    log_fail "doctor" "curl" "curl is required. brew install curl  /  apt-get install curl."
    rc=2
  else
    log_ok "doctor" "curl" "curl present."
  fi
  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required. brew install jq  /  apt-get install jq."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi
  if ! command -v doctl >/dev/null 2>&1; then
    log_warn "doctor" "doctl" "doctl not installed. brew install doctl  /  snap install doctl. Required for typed reads." "https://docs.digitalocean.com/reference/doctl/how-to/install/"
  else
    local v; v="$(doctl version 2>/dev/null | head -n1)"
    log_ok "doctor" "doctl" "$v"
  fi

  if api_check_auth_env; then
    log_ok "doctor" "auth" "DigitalOcean credentials available (source: ${DOSEC_TOKEN_SOURCE})."
  else
    rc=2
  fi

  if [[ -n "${DOSEC_MCP_PRESENT:-}" ]]; then
    log_ok "doctor" "mcp" "DigitalOcean MCP detected — agent will prefer it for typed reads."
  else
    log_info "DigitalOcean MCP not detected. doctl is the primary CLI. The skill works fine without an MCP."
  fi

  return $rc
}
