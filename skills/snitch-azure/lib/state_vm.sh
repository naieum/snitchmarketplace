# lib/state_vm.sh — Virtual Machines digest.
# slice ∈ digest (default) | vms | full

run_state_vm() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local vms public_ips
  vms="$(az_run_json vm list -d --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location, powerState,
      publicIps, privateIps, osType: .storageProfile.osDisk.osType,
      vmSize: .hardwareProfile.vmSize,
      identity_type: .identity.type,
      encryption_atHost: .securityProfile.encryptionAtHost,
      bootDiagnostics: .diagnosticsProfile.bootDiagnostics.enabled,
      tags
    }]' 2>/dev/null || printf '[]')"
  public_ips="$(az_run_json network public-ip list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, ipAddress, sku: .sku.name}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    vms|full)
      local schema_name="azsec.state-vm.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson v "$vms" --argjson p "$public_ips" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-vm", slice:$sl, subscription_id:$sub_id,
          vms:$v, public_ips:$p}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson v "$vms" --argjson p "$public_ips" \
    '{
      schema: "azsec.state-vm.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-vm",
      slice: "digest",
      subscription_id: $sub_id,
      vms_summary: {
        total: ($v | length),
        with_public_ip: ($v | map(select((.publicIps // "")!="")) | length),
        encryption_at_host_off: ($v | map(select(.encryption_atHost!=true)) | length),
        managed_identity_count: ($v | map(select((.identity_type // "None")!="None")) | length),
        running: ($v | map(select(.powerState=="VM running")) | length),
        os_breakdown: ($v | group_by(.osType) | map({key: (.[0].osType // "Unknown"), value: length}) | from_entries)
      },
      public_ips_summary: { total: ($p | length), basic_sku: ($p | map(select(.sku=="Basic")) | length) },
      hint: "for per-VM data, run: state vm [vms|full]"
    }'
}
