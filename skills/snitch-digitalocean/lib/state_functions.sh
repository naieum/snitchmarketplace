# lib/state_functions.sh — Functions (serverless) state.
# Exports: run_state_functions [slice]   slice ∈ digest|list|full

run_state_functions() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_fn_digest "$ts" ;;
    list)   _state_fn_list   "$ts" ;;
    full)   _state_fn_full   "$ts" ;;
    *)
      printf '{"error":"unknown state functions slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sfn_namespaces_raw() {
  local body; body="$(do_get /functions/namespaces?per_page=200)" || {
    printf '{"error":"failed to fetch namespaces","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"namespaces":[]}'
    return
  }
  printf '%s' "$body"
}

_sfn_summary() {
  local raw="$1"
  jq '{
    total_namespaces: ((.namespaces // []) | length),
    by_region: ((.namespaces // []) | group_by(.region // "unknown") | map({key:(.[0].region // "unknown"), value:length}) | from_entries),
    sample: ((.namespaces // [])[:5] | map({namespace, label, region, created_at}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_fn_digest() {
  local ts="$1"
  local raw summary
  raw="$(_sfn_namespaces_raw)"
  summary="$(_sfn_summary "$raw")"
  jq -n --arg ts "$ts" --argjson summary "$summary" \
    '{ schema: "dosec.state-functions.digest", schema_version: 1, generated_at: $ts,
       tool: "state-functions", slice: "digest",
       functions_summary: $summary,
       hint: "function-level enumeration requires doctl serverless connect + doctl serverless functions list per namespace" }'
}

_state_fn_list() {
  local ts="$1"
  local raw; raw="$(_sfn_namespaces_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-functions.list", schema_version: 1, generated_at: $ts,
       tool: "state-functions", slice: "list",
       namespaces: (.namespaces // []) }' \
    <<<"$raw"
}

_state_fn_full() {
  local ts="$1"
  local raw; raw="$(_sfn_namespaces_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-functions.full", schema_version: 1, generated_at: $ts,
           tool: "state-functions", slice: "full" }' \
    <<<"$raw"
}
