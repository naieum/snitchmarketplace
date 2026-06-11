# lib/apply_services.sh — service hardening: health checks, replicas, restart policy.
# Reads current state, recommends specific CLI invocations. Never mutates
# replica count downward and never disables a healthcheck.
# Exports: apply_services [project-id]

apply_services() {
  local project_id="${1:-}"
  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      log_fail "services" "pick" "could not resolve project id"
      return 3
    }
  fi
  log_section "services hardening for project=${project_id}"

  . "$LIB_DIR/state_services.sh"
  local digest
  digest="$(run_state_services "$project_id" digest 2>/dev/null)"
  if [[ -z "$digest" ]] || ! jq -e '.services_summary' >/dev/null 2>&1 <<<"$digest"; then
    log_fail "services" "read" "could not read services digest"
    return 3
  fi

  local total without_hc with_replicas_gt_1
  total="$(jq '.services_summary.total // 0' <<<"$digest")"
  without_hc="$(jq '.services_summary.without_healthcheck // 0' <<<"$digest")"
  with_replicas_gt_1="$(jq '.services_summary.with_replicas_gt_1 // 0' <<<"$digest")"

  log_info "found ${total} service(s)"

  if [[ "$without_hc" == "0" ]]; then
    log_ok "services" "healthcheck" "every service has a healthcheck path."
  else
    log_warn "services" "healthcheck" "${without_hc} service(s) without a healthcheckPath. Set one in railway.json or via dashboard so Railway can detect bad deploys before routing traffic." "https://docs.railway.com/reference/healthchecks"
    jq -r '.services[] | select((.instances // []) | all(.healthcheckPath == null or .healthcheckPath == "")) | "  - service \(.name) (\(.id))  → set healthcheckPath in railway.json or dashboard"' <<<"$digest" >&2
  fi

  if [[ "$with_replicas_gt_1" -gt 0 ]]; then
    log_ok "services" "replicas" "${with_replicas_gt_1} service(s) running >1 replica."
  else
    log_warn "services" "replicas" "all services run a single replica. For production HTTP services, recommend numReplicas ≥ 2 so a deploy or crash doesn't take the service offline."
  fi

  # Emit a railway.json template the user can drop into their repo.
  log_subsection "recommended railway.json (per service)"
  if [[ -f "${TPL_DIR}/railway.json.tpl" ]]; then
    printf '\n=== FILE: railway.json ===\n=== DIFF ===\n(new file or merge)\n=== CONTENT ===\n'
    cat "${TPL_DIR}/railway.json.tpl"
    printf '\n=== END ===\n'
  fi
}
