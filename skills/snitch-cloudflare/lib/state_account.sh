# lib/state_account.sh — account state, digest by default + slice on request.
# Exports: run_state_account [account-id] [slice]
#   slice ∈ digest (default) | members | tokens | audit | full
#
# Digest emits derived signals (2FA coverage, expiring tokens, alert presence)
# rather than full lists. Slices emit one section in full. Full emits everything.

run_state_account() {
  local account_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  if [[ -z "$account_id" ]]; then
    account_id="$(api_pick_account)" || {
      printf '{"error":"could not resolve account id","code":"E_ACCOUNT","remediation":"set CFSEC_ACCOUNT_ID or pass account-id as the first argument"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest)  _state_account_digest  "$account_id" "$ts" ;;
    members) _state_account_members "$account_id" "$ts" ;;
    tokens)  _state_account_tokens  "$account_id" "$ts" ;;
    audit)   _state_account_audit   "$account_id" "$ts" ;;
    full)    _state_account_full    "$account_id" "$ts" ;;
    *)
      printf '{"error":"unknown state account slice","code":"E_USAGE","got":"%s","valid":["digest","members","tokens","audit","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

# --- helpers ---

_sa_account_meta() {
  local account_id="$1"
  local body; body="$(cf_get "/accounts/${account_id}")" || {
    printf '{"error":"failed to fetch account meta","code":"E_API","status":%s,"account_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$account_id" >&2
    printf '{}'
    return
  }
  jq '{
    id: (.result.id // null),
    name: (.result.name // null),
    type: (.result.type // null)
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_sa_members_full() {
  local account_id="$1"
  local body; body="$(cf_get "/accounts/${account_id}/members?per_page=200")" || {
    printf '{"error":"failed to fetch members","code":"E_API","status":%s,"account_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$account_id" >&2
    printf '[]'
    return
  }
  jq '[(.result // [])[] | {
    id, status,
    user: {
      email: (.user.email // null),
      two_factor_authentication_enabled: (.user.two_factor_authentication_enabled // null)
    },
    roles: [(.roles // [])[] | .name]
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

_sa_tokens_full() {
  local body; body="$(cf_get "/user/tokens")" || {
    printf '{"error":"failed to fetch user tokens","code":"E_API","status":%s,"remediation":"token must be created from /profile/api-tokens"}\n' "${CFSEC_LAST_STATUS:-0}" >&2
    printf '[]'
    return
  }
  jq '[(.result // [])[] | {
    id, name, status, issued_on, expires_on, last_used_on,
    has_ip_restriction: ((.condition.request_ip.in // []) | length > 0)
  } | del(.value)]' <<<"$body" 2>/dev/null || printf '[]'
}

_sa_policies_full() {
  local account_id="$1"
  local body; body="$(cf_get "/accounts/${account_id}/alerting/v3/policies")" || {
    printf '{"error":"failed to fetch notification policies","code":"E_API","status":%s,"account_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$account_id" >&2
    printf '[]'
    return
  }
  jq '[(.result // [])[] | { id, name, alert_type, enabled }]' <<<"$body" 2>/dev/null || printf '[]'
}

_sa_audit_recent() {
  local account_id="$1"
  local body; body="$(cf_get "/accounts/${account_id}/audit_logs?per_page=20")" || {
    printf '{"error":"failed to fetch audit log","code":"E_API","status":%s,"account_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$account_id" >&2
    printf '[]'
    return
  }
  jq '[(.result // [])[] | {
    when,
    action_type: (.action.type // null),
    actor_email: (.actor.email // null),
    actor_type: (.actor.type // null)
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

# --- emit functions ---

_state_account_digest() {
  local account_id="$1" ts="$2"
  local account members tokens policies audit
  account="$(_sa_account_meta "$account_id")"
  members="$(_sa_members_full "$account_id")"
  tokens="$(_sa_tokens_full)"
  policies="$(_sa_policies_full "$account_id")"
  audit="$(_sa_audit_recent "$account_id")"

  # Derived signals — what the agent actually checks during an audit.
  jq -n \
    --arg ts "$ts" --arg account_id "$account_id" \
    --argjson account "$account" \
    --argjson members "$members" \
    --argjson tokens "$tokens" \
    --argjson policies "$policies" \
    --argjson audit "$audit" \
    '{
      schema: "cfsec.state-account.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-account",
      slice: "digest",
      account_id: $account_id,
      account: $account,
      members_summary: {
        total: ($members | length),
        with_2fa: ($members | map(select(.user.two_factor_authentication_enabled == true)) | length),
        without_2fa: ($members | map(select(.user.two_factor_authentication_enabled != true)) | length),
        without_2fa_emails: ($members | map(select(.user.two_factor_authentication_enabled != true) | .user.email))
      },
      tokens_summary: {
        total: ($tokens | length),
        active: ($tokens | map(select(.status == "active")) | length),
        no_expiry: ($tokens | map(select(.expires_on == null)) | length),
        expiring_30d: ($tokens | map(select((.expires_on // "9999") < (($ts | sub("T.*Z";""))) ) | not | not) | length),
        with_ip_restriction: ($tokens | map(select(.has_ip_restriction == true)) | length),
        names: ($tokens | map(.name))
      },
      notification_summary: {
        total: ($policies | length),
        enabled: ($policies | map(select(.enabled == true)) | length),
        alert_types: ($policies | map(.alert_type) | unique)
      },
      audit_log_recent_count: ($audit | length),
      audit_log_action_types_recent: ($audit | map(.action_type) | unique),
      hint: "for full data, run: state account <account-id> [members|tokens|audit|full]"
    }'
}

_state_account_members() {
  local account_id="$1" ts="$2"
  local account members
  account="$(_sa_account_meta "$account_id")"
  members="$(_sa_members_full "$account_id")"
  jq -n \
    --arg ts "$ts" --arg account_id "$account_id" \
    --argjson account "$account" \
    --argjson members "$members" \
    '{ schema: "cfsec.state-account.members", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "members", account_id: $account_id,
       account: $account, members: $members }'
}

_state_account_tokens() {
  local account_id="$1" ts="$2"
  local account tokens
  account="$(_sa_account_meta "$account_id")"
  tokens="$(_sa_tokens_full)"
  jq -n \
    --arg ts "$ts" --arg account_id "$account_id" \
    --argjson account "$account" \
    --argjson tokens "$tokens" \
    '{ schema: "cfsec.state-account.tokens", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "tokens", account_id: $account_id,
       account: $account, tokens: $tokens }'
}

_state_account_audit() {
  local account_id="$1" ts="$2"
  local account audit
  account="$(_sa_account_meta "$account_id")"
  audit="$(_sa_audit_recent "$account_id")"
  jq -n \
    --arg ts "$ts" --arg account_id "$account_id" \
    --argjson account "$account" \
    --argjson audit "$audit" \
    '{ schema: "cfsec.state-account.audit", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "audit", account_id: $account_id,
       account: $account, audit_log_recent: $audit }'
}

_state_account_full() {
  local account_id="$1" ts="$2"
  local account members tokens policies audit
  account="$(_sa_account_meta "$account_id")"
  members="$(_sa_members_full "$account_id")"
  tokens="$(_sa_tokens_full)"
  policies="$(_sa_policies_full "$account_id")"
  audit="$(_sa_audit_recent "$account_id")"
  jq -n \
    --arg ts "$ts" --arg account_id "$account_id" \
    --argjson account "$account" \
    --argjson members "$members" \
    --argjson tokens "$tokens" \
    --argjson policies "$policies" \
    --argjson audit "$audit" \
    '{ schema: "cfsec.state-account.full", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "full", account_id: $account_id,
       account: $account, members: $members, tokens: $tokens,
       notification_policies: $policies, audit_log_recent: $audit }'
}
