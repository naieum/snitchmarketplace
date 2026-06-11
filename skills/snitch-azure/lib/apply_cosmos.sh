# lib/apply_cosmos.sh — idempotent fixes for Cosmos DB.
# Targets: TLS 1.2 min, disable local auth, public network access disable.

apply_cosmos() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target="${1:-}"
  local accounts
  if [[ -n "$target" ]]; then
    accounts="$(az_run_json cosmosdb list --subscription "$sub_id" --query "[?name=='${target}']" 2>/dev/null || printf '[]')"
  else
    accounts="$(az_run_json cosmosdb list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$accounts")"
  if [[ "$n" == "0" ]]; then
    log_warn "cosmos" "scope" "no Cosmos DB accounts found"
    return 0
  fi

  local i a name rg minTls disableLocal public
  for ((i=0;i<n;i++)); do
    a="$(jq -c ".[$i]" <<<"$accounts")"
    name="$(jq -r '.name' <<<"$a")"
    rg="$(jq -r '.resourceGroup' <<<"$a")"
    minTls="$(jq -r '.minimalTlsVersion // ""' <<<"$a")"
    disableLocal="$(jq -r '.disableLocalAuth // false' <<<"$a")"
    public="$(jq -r '.publicNetworkAccess // ""' <<<"$a")"

    if [[ "$minTls" == "Tls12" || "$minTls" == "Tls13" ]]; then
      log_ok "cosmos" "${name}/tls" "min TLS already ${minTls}."
    else
      if az_run cosmosdb update -n "$name" -g "$rg" --subscription "$sub_id" --minimal-tls-version Tls12 >/dev/null 2>&1; then
        log_ok "cosmos" "${name}/tls" "min TLS set to Tls12."
      else
        log_warn "cosmos" "${name}/tls" "could not set min TLS via az; check api version. $(az_last_error)"
      fi
    fi

    if [[ "$disableLocal" == "true" ]]; then
      log_ok "cosmos" "${name}/local-auth" "local auth already disabled."
    else
      log_warn "cosmos" "${name}/local-auth" "local auth enabled. Confirm AAD identities are wired before running: az cosmosdb update -n ${name} -g ${rg} --disable-local-auth true"
    fi

    if [[ "$public" == "Disabled" ]]; then
      log_ok "cosmos" "${name}/public" "public network access disabled."
    else
      log_warn "cosmos" "${name}/public" "public network access ${public}. Switch to private endpoint, then disable public."
    fi
  done
}
