# lib/state_domains.sh — project domains + TLS posture.
# Exports: run_state_domains [project-id]

run_state_domains() {
  local project_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    printf '{"error":"could not resolve project id","code":"E_PROJECT","remediation":"set VRCSEC_PROJECT_ID or pass project-id"}\n' >&2
    return 3
  fi
  local body; body="$(vrc_get "/v9/projects/${project_id}/domains")" || {
    printf '{"error":"failed to list project domains","code":"E_API","status":%s,"project_id":"%s"}\n' "${VRCSEC_LAST_STATUS:-0}" "$project_id" >&2
    return 3
  }
  local domains
  domains="$(jq '[(.domains // [])[] | {
    name,
    apexName: (.apexName // null),
    projectId: (.projectId // null),
    redirect: (.redirect // null),
    redirectStatusCode: (.redirectStatusCode // null),
    gitBranch: (.gitBranch // null),
    verified: (.verified // null),
    verification: (.verification // []),
    createdAt
  }]' <<<"$body" 2>/dev/null || printf '[]')"

  # For each verified domain, fetch /v6/domains/<name>/config to check nameservers + TLS owner.
  local config_arr='[]'
  local d
  while IFS= read -r d; do
    [[ -z "$d" || "$d" == "null" ]] && continue
    local cfg
    cfg="$(vrc_get "/v6/domains/${d}/config")" || cfg='{}'
    config_arr="$(jq --arg d "$d" --argjson c "$cfg" '. + [{ name: $d, config: $c }]' <<<"$config_arr")"
  done < <(jq -r '.[] | .name // empty' <<<"$domains")

  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --argjson domains "$domains" --argjson configs "$config_arr" \
    '{
      schema: "vrcsec.state-domains",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-domains",
      project_id: $project_id,
      summary: {
        total: ($domains | length),
        verified: ($domains | map(select(.verified == true)) | length),
        with_redirects: ($domains | map(select(.redirect != null)) | length)
      },
      domains: $domains,
      configs: $configs
    }'
}
