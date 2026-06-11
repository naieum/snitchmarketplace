# lib/drift.sh — diff current findings vs last snapshot.
# Exports: drift_run

drift_run() {
  local cur="$AWSSEC_FINDINGS_FILE"
  local last="${STATE_DIR}/snapshot-latest.tsv"
  if [[ ! -f "$cur" || ! -s "$cur" ]]; then
    log_info "no current findings — run an audit first."
    return 0
  fi
  if [[ ! -f "$last" ]]; then
    log_warn "drift" "snapshot" "no prior snapshot. Saving current findings as the baseline."
    snapshot_write
    return 0
  fi
  log_section "drift vs last snapshot"
  diff -u "$last" "$cur" || true
}
