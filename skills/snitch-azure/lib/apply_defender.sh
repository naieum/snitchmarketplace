# lib/apply_defender.sh — enable Defender for Cloud Standard plans for core workloads.
# Workloads enabled: VirtualMachines, AppServices, StorageAccounts, SqlServers,
# KeyVaults, Arm, Dns, ContainerRegistry, KubernetesService, OpenSourceRelationalDatabases.

apply_defender() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local workloads=(
    VirtualMachines AppServices StorageAccounts SqlServers KeyVaults Arm Dns
    ContainerRegistry KubernetesService OpenSourceRelationalDatabases CosmosDbs
  )
  local w cur
  for w in "${workloads[@]}"; do
    cur="$(az_run_json security pricing show -n "$w" --subscription "$sub_id" 2>/dev/null \
      | jq -r '.pricingTier // "unknown"' 2>/dev/null || printf 'unknown')"
    if [[ "$cur" == "Standard" ]]; then
      log_ok "defender" "${w}" "Defender plan already Standard."
      continue
    fi
    log_warn "defender" "${w}" "Defender plan is ${cur}. Standard is paid; confirm pricing impact, then run: az security pricing create -n ${w} --tier Standard"
  done
}
