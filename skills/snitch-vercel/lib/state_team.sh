# lib/state_team.sh — team digest + slices.
# Exports: run_state_team [team-id] [slice]
#   slice ∈ digest (default) | members | full

run_state_team() {
  local team_id="${1:-}" slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$team_id" ]]; then
    team_id="$(vercel_pick_team 2>/dev/null || true)"
  fi
  if [[ -z "$team_id" ]]; then
    printf '{"error":"could not resolve team id","code":"E_TEAM","remediation":"set VRCSEC_TEAM_ID or pass team-id as the first argument"}\n' >&2
    return 3
  fi
  case "$slice" in
    digest)  _st_digest "$team_id" "$ts" ;;
    members) _st_members "$team_id" "$ts" ;;
    full)    _st_full "$team_id" "$ts" ;;
    *)
      printf '{"error":"unknown state team slice","code":"E_USAGE","got":"%s","valid":["digest","members","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_st_team_meta() {
  local team_id="$1"
  local body; body="$(vrc_get "/v2/teams/${team_id}")" || {
    printf '{"error":"failed to fetch team","code":"E_API","status":%s,"team_id":"%s"}\n' "${VRCSEC_LAST_STATUS:-0}" "$team_id" >&2
    printf '{}'
    return
  }
  jq '{
    id, slug, name,
    plan: (.billing.plan // .plan // null),
    saml: (.saml // null),
    createdAt
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_st_members() {
  local team_id="$1" ts="$2"
  local body members
  body="$(vrc_get "/v2/teams/${team_id}/members")" || true
  members="$(jq '[(.members // [])[] | {
    uid, role, email: (.email // .user.email // null),
    twoFactor: (.user.twoFactor // null),
    createdAt
  }]' <<<"$body" 2>/dev/null || printf '[]')"
  jq -n --arg ts "$ts" --arg team_id "$team_id" --argjson members "$members" \
    '{ schema: "vrcsec.state-team.members", schema_version: 1, generated_at: $ts,
       tool: "state-team", slice: "members", team_id: $team_id, members: $members }'
}

_st_digest() {
  local team_id="$1" ts="$2"
  local meta body members
  meta="$(_st_team_meta "$team_id")"
  body="$(vrc_get "/v2/teams/${team_id}/members")" || true
  members="$(jq '[(.members // [])[] | {
    role, email: (.email // .user.email // null),
    twoFactor: (.user.twoFactor // null)
  }]' <<<"$body" 2>/dev/null || printf '[]')"
  jq -n \
    --arg ts "$ts" --arg team_id "$team_id" \
    --argjson team "$meta" --argjson members "$members" \
    '{
      schema: "vrcsec.state-team.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-team",
      slice: "digest",
      team_id: $team_id,
      team: $team,
      members_summary: {
        total: ($members | length),
        owners: ($members | map(select(.role == "OWNER")) | length),
        with_2fa: ($members | map(select(.twoFactor != null and .twoFactor != false)) | length),
        without_2fa: ($members | map(select(.twoFactor == null or .twoFactor == false)) | length)
      },
      hint: "for full data, run: state team <team-id> [members|full]"
    }'
}

_st_full() {
  local team_id="$1" ts="$2"
  local meta body members
  meta="$(_st_team_meta "$team_id")"
  body="$(vrc_get "/v2/teams/${team_id}/members")" || true
  members="$(jq '[(.members // [])[] | {
    uid, role, email: (.email // .user.email // null),
    twoFactor: (.user.twoFactor // null), createdAt
  }]' <<<"$body" 2>/dev/null || printf '[]')"
  jq -n \
    --arg ts "$ts" --arg team_id "$team_id" \
    --argjson team "$meta" --argjson members "$members" \
    '{ schema: "vrcsec.state-team.full", schema_version: 1, generated_at: $ts,
       tool: "state-team", slice: "full", team_id: $team_id,
       team: $team, members: $members }'
}
