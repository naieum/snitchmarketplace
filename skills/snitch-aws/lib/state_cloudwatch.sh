# lib/state_cloudwatch.sh — CloudWatch log groups, metric filters, alarms.
# Exports: run_state_cloudwatch [slice]
#   slice ∈ digest (default) | log-groups | alarms | full

run_state_cloudwatch() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|log-groups|alarms|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","log-groups","alarms","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local lgs alarms
  lgs="$(aws_run_json logs describe-log-groups 2>/dev/null | jq '.logGroups // []' 2>/dev/null || printf '[]')"
  alarms="$(aws_run_json cloudwatch describe-alarms 2>/dev/null | jq '.MetricAlarms // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-cloudwatch.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson lgs "$lgs" --argjson alarms "$alarms" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-cloudwatch", slice: $slice,
          account_id: $account, region: $region,
          log_groups_summary: {
            total: ($lgs | length),
            never_expires: ($lgs | map(select(.retentionInDays == null)) | length),
            short_retention_lt_30: ($lgs | map(select(.retentionInDays != null and .retentionInDays < 30)) | length),
            with_kms_encryption: ($lgs | map(select(.kmsKeyId != null)) | length)
          },
          alarms_summary: {
            total: ($alarms | length),
            in_alarm: ($alarms | map(select(.StateValue == "ALARM")) | length),
            insufficient_data: ($alarms | map(select(.StateValue == "INSUFFICIENT_DATA")) | length),
            no_actions: ($alarms | map(select((.AlarmActions // []) | length == 0)) | length)
          },
          hint: "for full data, run: state cloudwatch [log-groups|alarms|full]"
        }'
      ;;
    log-groups)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson lgs "$lgs" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-cloudwatch", slice: $slice,
           account_id: $account, region: $region, log_groups: $lgs }'
      ;;
    alarms)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson alarms "$alarms" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-cloudwatch", slice: $slice,
           account_id: $account, region: $region, alarms: $alarms }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson lgs "$lgs" --argjson alarms "$alarms" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-cloudwatch", slice: $slice,
           account_id: $account, region: $region,
           log_groups: $lgs, alarms: $alarms }'
      ;;
  esac
}
