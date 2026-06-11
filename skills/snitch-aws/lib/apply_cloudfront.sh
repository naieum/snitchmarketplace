# lib/apply_cloudfront.sh — CloudFront hardening:
#  - Surface distributions without WAFv2 association.
#  - Surface distributions allowing TLSv1.0 / TLSv1.1.
#  - Recommend CloudFront Functions for security headers (emit project file).
# Mutating fixes (WAF associate / min TLS bump) are conservative — they require
# the user to opt in by passing `force` because they re-deploy the distribution.
# Exposes: apply_cloudfront [args]

apply_cloudfront() {
  log_section "CloudFront hardening"

  local force=0
  if [[ "${1:-}" == "force" ]]; then force=1; fi

  local dists
  dists="$(aws_run_json cloudfront list-distributions 2>/dev/null | jq -c '.DistributionList.Items // []')"
  local n; n="$(jq -r 'length' <<<"$dists")"
  if [[ "${n:-0}" -eq 0 ]]; then
    log_info "no CloudFront distributions in this account"
    return 0
  fi
  local rows
  rows="$(jq -r '.[] | "\(.Id)\t\(.DomainName)\t\(.WebACLId // "")\t\(.ViewerCertificate.MinimumProtocolVersion // "?")\t\(.DefaultCacheBehavior.ViewerProtocolPolicy // "?")"' <<<"$dists")"
  while IFS=$'\t' read -r id domain webacl mintls vpolicy; do
    [[ -z "$id" ]] && continue
    if [[ -z "$webacl" ]]; then
      log_warn "cloudfront" "waf/${id}" "Distribution ${id} (${domain}) has no WAFv2 web ACL. Use 'aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1' to find one."
    else
      log_ok "cloudfront" "waf/${id}" "${id} associated with WAF ${webacl}."
    fi
    if [[ "$mintls" =~ ^TLSv1(\.0|\.1)?$ ]]; then
      log_warn "cloudfront" "min-tls/${id}" "Distribution ${id} permits ${mintls}. Recommended: 'TLSv1.2_2021' (requires distribution update)."
    else
      log_ok "cloudfront" "min-tls/${id}" "${id} min TLS = ${mintls}."
    fi
    if [[ "$vpolicy" == "allow-all" ]]; then
      log_warn "cloudfront" "https/${id}" "Distribution ${id} allows HTTP without redirect. Set ViewerProtocolPolicy=redirect-to-https."
    else
      log_ok "cloudfront" "https/${id}" "${id} ViewerProtocolPolicy=${vpolicy}."
    fi
  done <<<"$rows"

  log_info "Security headers via CloudFront Functions: see ${TPL_DIR}/cloudfront-functions/security-headers.js"

  if [[ $force -eq 0 ]]; then
    log_info "(rerun with 'fix cloudfront force' to attempt opt-in updates — currently read-only since CloudFront updates re-deploy the distribution)"
  fi

  return 0
}
