# lib/apply_postgres.sh — idempotent fixes for PostgreSQL Flexible Server.

apply_postgres() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target="${1:-}"
  local servers
  if [[ -n "$target" ]]; then
    servers="$(az_run_json postgres flexible-server list --subscription "$sub_id" --query "[?name=='${target}']" 2>/dev/null || printf '[]')"
  else
    servers="$(az_run_json postgres flexible-server list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$servers")"
  if [[ "$n" == "0" ]]; then
    log_warn "postgres" "scope" "no PostgreSQL flexible servers found"
    return 0
  fi
  local i s name rg public aad_auth
  for ((i=0;i<n;i++)); do
    s="$(jq -c ".[$i]" <<<"$servers")"
    name="$(jq -r '.name' <<<"$s")"
    rg="$(jq -r '.resourceGroup' <<<"$s")"
    public="$(jq -r '.network.publicNetworkAccess // ""' <<<"$s")"
    aad_auth="$(jq -r '.authConfig.activeDirectoryAuth // ""' <<<"$s")"

    if [[ "$public" == "Disabled" ]]; then
      log_ok "postgres" "${name}/public" "public network access disabled."
    else
      log_warn "postgres" "${name}/public" "public network access ${public}. Move to VNet integration, then disable public."
    fi
    if [[ "$aad_auth" == "Enabled" ]]; then
      log_ok "postgres" "${name}/aad" "Microsoft Entra auth enabled."
    else
      log_warn "postgres" "${name}/aad" "Microsoft Entra auth disabled. Run: az postgres flexible-server update -n ${name} -g ${rg} --active-directory-auth Enabled"
    fi
  done
}
