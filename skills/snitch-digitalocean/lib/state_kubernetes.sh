# lib/state_kubernetes.sh — DOKS cluster state.
# Exports: run_state_kubernetes [slice]   slice ∈ digest|list|full

run_state_kubernetes() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_doks_digest "$ts" ;;
    list)   _state_doks_list   "$ts" ;;
    full)   _state_doks_full   "$ts" ;;
    *)
      printf '{"error":"unknown state kubernetes slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sdoks_raw() {
  local body; body="$(do_get /kubernetes/clusters?per_page=200)" || {
    printf '{"error":"failed to fetch clusters","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"kubernetes_clusters":[]}'
    return
  }
  printf '%s' "$body"
}

_sdoks_options() {
  local body; body="$(do_get /kubernetes/options)" || { printf '{}'; return; }
  printf '%s' "$body"
}

_sdoks_summary() {
  local raw="$1"
  jq '{
    total: ((.kubernetes_clusters // []) | length),
    by_region: ((.kubernetes_clusters // []) | group_by(.region // "unknown") | map({key:(.[0].region // "unknown"), value:length}) | from_entries),
    versions: ((.kubernetes_clusters // []) | map(.version) | unique),
    auto_upgrade_count: ((.kubernetes_clusters // []) | map(select(.auto_upgrade == true)) | length),
    surge_upgrade_count: ((.kubernetes_clusters // []) | map(select(.surge_upgrade == true)) | length),
    ha_count: ((.kubernetes_clusters // []) | map(select(.ha == true)) | length),
    autoscaler_node_pool_count: ((.kubernetes_clusters // []) | map(.node_pools // [] | map(select(.auto_scale == true)) | length) | add // 0),
    sample: ((.kubernetes_clusters // [])[:5] | map({id, name, region, version, auto_upgrade, surge_upgrade, ha, vpc_uuid, status: (.status.state // null), node_pools: ((.node_pools // []) | map({name, size, count, auto_scale, min_nodes, max_nodes}))}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_doks_digest() {
  local ts="$1"
  local raw summary opts
  raw="$(_sdoks_raw)"
  summary="$(_sdoks_summary "$raw")"
  opts="$(_sdoks_options)"
  jq -n --arg ts "$ts" --argjson summary "$summary" --argjson opts "$opts" \
    '{ schema: "dosec.state-kubernetes.digest", schema_version: 1, generated_at: $ts,
       tool: "state-kubernetes", slice: "digest",
       clusters_summary: $summary,
       latest_versions: (($opts.options.versions // []) | map(.slug) | sort | reverse | .[0:5]),
       hint: "for full data, run: state kubernetes [list|full]. NetworkPolicy presence requires kubectl access." }'
}

_state_doks_list() {
  local ts="$1"
  local raw; raw="$(_sdoks_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-kubernetes.list", schema_version: 1, generated_at: $ts,
       tool: "state-kubernetes", slice: "list",
       kubernetes_clusters: [(.kubernetes_clusters // [])[] | {id, name, region, version, auto_upgrade, surge_upgrade, ha, vpc_uuid, status, node_pools, maintenance_policy, registry_integration: (.registry_enabled // null)}] }' \
    <<<"$raw"
}

_state_doks_full() {
  local ts="$1"
  local raw; raw="$(_sdoks_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-kubernetes.full", schema_version: 1, generated_at: $ts,
           tool: "state-kubernetes", slice: "full" }' \
    <<<"$raw"
}
