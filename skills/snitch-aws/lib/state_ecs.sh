# lib/state_ecs.sh — ECS clusters, services, tasks (Fargate posture).
# Exports: run_state_ecs [slice]
#   slice ∈ digest (default) | clusters | services | full

run_state_ecs() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|clusters|services|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","clusters","services","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local clusters_arns clusters='[]'
  clusters_arns="$(aws_run_json ecs list-clusters 2>/dev/null | jq -r '.clusterArns[]?' 2>/dev/null)"
  if [[ -n "$clusters_arns" ]]; then
    local arr
    arr="$(printf '%s\n' "$clusters_arns" | jq -R . | jq -s . )"
    clusters="$(aws_run_json ecs describe-clusters --clusters $clusters_arns --include SETTINGS CONFIGURATIONS 2>/dev/null | jq '.clusters // []' 2>/dev/null || printf '[]')"
    : "$arr" # quiet -u
  fi

  local schema="awssec.state-ecs.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson clusters "$clusters" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-ecs", slice: $slice,
          account_id: $account, region: $region,
          clusters_summary: {
            total: ($clusters | length),
            with_container_insights: ($clusters | map(select((.settings // []) | any(.name == "containerInsights" and .value == "enabled"))) | length),
            running_tasks: ($clusters | map(.runningTasksCount // 0) | add // 0),
            active_services: ($clusters | map(.activeServicesCount // 0) | add // 0)
          },
          hint: "for full data, run: state ecs [clusters|services|full]"
        }'
      ;;
    clusters|services|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson clusters "$clusters" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-ecs", slice: $slice,
           account_id: $account, region: $region, clusters: $clusters }'
      ;;
  esac
}
