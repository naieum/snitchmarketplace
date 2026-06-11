# lib/state_access.sh — list account-scoped Cloudflare Access apps + service tokens.
# Exports: run_state_access [account-id]
#
# Reads CLOUDFLARE_API_TOKEN. GETs /accounts/{id}/access/apps and
# /accounts/{id}/access/service_tokens. Emits one JSON document on stdout
# with header { schema: "cfsec.state-access", schema_version: 1, generated_at, tool }.
#
# Per-call API errors go to stderr as JSON; partial data still emits on stdout.

run_state_access() {
  local account_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  if [[ -z "$account_id" ]]; then
    account_id="$(api_pick_account)" || {
      printf '{"error":"could not resolve account id","code":"E_ACCOUNT","remediation":"set CFSEC_ACCOUNT_ID or pass account-id as the first argument"}\n' >&2
      return 3
    }
  fi

  local apps_body svc_body
  local apps_status="" svc_status=""
  apps_body="$(cf_get "/accounts/${account_id}/access/apps")" && apps_status="ok" || apps_status="$CFSEC_LAST_STATUS"
  svc_body="$(cf_get "/accounts/${account_id}/access/service_tokens")" && svc_status="ok" || svc_status="$CFSEC_LAST_STATUS"

  local apps='[]'
  if [[ "$apps_status" == "ok" ]]; then
    apps="$(jq '.result // []' <<<"$apps_body" 2>/dev/null)" || apps='[]'
  else
    printf '{"error":"failed to fetch access apps","code":"E_API","status":%s,"remediation":"verify token has Access: Apps and Policies:Read for %s"}\n' "${apps_status:-0}" "$account_id" >&2
  fi

  local service_tokens='[]'
  if [[ "$svc_status" == "ok" ]]; then
    service_tokens="$(jq '[(.result // [])[] | {
      id,
      name,
      client_id,
      created_at,
      updated_at,
      expires_at,
      duration
    } | del(.client_secret)]' <<<"$svc_body" 2>/dev/null)" || service_tokens='[]'
  else
    printf '{"error":"failed to fetch access service tokens","code":"E_API","status":%s,"remediation":"verify token has Access: Service Tokens:Read for %s"}\n' "${svc_status:-0}" "$account_id" >&2
  fi

  jq -n \
    --arg ts "$ts" \
    --arg account_id "$account_id" \
    --argjson apps "$apps" \
    --argjson service_tokens "$service_tokens" \
    '{
      schema: "cfsec.state-access",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-access",
      account_id: $account_id,
      apps: $apps,
      service_tokens: $service_tokens
    }'
}
