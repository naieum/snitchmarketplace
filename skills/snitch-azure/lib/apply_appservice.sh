# lib/apply_appservice.sh — idempotent fixes for App Service.
# Targets: HTTPS-only, TLS 1.2+, FTPS-only/disabled, SCM basic-auth disabled, identity.

apply_appservice() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target="${1:-}"
  local apps
  if [[ -n "$target" ]]; then
    apps="$(az_run_json webapp list --subscription "$sub_id" --query "[?name=='${target}']" 2>/dev/null || printf '[]')"
  else
    apps="$(az_run_json webapp list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$apps")"
  if [[ "$n" == "0" ]]; then
    log_warn "appservice" "scope" "no app service apps found"
    return 0
  fi

  local i a name rg https minTls ftps identity_type
  for ((i=0;i<n;i++)); do
    a="$(jq -c ".[$i]" <<<"$apps")"
    name="$(jq -r '.name' <<<"$a")"
    rg="$(jq -r '.resourceGroup' <<<"$a")"
    https="$(jq -r '.httpsOnly' <<<"$a")"
    minTls="$(jq -r '.siteConfig.minTlsVersion // ""' <<<"$a")"
    ftps="$(jq -r '.siteConfig.ftpsState // ""' <<<"$a")"
    identity_type="$(jq -r '.identity.type // "None"' <<<"$a")"

    # HTTPS-only
    if [[ "$https" == "true" ]]; then
      log_ok "appservice" "${name}/https" "HTTPS-only already enabled."
    else
      if az_run webapp update -n "$name" -g "$rg" --subscription "$sub_id" --https-only true >/dev/null 2>&1; then
        log_ok "appservice" "${name}/https" "HTTPS-only enabled."
      else
        log_fail "appservice" "${name}/https" "could not enable HTTPS-only. $(az_last_error)"
      fi
    fi

    # TLS min
    if [[ "$minTls" == "1.2" || "$minTls" == "1.3" ]]; then
      log_ok "appservice" "${name}/tls" "min TLS already ${minTls}."
    else
      if az_run webapp config set --name "$name" --resource-group "$rg" --subscription "$sub_id" --min-tls-version 1.2 >/dev/null 2>&1; then
        log_ok "appservice" "${name}/tls" "min TLS set to 1.2."
      else
        log_fail "appservice" "${name}/tls" "could not set min TLS. $(az_last_error)"
      fi
    fi

    # FTPS — disable or FTPS-only
    if [[ "$ftps" == "Disabled" || "$ftps" == "FtpsOnly" ]]; then
      log_ok "appservice" "${name}/ftps" "FTPS state ${ftps}."
    else
      if az_run webapp config set --name "$name" --resource-group "$rg" --subscription "$sub_id" --ftps-state Disabled >/dev/null 2>&1; then
        log_ok "appservice" "${name}/ftps" "FTPS disabled."
      else
        log_fail "appservice" "${name}/ftps" "could not disable FTPS. $(az_last_error)"
      fi
    fi

    # SCM basic auth — disable
    local site_id="/subscriptions/${sub_id}/resourceGroups/${rg}/providers/Microsoft.Web/sites/${name}/basicPublishingCredentialsPolicies/scm"
    local cur_scm
    cur_scm="$(az_run_json rest --method GET --url "https://management.azure.com${site_id}?api-version=2022-09-01" 2>/dev/null \
      | jq -r '.properties.allow // true' 2>/dev/null || printf 'true')"
    if [[ "$cur_scm" == "false" ]]; then
      log_ok "appservice" "${name}/scm-basic" "SCM basic auth already disabled."
    else
      if az_run rest --method PUT --url "https://management.azure.com${site_id}?api-version=2022-09-01" \
        --body '{"properties":{"allow":false}}' >/dev/null 2>&1; then
        log_ok "appservice" "${name}/scm-basic" "SCM basic auth disabled."
      else
        log_warn "appservice" "${name}/scm-basic" "could not disable SCM basic auth via REST. $(az_last_error)"
      fi
    fi

    # Managed identity
    if [[ "$identity_type" == "None" || "$identity_type" == "" ]]; then
      log_warn "appservice" "${name}/identity" "no managed identity. Confirm with user, then run: az webapp identity assign -n ${name} -g ${rg}"
    else
      log_ok "appservice" "${name}/identity" "managed identity ${identity_type}."
    fi
  done
}
