# lib/apply_iam.sh — IAM hardening (Access Analyzer enable, key-age warn, MFA hint).
# Exposes: apply_iam [args]

apply_iam() {
  log_section "IAM hardening"

  # Ensure at least one Access Analyzer exists in this region.
  local analyzers
  analyzers="$(aws_run_json accessanalyzer list-analyzers 2>/dev/null | jq '.analyzers // []')"
  local count; count="$(jq -r 'length' <<<"$analyzers")"
  if [[ "${count:-0}" -gt 0 ]]; then
    log_ok "iam" "access-analyzer" "Access Analyzer present (${count} in this region)."
  else
    local name="snitch-aws-account-analyzer"
    if aws_run accessanalyzer create-analyzer \
      --analyzer-name "$name" --type ACCOUNT >/dev/null 2>&1; then
      log_ok "iam" "access-analyzer" "Created Access Analyzer: ${name}"
    else
      log_warn "iam" "access-analyzer" "Could not create Access Analyzer. ${AWSSEC_LAST_STDERR}"
    fi
  fi

  # Surface old access keys (>90 days) as warnings; do not auto-rotate.
  local users
  users="$(aws_run_json iam list-users 2>/dev/null | jq -r '.Users[]?.UserName' 2>/dev/null)"
  local now_secs
  now_secs="$(date -u +%s)"
  local found_old=0
  while IFS= read -r u; do
    [[ -z "$u" ]] && continue
    local keys
    keys="$(aws_run_json iam list-access-keys --user-name "$u" 2>/dev/null | jq -r '.AccessKeyMetadata[]? | "\(.AccessKeyId)\t\(.CreateDate)\t\(.Status)"' 2>/dev/null)"
    while IFS=$'\t' read -r kid created status; do
      [[ -z "$kid" ]] && continue
      local k_secs
      if k_secs="$(date -u -j -f "%Y-%m-%dT%H:%M:%S" "${created%+*}" +%s 2>/dev/null)"; then
        :
      else
        k_secs="$(date -u -d "$created" +%s 2>/dev/null || echo 0)"
      fi
      local age_days
      age_days=$(( (now_secs - k_secs) / 86400 ))
      if (( age_days > 90 )); then
        log_warn "iam" "key-age" "user=${u} key=${kid} age=${age_days}d status=${status}. Rotate or delete."
        found_old=1
      fi
    done <<<"$keys"
  done <<<"$users"
  if [[ $found_old -eq 0 ]]; then
    log_ok "iam" "key-age" "No access keys older than 90 days."
  fi

  log_warn "iam" "user-mfa" "Per-user console-MFA cannot be auto-enforced. Use the AWS managed policy 'IAMUserChangePassword' + an MFA-required boundary or SCP." "https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html"

  return 0
}
