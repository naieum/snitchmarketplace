# lib/export.sh — JSON snapshot of project + team to cwd.
# Exports: run_export

run_export() {
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local out="snitch-vercel-export-${ts}.json"

  local project_id team_id
  project_id="$(vercel_pick_project 2>/dev/null || true)"
  team_id="$(vercel_pick_team 2>/dev/null || true)"

  local project='{}' team='{}' env_meta='[]' domains='{}' protection='{}'
  if [[ -n "$project_id" ]]; then
    project="$(vrc_get "/v9/projects/${project_id}" 2>/dev/null || printf '{}')"
    env_meta="$(vrc_get "/v9/projects/${project_id}/env?decrypt=false" 2>/dev/null | jq '.envs // []' 2>/dev/null || printf '[]')"
    domains="$(vrc_get "/v9/projects/${project_id}/domains" 2>/dev/null || printf '{}')"
    protection="$(jq '{ ssoProtection, passwordProtection, trustedIps, deploymentExpiration, gitForkProtection }' <<<"$project" 2>/dev/null || printf '{}')"
  fi
  if [[ -n "$team_id" ]]; then
    team="$(vrc_get "/v2/teams/${team_id}" 2>/dev/null || printf '{}')"
  fi

  jq -n --arg ts "$ts" \
    --arg project_id "$project_id" --arg team_id "$team_id" \
    --argjson project "$project" --argjson team "$team" \
    --argjson envs "$env_meta" --argjson domains "$domains" \
    --argjson protection "$protection" \
    '{
      schema: "vrcsec.export",
      schema_version: 1,
      generated_at: $ts,
      project_id: $project_id,
      team_id: $team_id,
      project: $project,
      team: $team,
      envs: $envs,
      domains: $domains,
      protection: $protection
    }' > "$out"
  log_ok "export" "wrote" "Snapshot written → ${out}"
}
