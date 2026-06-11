# lib/state_account.sh — account-level state (root MFA, password policy, contacts).
# Exports: run_state_account [slice]
#   slice ∈ digest (default) | password-policy | summary | full

run_state_account() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|password-policy|summary|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","password-policy","summary","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local pwd_policy summary contacts
  pwd_policy="$(aws_run_json iam get-account-password-policy 2>/dev/null | jq '.PasswordPolicy // null' 2>/dev/null || printf 'null')"
  summary="$(aws_run_json iam get-account-summary 2>/dev/null | jq '.SummaryMap // {}' 2>/dev/null || printf '{}')"
  contacts="$(aws_run_json account get-contact-information 2>/dev/null | jq '.ContactInformation // null' 2>/dev/null || printf 'null')"

  local schema="awssec.state-account.${slice}"

  jq -n \
    --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson password_policy "$pwd_policy" \
    --argjson summary "$summary" \
    --argjson contacts "$contacts" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-account", slice: $slice,
      account_id: $account, region: $region,
      password_policy: $password_policy,
      account_summary: $summary,
      account_summary_signals: {
        AccountMFAEnabled: ($summary.AccountMFAEnabled // 0),
        AccessKeysPerUserQuota: ($summary.AccessKeysPerUserQuota // null),
        Users: ($summary.Users // 0),
        UsersWithMFA: ($summary.UsersWithMFA // 0),
        Roles: ($summary.Roles // 0),
        Policies: ($summary.Policies // 0),
        Groups: ($summary.Groups // 0),
        ServerCertificates: ($summary.ServerCertificates // 0)
      },
      contacts: $contacts,
      hint: "for full data, run: state account full"
    }'
}
