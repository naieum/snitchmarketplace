# lib/state_droplets.sh — Droplet state, digest by default + slice on request.
# Exports: run_state_droplets [slice]
#   slice ∈ digest (default) | list | full

run_state_droplets() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH","remediation":"set DIGITALOCEAN_ACCESS_TOKEN or run doctl auth init"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_droplets_digest "$ts" ;;
    list)   _state_droplets_list   "$ts" ;;
    full)   _state_droplets_full   "$ts" ;;
    *)
      printf '{"error":"unknown state droplets slice","code":"E_USAGE","got":"%s","valid":["digest","list","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sd_droplets_raw() {
  local body; body="$(do_get /droplets?per_page=200)" || {
    printf '{"error":"failed to fetch droplets","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"droplets":[]}'
    return
  }
  printf '%s' "$body"
}

_sd_droplets_summary() {
  local raw="$1"
  jq '{
    total: ((.droplets // []) | length),
    by_region: ((.droplets // []) | group_by(.region.slug // "unknown") | map({key:(.[0].region.slug // "unknown"), value:length}) | from_entries),
    by_size: ((.droplets // []) | group_by(.size_slug // "unknown") | map({key:(.[0].size_slug // "unknown"), value:length}) | from_entries),
    backups_enabled_count: ((.droplets // []) | map(select(.features // [] | index("backups"))) | length),
    monitoring_enabled_count: ((.droplets // []) | map(select(.features // [] | index("monitoring"))) | length),
    ipv6_enabled_count: ((.droplets // []) | map(select(.features // [] | index("ipv6"))) | length),
    private_networking_count: ((.droplets // []) | map(select(.features // [] | index("private_networking"))) | length),
    public_ipv4_count: ((.droplets // []) | map(select(.networks.v4 // [] | map(.type) | index("public"))) | length),
    sample: ((.droplets // [])[:5] | map({id, name, status, size_slug, region: (.region.slug // null), created_at, image: (.image.slug // .image.distribution // null), features, vpc_uuid}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_droplets_digest() {
  local ts="$1"
  local raw summary
  raw="$(_sd_droplets_raw)"
  summary="$(_sd_droplets_summary "$raw")"
  jq -n --arg ts "$ts" --argjson summary "$summary" \
    '{ schema: "dosec.state-droplets.digest", schema_version: 1, generated_at: $ts,
       tool: "state-droplets", slice: "digest",
       droplets_summary: $summary,
       hint: "for full data, run: state droplets [list|full]" }'
}

_state_droplets_list() {
  local ts="$1"
  local raw; raw="$(_sd_droplets_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-droplets.list", schema_version: 1, generated_at: $ts,
       tool: "state-droplets", slice: "list",
       droplets: [(.droplets // [])[] | {id, name, status, size_slug, region: (.region.slug // null), image: (.image.slug // .image.distribution // null), features, vpc_uuid, created_at, tags}] }' \
    <<<"$raw"
}

_state_droplets_full() {
  local ts="$1"
  local raw; raw="$(_sd_droplets_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-droplets.full", schema_version: 1, generated_at: $ts,
            tool: "state-droplets", slice: "full" }' \
    <<<"$raw"
}
