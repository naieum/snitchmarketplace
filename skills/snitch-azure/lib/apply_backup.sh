# lib/apply_backup.sh — idempotent fixes for Recovery Services Vaults.
# Targets: soft-delete Always-On, immutability locked, MUA enabled.

apply_backup() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local vaults
  vaults="$(az_run_json backup vault list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  local n; n="$(jq -r 'length' <<<"$vaults")"
  if [[ "$n" == "0" ]]; then
    log_warn "backup" "scope" "no Recovery Services vaults found"
    return 0
  fi
  local i v name rg sd imm mua
  for ((i=0;i<n;i++)); do
    v="$(jq -c ".[$i]" <<<"$vaults")"
    name="$(jq -r '.name' <<<"$v")"
    rg="$(jq -r '.resourceGroup' <<<"$v")"
    sd="$(jq -r '.properties.securitySettings.softDeleteSettings.softDeleteState // "Disabled"' <<<"$v")"
    imm="$(jq -r '.properties.securitySettings.immutabilitySettings.state // "Disabled"' <<<"$v")"
    mua="$(jq -r '.properties.securitySettings.multiUserAuthorization // "Disabled"' <<<"$v")"

    if [[ "$sd" == "AlwaysON" || "$sd" == "Enabled" ]]; then
      log_ok "backup" "${name}/soft-delete" "soft-delete state ${sd}."
    else
      log_warn "backup" "${name}/soft-delete" "soft-delete is ${sd}. Run: az backup vault backup-properties set -n ${name} -g ${rg} --soft-delete-feature-state Enable"
    fi
    if [[ "$imm" != "Disabled" ]]; then
      log_ok "backup" "${name}/immutability" "immutability state ${imm}."
    else
      log_warn "backup" "${name}/immutability" "immutability disabled. Once Locked, it's irreversible. Confirm with user."
    fi
    if [[ "$mua" != "Disabled" ]]; then
      log_ok "backup" "${name}/mua" "MUA state ${mua}."
    else
      log_warn "backup" "${name}/mua" "MUA disabled. Multi-user auth needs a Resource Guard in a different RG/sub. See Azure docs."
    fi
  done
}
