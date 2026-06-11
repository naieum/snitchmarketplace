# lib/state_sqs_sns.sh — SQS queues + SNS topics encryption + DLQs.
# Exports: run_state_sqs_sns [slice]
#   slice ∈ digest (default) | sqs | sns | full

run_state_sqs_sns() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|sqs|sns|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","sqs","sns","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local q_urls q_attrs='[]' topics
  q_urls="$(aws_run_json sqs list-queues 2>/dev/null | jq -r '.QueueUrls[]?' 2>/dev/null)"
  while IFS= read -r u; do
    [[ -z "$u" ]] && continue
    local a
    a="$(aws_run_json sqs get-queue-attributes --queue-url "$u" --attribute-names All 2>/dev/null | jq '.Attributes // {}' 2>/dev/null || printf '{}')"
    q_attrs="$(jq --arg u "$u" --argjson a "$a" '. + [{queue_url:$u, attributes:$a}]' <<<"$q_attrs")"
  done <<<"$q_urls"

  topics="$(aws_run_json sns list-topics 2>/dev/null | jq '.Topics // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-sqs-sns.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson q "$q_attrs" --argjson topics "$topics" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-sqs-sns", slice: $slice,
          account_id: $account, region: $region,
          sqs_summary: {
            total: ($q | length),
            with_kms: ($q | map(select((.attributes.KmsMasterKeyId // "") != "")) | length),
            with_dlq: ($q | map(select((.attributes.RedrivePolicy // "") != "")) | length)
          },
          sns_summary: { total: ($topics | length) },
          hint: "for full data, run: state sqs-sns [sqs|sns|full]"
        }'
      ;;
    sqs)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson q "$q_attrs" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-sqs-sns", slice: $slice,
           account_id: $account, region: $region, queues: $q }'
      ;;
    sns)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson topics "$topics" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-sqs-sns", slice: $slice,
           account_id: $account, region: $region, topics: $topics }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson q "$q_attrs" --argjson topics "$topics" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-sqs-sns", slice: $slice,
           account_id: $account, region: $region, queues: $q, topics: $topics }'
      ;;
  esac
}
