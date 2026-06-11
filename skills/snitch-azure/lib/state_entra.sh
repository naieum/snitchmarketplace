# lib/state_entra.sh — Entra ID digest.
# Surfaces user/group/role counts, Conditional Access policy count, app
# registrations + reply URLs, legacy-auth signal.
# slice ∈ digest (default) | apps | policies | full

run_state_entra() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  local users groups apps ca_policies sps directory_roles
  users="$(az_run_json ad user list --query '[].{id:id,upn:userPrincipalName,enabled:accountEnabled}' 2>/dev/null || printf '[]')"
  groups="$(az_run_json ad group list --query '[].{id:id,displayName:displayName,membershipRule:membershipRule}' 2>/dev/null || printf '[]')"
  apps="$(az_run_json ad app list --all --query '[].{id:id,appId:appId,displayName:displayName,replyUrls:web.redirectUris,signInAudience:signInAudience}' 2>/dev/null || printf '[]')"
  sps="$(az_run_json ad sp list --all --query '[].{id:id,appId:appId,displayName:displayName,servicePrincipalType:servicePrincipalType}' 2>/dev/null || printf '[]')"
  ca_policies="$(az_run_json rest --method GET --url 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies' 2>/dev/null \
    | jq '.value // []' 2>/dev/null || printf '[]')"
  directory_roles="$(az_run_json rest --method GET --url 'https://graph.microsoft.com/v1.0/directoryRoles' 2>/dev/null \
    | jq '.value // []' 2>/dev/null || printf '[]')"

  case "$slice" in
    apps)
      jq -n --arg ts "$ts" --argjson apps "$apps" --argjson sps "$sps" \
        '{schema:"azsec.state-entra.apps", schema_version:1, generated_at:$ts,
          tool:"state-entra", slice:"apps", apps:$apps, service_principals:$sps}'
      return 0 ;;
    policies)
      jq -n --arg ts "$ts" --argjson policies "$ca_policies" \
        '{schema:"azsec.state-entra.policies", schema_version:1, generated_at:$ts,
          tool:"state-entra", slice:"policies", conditional_access_policies:$policies}'
      return 0 ;;
    full)
      jq -n --arg ts "$ts" \
        --argjson users "$users" --argjson groups "$groups" \
        --argjson apps "$apps" --argjson sps "$sps" \
        --argjson policies "$ca_policies" --argjson roles "$directory_roles" \
        '{schema:"azsec.state-entra.full", schema_version:1, generated_at:$ts,
          tool:"state-entra", slice:"full", users:$users, groups:$groups,
          apps:$apps, service_principals:$sps,
          conditional_access_policies:$policies, directory_roles:$roles}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" \
    --argjson users "$users" --argjson groups "$groups" \
    --argjson apps "$apps" --argjson sps "$sps" \
    --argjson policies "$ca_policies" --argjson roles "$directory_roles" \
    '{
      schema: "azsec.state-entra.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-entra",
      slice: "digest",
      users_summary:  { total: ($users  | length), enabled: ($users  | map(select(.enabled==true)) | length) },
      groups_summary: { total: ($groups | length), dynamic: ($groups | map(select((.membershipRule // "")!="")) | length) },
      apps_summary:   { total: ($apps   | length),
                        multi_tenant: ($apps | map(select(.signInAudience=="AzureADMultipleOrgs" or .signInAudience=="AzureADandPersonalMicrosoftAccount")) | length),
                        with_reply_urls: ($apps | map(select((.replyUrls // [] | length) > 0)) | length) },
      service_principals_summary: { total: ($sps | length),
                                    by_type: ($sps | group_by(.servicePrincipalType // "Unknown") | map({key: .[0].servicePrincipalType // "Unknown", value: length}) | from_entries) },
      conditional_access_summary: { total: ($policies | length),
                                    enabled: ($policies | map(select(.state=="enabled")) | length),
                                    block_legacy_auth_present: (($policies | map(select((.conditions.clientAppTypes // []) | any(. == "exchangeActiveSync" or . == "other"))) | length) > 0) },
      directory_roles_summary: { total: ($roles | length) },
      hint: "for full data, run: state entra [apps|policies|full]"
    }'
}
