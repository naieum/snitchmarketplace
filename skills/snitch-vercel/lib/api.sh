# lib/api.sh — Vercel CLI + REST helpers.
# Every other lib/*.sh that touches Vercel uses these.
# Reads $VERCEL_TOKEN for direct REST calls; falls back to $(vercel ...) CLI for command-style queries.

VRCSEC_API_BASE="${VRCSEC_API_BASE:-https://api.vercel.com}"
VRCSEC_LAST_STATUS=""
VRCSEC_LAST_BODY=""
VRCSEC_CALL_LOG="${STATE_DIR:-/tmp}/api-calls.log"
VRCSEC_AUTH_FILE_LINUX="${HOME}/.local/share/com.vercel.cli/auth.json"
VRCSEC_AUTH_FILE_DARWIN="${HOME}/Library/Application Support/com.vercel.cli/auth.json"

# vercel_auth_file — echo path to the CLI-managed auth json if present.
vercel_auth_file() {
  if [[ -f "$VRCSEC_AUTH_FILE_LINUX" ]]; then
    printf '%s' "$VRCSEC_AUTH_FILE_LINUX"; return 0
  fi
  if [[ -f "$VRCSEC_AUTH_FILE_DARWIN" ]]; then
    printf '%s' "$VRCSEC_AUTH_FILE_DARWIN"; return 0
  fi
  return 1
}

# api_check_auth_env — log a [FAIL] if neither a CLI session nor VERCEL_TOKEN is usable.
# Returns 0 if auth is present, 2 if not.
api_check_auth_env() {
  if [[ -n "${VERCEL_TOKEN:-}" ]]; then
    return 0
  fi
  if command -v vercel >/dev/null 2>&1 && vercel whoami >/dev/null 2>&1; then
    return 0
  fi
  log_fail "auth" "missing-token" "Neither VERCEL_TOKEN nor a working 'vercel whoami' session detected. Run 'vercel login' OR export a scoped token from https://vercel.com/account/tokens." "https://vercel.com/account/tokens"
  return 2
}

# _vrc_team_query — appends ?teamId=… when VRCSEC_TEAM_ID is set.
_vrc_team_query() {
  local path="$1"
  if [[ -n "${VRCSEC_TEAM_ID:-}" ]]; then
    if [[ "$path" == *\?* ]]; then
      printf '%s&teamId=%s' "$path" "${VRCSEC_TEAM_ID}"
    else
      printf '%s?teamId=%s' "$path" "${VRCSEC_TEAM_ID}"
    fi
  else
    printf '%s' "$path"
  fi
}

_api_call() {
  local method="$1" path="$2" body="${3:-}"
  local qpath; qpath="$(_vrc_team_query "$path")"
  local url="${VRCSEC_API_BASE}${qpath}"
  local tok="${VERCEL_TOKEN:-}"
  if [[ -z "$tok" ]]; then
    VRCSEC_LAST_STATUS="000"
    VRCSEC_LAST_BODY='{"error":{"code":"missing_token","message":"VERCEL_TOKEN not set; some richer-JSON endpoints require it"}}'
    printf '%s\n' "$VRCSEC_LAST_BODY"
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
  VRCSEC_LAST_STATUS="$code"
  VRCSEC_LAST_BODY="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\t%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$method" "$url" "$code" >> "$VRCSEC_CALL_LOG" 2>/dev/null || true
  if [[ "$code" =~ ^2 ]]; then
    printf '%s\n' "$VRCSEC_LAST_BODY"
    return 0
  fi
  printf '%s\n' "$VRCSEC_LAST_BODY"
  return 3
}

vrc_get()    { _api_call GET    "$1"; }
vrc_post()   { _api_call POST   "$1" "${2:-}"; }
vrc_patch()  { _api_call PATCH  "$1" "${2:-}"; }
vrc_put()    { _api_call PUT    "$1" "${2:-}"; }
vrc_delete() { _api_call DELETE "$1"; }

# vrc_last_error — pretty-print Vercel REST error.
vrc_last_error() {
  jq -r '.error // {} | "[\(.code // "?")] \(.message // "no message")"' <<<"$VRCSEC_LAST_BODY" 2>/dev/null
}

