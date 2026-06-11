# lib/state_tcp_proxies.sh — public TCP proxy exposure per service.
# Exports: run_state_tcp_proxies [project-id] [slice]
#   slice ∈ digest (default) | full

run_state_tcp_proxies() {
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
    digest) _state_tcp_proxies_digest "$project_id" "$ts" ;;
    full)   _state_tcp_proxies_full   "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state tcp-proxies slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_stp_proxies_full() {
  local pid="$1"
  local body
  body="$(rw_gql 'query($id:String!){
    project(id:$id){
      services {
        edges {
          node {
            id name
            serviceInstances {
              edges {
                node {
                  tcpProxies {
                    id applicationPort proxyPort domain
                  }
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
    service_id: .id, service_name: .name,
    tcp_proxies: ([(.serviceInstances.edges // [])[].node.tcpProxies[]?])
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_tcp_proxies_digest() {
  local pid="$1" ts="$2"
  local px
  px="$(_stp_proxies_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson px "$px" \
    '{
      schema: "rwsec.state-tcp-proxies.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-tcp-proxies",
      slice: "digest",
      project_id: $pid,
      tcp_proxies_summary: {
        services_with_tcp_exposure: ([.[] | select((.tcp_proxies // []) | length > 0) | .service_name]),
        total_proxies: ([.[] | (.tcp_proxies // [])[]] | length),
        warning: "Public TCP proxies bypass HTTPS termination. Anything reachable here is a direct internet-facing port. Audit each service expectation: is the application on the other end actually meant to be public?"
      },
      services: $px,
      hint: "for full data, run: state tcp-proxies <project-id> full"
    }'
}

_state_tcp_proxies_full() {
  local pid="$1" ts="$2"
  local px
  px="$(_stp_proxies_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson px "$px" \
    '{ schema:"rwsec.state-tcp-proxies.full", schema_version:1, generated_at:$ts,
       tool:"state-tcp-proxies", slice:"full", project_id:$pid, services:$px }'
}
