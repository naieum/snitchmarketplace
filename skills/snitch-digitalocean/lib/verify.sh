# lib/verify.sh — re-run digests and diff against the latest snapshot.
# Exports: run_verify

run_verify() {
  log_section "verify"
  . "${LIB_DIR}/drift.sh"

  # Re-run a few digests so findings.tsv has fresh entries.
  . "${LIB_DIR}/state_account.sh"
  . "${LIB_DIR}/state_droplets.sh"
  . "${LIB_DIR}/state_databases.sh"
  . "${LIB_DIR}/state_firewalls.sh"

  run_state_account digest >/dev/null
  run_state_droplets digest >/dev/null
  run_state_databases digest >/dev/null
  run_state_firewalls digest >/dev/null

  drift_run
  snapshot_write
}
