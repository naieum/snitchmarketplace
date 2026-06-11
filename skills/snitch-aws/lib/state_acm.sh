# lib/state_acm.sh — ACM certificates, validation status, expiry.
# Exports: run_state_acm [slice]
#   slice ∈ digest (default) | certificates | full

run_state_acm() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|certificates|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","certificates","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local certs detailed='[]'
  certs="$(aws_run_json acm list-certificates 2>/dev/null | jq '.CertificateSummaryList // []' 2>/dev/null || printf '[]')"
  local arns
  arns="$(jq -r '.[].CertificateArn' <<<"$certs" 2>/dev/null)"
  while IFS= read -r a; do
    [[ -z "$a" ]] && continue
    local d
    d="$(aws_run_json acm describe-certificate --certificate-arn "$a" 2>/dev/null | jq '.Certificate // {}' 2>/dev/null || printf '{}')"
    detailed="$(jq --argjson c "$d" '. + [$c]' <<<"$detailed")"
  done <<<"$arns"

  local schema="awssec.state-acm.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson detailed "$detailed" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-acm", slice: $slice,
          account_id: $account, region: $region,
          certificates_summary: {
            total: ($detailed | length),
            issued: ($detailed | map(select(.Status == "ISSUED")) | length),
            pending_validation: ($detailed | map(select(.Status == "PENDING_VALIDATION")) | length),
            failed: ($detailed | map(select(.Status == "FAILED")) | length),
            in_use: ($detailed | map(select((.InUseBy // []) | length > 0)) | length)
          },
          hint: "for full data, run: state acm [certificates|full]"
        }'
      ;;
    certificates|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson detailed "$detailed" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-acm", slice: $slice,
           account_id: $account, region: $region, certificates: $detailed }'
      ;;
  esac
}
