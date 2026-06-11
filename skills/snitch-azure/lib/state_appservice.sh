# lib/state_appservice.sh — App Service digest.
# slice ∈ digest (default) | apps | full

run_state_appservice() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local apps
  apps="$(az_run_json webapp list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location, kind, state,
      httpsOnly,
      defaultHostName,
      identity_type: (.identity.type // "None"),
      siteConfig_minTlsVersion: .siteConfig.minTlsVersion,
      siteConfig_ftpsState: .siteConfig.ftpsState,
      siteConfig_http20Enabled: .siteConfig.http20Enabled,
      siteConfig_alwaysOn: .siteConfig.alwaysOn,
      clientAffinityEnabled,
      clientCertEnabled
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    apps|full)
      local schema_name="azsec.state-appservice.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson a "$apps" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-appservice", slice:$sl, subscription_id:$sub_id, apps:$a}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson a "$apps" \
    '{
      schema: "azsec.state-appservice.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-appservice",
      slice: "digest",
      subscription_id: $sub_id,
      apps_summary: {
        total: ($a | length),
        https_only_off: ($a | map(select(.httpsOnly!=true)) | length),
        tls_below_12: ($a | map(select((.siteConfig_minTlsVersion // "") < "1.2")) | length),
        ftps_allowed: ($a | map(select(.siteConfig_ftpsState=="AllAllowed" or .siteConfig_ftpsState=="FtpsOnly")) | length),
        no_identity: ($a | map(select(.identity_type=="None")) | length),
        names: ($a | map(.name))
      },
      hint: "for per-app data, run: state appservice [apps|full]. SCM basic-auth requires per-site Microsoft.Web/sites/basicPublishingCredentialsPolicies/scm GET."
    }'
}
