# lib/apply_cloudtrail.sh — CloudTrail hardening:
#  - Ensure at least one multi-region trail with log file validation enabled.
#  - Surface trails missing KMS encryption / CloudWatch logs.
# Exposes: apply_cloudtrail [args]

apply_cloudtrail() {
  log_section "CloudTrail hardening"

  local trails
  trails="$(aws_run_json cloudtrail describe-trails 2>/dev/null | jq -c '.trailList // []')"
  local n; n="$(jq -r 'length' <<<"$trails")"
  if [[ "${n:-0}" -eq 0 ]]; then
    log_fail "cloudtrail" "exists" "No CloudTrail trails configured. Create one: 'aws cloudtrail create-trail --name snitch-aws-account-trail --s3-bucket-name <secure-bucket> --is-multi-region-trail --enable-log-file-validation'."
    return 0
  fi

  local rows
  rows="$(jq -r '.[] | "\(.Name)\t\(.IsMultiRegionTrail)\t\(.LogFileValidationEnabled)\t\(.KmsKeyId // "")\t\(.CloudWatchLogsLogGroupArn // "")"' <<<"$trails")"
  local has_multi=0
  while IFS=$'\t' read -r name multi val kms cwl; do
    [[ -z "$name" ]] && continue
    if [[ "$multi" == "true" ]]; then
      has_multi=1
      log_ok "cloudtrail" "multi-region/${name}" "${name} multi-region."
    else
      log_warn "cloudtrail" "multi-region/${name}" "${name} single-region only. Recommend update-trail --is-multi-region-trail."
      if aws_run cloudtrail update-trail --name "$name" --is-multi-region-trail >/dev/null 2>&1; then
        log_ok "cloudtrail" "multi-region/${name}" "${name} updated to multi-region."
      fi
    fi
    if [[ "$val" == "true" ]]; then
      log_ok "cloudtrail" "log-validation/${name}" "${name} log file validation ON."
    else
      if aws_run cloudtrail update-trail --name "$name" --enable-log-file-validation >/dev/null 2>&1; then
        log_ok "cloudtrail" "log-validation/${name}" "${name} log file validation enabled."
      else
        log_warn "cloudtrail" "log-validation/${name}" "Could not enable log file validation on ${name}. ${AWSSEC_LAST_STDERR}"
      fi
    fi
    if [[ -z "$kms" ]]; then
      log_warn "cloudtrail" "kms/${name}" "${name} not encrypted with a customer KMS key. Recommend: 'aws cloudtrail update-trail --name ${name} --kms-key-id <key-arn>'."
    else
      log_ok "cloudtrail" "kms/${name}" "${name} encrypted with KMS."
    fi
    if [[ -z "$cwl" ]]; then
      log_warn "cloudtrail" "cwl/${name}" "${name} not shipping to CloudWatch Logs (recommended for metric filters / alarms)."
    else
      log_ok "cloudtrail" "cwl/${name}" "${name} ships to CloudWatch Logs."
    fi
  done <<<"$rows"

  if [[ $has_multi -eq 0 ]]; then
    log_warn "cloudtrail" "summary" "No multi-region trail in account. Create one to capture global service events."
  fi

  return 0
}
