# lib/state_account.sh — user + team-summary digest, slices on request.
# Exports: run_state_account [slice]
#   slice ∈ digest (default) | members | tokens | audit | full

run_state_account() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  case "$slice" in
    digest)  _state_account_digest "$ts" ;;
    members) _state_account_members "$ts" ;;
    tokens)  _state_account_tokens "$ts" ;;
    audit)   _state_account_audit "$ts" ;;
    full)    _state_account_full "$ts" ;;
    *)
      printf '{"error":"unknown state account slice","code":"E_USAGE","got":"%s","valid":["digest","members","tokens","audit","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sa_user() {
  local body; body="$(vrc_get "/v2/user")" || {
    printf '{"error":"failed to fetch user","code":"E_API","status":%s}\n' "${VRCSEC_LAST_STATUS:-0}" >&2
    printf '{}'
    return
  }
  jq '.user // {} | {
    id, username, email, name,
    sfdcGroupId: (.sfdcGroupId // null),
    plan: (.billing.plan // .plan // null),
    createdAt
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_sa_teams() {
  local body; body="$(vrc_get "/v2/teams")" || {
    printf '{"error":"failed to list teams","code":"E_API","status":%s}\n' "${VRCSEC_LAST_STATUS:-0}" >&2
    printf '[]'
    return
  }
  jq '[(.teams // [])[] | {
    id, slug, name,
    plan: (.billing.plan // .plan // null),
    createdAt
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_sa_tokens() {
  local body; body="$(vrc_get "/v5/user/tokens")" || {
    printf '{"error":"failed to fetch tokens","code":"E_API","status":%s,"remediation":"create a token at https://vercel.com/account/tokens"}\n' "${VRCSEC_LAST_STATUS:-0}" >&2
    printf '[]'
    return
  }
  # Strip any sensitive value fields, keep metadata only.
  jq '[(.tokens // [])[] | {
    id, name, type, scopes,
    activeAt, createdAt, expiresAt
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_sa_audit_recent() {
  local team_id; team_id="$(vercel_pick_team 2>/dev/null || true)"
  if [[ -z "$team_id" ]]; then
    printf '[]'
    return
  fi
  local body; body="$(vrc_get "/v1/teams/${team_id}/audit-logs?limit=20")" || {
    # Audit logs are Pro+ — silently emit empty.
    printf '[]'
    return
  }
  jq '[(.events // .audit // [])[] | {
    id, action: (.action // .type // null),
    actor: (.user.email // .actor // null),
    when: (.createdAt // .timestamp // null)
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_account_digest() {
  local ts="$1"
  local user teams tokens audit
  user="$(_sa_user)"
  teams="$(_sa_teams)"
  tokens="$(_sa_tokens)"
  audit="$(_sa_audit_recent)"

  jq -n \
    --arg ts "$ts" \
    --argjson user "$user" \
    --argjson teams "$teams" \
    --argjson tokens "$tokens" \
    --argjson audit "$audit" \
    '{
      schema: "vrcsec.state-account.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-account",
      slice: "digest",
      user: $user,
      teams_summary: {
        total: ($teams | length),
        plans: ($teams | map(.plan // "hobby") | unique),
        teams: $teams
      },
      tokens_summary: {
        total: ($tokens | length),
        no_expiry: ($tokens | map(select(.expiresAt == null)) | length),
        expired: ($tokens | map(select((.expiresAt // 0) > 0 and (.expiresAt // 0) < (now * 1000))) | length),
        names: ($tokens | map(.name))
      },
      audit_log_recent_count: ($audit | length),
      hint: "for full data, run: state account [members|tokens|audit|full]"
    }'
}

_state_account_members() {
  local ts="$1"
  # member listing requires team-id; use vercel_pick_team
  local team_id; team_id="$(vercel_pick_team 2>/dev/null || true)"
  local members='[]'
  if [[ -n "$team_id" ]]; then
    local body; body="$(vrc_get "/v2/teams/${team_id}/members")" || true
    members="$(jq '[(.members // [])[] | {
      uid, role, email: (.email // .user.email // null),
      twoFactor: (.user.twoFactor // null),
      createdAt
    }]' <<<"$body" 2>/dev/null || printf '[]')"
  fi
  jq -n --arg ts "$ts" --argjson members "$members" \
    '{ schema: "vrcsec.state-account.members", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "members", members: $members }'
}

_state_account_tokens() {
  local ts="$1"
  local tokens; tokens="$(_sa_tokens)"
  jq -n --arg ts "$ts" --argjson tokens "$tokens" \
    '{ schema: "vrcsec.state-account.tokens", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "tokens", tokens: $tokens }'
}

_state_account_audit() {
  local ts="$1"
  local audit; audit="$(_sa_audit_recent)"
  jq -n --arg ts "$ts" --argjson audit "$audit" \
    '{ schema: "vrcsec.state-account.audit", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "audit", audit_log_recent: $audit }'
}

_state_account_full() {
  local ts="$1"
  local user teams tokens audit
  user="$(_sa_user)"
  teams="$(_sa_teams)"
  tokens="$(_sa_tokens)"
  audit="$(_sa_audit_recent)"
  jq -n --arg ts "$ts" \
    --argjson user "$user" --argjson teams "$teams" \
    --argjson tokens "$tokens" --argjson audit "$audit" \
    '{ schema: "vrcsec.state-account.full", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "full",
       user: $user, teams: $teams, tokens: $tokens, audit_log_recent: $audit }'
}
