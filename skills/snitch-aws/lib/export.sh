# lib/export.sh — JSON snapshot of in-scope account areas to cwd.
# Exports: run_export

run_export() {
  local out_dir="${1:-./snitch-aws-export}"
  mkdir -p "$out_dir"
  local areas="account iam s3 ec2 vpc rds dynamodb lambda cloudfront route53 acm cognito secrets cloudtrail cloudwatch wafv2 shield config inspector macie guardduty securityhub backup kms organizations eks ecs eventbridge sqs-sns cost"
  local a
  for a in $areas; do
    local lib="${LIB_DIR}/state_${a//-/_}.sh"
    if [[ ! -f "$lib" ]]; then
      log_warn "export" "skip" "no lib for ${a}"
      continue
    fi
    . "$lib"
    if "run_state_${a//-/_}" digest > "${out_dir}/${a}.digest.json" 2>/dev/null; then
      log_ok "export" "$a" "wrote ${out_dir}/${a}.digest.json"
    else
      log_warn "export" "$a" "failed to export ${a}"
    fi
  done
}
