# lib/state_monitoring.sh — Monitoring + Alert policies state.
# Exports: run_state_monitoring [slice]   slice ∈ digest|list|full

run_state_monitoring() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_mon_digest "$ts" ;;
    list)   _state_mon_list   "$ts" ;;
    full)   _state_mon_full   "$ts" ;;
    *)
      printf '{"error":"unknown state monitoring slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_smon_alerts_raw() {
  local body; body="$(do_get /monitoring/alerts?per_page=200)" || {
    printf '{"error":"failed to fetch alert policies","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"policies":[]}'
    return
  }
  printf '%s' "$body"
}

_smon_summary() {
  local raw="$1"
  jq '{
    total: ((.policies // []) | length),
    enabled: ((.policies // []) | map(select(.enabled == true)) | length),
    by_type: ((.policies // []) | group_by(.type // "unknown") | map({key:(.[0].type // "unknown"), value:length}) | from_entries),
    channels_used: ((.policies // []) | map(.alerts // {} | (.email // []) + (.slack // [])) | flatten | unique),
    sample: ((.policies // [])[:5] | map({uuid, type, enabled, compare, value, window, description, alerts}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_mon_digest() {
  local ts="$1"
  local raw summary
  raw="$(_smon_alerts_raw)"
  summary="$(_smon_summary "$raw")"
  jq -n --arg ts "$ts" --argjson summary "$summary" \
    '{ schema: "dosec.state-monitoring.digest", schema_version: 1, generated_at: $ts,
       tool: "state-monitoring", slice: "digest",
       alerts_summary: $summary,
       hint: "for full data, run: state monitoring [list|full]" }'
}

_state_mon_list() {
  local ts="$1"
  local raw; raw="$(_smon_alerts_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-monitoring.list", schema_version: 1, generated_at: $ts,
       tool: "state-monitoring", slice: "list",
       alert_policies: (.policies // []) }' \
    <<<"$raw"
}

_state_mon_full() {
  local ts="$1"
  local raw; raw="$(_smon_alerts_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-monitoring.full", schema_version: 1, generated_at: $ts,
           tool: "state-monitoring", slice: "full" }' \
    <<<"$raw"
}
