# lib/apply_account.sh — account-level hardening.
# 2FA cannot be enforced via API — surface as recommendation.
# Billing alerts: ensure at least one alert policy exists for "balance" type.
#
# Exports: apply_account [args]

apply_account() {
  # 2FA / SSO recommendation
  log_warn "account" "2fa-recommend" "DigitalOcean 2FA must be enabled per-user via the UI. Verify all team members have 2FA on." "https://docs.digitalocean.com/platform/security/two-factor-authentication/"

  # Billing alerts — DigitalOcean has 'balance' notification policies in the monitoring API.
  local body; body="$(do_get /monitoring/alerts?per_page=200)" || {
    log_warn "account" "alerts-read" "Could not read alert policies."
    return 0
  }
  local has_balance
  has_balance="$(jq -r '[.policies // [] | .[] | select(.type | test("billing|balance"; "i"))] | length' <<<"$body" 2>/dev/null)"
  if [[ "${has_balance:-0}" -gt 0 ]]; then
    log_ok "account" "billing-alert" "Billing-related alert policy present."
  else
    log_warn "account" "billing-alert" "No billing/balance alert policy. Configure a budget alert in the dashboard." "https://docs.digitalocean.com/products/billing/notifications/"
  fi

  # Recovery email / verification
  local acct; acct="$(do_get /account)" || acct='{}'
  local verified; verified="$(jq -r '.account.email_verified // false' <<<"$acct")"
  if [[ "$verified" == "true" ]]; then
    log_ok "account" "email-verified" "Account email verified."
  else
    log_fail "account" "email-verified" "Account email is NOT verified. Verify the email to ensure recovery and security alerts reach you."
  fi
}
