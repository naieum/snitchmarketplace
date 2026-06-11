# lib/state_activitylog.sh — diagnostic settings target presence.
# slice ∈ digest (default) | settings | full

run_state_activitylog() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local settings
  settings="$(az_run_json monitor diagnostic-settings subscription list --subscription "$sub_id" 2>/dev/null \
    | jq '.value // []' 2>/dev/null || printf '[]')"

  case "$slice" in
    settings|full)
      local schema_name="azsec.state-activitylog.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson s "$settings" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-activitylog", slice:$sl, subscription_id:$sub_id, diagnostic_settings:$s}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson s "$settings" \
    '{
      schema: "azsec.state-activitylog.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-activitylog",
      slice: "digest",
      subscription_id: $sub_id,
      diagnostic_settings_summary: {
        total: ($s | length),
        with_workspace: ($s | map(select(.properties.workspaceId != null and .properties.workspaceId != "")) | length),
        with_storage: ($s | map(select(.properties.storageAccountId != null and .properties.storageAccountId != "")) | length),
        with_eventhub: ($s | map(select(.properties.eventHubAuthorizationRuleId != null and .properties.eventHubAuthorizationRuleId != "")) | length),
        names: ($s | map(.name))
      },
      hint: "for full data, run: state activitylog [settings|full]"
    }'
}
