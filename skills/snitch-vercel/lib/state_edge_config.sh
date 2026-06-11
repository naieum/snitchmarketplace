# lib/state_edge_config.sh — Edge Config inventory.
# Exports: run_state_edge_config [project-id]

run_state_edge_config() {
  local project_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local team_id; team_id="$(vercel_pick_team 2>/dev/null || true)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi

  local body; body="$(vrc_get "/v1/edge-config")" || body='{"edgeConfigs":[]}'
  local items
  items="$(jq '[(.edgeConfigs // .items // [])[] | {
    id, slug,
    digest: (.digest // null),
    sizeInBytes: (.sizeInBytes // null),
    itemCount: (.itemCount // null),
    transferred: (.transferred // null),
    createdAt
  }]' <<<"$body" 2>/dev/null || printf '[]')"

  # For each Edge Config, list its tokens (read tokens).
  local tokens_arr='[]'
  local id
  while IFS= read -r id; do
    [[ -z "$id" || "$id" == "null" ]] && continue
    local tbody; tbody="$(vrc_get "/v1/edge-config/${id}/tokens")" || tbody='{"tokens":[]}'
    local trim; trim="$(jq --arg id "$id" '{ edgeConfigId: $id, tokens: [(.tokens // [])[] | { id, label: (.label // null), createdAt }]}' <<<"$tbody" 2>/dev/null)"
    [[ -n "$trim" ]] && tokens_arr="$(jq --argjson t "$trim" '. + [$t]' <<<"$tokens_arr")"
  done < <(jq -r '.[] | .id // empty' <<<"$items")

  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --argjson items "$items" --argjson tokens "$tokens_arr" \
    '{
      schema: "vrcsec.state-edge-config",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-edge-config",
      project_id: $project_id,
      edge_configs: $items,
      tokens: $tokens,
      summary: {
        total: ($items | length),
        total_items: ($items | map(.itemCount // 0) | add // 0),
        total_tokens: ($tokens | map(.tokens | length) | add // 0)
      }
    }'
}
