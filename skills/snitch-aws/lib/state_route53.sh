# lib/state_route53.sh — Route 53 hosted zones, DNSSEC, query logging.
# Exports: run_state_route53 [slice]
#   slice ∈ digest (default) | zones | full

run_state_route53() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|zones|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","zones","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local zones detailed='[]'
  zones="$(aws_run_json route53 list-hosted-zones 2>/dev/null | jq '.HostedZones // []' 2>/dev/null || printf '[]')"

  local zids
  zids="$(jq -r '.[].Id' <<<"$zones" 2>/dev/null)"
  while IFS= read -r zid; do
    [[ -z "$zid" ]] && continue
    local zid_short="${zid##*/}"
    local dnssec qlogs
    dnssec="$(aws_run_json route53 get-dnssec --hosted-zone-id "$zid_short" 2>/dev/null | jq '.Status // null' 2>/dev/null || printf 'null')"
    qlogs="$(aws_run_json route53 list-query-logging-configs --hosted-zone-id "$zid_short" 2>/dev/null | jq '.QueryLoggingConfigs // []' 2>/dev/null || printf '[]')"
    detailed="$(jq --arg id "$zid_short" --argjson d "$dnssec" --argjson q "$qlogs" \
      '. + [{id:$id, dnssec:$d, query_logging:$q}]' <<<"$detailed")"
  done <<<"$zids"

  local schema="awssec.state-route53.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson zones "$zones" --argjson detailed "$detailed" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-route53", slice: $slice,
          account_id: $account, region: $region,
          zones_summary: {
            total: ($zones | length),
            private: ($zones | map(select(.Config.PrivateZone == true)) | length),
            public: ($zones | map(select(.Config.PrivateZone != true)) | length),
            with_dnssec_signing: ($detailed | map(select(.dnssec.ServeSignature == "SIGNING")) | length),
            with_query_logging: ($detailed | map(select((.query_logging | length) > 0)) | length)
          },
          hint: "for full data, run: state route53 [zones|full]"
        }'
      ;;
    zones|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson zones "$zones" --argjson detailed "$detailed" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-route53", slice: $slice,
           account_id: $account, region: $region,
           zones: $zones, zones_detail: $detailed }'
      ;;
  esac
}
