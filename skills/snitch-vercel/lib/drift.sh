# lib/drift.sh — re-export drift_run for callers that prefer this name.
# The implementation lives in lib/verify.sh (run_verify); drift_run is an alias.

drift_run() {
  if ! declare -F run_verify >/dev/null; then
    . "${LIB_DIR}/verify.sh"
  fi
  run_verify "$@"
}
