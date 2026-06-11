# lib/analytics.sh — activity-log-derived analytics for the subscription.
# Exports: run_analytics <scope> [window]

run_analytics() {
  local scope="$1"; shift || true
  if [[ "$scope" != "subscription" ]]; then
    printf '{"error":"unknown analytics scope","code":"E_USAGE","got":"%s","valid":["subscription"]}\n' "$scope" >&2
    return 2
  fi
  local window="${1:-24h}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local since
  case "$window" in
    1h)  since="$(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)" ;;
    24h) since="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)" ;;
    7d)  since="$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)" ;;
    *)   since="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)"; window="24h" ;;
  esac

  local logs
  logs="$(az_run_json monitor activity-log list --subscription "$sub_id" --start-time "$since" --max-events 1000 2>/dev/null \
    | jq '[.[] | {operationName: .operationName.value, status: .status.value, caller, resourceType: .resourceType.value, level, eventTimestamp}]' 2>/dev/null || printf '[]')"

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg window "$window" \
    --argjson logs "$logs" \
    '{
      schema: "azsec.analytics-subscription",
      schema_version: 1,
      generated_at: $ts,
      tool: "analytics-subscription",
      subscription_id: $sub_id,
      window: $window,
      totals: {
        events: ($logs | length),
        succeeded: ($logs | map(select(.status=="Succeeded")) | length),
        failed: ($logs | map(select(.status=="Failed")) | length),
        write: ($logs | map(select((.operationName // "") | test("/write$"))) | length),
        delete: ($logs | map(select((.operationName // "") | test("/delete$"))) | length),
        action: ($logs | map(select((.operationName // "") | test("/action$"))) | length)
      },
      top_callers: ($logs | group_by(.caller // "Unknown") | map({caller: (.[0].caller // "Unknown"), events: length}) | sort_by(-.events)[:10]),
      top_operations: ($logs | group_by(.operationName // "Unknown") | map({operation: (.[0].operationName // "Unknown"), events: length}) | sort_by(-.events)[:10]),
      top_resource_types: ($logs | group_by(.resourceType // "Unknown") | map({resource_type: (.[0].resourceType // "Unknown"), events: length}) | sort_by(-.events)[:10])
    }'
}
