# lib/state_services.sh — service state, digest + full.
# Exports: run_state_services [project-id] [slice]
#   slice ∈ digest (default) | full

run_state_services() {
  local project_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      printf '{"error":"could not resolve project id","code":"E_PROJECT","remediation":"set RWSEC_PROJECT_ID or run from a linked project"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_services_digest "$project_id" "$ts" ;;
    full)   _state_services_full   "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state services slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_ss_services_full() {
  local pid="$1"
  local body
  body="$(rw_gql 'query($id:String!){
    project(id:$id){
      services {
        edges {
          node {
            id name createdAt
            serviceInstances {
              edges {
                node {
                  id environmentId
                  source { repo image }
                  builder
                  startCommand
                  buildCommand
                  rootDirectory
                  healthcheckPath
                  healthcheckTimeout
                  numReplicas
                  region
                  restartPolicyType
                  restartPolicyMaxRetries
                  sleepApplication
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
  jq '[(.data.project.services.edges // [])[].node | {
    id, name, createdAt,
    instances: [(.serviceInstances.edges // [])[].node]
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_services_digest() {
  local pid="$1" ts="$2"
  local svcs
  svcs="$(_ss_services_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson svcs "$svcs" \
    '{
      schema: "rwsec.state-services.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-services",
      slice: "digest",
      project_id: $pid,
      services_summary: {
        total: ($svcs | length),
        with_healthcheck: ($svcs | map(select((.instances // []) | any(.healthcheckPath != null and .healthcheckPath != ""))) | length),
        without_healthcheck: ($svcs | map(select((.instances // []) | all(.healthcheckPath == null or .healthcheckPath == ""))) | length),
        builders: ($svcs | map(.instances[]? | .builder) | unique),
        with_replicas_gt_1: ($svcs | map(select((.instances // []) | any((.numReplicas // 1) > 1))) | length),
        with_sleep_enabled: ($svcs | map(select((.instances // []) | any(.sleepApplication == true))) | length),
        sources: ($svcs | map({name, source: (.instances[0]?.source // null)}))
      },
      services: $svcs,
      hint: "for full data, run: state services <project-id> full"
    }'
}

_state_services_full() {
  local pid="$1" ts="$2"
  local svcs
  svcs="$(_ss_services_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson svcs "$svcs" \
    '{ schema:"rwsec.state-services.full", schema_version:1, generated_at:$ts,
       tool:"state-services", slice:"full", project_id:$pid, services:$svcs }'
}
