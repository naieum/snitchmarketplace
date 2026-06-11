# lib/state_nsg.sh — NSG digest. Detects 0.0.0.0/0 on management ports.
# slice ∈ digest (default) | nsgs | full

run_state_nsg() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local nsgs flow_logs
  nsgs="$(az_run_json network nsg list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location,
      securityRules: [.securityRules[]? | {
        name, priority, direction, access, protocol,
        sourceAddressPrefix, sourceAddressPrefixes,
        destinationPortRange, destinationPortRanges
      }]
    }]' 2>/dev/null || printf '[]')"
  flow_logs="$(az_run_json network watcher flow-log list --location eastus --subscription "$sub_id" 2>/dev/null \
    | jq '[.[]? | {id, name, enabled, targetResourceId}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    nsgs|full)
      local schema_name="azsec.state-nsg.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson n "$nsgs" --argjson fl "$flow_logs" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-nsg", slice:$sl, subscription_id:$sub_id,
          nsgs:$n, flow_logs:$fl}'
      return 0 ;;
  esac

  # Find management-port (22, 3389, 5985, 5986) Allow-from-Any rules.
  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson n "$nsgs" --argjson fl "$flow_logs" \
    '{
      schema: "azsec.state-nsg.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-nsg",
      slice: "digest",
      subscription_id: $sub_id,
      nsgs_summary: {
        total: ($n | length),
        rules_total: ($n | map(.securityRules | length) | add // 0),
        risky_inbound_management_rules: [
          ($n[] |
            .name as $nsg |
            .securityRules[]? |
            select(.direction=="Inbound" and .access=="Allow") |
            select((.sourceAddressPrefix=="*" or .sourceAddressPrefix=="0.0.0.0/0" or .sourceAddressPrefix=="Internet") and
                   ((.destinationPortRange | tostring | test("^(22|3389|5985|5986)$")) or
                    ((.destinationPortRanges // []) | any(tostring | test("^(22|3389|5985|5986)$"))))) |
            { nsg: $nsg, rule: .name, port: .destinationPortRange, source: .sourceAddressPrefix }
          )
        ]
      },
      flow_logs_summary: { total: ($fl | length), enabled: ($fl | map(select(.enabled==true)) | length) },
      hint: "for per-NSG data, run: state nsg [nsgs|full]. Flow-log enumeration is region-scoped — repeat per region for completeness."
    }'
}
