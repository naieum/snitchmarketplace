# lib/state_protection.sh — deployment protection inventory.
# Exports: run_state_protection [project-id]
# Pulls from /v9/projects/<id> and reports on:
#   - SSO / Vercel Authentication
#   - Password protection
#   - Trusted IPs
#   - Deployment expiration

run_state_protection() {
  local project_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
    return 3
  fi
  local body; body="$(vrc_get "/v9/projects/${project_id}")" || {
    printf '{"error":"failed to fetch project","code":"E_API","status":%s}\n' "${VRCSEC_LAST_STATUS:-0}" >&2
    return 3
  }
  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --argjson p "$body" \
    '{
      schema: "vrcsec.state-protection",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-protection",
      project_id: $project_id,
      sso_protection: ($p.ssoProtection // null),
      password_protection: ($p.passwordProtection // null),
      trusted_ips: ($p.trustedIps // null),
      deployment_expiration: ($p.deploymentExpiration // null),
      git_fork_protection: ($p.gitForkProtection // null),
      summary: {
        any_protection_enabled:
          (($p.ssoProtection // null) != null
           or ($p.passwordProtection // null) != null
           or ($p.trustedIps // null) != null),
        production_only_protections: (
          [($p.ssoProtection.deploymentType // null),
           ($p.passwordProtection.deploymentType // null)]
          | map(select(. != null))
        )
      },
      hint: "Pro+: Vercel Authentication for previews; Enterprise: trusted IPs + SAML SSO."
    }'
}
