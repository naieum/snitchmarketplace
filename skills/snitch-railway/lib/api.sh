# lib/api.sh — Railway CLI + GraphQL helpers.
# Every other lib/*.sh that touches the API uses these. Reads RAILWAY_TOKEN /
# RAILWAY_API_TOKEN from env. Refuses to operate when neither is available
# AND `railway whoami` fails — Railway has no global API key fallback by design.

RWSEC_GQL_URL="${RWSEC_GQL_URL:-https://backboard.railway.com/graphql/v2}"
RWSEC_LAST_STATUS=""
RWSEC_LAST_BODY=""
RWSEC_CALL_LOG="${STATE_DIR:-/tmp}/api-calls.log"

# api_check_auth_env — refuse if there is no usable auth path.
# Returns 0 if either:
#   - RAILWAY_API_TOKEN or RAILWAY_TOKEN is set (GraphQL path), OR
#   - `railway whoami` succeeds (CLI session path).
api_check_auth_env() {
  if [[ -n "${RAILWAY_API_TOKEN:-}" || -n "${RAILWAY_TOKEN:-}" ]]; then
    return 0
  fi
  if command -v railway >/dev/null 2>&1; then
    if railway whoami >/dev/null 2>&1; then
      return 0
    fi
  fi
  log_fail "auth" "missing" "Railway auth not found. Run 'railway login' or export RAILWAY_API_TOKEN. The skill refuses to operate without a valid session." "https://docs.railway.com/guides/cli"
  return 2
}

# api_check_auth_env_json — JSON-stderr variant for state subcommands.
api_check_auth_env_json() {
  if [[ -n "${RAILWAY_API_TOKEN:-}" || -n "${RAILWAY_TOKEN:-}" ]]; then
    return 0
  fi
  if command -v railway >/dev/null 2>&1; then
    if railway whoami >/dev/null 2>&1; then
      return 0
    fi
  fi
  printf '{"error":"Railway auth not found","code":"E_AUTH","remediation":"run \"railway login\" or export RAILWAY_API_TOKEN"}\n' >&2
  return 2
}

# rw_cli <args...>
# Wraps the railway CLI. Stdout is the CLI's stdout; non-zero exit returns rc=3.
rw_cli() {
  if ! command -v railway >/dev/null 2>&1; then
    RWSEC_LAST_STATUS="000"
    RWSEC_LAST_BODY='{"error":"railway CLI not installed"}'
    printf '%s\n' "$RWSEC_LAST_BODY"
    return 3
  fi
  local out rc
  out="$(railway "$@" 2>&1)"
  rc=$?
  RWSEC_LAST_STATUS="$rc"
  RWSEC_LAST_BODY="$out"
  printf '%s\n' "$RWSEC_LAST_BODY"
  printf '%s\trailway %s\trc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" "$rc" >> "$RWSEC_CALL_LOG" 2>/dev/null || true
  if [[ "$rc" -ne 0 ]]; then
    return 3
  fi
  return 0
}

# rw_gql <query> [variables_json]
# POST a GraphQL query to backboard.railway.com.
# Auth: prefers RAILWAY_API_TOKEN (account scope), falls back to RAILWAY_TOKEN
# (project scope). Returns body on stdout; rc=3 on non-2xx.
rw_gql() {
  local query="$1" vars="${2:-{}}"
  local tok="${RAILWAY_API_TOKEN:-${RAILWAY_TOKEN:-}}"
  if [[ -z "$tok" ]]; then
    RWSEC_LAST_STATUS="000"
    RWSEC_LAST_BODY='{"errors":[{"message":"no RAILWAY_API_TOKEN or RAILWAY_TOKEN set"}]}'
    printf '%s\n' "$RWSEC_LAST_BODY"
    return 3
  fi
  if ! command -v curl >/dev/null 2>&1; then
    RWSEC_LAST_STATUS="000"
    RWSEC_LAST_BODY='{"errors":[{"message":"curl not present"}]}'
    printf '%s\n' "$RWSEC_LAST_BODY"
    return 3
  fi

  local payload
  payload="$(jq -nc --arg q "$query" --argjson v "$vars" '{query:$q,variables:$v}' 2>/dev/null)"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -X POST \
    -H "Authorization: Bearer ${tok}" \
    -H "Content-Type: application/json" \
    --data "$payload" \
    "$RWSEC_GQL_URL" 2>/dev/null || echo "000")
  RWSEC_LAST_STATUS="$code"
  RWSEC_LAST_BODY="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\trw_gql\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${query:0:60}..." "$code" >> "$RWSEC_CALL_LOG" 2>/dev/null || true
  if [[ "$code" =~ ^2 ]]; then
    printf '%s\n' "$RWSEC_LAST_BODY"
    return 0
  fi
  printf '%s\n' "$RWSEC_LAST_BODY"
  return 3
}

