# lib/state_backup.sh — Recovery Services Vaults digest.
# slice ∈ digest (default) | vaults | full

run_state_backup() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local vaults
  vaults="$(az_run_json backup vault list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, resourceGroup, location,
      sku: .sku.name,
      properties_softDeleteFeatureState: .properties.securitySettings.softDeleteSettings.softDeleteState,
      properties_immutability: .properties.securitySettings.immutabilitySettings.state,
      properties_mua: .properties.securitySettings.multiUserAuthorization,
      properties_publicNetworkAccess: .properties.publicNetworkAccess
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    vaults|full)
      local schema_name="azsec.state-backup.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson v "$vaults" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-backup", slice:$sl, subscription_id:$sub_id, vaults:$v}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson v "$vaults" \
    '{
      schema: "azsec.state-backup.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-backup",
      slice: "digest",
      subscription_id: $sub_id,
      vaults_summary: {
        total: ($v | length),
        soft_delete_off: ($v | map(select((.properties_softDeleteFeatureState // "")!="Enabled" and (.properties_softDeleteFeatureState // "")!="AlwaysON")) | length),
        immutability_off: ($v | map(select((.properties_immutability // "Disabled")=="Disabled")) | length),
        mua_off: ($v | map(select((.properties_mua // "Disabled")=="Disabled")) | length),
        public_access: ($v | map(select(.properties_publicNetworkAccess=="Enabled")) | length),
        names: ($v | map(.name))
      },
      hint: "for per-vault data, run: state backup [vaults|full]"
    }'
}
