# lib/state_s3.sh — S3 state (buckets, public access blocks, encryption, versioning).
# Exports: run_state_s3 [slice]
#   slice ∈ digest (default) | buckets | full

run_state_s3() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|buckets|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","buckets","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local buckets account_pab
  buckets="$(aws_run_json s3api list-buckets 2>/dev/null | jq '.Buckets // []' 2>/dev/null || printf '[]')"
  account_pab="$(aws_run_json s3control get-public-access-block --account-id "$account" 2>/dev/null | jq '.PublicAccessBlockConfiguration // null' 2>/dev/null || printf 'null')"

  # For digest + buckets/full, fetch per-bucket details (capped at 50 for digest, all otherwise).
  local cap=50
  [[ "$slice" == "buckets" || "$slice" == "full" ]] && cap=10000

  local detailed='[]'
  local names
  names="$(jq -r '.[].Name' <<<"$buckets" 2>/dev/null | head -n "$cap")"
  while IFS= read -r b; do
    [[ -z "$b" ]] && continue
    local pab pol enc ver log obj_lock
    pab="$(aws_run_json s3api get-public-access-block --bucket "$b" 2>/dev/null | jq '.PublicAccessBlockConfiguration // null' 2>/dev/null || printf 'null')"
    pol="$(aws_run_json s3api get-bucket-policy --bucket "$b" 2>/dev/null | jq '.Policy // null' 2>/dev/null || printf 'null')"
    enc="$(aws_run_json s3api get-bucket-encryption --bucket "$b" 2>/dev/null | jq '.ServerSideEncryptionConfiguration // null' 2>/dev/null || printf 'null')"
    ver="$(aws_run_json s3api get-bucket-versioning --bucket "$b" 2>/dev/null | jq '{Status: (.Status // null), MFADelete: (.MFADelete // null)}' 2>/dev/null || printf '{}')"
    log="$(aws_run_json s3api get-bucket-logging --bucket "$b" 2>/dev/null | jq '.LoggingEnabled // null' 2>/dev/null || printf 'null')"
    obj_lock="$(aws_run_json s3api get-object-lock-configuration --bucket "$b" 2>/dev/null | jq '.ObjectLockConfiguration // null' 2>/dev/null || printf 'null')"
    detailed="$(jq --arg b "$b" \
      --argjson pab "$pab" --argjson enc "$enc" --argjson ver "$ver" \
      --argjson log "$log" --argjson lk "$obj_lock" \
      '. + [{name:$b, public_access_block:$pab, encryption:$enc, versioning:$ver, logging:$log, object_lock:$lk}]' \
      <<<"$detailed")"
  done <<<"$names"

  local schema="awssec.state-s3.${slice}"

  case "$slice" in
    digest)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson buckets "$buckets" --argjson detailed "$detailed" \
        --argjson account_pab "$account_pab" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-s3", slice: $slice,
          account_id: $account, region: $region,
          buckets_total: ($buckets | length),
          account_public_access_block: $account_pab,
          buckets_summary: {
            with_full_pab: ($detailed | map(select(.public_access_block.BlockPublicAcls == true and .public_access_block.IgnorePublicAcls == true and .public_access_block.BlockPublicPolicy == true and .public_access_block.RestrictPublicBuckets == true)) | length),
            without_pab: ($detailed | map(select(.public_access_block == null)) | length),
            with_default_encryption: ($detailed | map(select(.encryption != null)) | length),
            with_versioning: ($detailed | map(select(.versioning.Status == "Enabled")) | length),
            with_mfa_delete: ($detailed | map(select(.versioning.MFADelete == "Enabled")) | length),
            with_access_logging: ($detailed | map(select(.logging != null)) | length),
            with_object_lock: ($detailed | map(select(.object_lock != null)) | length)
          },
          first_50_detail: $detailed,
          hint: "for full data, run: state s3 [buckets|full]"
        }'
      ;;
    buckets|full)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson buckets "$buckets" --argjson detailed "$detailed" \
        --argjson account_pab "$account_pab" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-s3", slice: $slice,
           account_id: $account, region: $region,
           buckets: $buckets, account_public_access_block: $account_pab,
           buckets_detail: $detailed }'
      ;;
  esac
}
