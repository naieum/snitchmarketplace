# lib/state_functions.sh — serverless + edge function inventory.
# Exports: run_state_functions [project-id]
# Sources:
#   - vercel.json `functions` block (config-time)
#   - /v9/projects/<id> for project-default region & runtime
#   - latest production deployment build output (via /v13/deployments/<uid>)

run_state_functions() {
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
  local default_region; default_region="$(jq -r '.serverlessFunctionRegion // "iad1"' <<<"$proj")"
  local node_version;   node_version="$(jq -r '.nodeVersion // "?"' <<<"$proj")"

  local vjson_functions='{}'
  if [[ -f "vercel.json" ]]; then
    vjson_functions="$(jq '.functions // {}' vercel.json 2>/dev/null || printf '{}')"
  fi

  # Try to grab the most recent production deployment to inspect its functions output.
  local deps; deps="$(vrc_get "/v6/deployments?projectId=${project_id}&target=production&limit=1")" || deps='{"deployments":[]}'
  local dep_uid; dep_uid="$(jq -r '.deployments[0].uid // empty' <<<"$deps")"
  local dep_funcs='[]'
  if [[ -n "$dep_uid" ]]; then
    local dep_full; dep_full="$(vrc_get "/v13/deployments/${dep_uid}")" || dep_full='{}'
    dep_funcs="$(jq '[(.functions // {}) | to_entries[] | { name: .key, runtime: .value.runtime, memory: .value.memory, maxDuration: .value.maxDuration, regions: (.value.regions // null) }]' <<<"$dep_full" 2>/dev/null || printf '[]')"
  fi

  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --arg default_region "$default_region" \
    --arg node_version "$node_version" \
    --argjson config_functions "$vjson_functions" \
    --argjson deployment_functions "$dep_funcs" \
    '{
      schema: "vrcsec.state-functions",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-functions",
      project_id: $project_id,
      project_defaults: {
        serverless_function_region: $default_region,
        node_version: $node_version
      },
      vercel_json_functions: $config_functions,
      latest_production_functions: $deployment_functions,
      summary: {
        config_function_count: ($config_functions | length),
        deployed_function_count: ($deployment_functions | length),
        edge_runtime_count: ($deployment_functions | map(select((.runtime // "") | test("edge"))) | length),
        nodejs_runtime_count: ($deployment_functions | map(select((.runtime // "") | test("nodejs"))) | length)
      }
    }'
}
