# lib/state_keyvault.sh — Key Vault digest.
# slice ∈ digest (default) | vaults | full

run_state_keyvault() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local vaults
  vaults="$(az_run_json keyvault list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, location, resourceGroup,
      sku: .properties.sku.name,
      enableRbacAuthorization: .properties.enableRbacAuthorization,
      enableSoftDelete: .properties.enableSoftDelete,
      enablePurgeProtection: .properties.enablePurgeProtection,
      softDeleteRetentionInDays: .properties.softDeleteRetentionInDays,
      networkAcls_defaultAction: .properties.networkAcls.defaultAction,
      networkAcls_bypass: .properties.networkAcls.bypass,
      privateEndpointConnections_count: ((.properties.privateEndpointConnections // []) | length)
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    vaults|full)
      local schema_name
      if [[ "$slice" == "vaults" ]]; then schema_name="azsec.state-keyvault.vaults"; else schema_name="azsec.state-keyvault.full"; fi
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson v "$vaults" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-keyvault", slice:$sl, subscription_id:$sub_id, vaults:$v}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson v "$vaults" \
    '{
      schema: "azsec.state-keyvault.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-keyvault",
      slice: "digest",
      subscription_id: $sub_id,
      vaults_summary: {
        total: ($v | length),
        soft_delete_off: ($v | map(select(.enableSoftDelete!=true)) | length),
        purge_protection_off: ($v | map(select(.enablePurgeProtection!=true)) | length),
        rbac_count: ($v | map(select(.enableRbacAuthorization==true)) | length),
        legacy_policy_count: ($v | map(select(.enableRbacAuthorization!=true)) | length),
        public_default_network_count: ($v | map(select(.networkAcls_defaultAction=="Allow")) | length),
        private_endpoint_count: ($v | map(select((.privateEndpointConnections_count // 0) > 0)) | length),
        names: ($v | map(.name))
      },
      hint: "for per-vault data, run: state keyvault [vaults|full]"
    }'
}
