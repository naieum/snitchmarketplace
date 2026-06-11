# lib/export.sh — read-only JSON snapshot of DigitalOcean config.
# Captures the digest from each subscope into a single document. Stable, versioned schema.
#
# Exports: run_export

run_export() {
  log_section "export"
  api_check_auth_env || return $?
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local out_file="./digitalocean-export-${ts}.json"

  # Source each state lib lazily; fetch its digest.
  . "${LIB_DIR}/state_account.sh"
  . "${LIB_DIR}/state_droplets.sh"
  . "${LIB_DIR}/state_databases.sh"
  . "${LIB_DIR}/state_apps.sh"
  . "${LIB_DIR}/state_loadbalancers.sh"
  . "${LIB_DIR}/state_firewalls.sh"
  . "${LIB_DIR}/state_registry.sh"
  . "${LIB_DIR}/state_kubernetes.sh"
  . "${LIB_DIR}/state_functions.sh"
  . "${LIB_DIR}/state_vpcs.sh"
  . "${LIB_DIR}/state_dns.sh"
  . "${LIB_DIR}/state_monitoring.sh"
  . "${LIB_DIR}/state_cost.sh"
  . "${LIB_DIR}/state_spaces.sh"

  local account droplets databases apps lbs fws regs k8s fns vpcs dns mon cost spaces
  account="$(run_state_account digest 2>/dev/null   || echo '{}')"
  droplets="$(run_state_droplets digest 2>/dev/null || echo '{}')"
  databases="$(run_state_databases digest 2>/dev/null || echo '{}')"
  apps="$(run_state_apps digest 2>/dev/null         || echo '{}')"
  lbs="$(run_state_loadbalancers digest 2>/dev/null || echo '{}')"
  fws="$(run_state_firewalls digest 2>/dev/null     || echo '{}')"
  regs="$(run_state_registry digest 2>/dev/null     || echo '{}')"
  k8s="$(run_state_kubernetes digest 2>/dev/null    || echo '{}')"
  fns="$(run_state_functions digest 2>/dev/null     || echo '{}')"
  vpcs="$(run_state_vpcs digest 2>/dev/null         || echo '{}')"
  dns="$(run_state_dns digest 2>/dev/null           || echo '{}')"
  mon="$(run_state_monitoring digest 2>/dev/null    || echo '{}')"
  cost="$(run_state_cost digest 2>/dev/null         || echo '{}')"
  spaces="$(run_state_spaces digest 2>/dev/null     || echo '{}')"

  jq -n --arg ts "$ts" \
    --argjson account "$account" \
    --argjson droplets "$droplets" \
    --argjson databases "$databases" \
    --argjson apps "$apps" \
    --argjson lbs "$lbs" \
    --argjson fws "$fws" \
    --argjson regs "$regs" \
    --argjson k8s "$k8s" \
    --argjson fns "$fns" \
    --argjson vpcs "$vpcs" \
    --argjson dns "$dns" \
    --argjson mon "$mon" \
    --argjson cost "$cost" \
    --argjson spaces "$spaces" \
    '{
      schema: "dosec.export",
      schema_version: 1,
      generated_at: $ts,
      account: $account,
      droplets: $droplets,
      databases: $databases,
      apps: $apps,
      loadbalancers: $lbs,
      firewalls: $fws,
      registry: $regs,
      kubernetes: $k8s,
      functions: $fns,
      vpcs: $vpcs,
      dns: $dns,
      monitoring: $mon,
      cost: $cost,
      spaces: $spaces
    }' > "$out_file"

  log_ok "export" "snapshot" "wrote ${out_file}"
}
