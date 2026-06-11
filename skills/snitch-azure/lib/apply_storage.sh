# lib/apply_storage.sh — idempotent fixes for storage accounts.
# Targets: HTTPS-only on, public blob access disabled, soft-delete on,
# default encryption with CMK note, allow-shared-key off (when possible).

# apply_storage [<account-name>] — operate on one account or every account in scope.
apply_storage() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target_account="${1:-}"
  local accounts
  if [[ -n "$target_account" ]]; then
    accounts="$(az_run_json storage account list --subscription "$sub_id" --query "[?name=='${target_account}']" 2>/dev/null || printf '[]')"
  else
    accounts="$(az_run_json storage account list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$accounts")"
  if [[ "$n" == "0" ]]; then
    log_warn "storage" "scope" "no storage accounts found"
    return 0
  fi

  local i acct name rg https minTls public sharedKey
  for ((i=0;i<n;i++)); do
    acct="$(jq -c ".[$i]" <<<"$accounts")"
    name="$(jq -r '.name' <<<"$acct")"
    rg="$(jq -r '.resourceGroup' <<<"$acct")"
    https="$(jq -r '.enableHttpsTrafficOnly' <<<"$acct")"
    minTls="$(jq -r '.minimumTlsVersion // ""' <<<"$acct")"
    public="$(jq -r '.allowBlobPublicAccess' <<<"$acct")"
    sharedKey="$(jq -r '.allowSharedKeyAccess' <<<"$acct")"

    # 1) HTTPS-only
    if [[ "$https" == "true" ]]; then
      log_ok "storage" "${name}/https" "HTTPS-only already enabled."
    else
      if az_run storage account update -n "$name" -g "$rg" --subscription "$sub_id" --https-only true >/dev/null 2>&1; then
        log_ok "storage" "${name}/https" "HTTPS-only enabled."
      else
        log_fail "storage" "${name}/https" "could not enable HTTPS-only. $(az_last_error)"
      fi
    fi

    # 2) min TLS 1.2
    if [[ "$minTls" == "TLS1_2" || "$minTls" == "TLS1_3" ]]; then
      log_ok "storage" "${name}/tls" "min TLS already ${minTls}."
    else
      if az_run storage account update -n "$name" -g "$rg" --subscription "$sub_id" --min-tls-version TLS1_2 >/dev/null 2>&1; then
        log_ok "storage" "${name}/tls" "min TLS set to TLS1_2."
      else
        log_fail "storage" "${name}/tls" "could not set min TLS. $(az_last_error)"
      fi
    fi

    # 3) Public blob access off
    if [[ "$public" == "false" ]]; then
      log_ok "storage" "${name}/public" "public blob access already disabled."
    else
      if az_run storage account update -n "$name" -g "$rg" --subscription "$sub_id" --allow-blob-public-access false >/dev/null 2>&1; then
        log_ok "storage" "${name}/public" "public blob access disabled."
      else
        log_fail "storage" "${name}/public" "could not disable public blob access. $(az_last_error)"
      fi
    fi

    # 4) Shared-key access — warn before disabling (breaks legacy SDKs).
    if [[ "$sharedKey" == "false" ]]; then
      log_ok "storage" "${name}/shared-key" "shared-key access already disabled."
    else
      log_warn "storage" "${name}/shared-key" "shared-key access enabled. Disabling can break legacy clients — confirm with user, then run: az storage account update -n ${name} -g ${rg} --allow-shared-key-access false"
    fi

    # 5) Soft delete (blob + container)
    local sd_blob; sd_blob="$(az_run_json storage account blob-service-properties show -n "$name" --account-name "$name" --resource-group "$rg" --subscription "$sub_id" 2>/dev/null \
      | jq -r '.deleteRetentionPolicy.enabled // false' 2>/dev/null || printf 'false')"
    if [[ "$sd_blob" == "true" ]]; then
      log_ok "storage" "${name}/soft-delete-blob" "blob soft-delete already enabled."
    else
      if az_run storage account blob-service-properties update --account-name "$name" --resource-group "$rg" --subscription "$sub_id" --enable-delete-retention true --delete-retention-days 14 >/dev/null 2>&1; then
        log_ok "storage" "${name}/soft-delete-blob" "blob soft-delete enabled (14d retention)."
      else
        log_warn "storage" "${name}/soft-delete-blob" "could not enable blob soft-delete. $(az_last_error)"
      fi
    fi
  done
}
