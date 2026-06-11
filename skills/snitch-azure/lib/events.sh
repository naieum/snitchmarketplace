# lib/events.sh — recent activity-log entries (writes/deletes/role-assignments).
# Exports: run_events <scope> [window]

run_events() {
  local scope="$1"; shift || true
  if [[ "$scope" != "subscription" ]]; then
    printf '{"error":"unknown events scope","code":"E_USAGE","got":"%s","valid":["subscription"]}\n' "$scope" >&2
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
  logs="$(az_run_json monitor activity-log list --subscription "$sub_id" --start-time "$since" --max-events 500 2>/dev/null \
    | jq '[.[] | {eventTimestamp, operationName: .operationName.value, status: .status.value, caller, resourceId, resourceType: .resourceType.value, correlationId, level}
          | select((.operationName // "") | test("/(write|delete|action)$") or (test("Microsoft.Authorization/roleAssignments")))]' 2>/dev/null \
    || printf '[]')"

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg window "$window" \
    --argjson logs "$logs" \
    '{
      schema: "azsec.events-subscription",
      schema_version: 1,
      generated_at: $ts,
      tool: "events-subscription",
      subscription_id: $sub_id,
      window: $window,
      events: $logs
    }'
}
