# lib/state_workspace.sh — workspace (team) state, digest + slices.
# Exports: run_state_workspace [slice]
#   slice ∈ digest (default) | members | billing | full

run_state_workspace() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  case "$slice" in
    digest)  _state_workspace_digest  "$ts" ;;
    members) _state_workspace_members "$ts" ;;
    billing) _state_workspace_billing "$ts" ;;
    full)    _state_workspace_full    "$ts" ;;
    *)
      printf '{"error":"unknown state workspace slice","code":"E_USAGE","got":"%s","valid":["digest","members","billing","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sw_me() {
  local body
  body="$(rw_gql 'query { me { id email name plan } }' '{}' 2>/dev/null)" || {
    printf '{}'; return
  }
  jq '.data.me // {}' <<<"$body" 2>/dev/null || printf '{}'
}

_sw_teams() {
  local body
  body="$(rw_gql 'query { me { teams { edges { node { id name avatar } } } } }' '{}' 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.me.teams.edges // [])[].node]' <<<"$body" 2>/dev/null || printf '[]'
}

_sw_members() {
  # Best-effort; the GraphQL schema gates members behind team-scope queries.
  local body
  body="$(rw_gql 'query { me { teams { edges { node { id name members { edges { node { id email role } } } } } } } }' '{}' 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.me.teams.edges // [])[].node | {team:.name, members: [(.members.edges // [])[].node]}]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_workspace_digest() {
  local ts="$1"
  local me teams
  me="$(_sw_me)"
  teams="$(_sw_teams)"
  jq -n \
    --arg ts "$ts" \
    --argjson me "$me" \
    --argjson teams "$teams" \
    '{
      schema: "rwsec.state-workspace.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-workspace",
      slice: "digest",
      me: $me,
      teams_summary: {
        total: ($teams | length),
        names: ($teams | map(.name))
      },
      hint: "for full data, run: state workspace [members|billing|full]"
    }'
}

_state_workspace_members() {
  local ts="$1"
  local members
  members="$(_sw_members)"
  jq -n \
    --arg ts "$ts" \
    --argjson members "$members" \
    '{ schema:"rwsec.state-workspace.members", schema_version:1, generated_at:$ts,
       tool:"state-workspace", slice:"members", members:$members }'
}

_state_workspace_billing() {
  local ts="$1"
  local me
  me="$(_sw_me)"
  jq -n \
    --arg ts "$ts" \
    --argjson me "$me" \
    '{ schema:"rwsec.state-workspace.billing", schema_version:1, generated_at:$ts,
       tool:"state-workspace", slice:"billing",
       plan: ($me.plan // null),
       hint: "billing detail (usage, alerts) is not exposed by the public GraphQL schema; check dashboard." }'
}

_state_workspace_full() {
  local ts="$1"
  local me teams members
  me="$(_sw_me)"
  teams="$(_sw_teams)"
  members="$(_sw_members)"
  jq -n \
    --arg ts "$ts" \
    --argjson me "$me" \
    --argjson teams "$teams" \
    --argjson members "$members" \
    '{ schema:"rwsec.state-workspace.full", schema_version:1, generated_at:$ts,
       tool:"state-workspace", slice:"full",
       me:$me, teams:$teams, members:$members }'
}
