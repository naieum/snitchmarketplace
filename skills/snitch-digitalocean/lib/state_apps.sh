# lib/state_apps.sh — App Platform state.
# Exports: run_state_apps [slice]   slice ∈ digest|list|full

run_state_apps() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_apps_digest "$ts" ;;
    list)   _state_apps_list   "$ts" ;;
    full)   _state_apps_full   "$ts" ;;
    *)
      printf '{"error":"unknown state apps slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sa_apps_raw() {
  local body; body="$(do_get /apps?per_page=200)" || {
    printf '{"error":"failed to fetch apps","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"apps":[]}'
    return
  }
  printf '%s' "$body"
}

_sa_apps_summary() {
  local raw="$1"
  jq '{
    total: ((.apps // []) | length),
    by_region: ((.apps // []) | group_by(.region.slug // "unknown") | map({key:(.[0].region.slug // "unknown"), value:length}) | from_entries),
    by_tier_slug: ((.apps // []) | group_by(.spec.services[0].instance_size_slug // "unknown") | map({key:(.[0].spec.services[0].instance_size_slug // "unknown"), value:length}) | from_entries),
    services_with_health_check: ((.apps // []) | map(.spec.services // [] | map(select(.health_check // null != null)) | length) | add // 0),
    secrets_count: ((.apps // []) | map(.spec.envs // [] | map(select(.type == "SECRET")) | length) | add // 0),
    plain_envs_count: ((.apps // []) | map(.spec.envs // [] | map(select((.type // "GENERAL") == "GENERAL")) | length) | add // 0),
    domains_total: ((.apps // []) | map(.spec.domains // [] | length) | add // 0),
    sample: ((.apps // [])[:5] | map({id, spec_name: .spec.name, region: (.region.slug // null), default_ingress: (.default_ingress // null), live_url: (.live_url // null), updated_at, services: ((.spec.services // []) | map({name, instance_size_slug, instance_count})) }))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_apps_digest() {
  local ts="$1"
  local raw summary
  raw="$(_sa_apps_raw)"
  summary="$(_sa_apps_summary "$raw")"
  jq -n --arg ts "$ts" --argjson summary "$summary" \
    '{ schema: "dosec.state-apps.digest", schema_version: 1, generated_at: $ts,
       tool: "state-apps", slice: "digest",
       apps_summary: $summary,
       hint: "for full data, run: state apps [list|full]" }'
}

_state_apps_list() {
  local ts="$1"
  local raw; raw="$(_sa_apps_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-apps.list", schema_version: 1, generated_at: $ts,
       tool: "state-apps", slice: "list",
       apps: [(.apps // [])[] | {id, name: .spec.name, region: (.region.slug // null), live_url, default_ingress, updated_at, services: ((.spec.services // []) | map({name, instance_size_slug, instance_count, health_check, http_port, internal_ports})), envs: ((.spec.envs // []) | map({key, type, scope}))}] }' \
    <<<"$raw"
}

_state_apps_full() {
  local ts="$1"
  local raw; raw="$(_sa_apps_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-apps.full", schema_version: 1, generated_at: $ts,
           tool: "state-apps", slice: "full" }' \
    <<<"$raw"
}
