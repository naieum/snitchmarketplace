# lib/verify.sh — diff current findings vs last snapshot.
# Exports: run_verify

run_verify() {
  local snap="${STATE_DIR}/snapshot-latest.tsv"
  local cur="${STATE_DIR}/findings.tsv"
  if [[ ! -f "$snap" ]]; then
    log_warn "drift" "no-snapshot" "No prior snapshot. Run a fix pass first; it writes ${snap}."
    return 0
  fi
  if [[ ! -f "$cur" ]]; then
    log_warn "drift" "no-current" "No current findings. Run \`bash snitch-flyio.sh state apps\` etc to populate."
    return 0
  fi
  log_section "drift report"
  diff <(sort "$snap") <(sort "$cur") | head -n 50 || true
  log_info "Snapshot: ${snap}"
  log_info "Current:  ${cur}"
}
