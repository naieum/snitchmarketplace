# lib/apply_logs.sh — log drain to SIEM recommendation (Pro+).
# Exports: apply_logs [project-id]

apply_logs() {
  local project_id="${1:-}"
  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      log_fail "logs" "pick" "could not resolve project id"
      return 3
    }
  fi
  log_section "logs hardening for project=${project_id}"

  . "$LIB_DIR/state_logs.sh"
  local digest
  digest="$(run_state_logs "$project_id" digest 2>/dev/null)"
  if [[ -z "$digest" ]]; then
    log_fail "logs" "read" "could not read logs digest"
    return 3
  fi

  local drain_configured plan
  drain_configured="$(jq '.drain_configured // false' <<<"$digest")"
  plan="$(jq -r '.plan // "unknown"' <<<"$digest")"

  log_info "plan tier: ${plan}"

  if [[ "$drain_configured" == "true" ]]; then
    log_ok "logs" "drain" "log-drain-shaped env vars detected — assuming a drain is configured."
  else
    requires_tier "logs" "drain" "Configure a log drain (Datadog, Sentry, Loki, Honeycomb, etc.) in dashboard → project → Logs → Drain. Without one, security-relevant logs are lost when retention expires." "pro" "https://docs.railway.com/reference/logging" || return 0
    log_warn "logs" "drain" "No log drain detected. On Pro+, add one in dashboard so audit trails survive incidents."
  fi
}
