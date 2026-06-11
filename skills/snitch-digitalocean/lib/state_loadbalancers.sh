# lib/state_loadbalancers.sh — Load Balancer state.
# Exports: run_state_loadbalancers [slice]   slice ∈ digest|list|full

run_state_loadbalancers() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_lb_digest "$ts" ;;
    list)   _state_lb_list   "$ts" ;;
    full)   _state_lb_full   "$ts" ;;
    *)
      printf '{"error":"unknown state loadbalancers slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_slb_raw() {
  local body; body="$(do_get /load_balancers?per_page=200)" || {
    printf '{"error":"failed to fetch load_balancers","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"load_balancers":[]}'
    return
  }
  printf '%s' "$body"
}

_slb_summary() {
  local raw="$1"
  jq '{
    total: ((.load_balancers // []) | length),
    by_region: ((.load_balancers // []) | group_by(.region.slug // "unknown") | map({key:(.[0].region.slug // "unknown"), value:length}) | from_entries),
    https_listener_count: ((.load_balancers // []) | map(select(.forwarding_rules // [] | map(.entry_protocol) | index("https"))) | length),
    http_only_count: ((.load_balancers // []) | map(select((.forwarding_rules // [] | map(.entry_protocol) | unique) == ["http"])) | length),
    redirect_http_to_https_count: ((.load_balancers // []) | map(select(.redirect_http_to_https == true)) | length),
    sticky_sessions_count: ((.load_balancers // []) | map(select((.sticky_sessions.type // "none") != "none")) | length),
    health_check_configured_count: ((.load_balancers // []) | map(select(.health_check // null != null)) | length),
    sample: ((.load_balancers // [])[:5] | map({id, name, ip, status, region: (.region.slug // null), redirect_http_to_https, forwarding_rules}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_lb_digest() {
  local ts="$1"
  local raw summary
  raw="$(_slb_raw)"
  summary="$(_slb_summary "$raw")"
  jq -n --arg ts "$ts" --argjson summary "$summary" \
    '{ schema: "dosec.state-loadbalancers.digest", schema_version: 1, generated_at: $ts,
       tool: "state-loadbalancers", slice: "digest",
       loadbalancers_summary: $summary,
       hint: "for full data, run: state loadbalancers [list|full]" }'
}

_state_lb_list() {
  local ts="$1"
  local raw; raw="$(_slb_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-loadbalancers.list", schema_version: 1, generated_at: $ts,
       tool: "state-loadbalancers", slice: "list",
       load_balancers: [(.load_balancers // [])[] | {id, name, ip, status, region: (.region.slug // null), forwarding_rules, redirect_http_to_https, health_check, sticky_sessions, vpc_uuid, droplet_ids, tag, enable_proxy_protocol}] }' \
    <<<"$raw"
}

_state_lb_full() {
  local ts="$1"
  local raw; raw="$(_slb_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-loadbalancers.full", schema_version: 1, generated_at: $ts,
           tool: "state-loadbalancers", slice: "full" }' \
    <<<"$raw"
}
