# lib/state_eventbridge.sh — EventBridge buses + rules.
# Exports: run_state_eventbridge [slice]
#   slice ∈ digest (default) | full

run_state_eventbridge() {
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

  local buses rules
  buses="$(aws_run_json events list-event-buses 2>/dev/null | jq '.EventBuses // []' 2>/dev/null || printf '[]')"
  rules="$(aws_run_json events list-rules 2>/dev/null | jq '.Rules // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-eventbridge.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson buses "$buses" --argjson rules "$rules" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-eventbridge", slice: $slice,
      account_id: $account, region: $region,
      buses_summary: { total: ($buses | length) },
      rules_summary: {
        total: ($rules | length),
        enabled: ($rules | map(select(.State == "ENABLED")) | length),
        disabled: ($rules | map(select(.State == "DISABLED")) | length)
      },
      buses: (if $slice == "full" then $buses else null end),
      rules: (if $slice == "full" then $rules else null end),
      hint: "for full data, run: state eventbridge full"
    }'
}