# vercel_run — invoke the vercel CLI; pass through stdout. rc passes through.
vercel_run() {
  if ! command -v vercel >/dev/null 2>&1; then
    log_fail "auth" "no-cli" "vercel CLI not installed. npm i -g vercel"
    return 2
  fi
  local args=("$@")
  if [[ -n "${VRCSEC_TEAM_ID:-}" ]]; then
    args=(--scope "${VRCSEC_TEAM_ID}" "${args[@]}")
  fi
  if [[ -n "${VERCEL_TOKEN:-}" ]]; then
    args=(--token "${VERCEL_TOKEN}" "${args[@]}")
  fi
  vercel "${args[@]}" 2>/dev/null
}

# vercel_run_json — invoke the CLI and try to JSON-parse stdout. Falls back to
# a synthetic {"raw": "<stdout>"} object if not parseable.
vercel_run_json() {
  local out; out="$(vercel_run "$@" 2>/dev/null || true)"
  if printf '%s' "$out" | jq -e . >/dev/null 2>&1; then
    printf '%s' "$out"
  else
    jq -n --arg raw "$out" '{raw: $raw}'
  fi
}

# vercel_pick_team — resolve team id from cache, env, or .vercel/project.json.
vercel_pick_team() {
  if [[ -n "${VRCSEC_TEAM_ID:-}" ]]; then
    printf '%s' "${VRCSEC_TEAM_ID}"
    return 0
  fi
  if [[ -f ".vercel/project.json" ]]; then
    local tid; tid="$(jq -r '.orgId // empty' .vercel/project.json 2>/dev/null)"
    if [[ -n "$tid" && "$tid" != "null" ]]; then
      printf '%s' "$tid"
      return 0
    fi
  fi
  # Try /v2/teams
  local body; body="$(vrc_get /v2/teams)" || return 3
  local count; count="$(jq -r '.teams | length // 0' <<<"$body" 2>/dev/null)"
  if [[ "$count" == "1" ]]; then
    jq -r '.teams[0].id' <<<"$body"
    return 0
  fi
  return 3
}

# vercel_pick_project — resolve project id from env or .vercel/project.json.
vercel_pick_project() {
  if [[ -n "${VRCSEC_PROJECT_ID:-}" ]]; then
    printf '%s' "${VRCSEC_PROJECT_ID}"
    return 0
  fi
  if [[ -f ".vercel/project.json" ]]; then
    local pid; pid="$(jq -r '.projectId // empty' .vercel/project.json 2>/dev/null)"
    if [[ -n "$pid" && "$pid" != "null" ]]; then
      printf '%s' "$pid"
      return 0
    fi
  fi
  return 3
}

# doctor_run — foundation check.
doctor_run() {
  local rc=0
  if ! command -v curl >/dev/null 2>&1; then
    log_fail "doctor" "curl" "curl is required. Install via: brew install curl  (macOS) or apt-get install curl  (Linux)."
    rc=2
  else
    log_ok "doctor" "curl" "curl present."
  fi
  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required. Install via: brew install jq  (macOS) or apt-get install jq  (Linux)."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi

  if command -v vercel >/dev/null 2>&1; then
    local v; v="$(vercel --version 2>/dev/null | head -n1)"
    log_ok "doctor" "vercel-cli" "vercel CLI: ${v}"
  else
    log_warn "doctor" "vercel-cli" "vercel CLI not installed. Recommended: 'npm i -g vercel'." "https://vercel.com/docs/cli"
  fi

  if [[ -n "${VERCEL_TOKEN:-}" ]]; then
    log_ok "doctor" "token" "VERCEL_TOKEN is set."
  else
    log_warn "doctor" "token" "VERCEL_TOKEN not set. Some endpoints (env-var sensitivity, log drains, audit log) require it." "https://vercel.com/account/tokens"
  fi

  if command -v vercel >/dev/null 2>&1 && vercel whoami >/dev/null 2>&1; then
    local who; who="$(vercel whoami 2>/dev/null | head -n1)"
    log_ok "doctor" "whoami" "vercel session active: ${who}"
  else
    log_warn "doctor" "whoami" "no active vercel session (vercel whoami fails). Run 'vercel login' or set VERCEL_TOKEN."
  fi

  local af; if af="$(vercel_auth_file)"; then
    log_ok "doctor" "auth-file" "CLI auth file present: ${af}"
  fi

  if [[ -n "${VRCSEC_MCP_PRESENT:-}" ]]; then
    log_ok "doctor" "mcp" "Vercel MCP detected — agent will prefer it for typed reads where available."
  else
    log_info "no Vercel MCP detected (set VRCSEC_MCP_PRESENT=1 if one is loaded). The skill works without it."
  fi

  return $rc
}
