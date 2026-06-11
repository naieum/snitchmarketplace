# lib/state_aks.sh — AKS digest.
# slice ∈ digest (default) | clusters | full

run_state_aks() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local clusters
  clusters="$(az_run_json aks list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location,
      kubernetesVersion,
      enableRBAC,
      aadProfile_enabled: (.aadProfile != null),
      aadProfile_managed: .aadProfile.managed,
      aadProfile_azureRBAC: .aadProfile.enableAzureRBAC,
      networkProfile_networkPolicy: .networkProfile.networkPolicy,
      networkProfile_networkPlugin: .networkProfile.networkPlugin,
      apiServerAccessProfile_authorizedIpRanges: .apiServerAccessProfile.authorizedIpRanges,
      privateClusterEnabled: .apiServerAccessProfile.enablePrivateCluster,
      addonProfiles_omsagent: (.addonProfiles.omsagent.enabled // false),
      addonProfiles_azureKeyvaultSecretsProvider: (.addonProfiles.azureKeyvaultSecretsProvider.enabled // false),
      securityProfile_defender: (.securityProfile.defender != null),
      diskEncryptionSetID: .diskEncryptionSetID
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    clusters|full)
      local schema_name="azsec.state-aks.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson c "$clusters" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-aks", slice:$sl, subscription_id:$sub_id, clusters:$c}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson c "$clusters" \
    '{
      schema: "azsec.state-aks.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-aks",
      slice: "digest",
      subscription_id: $sub_id,
      clusters_summary: {
        total: ($c | length),
        rbac_disabled: ($c | map(select(.enableRBAC!=true)) | length),
        no_aad: ($c | map(select(.aadProfile_enabled!=true)) | length),
        no_network_policy: ($c | map(select((.networkProfile_networkPolicy // "")=="")) | length),
        no_omsagent: ($c | map(select(.addonProfiles_omsagent!=true)) | length),
        no_defender: ($c | map(select(.securityProfile_defender!=true)) | length),
        public_api: ($c | map(select(.privateClusterEnabled!=true and ((.apiServerAccessProfile_authorizedIpRanges // []) | length)==0)) | length),
        names: ($c | map(.name))
      },
      hint: "for per-cluster data, run: state aks [clusters|full]"
    }'
}
