# lib/apply_volumes.sh — snapshot retention + region affinity audit.
# Exports: apply_volumes [app]
#
# Idempotent: read-only inspection + emits canonical commands for snapshot
# create / retention update.

apply_volumes() {
  local app="${1:-}"
  if [[ -z "$app" ]]; then
    app="$(api_pick_app 2>/dev/null || printf '')"
  fi
  if [[ -z "$app" ]]; then
    log_warn "volumes" "no-app" "No app specified. Pass app or run from cwd with fly.toml."
    return 0
  fi

  log_section "volumes: ${app}"

  local body; body="$(fly_run_json volumes list -a "$app" 2>/dev/null || printf '[]')"
  local total; total="$(jq -r 'length' <<<"$body" 2>/dev/null || printf '0')"
  if [[ "$total" == "0" ]]; then
    log_info "No volumes attached to ${app}."
    return 0
  fi
  log_ok "volumes" "count" "${total} volume(s) for ${app}."

  # Encrypted by default since 2023; check anyway.
  local unenc; unenc="$(jq -r '[ .[] | select((.encrypted // .Encrypted // null) == false) | (.id // .ID) ] | join(", ")' <<<"$body" 2>/dev/null)"
  if [[ -n "$unenc" && "$unenc" != "" ]]; then
    log_fail "volumes" "encrypted" "Unencrypted volumes detected: ${unenc}. Recreate encrypted: fly volumes create <name> --size <gb> --region <r> -a ${app}; then snapshot-restore the data."
  else
    log_ok "volumes" "encrypted" "All volumes encrypted at rest."
  fi

  # Snapshot retention
  local short_retention; short_retention="$(jq -r '[ .[] | select(((.snapshot_retention // .SnapshotRetention // 0) | tonumber) < 5) | (.id // .ID) ] | join(", ")' <<<"$body" 2>/dev/null)"
  if [[ -n "$short_retention" && "$short_retention" != "" ]]; then
    log_warn "volumes" "snapshot-retention" "Volumes with snapshot_retention<5 days: ${short_retention}. Bump retention: fly volumes update <id> --snapshot-retention 14 -a ${app}."
  else
    log_ok "volumes" "snapshot-retention" "Snapshot retention >= 5 days on all volumes."
  fi

  # Auto-backup
  local no_backup; no_backup="$(jq -r '[ .[] | select((.auto_backup_enabled // .AutoBackupEnabled // null) != true) | (.id // .ID) ] | join(", ")' <<<"$body" 2>/dev/null)"
  if [[ -n "$no_backup" && "$no_backup" != "" ]]; then
    log_warn "volumes" "auto-backup" "Volumes without auto-backup: ${no_backup}. Enable: fly volumes update <id> --auto-backup -a ${app}."
  else
    log_ok "volumes" "auto-backup" "Auto-backup enabled on all volumes."
  fi

  # Region drift: for stateful apps, all volumes in one region is a risk; multiple regions also
  # need careful coordination. Surface the spread.
  local regions; regions="$(jq -r '[ .[] | (.region // .Region) ] | unique | join(", ")' <<<"$body" 2>/dev/null)"
  log_info "volumes span regions: ${regions}"

  return 0
}
