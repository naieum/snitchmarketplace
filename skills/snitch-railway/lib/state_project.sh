# lib/state_project.sh — project state, digest + slices.
# Exports: run_state_project [project-id] [slice]
#   slice ∈ digest (default) | environments | full

run_state_project() {
  local project_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      printf '{"error":"could not resolve project id","code":"E_PROJECT","remediation":"set RWSEC_PROJECT_ID or run from a project linked via railway link"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest)       _state_project_digest "$project_id" "$ts" ;;
    environments) _state_project_environments "$project_id" "$ts" ;;
    full)         _state_project_full "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state project slice","code":"E_USAGE","got":"%s","valid":["digest","environments","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sp_project() {
  local pid="$1"
  local body
  body="$(rw_gql 'query($id:String!){ project(id:$id){ id name description createdAt updatedAt isPublic } }' \
    "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    printf '{}'; return
  }
  jq '.data.project // {}' <<<"$body" 2>/dev/null || printf '{}'
}

_sp_environments() {
  local pid="$1"
  local body
  body="$(rw_gql 'query($id:String!){ project(id:$id){ environments { edges { node { id name } } } } }' \
    "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.project.environments.edges // [])[].node]' <<<"$body" 2>/dev/null || printf '[]'
}

_sp_services() {
  local pid="$1"
  local body
  body="$(rw_gql 'query($id:String!){ project(id:$id){ services { edges { node { id name } } } } }' \
    "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.project.services.edges // [])[].node]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_project_digest() {
  local pid="$1" ts="$2"
  local proj envs svcs
  proj="$(_sp_project "$pid")"
  envs="$(_sp_environments "$pid")"
  svcs="$(_sp_services "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson project "$proj" \
    --argjson envs "$envs" \
    --argjson svcs "$svcs" \
    '{
      schema: "rwsec.state-project.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-project",
      slice: "digest",
      project_id: $pid,
      project: $project,
      environments_summary: {
        total: ($envs | length),
        names: ($envs | map(.name))
      },
      services_summary: {
        total: ($svcs | length),
        names: ($svcs | map(.name))
      },
      public_warning: (if ($project.isPublic // false) then "project is publicly visible; secrets must never be exposed in vars" else null end),
      hint: "for full data, run: state project <project-id> [environments|full]"
    }'
}

_state_project_environments() {
  local pid="$1" ts="$2"
  local envs
  envs="$(_sp_environments "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson envs "$envs" \
    '{ schema:"rwsec.state-project.environments", schema_version:1, generated_at:$ts,
       tool:"state-project", slice:"environments", project_id:$pid, environments:$envs }'
}

_state_project_full() {
  local pid="$1" ts="$2"
  local proj envs svcs
  proj="$(_sp_project "$pid")"
  envs="$(_sp_environments "$pid")"
  svcs="$(_sp_services "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson project "$proj" \
    --argjson envs "$envs" \
    --argjson svcs "$svcs" \
    '{ schema:"rwsec.state-project.full", schema_version:1, generated_at:$ts,
       tool:"state-project", slice:"full", project_id:$pid,
       project:$project, environments:$envs, services:$svcs }'
}
