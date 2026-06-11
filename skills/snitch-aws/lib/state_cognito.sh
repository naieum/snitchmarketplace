# lib/state_cognito.sh — Cognito user pools posture.
# Exports: run_state_cognito [slice]
#   slice ∈ digest (default) | pools | full

run_state_cognito() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|pools|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","pools","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local pools detailed='[]'
  pools="$(aws_run_json cognito-idp list-user-pools --max-results 60 2>/dev/null | jq '.UserPools // []' 2>/dev/null || printf '[]')"
  local pids
  pids="$(jq -r '.[].Id' <<<"$pools" 2>/dev/null)"
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    local d
    d="$(aws_run_json cognito-idp describe-user-pool --user-pool-id "$p" 2>/dev/null | jq '.UserPool // {}' 2>/dev/null || printf '{}')"
    detailed="$(jq --argjson d "$d" '. + [$d]' <<<"$detailed")"
  done <<<"$pids"

  local schema="awssec.state-cognito.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson detailed "$detailed" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-cognito", slice: $slice,
          account_id: $account, region: $region,
          user_pools_summary: {
            total: ($detailed | length),
            mfa_enabled: ($detailed | map(select(.MfaConfiguration == "ON" or .MfaConfiguration == "OPTIONAL")) | length),
            mfa_required: ($detailed | map(select(.MfaConfiguration == "ON")) | length),
            with_advanced_security: ($detailed | map(select(.UserPoolAddOns.AdvancedSecurityMode == "ENFORCED" or .UserPoolAddOns.AdvancedSecurityMode == "AUDIT")) | length),
            with_deletion_protection: ($detailed | map(select(.DeletionProtection == "ACTIVE")) | length)
          },
          hint: "for full data, run: state cognito [pools|full]"
        }'
      ;;
    pools|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson detailed "$detailed" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-cognito", slice: $slice,
           account_id: $account, region: $region, user_pools: $detailed }'
      ;;
  esac
}
