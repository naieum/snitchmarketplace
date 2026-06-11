# lib/state_firewall.sh — Azure Firewall digest.
# slice ∈ digest (default) | firewalls | full

run_state_firewall() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local firewalls
  firewalls="$(az_run_json network firewall list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, resourceGroup, location,
      sku_name: .sku.name, sku_tier: .sku.tier,
      threatIntelMode: .threatIntelMode,
      firewallPolicy: .firewallPolicy.id}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    firewalls|full)
      local schema_name="azsec.state-firewall.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson f "$firewalls" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-firewall", slice:$sl, subscription_id:$sub_id, firewalls:$f}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson f "$firewalls" \
    '{
      schema: "azsec.state-firewall.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-firewall",
      slice: "digest",
      subscription_id: $sub_id,
      firewalls_summary: {
        total: ($f | length),
        premium: ($f | map(select(.sku_tier=="Premium")) | length),
        standard: ($f | map(select(.sku_tier=="Standard")) | length),
        threatintel_off: ($f | map(select(.threatIntelMode=="Off")) | length),
        threatintel_alert_only: ($f | map(select(.threatIntelMode=="Alert")) | length),
        names: ($f | map(.name))
      },
      hint: "for per-firewall data, run: state firewall [firewalls|full]"
    }'
}
