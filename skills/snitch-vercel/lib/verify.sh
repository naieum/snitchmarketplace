# lib/verify.sh — diff current findings against last snapshot.
# Exports: run_verify

run_verify() {
  if [[ ! -f "${STATE_DIR}/snapshot-latest.tsv" ]]; then
    log_warn "drift" "no-snapshot" "No prior snapshot found. Re-run an audit, then 'verify' will diff."
    return 0
  fi
  local cur="${VRCSEC_FINDINGS_FILE}"
  local prev; prev="${STATE_DIR}/snapshot-latest.tsv"
  if [[ ! -s "$cur" ]]; then
    log_warn "drift" "no-current" "No current findings to diff. Run an audit first."
    return 0
  fi
  log_section "drift vs snapshot ($(basename "$prev"))"
  diff -u "$prev" "$cur" || true
}
