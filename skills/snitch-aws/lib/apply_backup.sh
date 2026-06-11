# lib/apply_backup.sh — AWS Backup hardening:
#  - Surface absence of any backup plan / vault.
# Exposes: apply_backup [args]

apply_backup() {
  log_section "AWS Backup hardening"

  local plans vaults
  plans="$(aws_run_json backup list-backup-plans 2>/dev/null | jq '.BackupPlansList // []')"
  vaults="$(aws_run_json backup list-backup-vaults 2>/dev/null | jq '.BackupVaultList // []')"
  local pn vn
  pn="$(jq -r 'length' <<<"$plans")"
  vn="$(jq -r 'length' <<<"$vaults")"

  if [[ "${pn:-0}" -eq 0 ]]; then
    log_warn "backup" "plans" "No AWS Backup plans configured. See ${REF_DIR}/22-scaling-ladder.md and use the console wizard or Terraform 'aws_backup_plan'."
  else
    log_ok "backup" "plans" "${pn} backup plan(s) configured."
  fi
  if [[ "${vn:-0}" -eq 0 ]]; then
    log_warn "backup" "vaults" "No AWS Backup vaults. Create one: 'aws backup create-backup-vault --backup-vault-name snitch-aws-default'."
  else
    local locked; locked="$(jq '[.[] | select(.Locked == true)] | length' <<<"$vaults")"
    log_ok "backup" "vaults" "${vn} vault(s); ${locked:-0} with vault lock."
  fi
  return 0
}
