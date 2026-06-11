# lib/state_rds.sh — RDS / Aurora instances + clusters posture.
# Exports: run_state_rds [slice]
#   slice ∈ digest (default) | instances | clusters | full

run_state_rds() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|instances|clusters|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","instances","clusters","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local instances clusters
  instances="$(aws_run_json rds describe-db-instances 2>/dev/null | jq '.DBInstances // []' 2>/dev/null || printf '[]')"
  clusters="$(aws_run_json rds describe-db-clusters 2>/dev/null | jq '.DBClusters // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-rds.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson instances "$instances" --argjson clusters "$clusters" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-rds", slice: $slice,
          account_id: $account, region: $region,
          instances_summary: {
            total: ($instances | length),
            encrypted: ($instances | map(select(.StorageEncrypted == true)) | length),
            unencrypted: ($instances | map(select(.StorageEncrypted != true)) | length),
            publicly_accessible: ($instances | map(select(.PubliclyAccessible == true)) | length),
            iam_auth_enabled: ($instances | map(select(.IAMDatabaseAuthenticationEnabled == true)) | length),
            deletion_protection: ($instances | map(select(.DeletionProtection == true)) | length),
            backup_retention_zero: ($instances | map(select((.BackupRetentionPeriod // 0) == 0)) | length),
            performance_insights: ($instances | map(select(.PerformanceInsightsEnabled == true)) | length),
            engine_breakdown: ($instances | group_by(.Engine // "unknown") | map({key: (.[0].Engine // "unknown"), value: length}) | from_entries)
          },
          clusters_summary: {
            total: ($clusters | length),
            encrypted: ($clusters | map(select(.StorageEncrypted == true)) | length),
            iam_auth_enabled: ($clusters | map(select(.IAMDatabaseAuthenticationEnabled == true)) | length),
            deletion_protection: ($clusters | map(select(.DeletionProtection == true)) | length)
          },
          hint: "for full data, run: state rds [instances|clusters|full]"
        }'
      ;;
    instances)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson instances "$instances" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-rds", slice: $slice,
           account_id: $account, region: $region, instances: $instances }'
      ;;
    clusters)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson clusters "$clusters" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-rds", slice: $slice,
           account_id: $account, region: $region, clusters: $clusters }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson instances "$instances" --argjson clusters "$clusters" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-rds", slice: $slice,
           account_id: $account, region: $region,
           instances: $instances, clusters: $clusters }'
      ;;
  esac
}
