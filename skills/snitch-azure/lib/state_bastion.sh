# lib/state_bastion.sh — Bastion vs public RDP/SSH presence.
# slice ∈ digest (default) | hosts | full

run_state_bastion() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local hosts public_ips
  hosts="$(az_run_json network bastion list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, resourceGroup, location, sku: .sku.name, dnsName, scaleUnits, enableShareableLink, enableTunneling}]' 2>/dev/null || printf '[]')"
  # We surface VMs with public IP separately via state vm; here we just count.
  public_ips="$(az_run_json network public-ip list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | select(.ipAddress != null)] | length' 2>/dev/null || printf '0')"

  case "$slice" in
    hosts|full)
      local schema_name="azsec.state-bastion.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson h "$hosts" --argjson pip "$public_ips" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-bastion", slice:$sl, subscription_id:$sub_id,
          hosts:$h, public_ip_count:$pip}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson h "$hosts" --argjson pip "$public_ips" \
    '{
      schema: "azsec.state-bastion.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-bastion",
      slice: "digest",
      subscription_id: $sub_id,
      bastion_summary: { total: ($h | length), names: ($h | map(.name)),
        basic_sku: ($h | map(select(.sku=="Basic")) | length),
        standard_sku: ($h | map(select(.sku=="Standard")) | length) },
      public_ip_count: $pip,
      hint: "for per-host data, run: state bastion [hosts|full]. Cross-reference state vm to find VMs with public IPs that should sit behind Bastion."
    }'
}
