# lib/state_analytics.sh — Web Analytics + Speed Insights status.
# Exports: run_state_analytics [project-id]
# Vercel exposes analytics enablement on the project meta + via integrations API.

run_state_analytics() {
  local project_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
    return 3
  fi

  local proj; proj="$(vrc_get "/v9/projects/${project_id}")" || proj='{}'
  local web_analytics speed_insights
  web_analytics="$(jq '{ enabled: (.analytics.enabled // .webAnalytics.enabled // null), id: (.analytics.id // null) }' <<<"$proj" 2>/dev/null || printf '{}')"
  speed_insights="$(jq '{ enabled: (.speedInsights.enabled // null), id: (.speedInsights.id // null) }' <<<"$proj" 2>/dev/null || printf '{}')"

  # Detect package presence in cwd.
  local pkg_web=false pkg_speed=false
  if [[ -f "package.json" ]]; then
    grep -E -q '"@vercel/analytics"' package.json 2>/dev/null && pkg_web=true
    grep -E -q '"@vercel/speed-insights"' package.json 2>/dev/null && pkg_speed=true
  fi

  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --argjson web "$web_analytics" --argjson speed "$speed_insights" \
    --argjson pkg_web "$pkg_web" --argjson pkg_speed "$pkg_speed" \
    '{
      schema: "vrcsec.state-analytics",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-analytics",
      project_id: $project_id,
      web_analytics: $web,
      speed_insights: $speed,
      cwd_packages: {
        "@vercel/analytics": $pkg_web,
        "@vercel/speed-insights": $pkg_speed
      }
    }'
}
