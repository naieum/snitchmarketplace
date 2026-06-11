# lib/state_storage.sh — storage accounts: HTTPS-only, public access, shared-key, soft-delete, encryption.
# slice ∈ digest (default) | accounts | full

run_state_storage() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local accounts
  accounts="$(az_run_json storage account list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location, sku: .sku.name, kind,
      httpsOnly: .enableHttpsTrafficOnly,
      minTls: .minimumTlsVersion,
      allowBlobPublicAccess: .allowBlobPublicAccess,
      allowSharedKeyAccess: .allowSharedKeyAccess,
      networkRuleSet_default: .networkRuleSet.defaultAction,
      hns: .isHnsEnabled,
      encryption_keySource: .encryption.keySource,
      encryption_requireInfrastructureEncryption: .encryption.requireInfrastructureEncryption
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    accounts)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson a "$accounts" \
        '{schema:"azsec.state-storage.accounts", schema_version:1, generated_at:$ts,
          tool:"state-storage", slice:"accounts", subscription_id:$sub_id, accounts:$a}'
      return 0 ;;
    full)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson a "$accounts" \
        '{schema:"azsec.state-storage.full", schema_version:1, generated_at:$ts,
          tool:"state-storage", slice:"full", subscription_id:$sub_id, accounts:$a}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson a "$accounts" \
    '{
      schema: "azsec.state-storage.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-storage",
      slice: "digest",
      subscription_id: $sub_id,
      accounts_summary: {
        total: ($a | length),
        https_only_violations: ($a | map(select(.httpsOnly!=true)) | length),
        public_blob_access_count: ($a | map(select(.allowBlobPublicAccess==true)) | length),
        shared_key_enabled_count: ($a | map(select(.allowSharedKeyAccess==true)) | length),
        min_tls_below_12: ($a | map(select((.minTls // "") < "TLS1_2")) | length),
        public_default_network_count: ($a | map(select(.networkRuleSet_default=="Allow")) | length),
        cmk_count: ($a | map(select(.encryption_keySource=="Microsoft.Keyvault")) | length),
        names: ($a | map(.name))
      },
      hint: "for per-account data, run: state storage [accounts|full]"
    }'
}
