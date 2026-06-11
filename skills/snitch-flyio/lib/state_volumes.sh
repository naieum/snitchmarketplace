# lib/state_volumes.sh — volumes state, digest + slice.
# Exports: run_state_volumes [app] [slice]
#   slice ∈ digest (default) | full

run_state_volumes() {
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
    digest) _state_volumes_digest "$app" "$ts" ;;
    full)   _state_volumes_full   "$app" "$ts" ;;
    *)
      printf '{"error":"unknown state volumes slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_volumes_list() {
  local app="$1"
  local body; body="$(fly_run_json volumes list -a "$app" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    id: (.id // .ID),
    name: (.name // .Name),
    region: (.region // .Region),
    size_gb: (.size_gb // .SizeGb // .size // null),
    state: (.state // .State),
    encrypted: (.encrypted // .Encrypted // null),
    auto_backup_enabled: (.auto_backup_enabled // .AutoBackupEnabled // null),
    snapshot_retention: (.snapshot_retention // .SnapshotRetention // null),
    attached_machine_id: (.attached_machine_id // .AttachedMachine // null),
    fork_enabled: (.fork_enabled // .ForkEnabled // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_volumes_digest() {
  local app="$1" ts="$2"
  local v
  v="$(_volumes_list "$app")"
  jq -n --arg ts "$ts" --arg app "$app" --argjson v "$v" \
    '{
      schema: "flysec.state-volumes.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-volumes",
      slice: "digest",
      app: $app,
      volumes_summary: {
        total: ($v | length),
        by_region: ($v | group_by(.region) | map({key: (.[0].region // "?"), value: length}) | from_entries),
        encrypted_count: ($v | map(select(.encrypted == true)) | length),
        unencrypted_count: ($v | map(select(.encrypted == false or .encrypted == null)) | length),
        without_snapshot_retention: ($v | map(select(.snapshot_retention == null or .snapshot_retention == 0)) | length),
        unattached: ($v | map(select(.attached_machine_id == null or .attached_machine_id == "")) | length),
        total_size_gb: ($v | map(.size_gb // 0) | add)
      },
      volumes: $v,
      hint: "for full volume payloads (incl. snapshots list), run: state volumes <app> full"
    }'
}

_state_volumes_full() {
  local app="$1" ts="$2"
  local v body
  v="$(_volumes_list "$app")"
  body="$(fly_run_json volumes list -a "$app" 2>/dev/null)"
  [[ -z "$body" ]] && body="[]"
  jq -n --arg ts "$ts" --arg app "$app" --argjson v "$v" --argjson raw "$body" \
    '{ schema: "flysec.state-volumes.full", schema_version: 1, generated_at: $ts,
       tool: "state-volumes", slice: "full", app: $app, volumes: $v, raw: $raw }'
}
