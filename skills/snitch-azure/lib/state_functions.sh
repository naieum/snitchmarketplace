# lib/state_functions.sh — Azure Functions digest.
# slice ∈ digest (default) | functions | full

run_state_functions() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local fns
  fns="$(az_run_json functionapp list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {
      id, name, resourceGroup, location, state, kind,
      httpsOnly,
      defaultHostName,
      identity_type: (.identity.type // "None"),
      siteConfig_minTlsVersion: .siteConfig.minTlsVersion,
      siteConfig_http20Enabled: .siteConfig.http20Enabled,
      runtime: .siteConfig.linuxFxVersion
    }]' 2>/dev/null || printf '[]')"

  case "$slice" in
    functions|full)
      local schema_name="azsec.state-functions.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson f "$fns" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-functions", slice:$sl, subscription_id:$sub_id, functions:$f}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson f "$fns" \
    '{
      schema: "azsec.state-functions.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-functions",
      slice: "digest",
      subscription_id: $sub_id,
      functions_summary: {
        total: ($f | length),
        https_only_off: ($f | map(select(.httpsOnly!=true)) | length),
        tls_below_12: ($f | map(select((.siteConfig_minTlsVersion // "") < "1.2")) | length),
        no_identity: ($f | map(select(.identity_type=="None")) | length),
        names: ($f | map(.name))
      },
      hint: "for per-function data, run: state functions [functions|full]"
    }'
}
