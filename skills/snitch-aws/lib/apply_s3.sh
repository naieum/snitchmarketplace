# lib/apply_s3.sh — S3 hardening:
#  - Account-level Public Access Block ON.
#  - Per-bucket Public Access Block ON if missing.
#  - Default encryption enabled (SSE-S3 baseline) if none configured.
# Exposes: apply_s3 [args]

apply_s3() {
  log_section "S3 hardening"

  local account; account="$(aws_pick_account)" || account="unknown"

  # Account-level Public Access Block.
  local cur
  cur="$(aws_run_json s3control get-public-access-block --account-id "$account" 2>/dev/null | jq '.PublicAccessBlockConfiguration // null')"
  local cur_full=0
  if [[ "$cur" != "null" ]]; then
    cur_full="$(jq -r 'select(.BlockPublicAcls==true and .IgnorePublicAcls==true and .BlockPublicPolicy==true and .RestrictPublicBuckets==true) | "1"' <<<"$cur" 2>/dev/null || printf '0')"
  fi
  if [[ "${cur_full:-0}" == "1" ]]; then
    log_ok "s3" "account-pab" "Account-level Public Access Block already fully ON."
  else
    if aws_run s3control put-public-access-block --account-id "$account" \
      --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
      >/dev/null 2>&1; then
      log_ok "s3" "account-pab" "Account-level Public Access Block enabled (all 4 toggles)."
    else
      log_fail "s3" "account-pab" "Could not enable account-level PAB. ${AWSSEC_LAST_STDERR}"
    fi
  fi

  # Per-bucket loop.
  local buckets
  buckets="$(aws_run_json s3api list-buckets 2>/dev/null | jq -r '.Buckets[]?.Name' 2>/dev/null)"
  while IFS= read -r b; do
    [[ -z "$b" ]] && continue
    # Public Access Block per-bucket.
    local pab
    pab="$(aws_run_json s3api get-public-access-block --bucket "$b" 2>/dev/null | jq '.PublicAccessBlockConfiguration // null')"
    local pab_full=0
    if [[ "$pab" != "null" ]]; then
      pab_full="$(jq -r 'select(.BlockPublicAcls==true and .IgnorePublicAcls==true and .BlockPublicPolicy==true and .RestrictPublicBuckets==true) | "1"' <<<"$pab" 2>/dev/null || printf '0')"
    fi
    if [[ "${pab_full:-0}" == "1" ]]; then
      log_ok "s3" "bucket-pab/${b}" "Public Access Block already fully ON."
    else
      if aws_run s3api put-public-access-block --bucket "$b" \
        --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
        >/dev/null 2>&1; then
        log_ok "s3" "bucket-pab/${b}" "Public Access Block enabled."
      else
        log_warn "s3" "bucket-pab/${b}" "Could not enable PAB on bucket (may be intentionally public, e.g. CloudFront origin). ${AWSSEC_LAST_STDERR}"
      fi
    fi

    # Default encryption.
    local enc
    enc="$(aws_run_json s3api get-bucket-encryption --bucket "$b" 2>/dev/null | jq '.ServerSideEncryptionConfiguration // null')"
    if [[ "$enc" != "null" ]]; then
      log_ok "s3" "bucket-enc/${b}" "Default encryption already configured."
    else
      if aws_run s3api put-bucket-encryption --bucket "$b" \
        --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
        >/dev/null 2>&1; then
        log_ok "s3" "bucket-enc/${b}" "Default encryption set to SSE-S3 (AES256)."
      else
        log_warn "s3" "bucket-enc/${b}" "Could not set default encryption. ${AWSSEC_LAST_STDERR}"
      fi
    fi
  done <<<"$buckets"

  return 0
}
