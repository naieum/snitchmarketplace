# lib/state_storage.sh — Vercel KV / Postgres / Blob bindings.
# Exports: run_state_storage [project-id]

run_state_storage() {
  local project_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
    return 3
  fi

  # Storage stores attached to a team can be listed via /v1/storage/stores; binding via /v9/projects/<id>/integrations
  local team_id; team_id="$(vercel_pick_team 2>/dev/null || true)"
  local stores='[]'
  if [[ -n "$team_id" ]]; then
    local body; body="$(vrc_get "/v1/storage/stores")" || body='{"stores":[]}'
    stores="$(jq '[(.stores // [])[] | {
      id, type, name,
      primaryRegion: (.primaryRegion // null),
      readRegions: (.readRegions // null),
      createdAt
    }]' <<<"$body" 2>/dev/null || printf '[]')"
  fi

  # Project bindings (env-var injection of *_URL, *_REST_URL, etc).
  local envs; envs="$(vrc_get "/v9/projects/${project_id}/env?decrypt=false")" || envs='{"envs":[]}'
  local bindings
  bindings="$(jq '[
    (.envs // [])[] | select(.key | test("^(KV_|POSTGRES_|BLOB_|EDGE_CONFIG)")) | { key, target, type }
  ]' <<<"$envs" 2>/dev/null || printf '[]')"

  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --argjson stores "$stores" --argjson bindings "$bindings" \
    '{
      schema: "vrcsec.state-storage",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-storage",
      project_id: $project_id,
      stores: $stores,
      project_bindings: $bindings,
      summary: {
        stores_total: ($stores | length),
        kv:       ($stores | map(select(.type == "kv")) | length),
        postgres: ($stores | map(select(.type == "postgres")) | length),
        blob:     ($stores | map(select(.type == "blob")) | length),
        binding_keys: ($bindings | map(.key) | unique)
      }
    }'
}
