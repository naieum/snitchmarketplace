# lib/state_log_drains.sh — log-drain destinations (Pro+).
# Exports: run_state_log_drains [team-id]

run_state_log_drains() {
  local team_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$team_id" ]]; then
    team_id="$(vercel_pick_team 2>/dev/null || true)"
  fi
  if [[ -z "$team_id" ]]; then
    printf '{"error":"could not resolve team id","code":"E_TEAM","remediation":"set VRCSEC_TEAM_ID or pass team-id"}\n' >&2
    return 3
  fi

  # Plan-tier check first.
  local tier; tier="$(detect_plan "$team_id")"
  if ! tier_at_least "$tier" "pro"; then
    jq -n --arg ts "$ts" --arg team_id "$team_id" --arg tier "$tier" \
      '{
        schema: "vrcsec.state-log-drains",
        schema_version: 1,
        generated_at: $ts,
        tool: "state-log-drains",
        team_id: $team_id,
        locked: "pro",
        plan: $tier,
        drains: []
      }'
    return 0
  fi

  local body; body="$(vrc_get "/v1/integrations/log-drains")" || body='{"drains":[]}'
  local drains
  drains="$(jq '[(.drains // [])[] | {
    id, name, url, headers,
    deliveryFormat: (.deliveryFormat // null),
    sources: (.sources // []),
    environment: (.environment // null),
    createdAt
  }]' <<<"$body" 2>/dev/null || printf '[]')"

  jq -n --arg ts "$ts" --arg team_id "$team_id" --argjson drains "$drains" \
    '{
      schema: "vrcsec.state-log-drains",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-log-drains",
      team_id: $team_id,
      drains: $drains,
      summary: {
        total: ($drains | length),
        environments: ($drains | map(.environment) | unique)
      }
    }'
}
