# lib/apply_secrets.sh — Secrets Manager hardening:
#  - Surface secrets without rotation enabled.
# Exposes: apply_secrets [args]

apply_secrets() {
  log_section "Secrets Manager hardening"

  local secrets
  secrets="$(aws_run_json secretsmanager list-secrets --max-results 100 2>/dev/null | jq -c '.SecretList // []')"
  local n; n="$(jq -r 'length' <<<"$secrets")"
  if [[ "${n:-0}" -eq 0 ]]; then
    log_info "no secrets found in Secrets Manager"
    return 0
  fi
  local rows
  rows="$(jq -r '.[] | "\(.Name)\t\(.RotationEnabled // false)\t\(.KmsKeyId // "")"' <<<"$secrets")"
  while IFS=$'\t' read -r name rot kms; do
    [[ -z "$name" ]] && continue
    if [[ "$rot" == "true" ]]; then
      log_ok "secrets" "rotation/${name}" "${name} has rotation enabled."
    else
      log_warn "secrets" "rotation/${name}" "${name} has no rotation. For RDS-style secrets: 'aws secretsmanager rotate-secret --secret-id ${name} --rotation-lambda-arn <lambda-arn> --rotation-rules AutomaticallyAfterDays=30'."
    fi
    if [[ -z "$kms" ]]; then
      log_warn "secrets" "kms/${name}" "${name} uses default KMS key. Recommend a customer-managed KMS key for granular grants."
    else
      log_ok "secrets" "kms/${name}" "${name} uses customer KMS key."
    fi
  done <<<"$rows"

  return 0
}
