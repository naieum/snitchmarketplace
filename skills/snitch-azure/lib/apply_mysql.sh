# lib/apply_mysql.sh — idempotent fixes for MySQL Flexible Server.

apply_mysql() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target="${1:-}"
  local servers
  if [[ -n "$target" ]]; then
    servers="$(az_run_json mysql flexible-server list --subscription "$sub_id" --query "[?name=='${target}']" 2>/dev/null || printf '[]')"
  else
    servers="$(az_run_json mysql flexible-server list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$servers")"
  if [[ "$n" == "0" ]]; then
    log_warn "mysql" "scope" "no MySQL flexible servers found"
    return 0
  fi
  local i s name rg public
  for ((i=0;i<n;i++)); do
    s="$(jq -c ".[$i]" <<<"$servers")"
    name="$(jq -r '.name' <<<"$s")"
    rg="$(jq -r '.resourceGroup' <<<"$s")"
    public="$(jq -r '.network.publicNetworkAccess // ""' <<<"$s")"
    if [[ "$public" == "Disabled" ]]; then
      log_ok "mysql" "${name}/public" "public network access disabled."
    else
      log_warn "mysql" "${name}/public" "public network access ${public}. Move to VNet integration, then disable public."
    fi
    log_warn "mysql" "${name}/tls" "Verify require_secure_transport=ON via server parameter — run: az mysql flexible-server parameter show -n ${name} -g ${rg} --name require_secure_transport"
  done
}
