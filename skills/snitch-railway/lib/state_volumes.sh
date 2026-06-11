# lib/state_volumes.sh — volumes inventory.
# Exports: run_state_volumes [project-id] [slice]
#   slice ∈ digest (default) | full

run_state_volumes() {
  local project_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_volumes_digest "$project_id" "$ts" ;;
    full)   _state_volumes_full   "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state volumes slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sv_volumes_full() {
  local pid="$1"
  local body
  body="$(rw_gql 'query($id:String!){
    project(id:$id){
      volumes {
        edges {
          node {
            id name createdAt
            volumeInstances {
              edges {
                node {
                  id environmentId
                  mountPath
                  sizeMB
                  state
                  serviceId
                }
              }
            }
          }
        }
      }
    }
  }' "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.project.volumes.edges // [])[].node | {
    id, name, createdAt,
    instances: [(.volumeInstances.edges // [])[].node]
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_volumes_digest() {
  local pid="$1" ts="$2"
  local vols
  vols="$(_sv_volumes_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson vols "$vols" \
    '{
      schema: "rwsec.state-volumes.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-volumes",
      slice: "digest",
      project_id: $pid,
      volumes_summary: {
        total: ($vols | length),
        total_size_mb: ([(.[]?.instances[]? | (.sizeMB // 0))] | add // 0),
        mount_paths: ([(.[]?.instances[]? | .mountPath)] | unique),
        without_backup_warning: "Railway does not auto-snapshot volumes; recommend periodic application-level backup or external snapshot."
      },
      volumes: $vols,
      hint: "for full data, run: state volumes <project-id> full"
    }'
}

_state_volumes_full() {
  local pid="$1" ts="$2"
  local vols
  vols="$(_sv_volumes_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson vols "$vols" \
    '{ schema:"rwsec.state-volumes.full", schema_version:1, generated_at:$ts,
       tool:"state-volumes", slice:"full", project_id:$pid, volumes:$vols }'
}
