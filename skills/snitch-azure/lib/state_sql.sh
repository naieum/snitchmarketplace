# lib/state_sql.sh — Azure SQL digest.
# slice ∈ digest (default) | servers | databases | full

run_state_sql() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local servers
  servers="$(az_run_json sql server list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location, version,
      publicNetworkAccess,
      minimalTlsVersion,
      administrators_administratorType: .administrators.administratorType,
      administrators_login: .administrators.login,
      administrators_aadOnly: .administrators.azureAdOnlyAuthentication
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    servers|full)
      local schema_name="azsec.state-sql.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson s "$servers" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-sql", slice:$sl, subscription_id:$sub_id, servers:$s}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson s "$servers" \
    '{
      schema: "azsec.state-sql.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-sql",
      slice: "digest",
      subscription_id: $sub_id,
      servers_summary: {
        total: ($s | length),
        public_network_access: ($s | map(select(.publicNetworkAccess=="Enabled")) | length),
        tls_below_12: ($s | map(select((.minimalTlsVersion // "") < "1.2")) | length),
        no_aad_admin: ($s | map(select((.administrators_administratorType // "")=="")) | length),
        aad_only: ($s | map(select(.administrators_aadOnly==true)) | length),
        names: ($s | map(.name))
      },
      hint: "TDE / Defender / audit are per-server. for per-server data, run: state sql [servers|full]"
    }'
}
