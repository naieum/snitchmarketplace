# lib/state_cost.sh — Cost Explorer last 30d, budgets, anomaly monitors.
# Exports: run_state_cost [slice]
#   slice ∈ digest (default) | full

run_state_cost() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local end_d start_d
  end_d="$(date -u +%Y-%m-%d)"
  if date -v-30d +%Y-%m-%d >/dev/null 2>&1; then
    start_d="$(date -v-30d -u +%Y-%m-%d)"
  else
    start_d="$(date -d '30 days ago' -u +%Y-%m-%d 2>/dev/null || echo "$end_d")"
  fi

  local ce budgets monitors
  ce="$(aws_run_json ce get-cost-and-usage \
    --time-period "Start=${start_d},End=${end_d}" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE 2>/dev/null | jq '.ResultsByTime // []' 2>/dev/null || printf '[]')"
  budgets="$(aws_run_json budgets describe-budgets --account-id "$account" 2>/dev/null | jq '.Budgets // []' 2>/dev/null || printf '[]')"
  monitors="$(aws_run_json ce get-anomaly-monitors 2>/dev/null | jq '.AnomalyMonitors // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-cost.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --arg start_d "$start_d" --arg end_d "$end_d" \
    --argjson ce "$ce" --argjson budgets "$budgets" --argjson monitors "$monitors" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-cost", slice: $slice,
      account_id: $account, region: $region,
      window: { start: $start_d, end: $end_d },
      top_services_30d: ([($ce[]?.Groups[]?) | {service: .Keys[0], cost: (.Metrics.BlendedCost.Amount | tonumber? // 0)}] | sort_by(-.cost) | .[0:10]),
      total_30d_blended: ([($ce[]?.Groups[]?) | (.Metrics.BlendedCost.Amount | tonumber? // 0)] | add // 0),
      budgets_summary: {
        total: ($budgets | length),
        names: ($budgets | map(.BudgetName))
      },
      anomaly_monitors_count: ($monitors | length),
      details: (if $slice == "full" then {ce: $ce, budgets: $budgets, monitors: $monitors} else null end),
      hint: "for full data, run: state cost full"
    }'
}