# rw_last_error — pretty-print last GraphQL/CLI error.
rw_last_error() {
  if [[ "$RWSEC_LAST_BODY" == *"errors"* ]]; then
    jq -r '.errors // [] | .[] | "[\(.extensions.code // "?")] \(.message)"' <<<"$RWSEC_LAST_BODY" 2>/dev/null
  else
    printf '%s\n' "$RWSEC_LAST_BODY" | head -n 5
  fi
}

# api_pick_project — read RWSEC_PROJECT_ID, fall back to railway status -j.
api_pick_project() {
  local cache="${STATE_DIR}/project.json"
  if [[ -n "${RWSEC_PROJECT_ID:-}" ]]; then
    printf '%s' "$RWSEC_PROJECT_ID"
    return 0
  fi
  if [[ -f "$cache" ]]; then
    jq -r '.id // empty' "$cache" 2>/dev/null && return 0
  fi
  local body
  body="$(railway status --json 2>/dev/null || railway status -j 2>/dev/null || true)"
  if [[ -z "$body" ]]; then
    return 3
  fi
  local pid
  pid="$(jq -r '.project.id // .id // empty' <<<"$body" 2>/dev/null)"
  if [[ -z "$pid" ]]; then
    return 3
  fi
  printf '%s' "$body" > "$cache"
  printf '%s' "$pid"
}

# api_pick_environment — RWSEC_ENVIRONMENT or fall back to railway status -j default.
api_pick_environment() {
  if [[ -n "${RWSEC_ENVIRONMENT:-}" ]]; then
    printf '%s' "$RWSEC_ENVIRONMENT"
    return 0
  fi
  local body
  body="$(railway status --json 2>/dev/null || railway status -j 2>/dev/null || true)"
  if [[ -z "$body" ]]; then
    printf 'production'
    return 0
  fi
  local env
  env="$(jq -r '.environment.name // .environment // "production"' <<<"$body" 2>/dev/null)"
  printf '%s' "${env:-production}"
}

# doctor_run — foundation check.
doctor_run() {
  local rc=0
  if ! command -v curl >/dev/null 2>&1; then
    log_fail "doctor" "curl" "curl is required."
    rc=2
  else
    log_ok "doctor" "curl" "curl present."
  fi
  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi
  if ! command -v railway >/dev/null 2>&1; then
    log_fail "doctor" "railway" "railway CLI not installed. Install: brew install railway  (macOS) or npm i -g @railway/cli." "https://docs.railway.com/guides/cli"
    rc=2
  else
    local v; v="$(railway --version 2>/dev/null | head -n1)"
    log_ok "doctor" "railway" "$v"
    if railway whoami >/dev/null 2>&1; then
      local who; who="$(railway whoami 2>/dev/null | head -n1)"
      log_ok "doctor" "session" "logged in as: ${who}"
    else
      if [[ -n "${RAILWAY_API_TOKEN:-}" || -n "${RAILWAY_TOKEN:-}" ]]; then
        log_ok "doctor" "session" "RAILWAY_*_TOKEN set — GraphQL queries available."
      else
        log_fail "doctor" "session" "Not logged in and no RAILWAY_API_TOKEN. Run 'railway login' or export a token."
        rc=2
      fi
    fi
  fi

  if [[ -n "${RWSEC_MCP_PRESENT:-}" ]]; then
    log_ok "doctor" "mcp" "Railway MCP detected — agent will prefer it for typed reads."
  else
    log_warn "doctor" "mcp" "No Railway MCP detected. Skill works fine via CLI + GraphQL."
  fi

  return $rc
}
