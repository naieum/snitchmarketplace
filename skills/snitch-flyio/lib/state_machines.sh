# lib/state_machines.sh — per-app machines state, digest + slice.
# Exports:
#   run_state_machines [app] [slice]   slice ∈ digest (default) | full
#   run_state_regions  [app]           per-region presence summary

run_state_machines() {
  local app="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$app" ]]; then
    app="$(api_pick_app 2>/dev/null)" || {
      printf '{"error":"could not resolve app","code":"E_APP","remediation":"set FLYSEC_APP, pass app name, or run from a directory with fly.toml"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_machines_digest "$app" "$ts" ;;
    full)   _state_machines_full   "$app" "$ts" ;;
    *)
      printf '{"error":"unknown state machines slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

run_state_regions() {
  local app="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$app" ]]; then
    app="$(api_pick_app 2>/dev/null)" || {
      printf '{"error":"could not resolve app","code":"E_APP"}\n' >&2
      return 3
    }
  fi
  local body; body="$(_machines_list "$app")"
  jq -n --arg ts "$ts" --arg app "$app" --argjson m "$body" \
    '{ schema: "flysec.state-regions",
       schema_version: 1,
       generated_at: $ts,
       tool: "state-regions",
       app: $app,
       per_region: ($m | group_by(.region) | map({key: (.[0].region // "?"), value: length}) | from_entries),
       total_machines: ($m | length) }'
}

_machines_list() {
  local app="$1"
  local body; body="$(fly_run_json machines list -a "$app" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    id: (.id // .ID),
    name: (.name // .Name),
    state: (.state // .State),
    region: (.region // .Region),
    image: ((.config // .Config).image // null),
    cpu_kind: ((.config // .Config).guest.cpu_kind // null),
    cpus: ((.config // .Config).guest.cpus // null),
    memory_mb: ((.config // .Config).guest.memory_mb // null),
    restart_policy: ((.config // .Config).restart.policy // null),
    services_count: (((.config // .Config).services // []) | length),
    checks_count: (((.config // .Config).checks // {}) | length),
    mounts_count: (((.config // .Config).mounts // []) | length),
    auto_destroy: ((.config // .Config).auto_destroy // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_machines_digest() {
  local app="$1" ts="$2"
  local m
  m="$(_machines_list "$app")"
  jq -n --arg ts "$ts" --arg app "$app" --argjson m "$m" \
    '{
      schema: "flysec.state-machines.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-machines",
      slice: "digest",
      app: $app,
      machines_summary: {
        total: ($m | length),
        by_state: ($m | group_by(.state) | map({key: (.[0].state // "?"), value: length}) | from_entries),
        by_region: ($m | group_by(.region) | map({key: (.[0].region // "?"), value: length}) | from_entries),
        by_restart_policy: ($m | group_by(.restart_policy) | map({key: (.[0].restart_policy // "?"), value: length}) | from_entries),
        without_health_checks: ($m | map(select(.checks_count == 0 or .checks_count == null)) | length),
        with_volumes: ($m | map(select(.mounts_count > 0)) | length)
      },
      machines: $m,
      hint: "for full machine config dumps, run: state machines <app> full"
    }'
}

_state_machines_full() {
  local app="$1" ts="$2"
  local body; body="$(fly_run_json machines list -a "$app" 2>/dev/null)"
  [[ -z "$body" ]] && body="[]"
  jq -n --arg ts "$ts" --arg app "$app" --argjson m "$body" \
    '{ schema: "flysec.state-machines.full", schema_version: 1, generated_at: $ts,
       tool: "state-machines", slice: "full", app: $app, machines: $m }'
}
