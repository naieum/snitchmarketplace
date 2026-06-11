# lib/api.sh — Azure CLI wrappers.
# Every other lib/*.sh that touches Azure uses these. Refuses to run when
# AZURE_CLIENT_SECRET is set in env if Workload Identity / Managed Identity
# is available. Caches subscription / tenant / resource-group selection.

AZSEC_LAST_STATUS=""
AZSEC_LAST_STDERR=""
AZSEC_CALL_LOG="${STATE_DIR:-/tmp}/api-calls.log"

# api_check_auth_env — refuse dangerous defaults, ensure az is logged in.
# Called from doctor and every mutating dispatcher.
api_check_auth_env() {
  if [[ -n "${AZURE_CLIENT_SECRET:-}" ]]; then
    if [[ -n "${AZURE_FEDERATED_TOKEN_FILE:-}" || -n "${MSI_ENDPOINT:-}" \
          || -n "${IDENTITY_ENDPOINT:-}" || -n "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
      log_fail "auth" "embedded-secret" "AZURE_CLIENT_SECRET is set, but Workload Identity / Managed Identity is available. Drop the secret and use OIDC federation or MI." "https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation"
      return 2
    fi
  fi
  if ! command -v az >/dev/null 2>&1; then
    log_fail "auth" "missing-az" "Azure CLI ('az') is not installed. Install via: brew install azure-cli (macOS) or apt-get install azure-cli (Linux)." "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    return 2
  fi
  if ! az account show >/dev/null 2>&1; then
    log_fail "auth" "not-logged-in" "Not logged in to Azure CLI. Run 'az login' (interactive) or 'az login --identity' (managed-identity context)." "https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli"
    return 2
  fi
  return 0
}

# az_run <args...> — run az and capture stdout. Stderr goes to AZSEC_LAST_STDERR.
# Non-zero rc passes through. Logs the call into ${STATE_DIR}/api-calls.log.
az_run() {
  local err_tmp; err_tmp="$(mktemp)"
  local out
  if out="$(az "$@" 2>"$err_tmp")"; then
    AZSEC_LAST_STATUS=0
    AZSEC_LAST_STDERR="$(cat "$err_tmp" 2>/dev/null)"
    rm -f "$err_tmp"
    printf '%s\n' "$out"
    printf '%s\taz %s\t0\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >> "$AZSEC_CALL_LOG" 2>/dev/null || true
    return 0
  fi
  AZSEC_LAST_STATUS=$?
  AZSEC_LAST_STDERR="$(cat "$err_tmp" 2>/dev/null)"
  rm -f "$err_tmp"
  printf '%s\taz %s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" "$AZSEC_LAST_STATUS" >> "$AZSEC_CALL_LOG" 2>/dev/null || true
  return "$AZSEC_LAST_STATUS"
}

# az_run_json <args...> — run az and validate stdout parses as JSON.
# Injects '-o json' if not present in args.
az_run_json() {
  local has_o=0 a
  for a in "$@"; do
    case "$a" in
      -o|--output) has_o=1; break ;;
    esac
  done
  local out
  if [[ "$has_o" -eq 0 ]]; then
    out="$(az_run "$@" -o json)" || return $?
  else
    out="$(az_run "$@")" || return $?
  fi
  if ! printf '%s' "$out" | jq -e . >/dev/null 2>&1; then
    AZSEC_LAST_STDERR="non-json output from az: $out"
    return 3
  fi
  printf '%s\n' "$out"
}

# az_pick_subscription — echoes the active or pinned subscription id; caches in .state.
az_pick_subscription() {
  local cache="${STATE_DIR}/subscription.json"
  if [[ -n "${AZSEC_SUBSCRIPTION_ID:-}" ]]; then
    az_run_json account show --subscription "${AZSEC_SUBSCRIPTION_ID}" > "$cache" 2>/dev/null \
      || { return 3; }
    jq -r '.id' "$cache"
    return 0
  fi
  if [[ -f "$cache" ]]; then
    jq -r '.id' "$cache" 2>/dev/null && return 0
  fi
  local body
  body="$(az_run_json account show 2>/dev/null)" || {
    log_warn "auth" "subscription" "No active subscription. Run 'az account set --subscription <id>' or pass AZSEC_SUBSCRIPTION_ID."
    return 3
  }
  printf '%s' "$body" > "$cache"
  jq -r '.id' "$cache"
}

# az_pick_tenant — echoes the active or pinned tenant id; caches in .state.
az_pick_tenant() {
  local cache="${STATE_DIR}/tenant.txt"
  if [[ -n "${AZSEC_TENANT_ID:-}" ]]; then
    printf '%s' "${AZSEC_TENANT_ID}" > "$cache"
    printf '%s' "${AZSEC_TENANT_ID}"
    return 0
  fi
  if [[ -f "$cache" && -s "$cache" ]]; then
    cat "$cache"
    return 0
  fi
  local body
  body="$(az_run_json account show 2>/dev/null)" || return 3
  local tid; tid="$(jq -r '.tenantId // empty' <<<"$body")"
  if [[ -z "$tid" ]]; then
    return 3
  fi
  printf '%s' "$tid" > "$cache"
  printf '%s' "$tid"
}

# az_pick_rg — echoes a chosen resource group, or empty if none specified.
az_pick_rg() {
  if [[ -n "${AZSEC_RESOURCE_GROUP:-}" ]]; then
    printf '%s' "${AZSEC_RESOURCE_GROUP}"
    return 0
  fi
  return 0
}

# az_last_error — emit the captured stderr from the last call.
az_last_error() {
  printf '%s\n' "${AZSEC_LAST_STDERR:-}"
}

# auth_verify — succeeds when az can read the subscription.
auth_verify() {
  local body
  if ! body="$(az_run_json account show 2>/dev/null)"; then
    log_fail "auth" "verify" "az account show failed. $(az_last_error)"
    return 2
  fi
  local id name tenant
  id="$(jq -r '.id // "?"' <<<"$body")"
  name="$(jq -r '.name // "?"' <<<"$body")"
  tenant="$(jq -r '.tenantId // "?"' <<<"$body")"
  log_ok "auth" "verify" "subscription ${name} (${id}) / tenant ${tenant}"
  return 0
}

# doctor_run — env health check.
doctor_run() {
  local rc=0
  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required. Install via: brew install jq (macOS) or apt-get install jq (Linux)."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi
  if ! command -v az >/dev/null 2>&1; then
    log_fail "doctor" "az" "Azure CLI ('az') not installed." "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    rc=2
  else
    local v; v="$(az --version 2>/dev/null | head -n1 | awk '{print $2}')"
    log_ok "doctor" "az" "azure-cli ${v:-installed}"
  fi
  if [[ -n "${AZURE_CLIENT_SECRET:-}" ]]; then
    if [[ -n "${AZURE_FEDERATED_TOKEN_FILE:-}" || -n "${MSI_ENDPOINT:-}" \
          || -n "${IDENTITY_ENDPOINT:-}" || -n "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
      log_fail "doctor" "secret-leak" "AZURE_CLIENT_SECRET is set in env while Workload Identity / Managed Identity is available. Skill will refuse to run." "https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation"
      rc=2
    else
      log_warn "doctor" "secret-leak" "AZURE_CLIENT_SECRET is set in env. Prefer Workload Identity / Managed Identity / OIDC federation when possible."
    fi
  else
    log_ok "doctor" "secret-leak" "no embedded AZURE_CLIENT_SECRET in env."
  fi
  if az account show >/dev/null 2>&1; then
    auth_verify || rc=$?
  else
    log_fail "doctor" "login" "Not logged in. Run 'az login'." "https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli"
    rc=2
  fi
  if [[ -n "${AZSEC_MCP_PRESENT:-}" ]]; then
    log_ok "doctor" "mcp" "Azure MCP detected — agent will prefer it for typed inventory reads."
  else
    log_warn "doctor" "mcp" "Azure MCP not detected. The skill works fine without it; install one for typed inventory reads if available."
  fi
  return "$rc"
}
