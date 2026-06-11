# lib/apply_account.sh — idempotent account-level recommendations.
# Most account-level controls (2FA, SSO) are not API-mutable; surface as warnings.

apply_account() {
  log_section "account apply"

  local user; user="$(vrc_get "/v2/user" 2>/dev/null || printf '{}')"
  local has_2fa; has_2fa="$(jq -r '.user.twoFactor // empty' <<<"$user" 2>/dev/null)"
  if [[ "$has_2fa" == "true" || "$has_2fa" == "enabled" ]]; then
    log_ok "account" "2fa" "Account has 2FA enabled."
  else
    log_warn "account" "2fa" "2FA status not confirmed. Enable 2FA in https://vercel.com/account → Authentication. The skill cannot enforce this via the API." "https://vercel.com/docs/accounts/two-factor-authentication"
  fi

  # SSO is Enterprise-only.
  if requires_tier "account" "sso-recommend" "Enterprise: enforce SAML SSO for all team members." "enterprise" "https://vercel.com/docs/accounts/sso/saml"; then
    log_warn "account" "sso-recommend" "Configure SAML SSO at https://vercel.com/teams/<slug>/settings/security for the whole team."
  fi

  # Audit token expiry posture.
  local tokens; tokens="$(vrc_get "/v5/user/tokens" 2>/dev/null || printf '{}')"
  local no_expiry; no_expiry="$(jq -r '[(.tokens // [])[] | select(.expiresAt == null)] | length' <<<"$tokens" 2>/dev/null)"
  if [[ "${no_expiry:-0}" -gt 0 ]]; then
    log_warn "account" "token-expiry" "${no_expiry} token(s) have no expiry. Rotate by creating a new short-lived token, then revoking the old one." "https://vercel.com/account/tokens"
  else
    log_ok "account" "token-expiry" "All tokens have an expiration set."
  fi

  return 0
}
