# lib/apply_project.sh — deployment protection for a project.
# Idempotent: read first, only mutate if state differs. Mutations PATCH /v9/projects/<id>.

apply_project() {
  local project_id="${1:-}"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    log_fail "project" "pick" "No project selected. Set VRCSEC_PROJECT_ID or run inside a linked project."
    return 3
  fi

  log_section "project apply (project_id: ${project_id})"

  local cur; cur="$(vrc_get "/v9/projects/${project_id}")" || {
    log_fail "project" "read" "Could not read project. $(vrc_last_error)"
    return 3
  }

  # Vercel Authentication for previews — Pro+ feature on most teams.
  local sso_status sso_type
  sso_status="$(jq -r '.ssoProtection // null | tostring' <<<"$cur" 2>/dev/null)"
  sso_type="$(jq -r '.ssoProtection.deploymentType // empty' <<<"$cur" 2>/dev/null)"

  if requires_tier "project" "preview-auth" "Vercel Authentication on preview deployments (prevents drive-by access)." "pro" "https://vercel.com/docs/security/deployment-protection/methods-to-protect-deployments/vercel-authentication"; then
    if [[ "$sso_type" == "preview" || "$sso_type" == "all" ]]; then
      log_ok "project" "preview-auth" "Vercel Authentication already enabled for ${sso_type}."
    else
      local payload='{"ssoProtection":{"deploymentType":"preview"}}'
      vrc_patch "/v9/projects/${project_id}" "$payload" >/dev/null && \
        log_ok "project" "preview-auth" "Vercel Authentication enabled for preview deployments." || \
        log_fail "project" "preview-auth" "PATCH failed (status ${VRCSEC_LAST_STATUS}). $(vrc_last_error)"
    fi
  fi

  # Recommend deployment-approval flow for production (manual approval before going live).
  log_warn "project" "production-approval" "Configure required approvals for production deploys: Settings → Git → Production deploys (manual or PR-checks). The API exposes this as gitForkProtection only; full approval flow lives in the dashboard." "https://vercel.com/docs/deployments/checks"

  # Trusted IPs (Enterprise).
  if requires_tier "project" "trusted-ips" "Trusted IPs allowlist for production." "enterprise" "https://vercel.com/docs/security/deployment-protection/methods-to-protect-deployments/trusted-ips"; then
    local ti; ti="$(jq -r '.trustedIps // null | tostring' <<<"$cur")"
    if [[ "$ti" != "null" && "$ti" != "" ]]; then
      log_ok "project" "trusted-ips" "Trusted IPs already configured."
    else
      log_warn "project" "trusted-ips" "Configure Trusted IPs in Settings → Deployment Protection → Trusted IPs (Enterprise only)."
    fi
  fi

  return 0
}
