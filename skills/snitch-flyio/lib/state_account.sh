# lib/state_account.sh — org/account state, digest by default + slice on request.
# Exports: run_state_account [org] [slice]
#   slice ∈ digest (default) | members | full

run_state_account() {
  local org="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! command -v flyctl >/dev/null 2>&1 && ! command -v fly >/dev/null 2>&1; then
    printf '{"error":"flyctl not installed","code":"E_TOOL"}\n' >&2
    return 2
  fi

  if [[ -z "$org" ]]; then
    org="$(api_pick_org 2>/dev/null)" || {
      printf '{"error":"could not resolve org","code":"E_ORG","remediation":"set FLYSEC_ORG or pass org slug as the first argument"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest)  _state_account_digest  "$org" "$ts" ;;
    members) _state_account_members "$org" "$ts" ;;
    full)    _state_account_full    "$org" "$ts" ;;
    *)
      printf '{"error":"unknown state account slice","code":"E_USAGE","got":"%s","valid":["digest","members","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sa_org_meta() {
  local org="$1"
  local body; body="$(fly_run_json orgs show "$org" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '{"error":"failed to fetch org","code":"E_API","org":"%s"}\n' "$org" >&2
    printf '{}'
    return
  fi
  jq '{
    slug: (.Slug // .slug // null),
    name: (.Name // .name // null),
    type: (.Type // .type // null),
    billing_status: (.BillingStatus // .billing_status // null)
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_sa_members() {
  local org="$1"
  local body; body="$(fly_run_json orgs show "$org" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[
    (.Members // .members // [])[] | {
      email: (.Email // .email // null),
      role:  (.Role  // .role  // null),
      two_factor_authentication_enabled: (.TwoFactorAuthenticationEnabled // .two_factor_protection // null)
    }
  ]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_account_digest() {
  local org="$1" ts="$2"
  local meta members
  meta="$(_sa_org_meta "$org")"
  members="$(_sa_members "$org")"

  jq -n \
    --arg ts "$ts" --arg org "$org" \
    --argjson account "$meta" \
    --argjson members "$members" \
    '{
      schema: "flysec.state-account.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-account",
      slice: "digest",
      org: $org,
      account: $account,
      members_summary: {
        total: ($members | length),
        with_2fa: ($members | map(select(.two_factor_authentication_enabled == true)) | length),
        without_2fa: ($members | map(select(.two_factor_authentication_enabled != true)) | length),
        without_2fa_emails: ($members | map(select(.two_factor_authentication_enabled != true) | .email) | map(select(. != null)))
      },
      hint: "for full data, run: state account <org> [members|full]"
    }'
}

_state_account_members() {
  local org="$1" ts="$2"
  local meta members
  meta="$(_sa_org_meta "$org")"
  members="$(_sa_members "$org")"
  jq -n \
    --arg ts "$ts" --arg org "$org" \
    --argjson account "$meta" \
    --argjson members "$members" \
    '{ schema: "flysec.state-account.members", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "members", org: $org,
       account: $account, members: $members }'
}

_state_account_full() {
  local org="$1" ts="$2"
  local meta members
  meta="$(_sa_org_meta "$org")"
  members="$(_sa_members "$org")"
  jq -n \
    --arg ts "$ts" --arg org "$org" \
    --argjson account "$meta" \
    --argjson members "$members" \
    '{ schema: "flysec.state-account.full", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "full", org: $org,
       account: $account, members: $members }'
}
