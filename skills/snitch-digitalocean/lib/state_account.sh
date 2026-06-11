# lib/state_account.sh — account state, digest by default + slice on request.
# Exports: run_state_account [slice]
#   slice ∈ digest (default) | team | tokens | audit | full

run_state_account() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH","remediation":"set DIGITALOCEAN_ACCESS_TOKEN or run doctl auth init"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_account_digest "$ts" ;;
    team)   _state_account_team   "$ts" ;;
    tokens) _state_account_tokens "$ts" ;;
    audit)  _state_account_audit  "$ts" ;;
    full)   _state_account_full   "$ts" ;;
    *)
      printf '{"error":"unknown state account slice","code":"E_USAGE","got":"%s","valid":["digest","team","tokens","audit","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sa_account() {
  local body; body="$(do_get /account)" || {
    printf '{"error":"failed to fetch account","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{}'
    return
  }
  jq '{
    email: (.account.email // null),
    uuid: (.account.uuid // null),
    status: (.account.status // null),
    droplet_limit: (.account.droplet_limit // null),
    floating_ip_limit: (.account.floating_ip_limit // null),
    email_verified: (.account.email_verified // null),
    team: (.account.team // null)
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_sa_team_full() {
  # /v2/account doesn't list team members directly via public API in all plans.
  # The Teams endpoint is internal/limited; emit team metadata if present and
  # surface a helpful note otherwise.
  local body; body="$(do_get /account)" || { printf '{}'; return; }
  jq '.account.team // {}' <<<"$body" 2>/dev/null || printf '{}'
}

_sa_balance() {
  local body; body="$(do_get /customers/my/balance)" || { printf '{}'; return; }
  jq '{ month_to_date_balance: (.month_to_date_balance // null), account_balance: (.account_balance // null), generated_at: (.generated_at // null) }' <<<"$body" 2>/dev/null || printf '{}'
}

_sa_audit_recent() {
  # DigitalOcean exposes audit logs via the activity API for some plans; fall back to empty array.
  printf '[]'
}

_state_account_digest() {
  local ts="$1"
  local account team balance audit
  account="$(_sa_account)"
  team="$(_sa_team_full)"
  balance="$(_sa_balance)"
  audit="$(_sa_audit_recent)"

  jq -n \
    --arg ts "$ts" \
    --argjson account "$account" \
    --argjson team "$team" \
    --argjson balance "$balance" \
    --argjson audit "$audit" \
    '{
      schema: "dosec.state-account.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-account",
      slice: "digest",
      account: $account,
      account_type: (if ($team | length) > 0 then "team" else "personal" end),
      team_summary: {
        present: (($team | length) > 0),
        name: ($team.name // null),
        uuid: ($team.uuid // null)
      },
      billing_summary: $balance,
      audit_log_recent_count: ($audit | length),
      hint: "for full data, run: state account [team|tokens|audit|full]"
    }'
}

_state_account_team() {
  local ts="$1"
  local team; team="$(_sa_team_full)"
  jq -n --arg ts "$ts" --argjson team "$team" \
    '{ schema: "dosec.state-account.team", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "team", team: $team,
       note: "Member listing requires the team admin endpoint; doctl does not expose it directly. Use the cloud.digitalocean.com Settings -> Team UI." }'
}

_state_account_tokens() {
  local ts="$1"
  jq -n --arg ts "$ts" \
    '{ schema: "dosec.state-account.tokens", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "tokens",
       tokens: [],
       note: "DigitalOcean does NOT expose user tokens via API. Review tokens at https://cloud.digitalocean.com/account/api/tokens manually. Refuse any token older than ~1 year or any token with no expiry that is read-write." }'
}

_state_account_audit() {
  local ts="$1"
  local audit; audit="$(_sa_audit_recent)"
  jq -n --arg ts "$ts" --argjson audit "$audit" \
    '{ schema: "dosec.state-account.audit", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "audit", audit_log_recent: $audit,
       note: "Audit log access depends on team plan. Use cloud.digitalocean.com Activity for the dashboard view." }'
}

_state_account_full() {
  local ts="$1"
  local account team balance audit
  account="$(_sa_account)"
  team="$(_sa_team_full)"
  balance="$(_sa_balance)"
  audit="$(_sa_audit_recent)"
  jq -n --arg ts "$ts" \
    --argjson account "$account" --argjson team "$team" \
    --argjson balance "$balance" --argjson audit "$audit" \
    '{ schema: "dosec.state-account.full", schema_version: 1, generated_at: $ts,
       tool: "state-account", slice: "full",
       account: $account, team: $team, billing: $balance, audit_log_recent: $audit }'
}
