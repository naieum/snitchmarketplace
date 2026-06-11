# lib/state_vpcs.sh — VPC state.
# Exports: run_state_vpcs [slice]   slice ∈ digest|list|full

run_state_vpcs() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_vpc_digest "$ts" ;;
    list)   _state_vpc_list   "$ts" ;;
    full)   _state_vpc_full   "$ts" ;;
    *)
      printf '{"error":"unknown state vpcs slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_svpc_raw() {
  local body; body="$(do_get /vpcs?per_page=200)" || {
    printf '{"error":"failed to fetch vpcs","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"vpcs":[]}'
    return
  }
  printf '%s' "$body"
}

_svpc_droplets_with_public_ip() {
  local body; body="$(do_get /droplets?per_page=200)" || { printf '0'; return; }
  jq '[(.droplets // [])[] | select(.networks.v4 // [] | map(.type) | index("public"))] | length' <<<"$body" 2>/dev/null || printf '0'
}

_svpc_summary() {
  local raw="$1"
  local pub; pub="$(_svpc_droplets_with_public_ip)"
  jq --argjson pubcount "${pub:-0}" '{
    total: ((.vpcs // []) | length),
    by_region: ((.vpcs // []) | group_by(.region // "unknown") | map({key:(.[0].region // "unknown"), value:length}) | from_entries),
    default_count: ((.vpcs // []) | map(select(.default == true)) | length),
    public_ip_droplet_count: $pubcount,
    sample: ((.vpcs // [])[:5] | map({id, name, region, ip_range, default, created_at}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_vpc_digest() {
  local ts="$1"
  local raw summary
  raw="$(_svpc_raw)"
  summary="$(_svpc_summary "$raw")"
  jq -n --arg ts "$ts" --argjson summary "$summary" \
    '{ schema: "dosec.state-vpcs.digest", schema_version: 1, generated_at: $ts,
       tool: "state-vpcs", slice: "digest",
       vpcs_summary: $summary,
       hint: "for full data, run: state vpcs [list|full]" }'
}

_state_vpc_list() {
  local ts="$1"
  local raw; raw="$(_svpc_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-vpcs.list", schema_version: 1, generated_at: $ts,
       tool: "state-vpcs", slice: "list",
       vpcs: (.vpcs // []) }' \
    <<<"$raw"
}

_state_vpc_full() {
  local ts="$1"
  local raw; raw="$(_svpc_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-vpcs.full", schema_version: 1, generated_at: $ts,
           tool: "state-vpcs", slice: "full" }' \
    <<<"$raw"
}
