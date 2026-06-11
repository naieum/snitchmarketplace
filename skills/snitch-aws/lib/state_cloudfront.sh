# lib/state_cloudfront.sh — CloudFront distributions posture.
# Exports: run_state_cloudfront [slice]
#   slice ∈ digest (default) | distributions | full

run_state_cloudfront() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|distributions|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","distributions","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local dists
  dists="$(aws_run_json cloudfront list-distributions 2>/dev/null | jq '.DistributionList.Items // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-cloudfront.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson dists "$dists" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-cloudfront", slice: $slice,
          account_id: $account, region: $region,
          distributions_summary: {
            total: ($dists | length),
            enabled: ($dists | map(select(.Enabled == true)) | length),
            with_waf: ($dists | map(select(.WebACLId != null and .WebACLId != "")) | length),
            redirect_to_https: ($dists | map(select(.DefaultCacheBehavior.ViewerProtocolPolicy == "redirect-to-https" or .DefaultCacheBehavior.ViewerProtocolPolicy == "https-only")) | length),
            old_tls: ($dists | map(select(.ViewerCertificate.MinimumProtocolVersion // "" | test("TLSv1[.0-1]?$"))) | length),
            ipv6_enabled: ($dists | map(select(.IsIPv6Enabled == true)) | length)
          },
          hint: "for full data, run: state cloudfront [distributions|full]"
        }'
      ;;
    distributions|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson dists "$dists" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-cloudfront", slice: $slice,
           account_id: $account, region: $region, distributions: $dists }'
      ;;
  esac
}
