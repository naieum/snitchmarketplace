# lib/state_frontdoor.sh — Front Door digest (classic + Standard/Premium).
# slice ∈ digest (default) | profiles | full

run_state_frontdoor() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local profiles
  profiles="$(az_run_json afd profile list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, resourceGroup, sku: .sku.name, kind, location}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    profiles|full)
      local schema_name="azsec.state-frontdoor.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson p "$profiles" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-frontdoor", slice:$sl, subscription_id:$sub_id, profiles:$p}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson p "$profiles" \
    '{
      schema: "azsec.state-frontdoor.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-frontdoor",
      slice: "digest",
      subscription_id: $sub_id,
      profiles_summary: {
        total: ($p | length),
        premium: ($p | map(select(.sku=="Premium_AzureFrontDoor")) | length),
        standard: ($p | map(select(.sku=="Standard_AzureFrontDoor")) | length),
        classic: ($p | map(select(.sku=="Classic_AzureFrontDoor")) | length),
        names: ($p | map(.name))
      },
      hint: "WAF policy, custom rules, TLS policy require per-profile detail. for per-profile data, run: state frontdoor [profiles|full]"
    }'
}
