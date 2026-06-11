# lib/state_backup.sh — AWS Backup plans, vaults, vault locks.
# Exports: run_state_backup [slice]
#   slice ∈ digest (default) | full

run_state_backup() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local plans vaults
  plans="$(aws_run_json backup list-backup-plans 2>/dev/null | jq '.BackupPlansList // []' 2>/dev/null || printf '[]')"
  vaults="$(aws_run_json backup list-backup-vaults 2>/dev/null | jq '.BackupVaultList // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-backup.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson plans "$plans" --argjson vaults "$vaults" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-backup", slice: $slice,
      account_id: $account, region: $region,
      plans_count: ($plans | length),
      vaults_summary: {
        total: ($vaults | length),
        with_lock: ($vaults | map(select(.Locked == true)) | length),
        with_encryption_kms: ($vaults | map(select(.EncryptionKeyArn != null)) | length)
      },
      plans: (if $slice == "full" then $plans else null end),
      vaults: (if $slice == "full" then $vaults else null end),
      hint: "for full data, run: state backup full"
    }'
}
