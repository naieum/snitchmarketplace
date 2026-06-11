# lib/apply_workspace.sh — workspace member roles + billing alerts recommendations.
# Read-only audit with dashboard-link remediation since Railway's GraphQL
# does not expose member-role mutations or billing-alert configuration.
# Exports: apply_workspace

apply_workspace() {
  log_section "workspace hardening"

  . "$LIB_DIR/state_workspace.sh"
  local digest
  digest="$(run_state_workspace digest 2>/dev/null)"
  if [[ -z "$digest" ]]; then
    log_fail "workspace" "read" "could not read workspace digest"
    return 3
  fi

  local team_count
  team_count="$(jq '.teams_summary.total // 0' <<<"$digest")"

  log_info "${team_count} team(s) visible to this token"

  # 2FA — Railway enforces via dashboard; we cannot read state. Surface as WARN if user-driven check is required.
  log_warn "workspace" "2fa" "Verify every member has 2FA enabled. Railway exposes this in dashboard → Account Settings → Security. The skill cannot read 2FA state via the public GraphQL schema." "https://railway.com/account/security"

  # Member roles — recommend audit but cannot enumerate via this skill.
  log_warn "workspace" "roles" "Audit team member roles (Owner / Admin / Developer / Viewer) in dashboard. Apply least privilege: most engineers should be Developer, not Admin." "https://docs.railway.com/reference/teams"

  # Billing alerts.
  log_warn "workspace" "billing-alerts" "Configure usage alerts in dashboard → team → Usage. Without alerts, runaway loops can rack up usage before you notice." "https://docs.railway.com/reference/usage"
}
