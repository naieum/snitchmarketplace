# lib/state_tokens.sh — token inventory (project + account scope).
# Exports: run_state_tokens [slice]
#   slice ∈ digest (default) | full

run_state_tokens() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  case "$slice" in
    digest) _state_tokens_digest "$ts" ;;
    full)   _state_tokens_full   "$ts" ;;
    *)
      printf '{"error":"unknown state tokens slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

# _st_account_tokens — `me { teams { node { ... } } }` — Railway's GraphQL doesn't
# expose a stable list-tokens endpoint for the account; fall back to listing
# project tokens where possible.
_st_account_tokens() {
  local body
  # Best-effort: query projectTokens via the user's projects.
  body="$(rw_gql 'query { me { projects { edges { node { id name } } } } }' '{}' 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.me.projects.edges // [])[].node]' <<<"$body" 2>/dev/null || printf '[]'
}

_st_project_tokens() {
  local pid; pid="$(api_pick_project 2>/dev/null || true)"
  [[ -z "$pid" ]] && { printf '[]'; return; }
  local body
  body="$(rw_gql 'query($id:String!){ project(id:$id){ projectTokens { edges { node { id name createdAt environment { name } } } } } }' \
    "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.project.projectTokens.edges // [])[].node]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_tokens_digest() {
  local ts="$1"
  local proj_tokens accts
  proj_tokens="$(_st_project_tokens)"
  accts="$(_st_account_tokens)"
  jq -n \
    --arg ts "$ts" \
    --argjson proj_tokens "$proj_tokens" \
    --argjson accts "$accts" \
    '{
      schema: "rwsec.state-tokens.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-tokens",
      slice: "digest",
      project_tokens_summary: {
        total: ($proj_tokens | length),
        names: ($proj_tokens | map(.name)),
        per_environment: ($proj_tokens | group_by(.environment.name // "any") | map({key: (.[0].environment.name // "any"), value: length}) | from_entries),
        oldest_created_at: ($proj_tokens | map(.createdAt) | sort | first)
      },
      account_projects_summary: {
        total: ($accts | length),
        names: ($accts | map(.name))
      },
      hint: "Railway tokens have no last-used timestamp in the public schema. Recommend rotation every 90 days. For full data, run: state tokens full"
    }'
}

_state_tokens_full() {
  local ts="$1"
  local proj_tokens accts
  proj_tokens="$(_st_project_tokens)"
  accts="$(_st_account_tokens)"
  jq -n \
    --arg ts "$ts" \
    --argjson proj_tokens "$proj_tokens" \
    --argjson accts "$accts" \
    '{ schema:"rwsec.state-tokens.full", schema_version:1, generated_at:$ts,
       tool:"state-tokens", slice:"full",
       project_tokens:$proj_tokens, account_projects:$accts }'
}
