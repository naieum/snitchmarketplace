# lib/apply_securityhub.sh — Security Hub hardening:
#  - Enable Security Hub if not already; subscribe to AWS Foundational Best Practices.
# Exposes: apply_securityhub [args]

apply_securityhub() {
  log_section "Security Hub hardening"

  local region; region="$(aws_pick_region)"
  local hub
  hub="$(aws_run_json securityhub describe-hub 2>/dev/null)"
  local arn; arn="$(jq -r '.HubArn // ""' <<<"$hub")"
  if [[ -z "$arn" ]]; then
    if aws_run securityhub enable-security-hub --enable-default-standards >/dev/null 2>&1; then
      log_ok "securityhub" "enabled" "Security Hub enabled (default standards subscribed)."
    else
      log_fail "securityhub" "enable" "Could not enable Security Hub. ${AWSSEC_LAST_STDERR}"
      return 0
    fi
  else
    log_ok "securityhub" "enabled" "Security Hub already enabled."
  fi

  # Subscribe to AWS FSBP if not already.
  local std
  std="$(aws_run_json securityhub get-enabled-standards 2>/dev/null | jq '.StandardsSubscriptions // []')"
  if jq -e '.[] | select(.StandardsArn | test("aws-foundational-security-best-practices"))' <<<"$std" >/dev/null 2>&1; then
    log_ok "securityhub" "fsbp" "AWS Foundational Security Best Practices already subscribed."
  else
    local std_arn="arn:aws:securityhub:${region}::standards/aws-foundational-security-best-practices/v/1.0.0"
    if aws_run securityhub batch-enable-standards --standards-subscription-requests "StandardsArn=${std_arn}" >/dev/null 2>&1; then
      log_ok "securityhub" "fsbp" "Subscribed to AWS Foundational Security Best Practices."
    else
      log_warn "securityhub" "fsbp" "Could not subscribe to FSBP. ${AWSSEC_LAST_STDERR}"
    fi
  fi
  return 0
}
