# lib/apply_sentinel.sh — guidance for enabling Microsoft Sentinel.
# Sentinel installs as a solution on a Log Analytics workspace; ARM template
# generation is project-side. We emit guidance + recommended connectors.

apply_sentinel() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local workspaces
  workspaces="$(az_run_json monitor log-analytics workspace list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {name, resourceGroup, id}]' 2>/dev/null || printf '[]')"
  local n; n="$(jq -r 'length' <<<"$workspaces")"
  if [[ "$n" == "0" ]]; then
    log_warn "sentinel" "workspace" "no Log Analytics workspaces. Create one first: az monitor log-analytics workspace create -g <rg> -n <ws-name>"
    return 0
  fi
  local i w name rg
  for ((i=0;i<n;i++)); do
    w="$(jq -c ".[$i]" <<<"$workspaces")"
    name="$(jq -r '.name' <<<"$w")"
    rg="$(jq -r '.resourceGroup' <<<"$w")"
    log_warn "sentinel" "${name}" "Sentinel enablement is workspace-scoped + paid. Confirm with user, then run: az sentinel onboarding-state create --resource-group ${rg} --workspace-name ${name} --name default"
    log_info "  recommended connectors: AzureActivity, AzureActiveDirectory, MicrosoftDefenderAdvancedThreatProtection, Office365, AzureFirewall, MicrosoftCloudAppSecurity"
  done
}
