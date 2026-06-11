# lib/state_acr.sh — ACR digest.
# slice ∈ digest (default) | registries | full

run_state_acr() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local registries
  registries="$(az_run_json acr list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location, sku: .sku.name,
      adminUserEnabled,
      publicNetworkAccess,
      networkRuleSet_default: .networkRuleSet.defaultAction,
      anonymousPullEnabled,
      policies_quarantine: .policies.quarantinePolicy.status,
      policies_trust: .policies.trustPolicy.status,
      policies_retention: .policies.retentionPolicy.status,
      policies_softDelete: .policies.softDeletePolicy.status
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    registries|full)
      local schema_name="azsec.state-acr.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson r "$registries" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-acr", slice:$sl, subscription_id:$sub_id, registries:$r}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson r "$registries" \
    '{
      schema: "azsec.state-acr.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-acr",
      slice: "digest",
      subscription_id: $sub_id,
      registries_summary: {
        total: ($r | length),
        admin_user_on: ($r | map(select(.adminUserEnabled==true)) | length),
        public_access: ($r | map(select(.publicNetworkAccess=="Enabled")) | length),
        anonymous_pull: ($r | map(select(.anonymousPullEnabled==true)) | length),
        no_content_trust: ($r | map(select(.policies_trust!="enabled")) | length),
        no_retention: ($r | map(select(.policies_retention!="enabled")) | length),
        names: ($r | map(.name))
      },
      hint: "for per-registry data, run: state acr [registries|full]"
    }'
}
