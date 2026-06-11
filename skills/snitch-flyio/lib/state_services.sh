# lib/state_services.sh — HTTP/TCP services state, digest + slice.
# Exports: run_state_services [app] [slice]
#   slice ∈ digest (default) | full
#
# Reads `fly config show -a <app> --json`. Inspects [http_service],
# [[services]] and any [[checks]].

run_state_services() {
  local app="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$app" ]]; then
    app="$(api_pick_app 2>/dev/null)" || {
      printf '{"error":"could not resolve app","code":"E_APP"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_services_digest "$app" "$ts" ;;
    full)   _state_services_full   "$app" "$ts" ;;
    *)
      printf '{"error":"unknown state services slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_config_show() {
  local app="$1"
  local body; body="$(fly_run_json config show -a "$app" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '{}'
    return
  fi
  printf '%s' "$body"
}

_state_services_digest() {
  local app="$1" ts="$2"
  local cfg
  cfg="$(_config_show "$app")"
  jq -n --arg ts "$ts" --arg app "$app" --argjson cfg "$cfg" \
    '{
      schema: "flysec.state-services.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-services",
      slice: "digest",
      app: $app,
      http_service: ($cfg.http_service // null),
      services_summary: {
        total: (($cfg.services // []) | length),
        force_https: ($cfg.http_service.force_https // null),
        auto_stop_machines: ($cfg.http_service.auto_stop_machines // null),
        auto_start_machines: ($cfg.http_service.auto_start_machines // null),
        min_machines_running: ($cfg.http_service.min_machines_running // null),
        http_checks: (($cfg.http_service.checks // []) | length),
        services_protocols: (($cfg.services // []) | map({proto: (.protocol // null), internal_port: (.internal_port // null)})),
        internal_only: (($cfg.services // []) | map(select(.internal_port != null and (.ports // []) | length == 0)) | length),
        public_tcp: (($cfg.services // []) | map(select((.protocol // "") == "tcp" and ((.ports // []) | length > 0))) | length)
      },
      env_keys: (($cfg.env // {}) | keys),
      hint: "force_https should be true; checks should exist. For full payload run: state services <app> full"
    }'
}

_state_services_full() {
  local app="$1" ts="$2"
  local cfg
  cfg="$(_config_show "$app")"
  jq -n --arg ts "$ts" --arg app "$app" --argjson cfg "$cfg" \
    '{ schema: "flysec.state-services.full", schema_version: 1, generated_at: $ts,
       tool: "state-services", slice: "full", app: $app, config: $cfg }'
}
