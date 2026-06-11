# lib/apply_account.sh — account-level idempotent fixes (password policy, alerts).
# Exposes: apply_account [args]
# Fixes:
#  - Strong IAM password policy (read-first, no-op if already strong).
#  - Recommend root MFA (cannot enforce via API; surface as WARN).
#  - Recommend account contacts complete.

apply_account() {
  log_section "account hardening"

  # Read current password policy.
  local cur target
  cur="$(aws_run_json iam get-account-password-policy 2>/dev/null | jq '.PasswordPolicy // null' 2>/dev/null)"
  target='{
    "MinimumPasswordLength": 14,
    "RequireSymbols": true,
    "RequireNumbers": true,
    "RequireUppercaseCharacters": true,
    "RequireLowercaseCharacters": true,
    "AllowUsersToChangePassword": true,
    "ExpirePasswords": true,
    "MaxPasswordAge": 90,
    "PasswordReusePrevention": 24,
    "HardExpiry": false
  }'

  local cur_norm tgt_norm
  cur_norm="$(jq -cS '{MinimumPasswordLength,RequireSymbols,RequireNumbers,RequireUppercaseCharacters,RequireLowercaseCharacters,AllowUsersToChangePassword,ExpirePasswords,MaxPasswordAge,PasswordReusePrevention,HardExpiry}' <<<"${cur:-null}" 2>/dev/null || printf 'null')"
  tgt_norm="$(jq -cS '.' <<<"$target")"

  if [[ "$cur_norm" == "$tgt_norm" ]]; then
    log_ok "account" "password-policy" "Password policy already meets target (14 chars, complexity, 90-day expiry, 24 history)."
  else
    aws_run iam update-account-password-policy \
      --minimum-password-length 14 \
      --require-symbols \
      --require-numbers \
      --require-uppercase-characters \
      --require-lowercase-characters \
      --allow-users-to-change-password \
      --max-password-age 90 \
      --password-reuse-prevention 24 \
      >/dev/null 2>&1 \
      && log_ok "account" "password-policy" "Password policy updated to target." \
      || log_fail "account" "password-policy" "Could not update password policy. ${AWSSEC_LAST_STDERR}"
  fi

  log_warn "account" "root-mfa" "Root account MFA cannot be set via API. Enforce at https://console.aws.amazon.com/iam/home#/security_credentials and verify periodically." "https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user_mfa.html"
  log_warn "account" "alternate-contacts" "Alternate (Billing/Operations/Security) contacts cannot all be auto-set without input. Use 'aws account put-alternate-contact' once you have the email/phone. Check 'aws account get-alternate-contact --alternate-contact-type SECURITY'." "https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-update-contact.html"

  if requires_org "account" "scp-coverage" "Organization SCPs review (deny dangerous actions at the org level)." "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html"; then
    log_warn "account" "scp-coverage" "Manage SCPs from the management account. Recommended baseline: deny IAM access-key creation outside specific roles, deny region-pinning, deny CloudTrail disable."
  fi

  return 0
}
