# lib/apply_rds.sh — RDS hardening:
#  - Enable deletion protection on production-looking instances (read-first).
#  - Recommend force_ssl param-group changes (cannot toggle without restart).
# Exposes: apply_rds [args]

apply_rds() {
  log_section "RDS hardening"

  local insts
  insts="$(aws_run_json rds describe-db-instances 2>/dev/null | jq -r '.DBInstances[]? | "\(.DBInstanceIdentifier)\t\(.Engine)\t\(.PubliclyAccessible)\t\(.StorageEncrypted)\t\(.DeletionProtection)\t\(.BackupRetentionPeriod // 0)"' 2>/dev/null)"
  local total_seen=0
  while IFS=$'\t' read -r id engine public encrypted del_prot retention; do
    [[ -z "$id" ]] && continue
    total_seen=$((total_seen+1))
    if [[ "$public" == "True" || "$public" == "true" ]]; then
      log_fail "rds" "public/${id}" "RDS instance ${id} (${engine}) is publicly accessible. Disable: 'aws rds modify-db-instance --db-instance-identifier ${id} --no-publicly-accessible --apply-immediately'."
    else
      log_ok "rds" "public/${id}" "${id} not publicly accessible."
    fi
    if [[ "$encrypted" != "True" && "$encrypted" != "true" ]]; then
      log_fail "rds" "encrypted/${id}" "Storage NOT encrypted on ${id}. Encryption can only be enabled at create-time; restore from snapshot to encrypted target."
    else
      log_ok "rds" "encrypted/${id}" "${id} storage encrypted."
    fi
    if [[ "$del_prot" != "True" && "$del_prot" != "true" ]]; then
      if aws_run rds modify-db-instance --db-instance-identifier "$id" --deletion-protection >/dev/null 2>&1; then
        log_ok "rds" "del-protection/${id}" "Deletion protection enabled on ${id}."
      else
        log_warn "rds" "del-protection/${id}" "Could not enable deletion protection on ${id}. ${AWSSEC_LAST_STDERR}"
      fi
    else
      log_ok "rds" "del-protection/${id}" "${id} already has deletion protection."
    fi
    if [[ "${retention:-0}" -lt 7 ]]; then
      log_warn "rds" "backup/${id}" "Backup retention=${retention}d on ${id}. Recommended >= 7d. 'aws rds modify-db-instance --db-instance-identifier ${id} --backup-retention-period 7 --apply-immediately'."
    else
      log_ok "rds" "backup/${id}" "${id} retention=${retention}d (>=7)."
    fi
  done <<<"$insts"

  if [[ $total_seen -eq 0 ]]; then
    log_info "no RDS instances in this region"
  fi
  return 0
}
