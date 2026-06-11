# lib/state_dynamodb.sh — DynamoDB tables (encryption, PITR, deletion protection).
# Exports: run_state_dynamodb [slice]
#   slice ∈ digest (default) | tables | full

run_state_dynamodb() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|tables|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","tables","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local table_names detailed='[]'
  table_names="$(aws_run_json dynamodb list-tables 2>/dev/null | jq -r '.TableNames[]?' 2>/dev/null)"
  while IFS= read -r t; do
    [[ -z "$t" ]] && continue
    local desc cont pitr
    desc="$(aws_run_json dynamodb describe-table --table-name "$t" 2>/dev/null | jq '.Table // {}' 2>/dev/null || printf '{}')"
    cont="$(aws_run_json dynamodb describe-continuous-backups --table-name "$t" 2>/dev/null | jq '.ContinuousBackupsDescription // {}' 2>/dev/null || printf '{}')"
    detailed="$(jq --arg t "$t" --argjson d "$desc" --argjson c "$cont" \
      '. + [{name:$t, table:$d, continuous_backups:$c}]' <<<"$detailed")"
  done <<<"$table_names"

  local schema="awssec.state-dynamodb.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson detailed "$detailed" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-dynamodb", slice: $slice,
          account_id: $account, region: $region,
          tables_summary: {
            total: ($detailed | length),
            with_pitr: ($detailed | map(select(.continuous_backups.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus == "ENABLED")) | length),
            with_kms_encryption: ($detailed | map(select(.table.SSEDescription.SSEType == "KMS")) | length),
            with_deletion_protection: ($detailed | map(select(.table.DeletionProtectionEnabled == true)) | length)
          },
          hint: "for full data, run: state dynamodb [tables|full]"
        }'
      ;;
    tables|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson detailed "$detailed" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-dynamodb", slice: $slice,
           account_id: $account, region: $region,
           tables: $detailed }'
      ;;
  esac
}
