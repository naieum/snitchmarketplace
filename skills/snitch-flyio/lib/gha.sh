# lib/gha.sh — emit the proposed GitHub Actions workflow.
# Exports: gha_fix
#
# Skill never writes inside the user project; the agent applies via Edit/Write.

gha_fix() {
  local target="${1:-}"
  local f="${TPL_DIR}/github-actions/snitch-flyio-on-pr.yml"
  if [[ ! -f "$f" ]]; then
    log_fail "gha" "missing-template" "GitHub Actions template not found at ${f}."
    return 2
  fi
  log_section "gha"
  log_info "Proposed workflow at .github/workflows/snitch-flyio-on-pr.yml"
  printf '\n=== FILE: .github/workflows/snitch-flyio-on-pr.yml ===\n'
  printf '=== DIFF ===\n'
  printf '+%s\n' "$(awk '{print "+"$0}' "$f" 2>/dev/null | head -n 80)"
  printf '=== CONTENT ===\n'
  cat "$f"
  printf '\n=== END ===\n'
}
