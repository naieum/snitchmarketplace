# lib/apply_wafv2.sh — WAFv2 hardening:
#  - Surface absence of a Web ACL in REGIONAL + CLOUDFRONT scope.
#  - Recommend AWS managed rule groups baseline.
# Exposes: apply_wafv2 [args]

apply_wafv2() {
  log_section "WAFv2 hardening"

  local cf rg
  cf="$(aws_run_json wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 2>/dev/null | jq '.WebACLs // []')"
  rg="$(aws_run_json wafv2 list-web-acls --scope REGIONAL 2>/dev/null | jq '.WebACLs // []')"

  local cf_n rg_n
  cf_n="$(jq -r 'length' <<<"$cf")"
  rg_n="$(jq -r 'length' <<<"$rg")"

  if [[ "${cf_n:-0}" -eq 0 ]]; then
    log_warn "wafv2" "scope-cloudfront" "No CLOUDFRONT-scope Web ACLs. If you have public CloudFront distributions, attach an ACL with the AWS managed core rule set (AWSManagedRulesCommonRuleSet)."
  else
    log_ok "wafv2" "scope-cloudfront" "${cf_n} CLOUDFRONT-scope Web ACL(s) present."
  fi
  if [[ "${rg_n:-0}" -eq 0 ]]; then
    log_warn "wafv2" "scope-regional" "No REGIONAL-scope Web ACLs. If you have ALB / API Gateway / AppSync, attach an ACL."
  else
    log_ok "wafv2" "scope-regional" "${rg_n} REGIONAL-scope Web ACL(s) present."
  fi

  log_info "Starter rules (managed): AWSManagedRulesCommonRuleSet, AWSManagedRulesKnownBadInputsRuleSet, AWSManagedRulesAmazonIpReputationList. See ${TPL_DIR}/wafv2-rules.starter.json."
  return 0
}
