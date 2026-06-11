# lib/apply_ec2.sh — EC2 hardening:
#  - Account-level EBS encryption-by-default ON.
#  - Per-instance: enforce IMDSv2 (HttpTokens=required) (read-first; warn if running).
# Exposes: apply_ec2 [args]

apply_ec2() {
  log_section "EC2 hardening"

  # EBS encryption-by-default.
  local cur
  cur="$(aws_run_json ec2 get-ebs-encryption-by-default 2>/dev/null | jq -r '.EbsEncryptionByDefault // false' 2>/dev/null)"
  if [[ "$cur" == "true" ]]; then
    log_ok "ec2" "ebs-encryption-default" "EBS encryption-by-default already ON."
  else
    if aws_run ec2 enable-ebs-encryption-by-default >/dev/null 2>&1; then
      log_ok "ec2" "ebs-encryption-default" "EBS encryption-by-default enabled."
    else
      log_fail "ec2" "ebs-encryption-default" "Could not enable EBS encryption default. ${AWSSEC_LAST_STDERR}"
    fi
  fi

  # IMDSv2 enforcement per instance.
  local insts
  insts="$(aws_run_json ec2 describe-instances 2>/dev/null | jq -r '[.Reservations[]?.Instances[]?] | .[] | "\(.InstanceId)\t\(.MetadataOptions.HttpTokens // "optional")\t\(.State.Name)"' 2>/dev/null)"
  while IFS=$'\t' read -r iid http_tokens state; do
    [[ -z "$iid" ]] && continue
    if [[ "$http_tokens" == "required" ]]; then
      log_ok "ec2" "imdsv2/${iid}" "IMDSv2 already required."
      continue
    fi
    if aws_run ec2 modify-instance-metadata-options \
        --instance-id "$iid" --http-tokens required --http-endpoint enabled >/dev/null 2>&1; then
      log_ok "ec2" "imdsv2/${iid}" "IMDSv2 enforced (HttpTokens=required)."
    else
      log_warn "ec2" "imdsv2/${iid}" "Could not enforce IMDSv2 on ${iid} (state=${state}). ${AWSSEC_LAST_STDERR}"
    fi
  done <<<"$insts"

  return 0
}
