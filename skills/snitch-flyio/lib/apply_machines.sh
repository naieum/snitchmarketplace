# lib/apply_machines.sh — restart policy + health-check audit.
# Exports: apply_machines [app]
#
# Idempotent: read-only audit + emits canonical commands the user can re-run.
# Never restarts machines automatically.

apply_machines() {
  local app="${1:-}"
  if [[ -z "$app" ]]; then
    app="$(api_pick_app 2>/dev/null || printf '')"
  fi
  if [[ -z "$app" ]]; then
    log_warn "machines" "no-app" "No app specified. Pass app or run from cwd with fly.toml."
    return 0
  fi

  log_section "machines: ${app}"

  local body; body="$(fly_run_json machines list -a "$app" 2>/dev/null || printf '[]')"
  local total; total="$(jq -r 'length' <<<"$body" 2>/dev/null || printf '0')"
  if [[ "$total" == "0" ]]; then
    log_warn "machines" "none" "No machines for app=${app}. Run \`fly deploy\` to provision."
    return 0
  fi
  log_ok "machines" "count" "${total} machine(s) for ${app}."

  # Restart policy distribution
  local policies
  policies="$(jq -r '[ .[] | ((.config // .Config).restart.policy // "unset") ] | group_by(.) | map("\(.[0]):\(length)") | join(", ")' <<<"$body" 2>/dev/null)"
  log_info "restart-policy distribution: ${policies:-unknown}"

  # Find machines with no restart.policy set or 'no' policy
  local risky; risky="$(jq -r '[ .[] | select(((.config // .Config).restart.policy // "unset") == "unset" or ((.config // .Config).restart.policy // "") == "no") | (.id // .ID) ] | join(", ")' <<<"$body" 2>/dev/null)"
  if [[ -n "$risky" && "$risky" != "" ]]; then
    log_warn "machines" "restart-policy" "Machines without a restart policy (or policy=no): ${risky}. Recommended: restart_policy=on-failure for stateless services. Configure in fly.toml [http_service] / [[services]]."
  else
    log_ok "machines" "restart-policy" "All machines have an explicit restart policy."
  fi

  # Find machines with no checks (services_count > 0 but checks_count == 0)
  local no_checks; no_checks="$(jq -r '[ .[] | select((((.config // .Config).services // []) | length) > 0 and ( ((.config // .Config).checks // {}) | length) == 0) | (.id // .ID) ] | join(", ")' <<<"$body" 2>/dev/null)"
  if [[ -n "$no_checks" && "$no_checks" != "" ]]; then
    log_warn "machines" "checks" "Machines with services but no health checks: ${no_checks}. Add [[http_service.checks]] in fly.toml so failed machines are replaced." \
      "https://fly.io/docs/reference/configuration/#http_service-checks"
  else
    log_ok "machines" "checks" "All service-running machines define checks."
  fi

  # Image source: pinned by digest? Fly recommends pinning prod to a digest.
  local floating; floating="$(jq -r '[ .[] | ((.config // .Config).image // "") | select(test("@sha256:") | not) ] | length' <<<"$body" 2>/dev/null || printf '0')"
  if [[ "$floating" -gt 0 ]]; then
    log_warn "machines" "image-pin" "${floating} machine(s) reference a tag, not an image digest. Pin prod images by digest to make rollbacks deterministic."
  else
    log_ok "machines" "image-pin" "All machines reference images by digest."
  fi

  return 0
}
