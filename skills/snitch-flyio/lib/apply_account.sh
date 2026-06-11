# lib/apply_account.sh — org-level hygiene reminders.
# Exports: apply_account [org]
#
# Idempotent: read-only audit. Emits 2FA reminder, billing-alert reminder.

apply_account() {
  local org="${1:-}"
  if [[ -z "$org" ]]; then
    org="$(api_pick_org 2>/dev/null || printf '')"
  fi
  if [[ -z "$org" ]]; then
    log_warn "account" "no-org" "No org specified. Set FLYSEC_ORG or pass org slug."
    return 0
  fi

  log_section "account / org: ${org}"

  local body; body="$(fly_run_json orgs show "$org" 2>/dev/null || printf '{}')"
  local members
  members="$(jq '[ (.Members // .members // [])[] | {email: (.Email // .email), role: (.Role // .role), tfa: (.TwoFactorAuthenticationEnabled // .two_factor_protection // null)} ]' <<<"$body" 2>/dev/null || printf '[]')"

  local total; total="$(jq -r 'length' <<<"$members" 2>/dev/null || printf '0')"
  local without_tfa; without_tfa="$(jq -r '[ .[] | select(.tfa != true) | .email ] | join(", ")' <<<"$members" 2>/dev/null)"

  log_info "members: ${total}"
  if [[ -n "$without_tfa" && "$without_tfa" != "" ]]; then
    log_fail "account" "2fa" "Members without 2FA: ${without_tfa}. Each must enroll at https://fly.io/user/security."
  else
    log_ok "account" "2fa" "All members have 2FA enabled."
  fi

  # Billing alerts: flyctl doesn't expose this directly; print reminder.
  log_info "Billing alerts live at https://fly.io/dashboard/${org}/billing — set spend caps + email alerts."
  log_info "Audit log: https://fly.io/dashboard/${org}/audit-log — review weekly for unexpected actions."

  return 0
}
