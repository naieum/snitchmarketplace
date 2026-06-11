# lib/events.sh — last 100 IAM-significant CloudTrail events.
# Exports: run_events [window]

run_events() {
  local window="${1:-24h}"
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  local end_d start_d hours
  case "$window" in
    1h)  hours=1  ;;
    24h) hours=24 ;;
    7d)  hours=168 ;;
    *)   hours=24; window="24h" ;;
  esac
  end_d="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if date -v-${hours}H +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
    start_d="$(date -v-${hours}H -u +%Y-%m-%dT%H:%M:%SZ)"
  else
    start_d="$(date -d "${hours} hours ago" -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "$end_d")"
  fi

  # IAM-significant event names.
  local events_buf='[]'
  local en
  for en in CreateUser DeleteUser CreateAccessKey UpdateAccessKey DeleteAccessKey \
            CreateRole DeleteRole AttachRolePolicy DetachRolePolicy \
            ConsoleLogin AssumeRole DeactivateMFADevice; do
    local body
    body="$(aws_run_json cloudtrail lookup-events \
      --lookup-attributes "AttributeKey=EventName,AttributeValue=${en}" \
      --start-time "$start_d" --end-time "$end_d" --max-results 50 2>/dev/null)"
    local ev
    ev="$(jq '[.Events[]? | {EventTime, EventName, Username, EventSource, AwsRegion, Resources}]' <<<"$body" 2>/dev/null || printf '[]')"
    events_buf="$(jq --argjson e "$ev" '. + $e' <<<"$events_buf")"
  done

  events_buf="$(jq 'sort_by(.EventTime) | reverse | .[0:100]' <<<"$events_buf")"

  jq -n --arg ts "$ts" --arg account "$account" --arg region "$region" \
    --arg start_d "$start_d" --arg end_d "$end_d" --arg window "$window" \
    --argjson events "$events_buf" \
    '{
      schema: "awssec.events", schema_version: 1, generated_at: $ts,
      tool: "events",
      account_id: $account, region: $region,
      window: { window_label: $window, start: $start_d, end: $end_d },
      events: $events
    }'
}
