# lib/state_tunnels.sh — list account-scoped Cloudflare Tunnels as JSON.
# Exports: run_state_tunnels [account-id]
#
# Reads CLOUDFLARE_API_TOKEN. GETs /accounts/{id}/cfd_tunnel?per_page=200,
# strips credential material, and emits one JSON document on stdout with
# header { schema: "cfsec.state-tunnels", schema_version: 1, generated_at, tool }.
#
# API errors go to stderr as JSON; on failure stdout still emits the header
# with an empty tunnels array.

run_state_tunnels() {
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

  local body status="" tunnels='[]' rc=0
  if body="$(cf_get "/accounts/${account_id}/cfd_tunnel?per_page=200")"; then
    status="ok"
  else
    status="$CFSEC_LAST_STATUS"
  fi

  if [[ "$status" == "ok" ]]; then
    tunnels="$(jq '[(.result // [])[] | {
      id,
      name,
      status,
      created_at,
      deleted_at,
      account_tag,
      connections: (.connections // []),
      conns_active_at: (.conns_active_at // null),
      metadata: (.metadata // {}),
      remote_config: (.remote_config // null)
    } | del(.credentials_file, .tunnel_secret, .token)]' <<<"$body" 2>/dev/null)" || tunnels='[]'
  else
    printf '{"error":"failed to fetch tunnels","code":"E_API","status":%s,"remediation":"verify token has Cloudflare Tunnel:Read for %s"}\n' "${status:-0}" "$account_id" >&2
    rc=3
  fi

  jq -n \
    --arg ts "$ts" \
    --arg account_id "$account_id" \
    --argjson tunnels "$tunnels" \
    '{
      schema: "cfsec.state-tunnels",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-tunnels",
      account_id: $account_id,
      tunnels: $tunnels
    }'

  return $rc
}
