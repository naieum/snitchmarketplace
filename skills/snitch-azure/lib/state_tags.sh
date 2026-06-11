# lib/state_tags.sh — required-tag policy presence + coverage.
# slice ∈ digest (default) | full

run_state_tags() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local resources tag_assignments
  resources="$(az_run_json resource list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, type, tags: (.tags // {})}]' 2>/dev/null || printf '[]')"
  tag_assignments="$(az_run_json policy assignment list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | select((.policyDefinitionId | tostring) | test("tag"; "i")) | {name, displayName, policyDefinitionId, enforcementMode}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    full)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
        --argjson r "$resources" --argjson t "$tag_assignments" \
        '{schema:"azsec.state-tags.full", schema_version:1, generated_at:$ts,
          tool:"state-tags", slice:"full", subscription_id:$sub_id,
          resources:$r, tag_policy_assignments:$t}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson r "$resources" --argjson t "$tag_assignments" \
    '{
      schema: "azsec.state-tags.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-tags",
      slice: "digest",
      subscription_id: $sub_id,
      resources_summary: {
        total: ($r | length),
        untagged: ($r | map(select(((.tags // {}) | length)==0)) | length),
        owner_tag_present: ($r | map(select(((.tags // {}) | keys) | any(. == "owner" or . == "Owner"))) | length),
        env_tag_present: ($r | map(select(((.tags // {}) | keys) | any(. == "environment" or . == "Environment" or . == "env" or . == "Env"))) | length)
      },
      tag_policies_summary: {
        total: ($t | length),
        names: ($t | map(.displayName // .name))
      },
      hint: "for full data, run: state tags full"
    }'
}
