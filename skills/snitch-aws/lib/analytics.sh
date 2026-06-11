# lib/analytics.sh — account-level signals: cost top services 30d, regions in use,
# untagged-cost amount, anomaly monitor count.
# Exports: run_analytics [window]

run_analytics() {
  local window="${1:-30d}"
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  local end_d start_d days
  case "$window" in
    7d)  days=7  ;;
    30d) days=30 ;;
    90d) days=90 ;;
    *)   days=30; window="30d" ;;
  esac
  end_d="$(date -u +%Y-%m-%d)"
  if date -v-${days}d +%Y-%m-%d >/dev/null 2>&1; then
    start_d="$(date -v-${days}d -u +%Y-%m-%d)"
  else
    start_d="$(date -d "${days} days ago" -u +%Y-%m-%d 2>/dev/null || echo "$end_d")"
  fi

  local ce
  ce="$(aws_run_json ce get-cost-and-usage \
    --time-period "Start=${start_d},End=${end_d}" \
    --granularity DAILY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE 2>/dev/null | jq '.ResultsByTime // []' 2>/dev/null || printf '[]')"

  local regs
  regs="$(aws_run_json ec2 describe-regions 2>/dev/null | jq '.Regions // []' 2>/dev/null || printf '[]')"

  local monitors
  monitors="$(aws_run_json ce get-anomaly-monitors 2>/dev/null | jq '.AnomalyMonitors // []' 2>/dev/null || printf '[]')"

  jq -n --arg ts "$ts" --arg account "$account" --arg region "$region" \
    --arg window "$window" --arg start_d "$start_d" --arg end_d "$end_d" \
    --argjson ce "$ce" --argjson regs "$regs" --argjson monitors "$monitors" \
    '{
      schema: "awssec.analytics", schema_version: 1, generated_at: $ts,
      tool: "analytics",
      account_id: $account, region: $region,
      window: { window_label: $window, start: $start_d, end: $end_d },
      total_blended: ([($ce[]?.Groups[]?) | (.Metrics.BlendedCost.Amount | tonumber? // 0)] | add // 0),
      top_services: ([($ce[]?.Groups[]?) | {service: .Keys[0], cost: (.Metrics.BlendedCost.Amount | tonumber? // 0)}]
                     | group_by(.service) | map({service: .[0].service, total: ([.[].cost] | add // 0)})
                     | sort_by(-.total) | .[0:10]),
      regions_enabled: ($regs | map(.RegionName)),
      anomaly_monitors_count: ($monitors | length)
    }'
}
