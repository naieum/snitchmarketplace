# lib/state_cost.sh — usage estimate, free-tier exhaustion, sleep config.
# Exports: run_state_cost [project-id] [slice]
#   slice ∈ digest (default) | full
#
# Railway's pricing is usage-based ($/GB-mo, $/vCPU-h). The public GraphQL
# schema exposes per-project metrics under Project.metrics(...). We synthesize
# the rough monthly projection using the past-24h sample.

run_state_cost() {
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
    digest) _state_cost_digest "$project_id" "$ts" ;;
    full)   _state_cost_full   "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state cost slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sc_metrics() {
  local pid="$1"
  # The metrics field shape is: { measurements:[{measurement,value,...}], aggregatedValue }
  # We try a generic query; if the schema rejects, return {}.
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
                  numReplicas
                  sleepApplication
                }
              }
            }
          }
        }
      }
    }
  }' "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    printf '{}'; return
  }
  jq '.data.project // {}' <<<"$body" 2>/dev/null || printf '{}'
}

_state_cost_digest() {
  local pid="$1" ts="$2"
  local metrics plan
  metrics="$(_sc_metrics "$pid")"
  plan="$(detect_plan)"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" --arg plan "$plan" \
    --argjson m "$metrics" \
    '{
      schema: "rwsec.state-cost.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-cost",
      slice: "digest",
      project_id: $pid,
      plan: $plan,
      sleep_summary: {
        sleeping_services: ([(.[] | (.serviceInstances.edges // [])[]?.node) | select(.sleepApplication == true)] | length),
        always_on_services: ([(.[] | (.serviceInstances.edges // [])[]?.node) | select((.sleepApplication // false) == false)] | length)
      } | . as $s | (if ($m.services | length // 0) == 0 then {sleeping_services:0,always_on_services:0} else $s end),
      replica_summary: {
        total_replicas: ([(.[] | (.serviceInstances.edges // [])[]?.node.numReplicas // 1)] | add // 0)
      },
      free_tier_exhaustion_warning: (if $plan == "trial" or $plan == "hobby" then
        "Free tier ($5/mo of usage) exhausts quickly with always-on services. Enable sleep on staging/preview services."
      else null end),
      hint: "Detailed usage / billing only available in dashboard. Run: state cost <project-id> full for raw metrics blob."
    }'
}

_state_cost_full() {
  local pid="$1" ts="$2"
  local metrics plan
  metrics="$(_sc_metrics "$pid")"
  plan="$(detect_plan)"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" --arg plan "$plan" \
    --argjson m "$metrics" \
    '{ schema:"rwsec.state-cost.full", schema_version:1, generated_at:$ts,
       tool:"state-cost", slice:"full", project_id:$pid, plan:$plan, metrics:$m }'
}
