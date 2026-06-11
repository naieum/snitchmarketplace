# lib/drift.sh — diff current findings vs last snapshot. Mirror of verify.sh; kept
# as a separate file for parity with cloudflare-secure.
# Exports: drift_run

drift_run() {
  local snap="${STATE_DIR}/snapshot-latest.tsv"
  local cur="${FLYSEC_FINDINGS_FILE}"
  if [[ ! -f "$snap" ]]; then
    log_warn "drift" "no-snapshot" "No prior snapshot."
    return 0
  fi
  if [[ ! -f "$cur" ]]; then
    log_warn "drift" "no-current" "No current findings."
    return 0
  fi
  log_section "drift"
  if diff -q "$snap" "$cur" >/dev/null 2>&1; then
    log_ok "drift" "stable" "No drift since last snapshot."
    return 0
  fi
  diff "$snap" "$cur" | head -n 60 || true
}
