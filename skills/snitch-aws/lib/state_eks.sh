# lib/state_eks.sh — EKS clusters posture (control plane logging, version, endpoints).
# Exports: run_state_eks [slice]
#   slice ∈ digest (default) | clusters | full

run_state_eks() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|clusters|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","clusters","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local names details='[]'
  names="$(aws_run_json eks list-clusters 2>/dev/null | jq -r '.clusters[]?' 2>/dev/null)"
  while IFS= read -r c; do
    [[ -z "$c" ]] && continue
    local d
    d="$(aws_run_json eks describe-cluster --name "$c" 2>/dev/null | jq '.cluster // {}' 2>/dev/null || printf '{}')"
    details="$(jq --argjson d "$d" '. + [$d]' <<<"$details")"
  done <<<"$names"

  local schema="awssec.state-eks.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson details "$details" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-eks", slice: $slice,
          account_id: $account, region: $region,
          clusters_summary: {
            total: ($details | length),
            public_endpoint: ($details | map(select(.resourcesVpcConfig.endpointPublicAccess == true)) | length),
            private_endpoint_only: ($details | map(select(.resourcesVpcConfig.endpointPublicAccess != true and .resourcesVpcConfig.endpointPrivateAccess == true)) | length),
            with_secrets_encryption: ($details | map(select((.encryptionConfig // []) | length > 0)) | length),
            full_logging: ($details | map(select(((.logging.clusterLogging // []) | map(select(.enabled == true)) | map(.types) | flatten | length) >= 5)) | length),
            no_logging: ($details | map(select(((.logging.clusterLogging // []) | map(select(.enabled == true)) | length) == 0)) | length)
          },
          hint: "for full data, run: state eks [clusters|full]"
        }'
      ;;
    clusters|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson details "$details" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-eks", slice: $slice,
           account_id: $account, region: $region, clusters: $details }'
      ;;
  esac
}
