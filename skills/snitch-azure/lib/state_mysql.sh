# lib/state_mysql.sh — MySQL Flexible Server digest.
# slice ∈ digest (default) | servers | full

run_state_mysql() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local servers
  servers="$(az_run_json mysql flexible-server list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location,
      version,
      sku: .sku.name, tier: .sku.tier,
      network_publicNetworkAccess: .network.publicNetworkAccess,
      backup_geoRedundantBackup: .backup.geoRedundantBackup,
      dataEncryption_type: .dataEncryption.type,
      highAvailability_mode: .highAvailability.mode
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    servers|full)
      local schema_name="azsec.state-mysql.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson s "$servers" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-mysql", slice:$sl, subscription_id:$sub_id, servers:$s}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson s "$servers" \
    '{
      schema: "azsec.state-mysql.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-mysql",
      slice: "digest",
      subscription_id: $sub_id,
      servers_summary: {
        total: ($s | length),
        public_access: ($s | map(select(.network_publicNetworkAccess=="Enabled")) | length),
        no_geo_backup: ($s | map(select(.backup_geoRedundantBackup!="Enabled")) | length),
        no_cmk: ($s | map(select(.dataEncryption_type!="AzureKeyVault")) | length),
        no_ha: ($s | map(select((.highAvailability_mode // "Disabled")=="Disabled")) | length),
        names: ($s | map(.name))
      },
      hint: "for per-server data, run: state mysql [servers|full]"
    }'
}
