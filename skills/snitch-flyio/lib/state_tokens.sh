# lib/state_tokens.sh — Fly tokens (deploy, org, app), digest + slice.
# Exports: run_state_tokens [org] [slice]
#   slice ∈ digest (default) | full
#
# `fly tokens list --json` enumerates deploy tokens scoped to an org. App-scoped
# tokens are listed similarly with `fly tokens list -a <app>`.

run_state_tokens() {
  local org="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$org" ]]; then
    org="$(api_pick_org 2>/dev/null)" || {
      printf '{"error":"could not resolve org","code":"E_ORG"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_tokens_digest "$org" "$ts" ;;
    full)   _state_tokens_full   "$org" "$ts" ;;
    *)
      printf '{"error":"unknown state tokens slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_tokens_list() {
  local org="$1"
  local body; body="$(fly_run_json tokens list --org "$org" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    id: (.ID // .id),
    name: (.Name // .name // null),
    expires_at: (.ExpiresAt // .expires_at // null),
    profile_id: (.ProfileID // .profile_id // null),
    profile_name: (.ProfileName // .profile_name // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_tokens_digest() {
  local org="$1" ts="$2"
  local t now_iso
  t="$(_tokens_list "$org")"
  now_iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  jq -n --arg ts "$ts" --arg org "$org" --argjson t "$t" --arg now "$now_iso" \
    '{
      schema: "flysec.state-tokens.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-tokens",
      slice: "digest",
      org: $org,
      tokens_summary: {
        total: ($t | length),
        no_expiry: ($t | map(select(.expires_at == null or .expires_at == "")) | length),
        expired: ($t | map(select(.expires_at != null and .expires_at != "" and .expires_at < $now)) | length),
        by_profile: ($t | group_by(.profile_name) | map({key: (.[0].profile_name // "?"), value: length}) | from_entries),
        names: ($t | map(.name))
      },
      tokens: $t,
      hint: "rotate stale tokens via: fly tokens revoke <id>; create scoped deploy tokens via: fly tokens create deploy --expiry 720h"
    }'
}

_state_tokens_full() {
  local org="$1" ts="$2"
  local t; t="$(_tokens_list "$org")"
  jq -n --arg ts "$ts" --arg org "$org" --argjson t "$t" \
    '{ schema: "flysec.state-tokens.full", schema_version: 1, generated_at: $ts,
       tool: "state-tokens", slice: "full", org: $org, tokens: $t }'
}
