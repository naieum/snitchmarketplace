# lib/state_logs.sh — log retention + drain config summary.
# Exports: run_state_logs [project-id] [slice]
#   slice ∈ digest (default) | full

run_state_logs() {
  local project_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_logs_digest "$project_id" "$ts" ;;
    full)   _state_logs_full   "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state logs slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

# Detect log-drain configuration via env-var convention.
# Railway exposes log drains via dashboard webhooks, not in the public GraphQL
# schema (yet). We surface heuristics: presence of LOG_DRAIN_* env vars or
# known SIEM-shaped destinations.
_sl_heuristic_drains() {
  local pid="$1"
  local env_id; env_id="$(api_pick_environment)"
  local body
  body="$(rw_gql 'query($pid:String!,$eid:String!){ variables(projectId:$pid, environmentId:$eid) }' \
    "$(jq -nc --arg pid "$pid" --arg eid "$env_id" '{pid:$pid, eid:$eid}')" 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.variables // {}) | to_entries[] | select(.key | test("(?i)(log[_-]?drain|datadog|sentry|loki|honeycomb|newrelic|sumologic|splunk|papertrail)"))
       | .key]' <<<"$body" 2>/dev/null || printf '[]'
}

_sl_plan_retention() {
  local plan; plan="$(detect_plan)"
  case "$plan" in
    trial)      printf '"7d (estimate; check dashboard)"' ;;
    hobby)      printf '"7d (estimate; check dashboard)"' ;;
    pro)        printf '"30d (estimate; check dashboard)"' ;;
    enterprise) printf '"custom"' ;;
    *)          printf '"unknown"' ;;
  esac
}

_state_logs_digest() {
  local pid="$1" ts="$2"
  local drains retention plan
  drains="$(_sl_heuristic_drains "$pid")"
  retention="$(_sl_plan_retention)"
  plan="$(detect_plan)"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" --arg plan "$plan" \
    --argjson drains "$drains" \
    --argjson retention "$retention" \
    '{
      schema: "rwsec.state-logs.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-logs",
      slice: "digest",
      project_id: $pid,
      plan: $plan,
      log_retention_estimate: $retention,
      detected_drain_env_vars: $drains,
      drain_configured: ($drains | length > 0),
      drain_warning: (if ($drains | length) == 0 then "no SIEM-shaped log drain detected (heuristic). For Pro+ plans, configure a log drain in the dashboard so security-relevant logs survive >30d." else null end),
      hint: "for full data, run: state logs <project-id> full"
    }'
}

_state_logs_full() {
  local pid="$1" ts="$2"
  local drains retention plan
  drains="$(_sl_heuristic_drains "$pid")"
  retention="$(_sl_plan_retention)"
  plan="$(detect_plan)"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" --arg plan "$plan" \
    --argjson drains "$drains" \
    --argjson retention "$retention" \
    '{ schema:"rwsec.state-logs.full", schema_version:1, generated_at:$ts,
       tool:"state-logs", slice:"full", project_id:$pid, plan:$plan,
       log_retention_estimate:$retention, detected_drain_env_vars:$drains }'
}
