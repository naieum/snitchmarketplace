# lib/state_appgw.sh — Application Gateway digest.
# slice ∈ digest (default) | gateways | full

run_state_appgw() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local gws
  gws="$(az_run_json network application-gateway list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location,
      sku: .sku.name, tier: .sku.tier,
      enableHttp2,
      sslPolicy_policyType: .sslPolicy.policyType,
      sslPolicy_minProtocolVersion: .sslPolicy.minProtocolVersion,
      webApplicationFirewallConfiguration_enabled: .webApplicationFirewallConfiguration.enabled,
      webApplicationFirewallConfiguration_firewallMode: .webApplicationFirewallConfiguration.firewallMode,
      firewallPolicy: .firewallPolicy.id
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    gateways|full)
      local schema_name="azsec.state-appgw.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson g "$gws" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-appgw", slice:$sl, subscription_id:$sub_id, gateways:$g}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson g "$gws" \
    '{
      schema: "azsec.state-appgw.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-appgw",
      slice: "digest",
      subscription_id: $sub_id,
      gateways_summary: {
        total: ($g | length),
        waf_v2: ($g | map(select(.tier=="WAF_v2")) | length),
        no_waf: ($g | map(select((.tier // "") | test("WAF") | not)) | length),
        detection_mode: ($g | map(select(.webApplicationFirewallConfiguration_firewallMode=="Detection")) | length),
        prevention_mode: ($g | map(select(.webApplicationFirewallConfiguration_firewallMode=="Prevention")) | length),
        weak_tls: ($g | map(select((.sslPolicy_minProtocolVersion // "") < "TLSv1_2")) | length),
        names: ($g | map(.name))
      },
      hint: "for per-gateway data, run: state appgw [gateways|full]"
    }'
}
