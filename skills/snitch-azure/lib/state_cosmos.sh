# lib/state_cosmos.sh — Cosmos DB digest.
# slice ∈ digest (default) | accounts | full

run_state_cosmos() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local accounts
  accounts="$(az_run_json cosmosdb list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location, kind,
      publicNetworkAccess,
      minimalTlsVersion,
      disableLocalAuth,
      isVirtualNetworkFilterEnabled,
      networkAclBypass,
      privateEndpointConnections_count: ((.privateEndpointConnections // []) | length),
      keyVaultKeyUri,
      backupPolicy_type: .backupPolicy.type,
      enableMultipleWriteLocations
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    accounts|full)
      local schema_name="azsec.state-cosmos.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson a "$accounts" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-cosmos", slice:$sl, subscription_id:$sub_id, accounts:$a}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson a "$accounts" \
    '{
      schema: "azsec.state-cosmos.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-cosmos",
      slice: "digest",
      subscription_id: $sub_id,
      accounts_summary: {
        total: ($a | length),
        public_access: ($a | map(select(.publicNetworkAccess=="Enabled")) | length),
        tls_below_12: ($a | map(select((.minimalTlsVersion // "") < "Tls12" and (.minimalTlsVersion // "")!="")) | length),
        local_auth_enabled: ($a | map(select(.disableLocalAuth!=true)) | length),
        no_cmk: ($a | map(select((.keyVaultKeyUri // "")=="")) | length),
        private_endpoint_count: ($a | map(select(.privateEndpointConnections_count > 0)) | length),
        names: ($a | map(.name))
      },
      hint: "for per-account data, run: state cosmos [accounts|full]"
    }'
}
