# lib/state_domains.sh — custom domains + TLS state per service.
# Exports: run_state_domains [project-id] [slice]
#   slice ∈ digest (default) | full

run_state_domains() {
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
    digest) _state_domains_digest "$project_id" "$ts" ;;
    full)   _state_domains_full   "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state domains slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sd_domains_full() {
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
                  domains {
                    customDomains { id domain status }
                    serviceDomains { id domain }
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
    service_id: .id,
    service_name: .name,
    custom_domains:  ([(.serviceInstances.edges // [])[].node.domains.customDomains[]?]),
    service_domains: ([(.serviceInstances.edges // [])[].node.domains.serviceDomains[]?])
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_domains_digest() {
  local pid="$1" ts="$2"
  local doms
  doms="$(_sd_domains_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson doms "$doms" \
    '{
      schema: "rwsec.state-domains.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-domains",
      slice: "digest",
      project_id: $pid,
      domains_summary: {
        custom_domain_count:    ([.[] | (.custom_domains // [])[]] | length),
        railway_subdomain_count: ([.[] | (.service_domains // [])[]] | length),
        custom_domain_unverified: ([.[] | (.custom_domains // [])[] | select(.status != "active")]),
        all_custom_domains: ([.[] | (.custom_domains // [])[]]),
        note: "Railway auto-issues TLS for custom domains via Lets Encrypt. status=active means cert is live; non-active means CNAME/AAAA still pending."
      } | . as $s | $s,
      domains: $doms,
      hint: "for full data, run: state domains <project-id> full"
    }'
}

_state_domains_full() {
  local pid="$1" ts="$2"
  local doms
  doms="$(_sd_domains_full "$pid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson doms "$doms" \
    '{ schema:"rwsec.state-domains.full", schema_version:1, generated_at:$ts,
       tool:"state-domains", slice:"full", project_id:$pid, domains:$doms }'
}
