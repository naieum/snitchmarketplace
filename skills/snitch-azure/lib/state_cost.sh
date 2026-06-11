# lib/state_cost.sh — budgets + spend, untagged spend.
# slice ∈ digest (default) | budgets | full

run_state_cost() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local budgets
  budgets="$(az_run_json consumption budget list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {name, amount, timeGrain, currentSpend: (.currentSpend.amount // 0), notifications: ((.notifications // {}) | length)}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    budgets|full)
      local schema_name="azsec.state-cost.${slice}"
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --arg sl "$slice" \
        --arg schema "$schema_name" --argjson b "$budgets" \
        '{schema:$schema, schema_version:1, generated_at:$ts,
          tool:"state-cost", slice:$sl, subscription_id:$sub_id, budgets:$b}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson b "$budgets" \
    '{
      schema: "azsec.state-cost.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-cost",
      slice: "digest",
      subscription_id: $sub_id,
      budgets_summary: {
        total: ($b | length),
        names: ($b | map(.name)),
        no_notifications: ($b | map(select(.notifications==0)) | length),
        over_budget: ($b | map(select(.currentSpend > .amount)) | length)
      },
      hint: "for per-budget data, run: state cost [budgets|full]. Anomaly detection requires Cost Management Reader."
    }'
}
