# lib/state_inspector.sh — Amazon Inspector v2 enablement + finding counts.
# Exports: run_state_inspector [slice]
#   slice ∈ digest (default) | full

run_state_inspector() {
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

  local status counts
  status="$(aws_run_json inspector2 batch-get-account-status --account-ids "$account" 2>/dev/null | jq '.accounts // []' 2>/dev/null || printf '[]')"
  counts="$(aws_run_json inspector2 list-coverage 2>/dev/null | jq '{total: ((.coveredResources // []) | length)}' 2>/dev/null || printf '{}')"

  local schema="awssec.state-inspector.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson status "$status" --argjson counts "$counts" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-inspector", slice: $slice,
      account_id: $account, region: $region,
      account_status: $status,
      coverage_summary: $counts,
      ec2_enabled: ($status | any(.resourceState.ec2.status == "ENABLED")),
      ecr_enabled: ($status | any(.resourceState.ecr.status == "ENABLED")),
      lambda_enabled: ($status | any(.resourceState.lambda.status == "ENABLED")),
      hint: "for full data, run: state inspector full"
    }'
}
