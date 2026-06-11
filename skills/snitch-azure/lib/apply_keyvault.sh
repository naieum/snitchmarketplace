# lib/apply_keyvault.sh — idempotent fixes for Key Vault.
# Targets: soft-delete on, purge protection on, RBAC over policy, network ACL default-deny.

apply_keyvault() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target="${1:-}"
  local vaults
  if [[ -n "$target" ]]; then
    vaults="$(az_run_json keyvault list --subscription "$sub_id" --query "[?name=='${target}']" 2>/dev/null || printf '[]')"
  else
    vaults="$(az_run_json keyvault list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$vaults")"
  if [[ "$n" == "0" ]]; then
    log_warn "keyvault" "scope" "no key vaults found"
    return 0
  fi

  local i v name rg sd pp rbac default_action
  for ((i=0;i<n;i++)); do
    v="$(jq -c ".[$i]" <<<"$vaults")"
    name="$(jq -r '.name' <<<"$v")"
    rg="$(jq -r '.resourceGroup' <<<"$v")"
    sd="$(jq -r '.properties.enableSoftDelete' <<<"$v")"
    pp="$(jq -r '.properties.enablePurgeProtection' <<<"$v")"
    rbac="$(jq -r '.properties.enableRbacAuthorization' <<<"$v")"
    default_action="$(jq -r '.properties.networkAcls.defaultAction // "Allow"' <<<"$v")"

    # Soft delete (always-on for new vaults; only old vaults may have it off)
    if [[ "$sd" == "true" ]]; then
      log_ok "keyvault" "${name}/soft-delete" "soft-delete already enabled."
    else
      if az_run keyvault update -n "$name" -g "$rg" --subscription "$sub_id" --enable-soft-delete true >/dev/null 2>&1; then
        log_ok "keyvault" "${name}/soft-delete" "soft-delete enabled."
      else
        log_fail "keyvault" "${name}/soft-delete" "could not enable soft-delete. $(az_last_error)"
      fi
    fi

    # Purge protection — IRREVERSIBLE; warn instead of forcing.
    if [[ "$pp" == "true" ]]; then
      log_ok "keyvault" "${name}/purge-protection" "purge protection already enabled."
    else
      log_warn "keyvault" "${name}/purge-protection" "purge protection OFF. Enabling is IRREVERSIBLE. Confirm with user, then run: az keyvault update -n ${name} -g ${rg} --enable-purge-protection true"
    fi

    # RBAC vs legacy access policies
    if [[ "$rbac" == "true" ]]; then
      log_ok "keyvault" "${name}/rbac" "RBAC authorization already enabled."
    else
      log_warn "keyvault" "${name}/rbac" "legacy access policy mode. Migration to RBAC requires reissuing access for principals — confirm before running: az keyvault update -n ${name} -g ${rg} --enable-rbac-authorization true"
    fi

    # Network ACL default
    if [[ "$default_action" == "Deny" ]]; then
      log_ok "keyvault" "${name}/net-acl" "network default action already Deny."
    else
      log_warn "keyvault" "${name}/net-acl" "network default action is ${default_action}. Confirm IP allowlist exists, then run: az keyvault update -n ${name} -g ${rg} --default-action Deny"
    fi
  done
}
