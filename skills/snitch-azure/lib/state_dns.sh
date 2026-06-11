# lib/state_dns.sh — DNS zones digest. DNSSEC support is limited on Azure DNS.
# slice ∈ digest (default) | zones | full

run_state_dns() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local zones private_zones
  zones="$(az_run_json network dns zone list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, resourceGroup, numberOfRecordSets, zoneType: (.zoneType // "Public")}]' 2>/dev/null || printf '[]')"
  private_zones="$(az_run_json network private-dns zone list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, resourceGroup, numberOfRecordSets}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    zones|full)
      local schema_name="azsec.state-dns.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson z "$zones" --argjson pz "$private_zones" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-dns", slice:$sl, subscription_id:$sub_id,
          public_zones:$z, private_zones:$pz}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson z "$zones" --argjson pz "$private_zones" \
    '{
      schema: "azsec.state-dns.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-dns",
      slice: "digest",
      subscription_id: $sub_id,
      public_zones_summary: { total: ($z | length), names: ($z | map(.name)), record_sets_total: ($z | map(.numberOfRecordSets // 0) | add // 0) },
      private_zones_summary: { total: ($pz | length), names: ($pz | map(.name)) },
      dnssec_note: "DNSSEC on Azure DNS is in preview / limited GA — surface as WARN; check current support before relying on it.",
      hint: "for per-zone data, run: state dns [zones|full]"
    }'
}
