# lib/state_deployments.sh — recent deployments + production-deploy gate.
# Exports: run_state_deployments [project-id] [window]
#   window ∈ 24h (default) | 7d | 30d

run_state_deployments() {
  local project_id="${1:-}" window="${2:-24h}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
    return 3
  fi

  local since now seconds_back
  case "$window" in
    24h) seconds_back=86400 ;;
    7d)  seconds_back=604800 ;;
    30d) seconds_back=2592000 ;;
    *)
      printf '{"error":"unknown window","code":"E_USAGE","got":"%s","valid":["24h","7d","30d"]}\n' "$window" >&2
      return 2 ;;
  esac
  now=$(date +%s)
  since=$(( (now - seconds_back) * 1000 ))

  local body; body="$(vrc_get "/v6/deployments?projectId=${project_id}&since=${since}&limit=100")" || {
    printf '{"error":"failed to list deployments","code":"E_API","status":%s,"project_id":"%s"}\n' "${VRCSEC_LAST_STATUS:-0}" "$project_id" >&2
    return 3
  }
  local deployments
  deployments="$(jq '[(.deployments // [])[] | {
    uid, name, url,
    target: (.target // null),
    state: (.state // .readyState // null),
    creator: (.creator.username // .creator.email // null),
    meta: (.meta // {}),
    inspectorUrl: (.inspectorUrl // null),
    created
  }]' <<<"$body" 2>/dev/null || printf '[]')"

  jq -n --arg ts "$ts" --arg project_id "$project_id" --arg window "$window" \
    --argjson d "$deployments" \
    '{
      schema: "vrcsec.state-deployments",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-deployments",
      project_id: $project_id,
      window: $window,
      summary: {
        total: ($d | length),
        production: ($d | map(select(.target == "production")) | length),
        preview: ($d | map(select(.target == "preview" or .target == null)) | length),
        ready: ($d | map(select(.state == "READY")) | length),
        error: ($d | map(select(.state == "ERROR")) | length),
        canceled: ($d | map(select(.state == "CANCELED")) | length)
      },
      deployments: $d
    }'
}
