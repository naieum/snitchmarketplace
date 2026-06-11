# lib/state_securityhub.sh — Security Hub enablement + standards.
# Exports: run_state_securityhub [slice]
#   slice ∈ digest (default) | full

run_state_securityhub() {
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

  local standards hub_status
  hub_status="$(aws_run_json securityhub describe-hub 2>/dev/null)"
  standards="$(aws_run_json securityhub get-enabled-standards 2>/dev/null | jq '.StandardsSubscriptions // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-securityhub.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson hub "$hub_status" --argjson standards "$standards" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-securityhub", slice: $slice,
      account_id: $account, region: $region,
      enabled: (($hub.HubArn // "") != ""),
      hub: $hub,
      standards_summary: {
        total: ($standards | length),
        ready: ($standards | map(select(.StandardsStatus == "READY")) | length),
        names: ($standards | map(.StandardsArn))
      },
      standards: (if $slice == "full" then $standards else null end),
      hint: "for full data, run: state securityhub full"
    }'
}
