# lib/state_cloudtrail.sh — CloudTrail trails (multi-region, log file integrity, KMS).
# Exports: run_state_cloudtrail [slice]
#   slice ∈ digest (default) | trails | full

run_state_cloudtrail() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|trails|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","trails","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local trails statuses='[]'
  trails="$(aws_run_json cloudtrail describe-trails 2>/dev/null | jq '.trailList // []' 2>/dev/null || printf '[]')"
  local arns
  arns="$(jq -r '.[].TrailARN' <<<"$trails" 2>/dev/null)"
  while IFS= read -r a; do
    [[ -z "$a" ]] && continue
    local s
    s="$(aws_run_json cloudtrail get-trail-status --name "$a" 2>/dev/null)"
    statuses="$(jq --arg arn "$a" --argjson s "$s" '. + [{trail:$arn, status:$s}]' <<<"$statuses")"
  done <<<"$arns"

  local schema="awssec.state-cloudtrail.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson trails "$trails" --argjson statuses "$statuses" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-cloudtrail", slice: $slice,
          account_id: $account, region: $region,
          trails_summary: {
            total: ($trails | length),
            multi_region: ($trails | map(select(.IsMultiRegionTrail == true)) | length),
            organization_trail: ($trails | map(select(.IsOrganizationTrail == true)) | length),
            log_file_validation: ($trails | map(select(.LogFileValidationEnabled == true)) | length),
            with_kms_key: ($trails | map(select(.KmsKeyId != null)) | length),
            with_cloudwatch_logs: ($trails | map(select(.CloudWatchLogsLogGroupArn != null)) | length),
            actively_logging: ($statuses | map(select(.status.IsLogging == true)) | length)
          },
          hint: "for full data, run: state cloudtrail [trails|full]"
        }'
      ;;
    trails|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson trails "$trails" --argjson statuses "$statuses" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-cloudtrail", slice: $slice,
           account_id: $account, region: $region,
           trails: $trails, statuses: $statuses }'
      ;;
  esac
}
