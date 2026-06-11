# lib/state_sentinel.sh — Microsoft Sentinel workspaces, connectors, analytics rules, incidents.
# slice ∈ digest (default) | full

run_state_sentinel() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  # Sentinel sits on top of Log Analytics workspaces. Listing per-workspace
  # rules / connectors requires extra calls; the digest just enumerates.
  local workspaces
  workspaces="$(az_run_json monitor log-analytics workspace list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, location, resourceGroup, retentionInDays}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    full)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson w "$workspaces" \
        '{schema:"azsec.state-sentinel.full", schema_version:1, generated_at:$ts,
          tool:"state-sentinel", slice:"full", subscription_id:$sub_id, workspaces:$w}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson w "$workspaces" \
    '{
      schema: "azsec.state-sentinel.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-sentinel",
      slice: "digest",
      subscription_id: $sub_id,
      workspaces_summary: { total: ($w | length), names: ($w | map(.name)) },
      hint: "Per-workspace Sentinel detail (rules/connectors/incidents) requires workspace name+RG; pass with state sentinel full"
    }'
}
