# lib/state_wafv2.sh — WAFv2 web ACLs (CLOUDFRONT + REGIONAL).
# Exports: run_state_wafv2 [slice]
#   slice ∈ digest (default) | acls | full

run_state_wafv2() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|acls|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","acls","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local cloudfront_acls regional_acls
  cloudfront_acls="$(aws_run_json wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 2>/dev/null | jq '.WebACLs // []' 2>/dev/null || printf '[]')"
  regional_acls="$(aws_run_json wafv2 list-web-acls --scope REGIONAL 2>/dev/null | jq '.WebACLs // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-wafv2.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson cf "$cloudfront_acls" --argjson rg "$regional_acls" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-wafv2", slice: $slice,
          account_id: $account, region: $region,
          web_acls_summary: {
            cloudfront_total: ($cf | length),
            regional_total: ($rg | length)
          },
          hint: "for full data, run: state wafv2 [acls|full]"
        }'
      ;;
    acls|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson cf "$cloudfront_acls" --argjson rg "$regional_acls" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-wafv2", slice: $slice,
           account_id: $account, region: $region,
           cloudfront_web_acls: $cf, regional_web_acls: $rg }'
      ;;
  esac
}
