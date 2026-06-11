# lib/audit_dns.sh — DNS settings + DNS analytics for a zone, as JSON (read-only).
# Exports: run_audit_dns [zone-id] [window]
#   window ∈ 1h | 24h (default) | 7d
#
# Two sources: REST GET /zones/{id}/dns_settings (posture) and GraphQL
# dnsAnalyticsAdaptiveGroups (query mix / RCODE distribution). Either may be
# absent (scope/plan); each degrades to null/error without failing the other.
# DNSSEC stays in `state zone` — not duplicated here.

run_audit_dns() {
  local zone_id="${1:-}"
  local window="${2:-24h}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  if [[ -z "$zone_id" ]]; then
    zone_id="$(api_pick_zone)" || {
      printf '{"error":"could not resolve zone id","code":"E_ZONE","remediation":"set CFSEC_ZONE_ID or pass zone-id"}\n' >&2
      return 3
    }
  fi

  local since_iso until_iso
  until_iso="$ts"
  case "$window" in
    1h)  since_iso="$(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
    7d)  since_iso="$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
    24h|*) window="24h"; since_iso="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
  esac

  # --- DNS settings (REST, best-effort) ---
  local settings='null' st body
  body="$(cf_get "/zones/${zone_id}/dns_settings")" && st=ok || st="$CFSEC_LAST_STATUS"
  if [[ "$st" == "ok" ]]; then
    # NB: bare `.field` (not `.field // null`) — `//` collapses a meaningful
    # `false` to the default; a missing key already yields null.
    settings="$(jq '.result // {} | {
        foundation_dns: .foundation_dns,
        multi_provider: .multi_provider,
        secondary_overrides: .secondary_overrides,
        zone_mode: .zone_mode,
        nameservers: .nameservers,
        ns_ttl: .ns_ttl
      }' <<<"$body" 2>/dev/null || printf 'null')"
  fi

  # --- DNS analytics (GraphQL, best-effort) ---
  local analytics='null' analytics_err=''
  local query
  query=$(cat <<'GRAPHQL'
query ($zoneTag: String!, $since: Time!, $until: Time!) {
  viewer {
    zones(filter: { zoneTag: $zoneTag }) {
      byCode: dnsAnalyticsAdaptiveGroups(
        limit: 25
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [count_DESC]
      ) { count dimensions { responseCode } }
      byType: dnsAnalyticsAdaptiveGroups(
        limit: 25
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [count_DESC]
      ) { count dimensions { queryType } }
      byName: dnsAnalyticsAdaptiveGroups(
        limit: 15
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [count_DESC]
      ) { count dimensions { queryName } }
    }
  }
}
GRAPHQL
)
  local gql_body resp gql_errors
  gql_body="$(jq -n --arg q "$query" --arg zoneTag "$zone_id" --arg since "$since_iso" --arg until "$until_iso" \
    '{query: $q, variables: {zoneTag: $zoneTag, since: $since, until: $until}}')"
  if resp="$(cf_post "/graphql" "$gql_body")"; then
    gql_errors="$(jq -r '.errors // [] | length' <<<"$resp" 2>/dev/null)"
    if [[ "$gql_errors" == "0" ]]; then
      analytics="$(jq '
        (.data.viewer.zones[0] // {}) as $z
        | ([($z.byCode // [])[] | {code: (.dimensions.responseCode // -1), count: .count}]) as $codes
        | ($codes | map(.count) | add // 0) as $total
        | {
            total_queries: $total,
            by_response_code: $codes,
            nxdomain_rate: (if $total > 0 then (([$codes[] | select(.code==3) | .count] | add // 0) / $total) else 0 end),
            servfail_rate: (if $total > 0 then (([$codes[] | select(.code==2) | .count] | add // 0) / $total) else 0 end),
            by_query_type: [($z.byType // [])[] | {type: (.dimensions.queryType // null), count: .count}],
            top_query_names: [($z.byName // [])[] | {name: (.dimensions.queryName // null), count: .count}]
          }' <<<"$resp" 2>/dev/null || printf 'null')"
    else
      analytics_err="graphql-unavailable"
    fi
  else
    analytics_err="graphql-unavailable"
  fi
  [[ -n "$analytics_err" ]] && analytics='null'

  jq -n --arg ts "$ts" --arg zone_id "$zone_id" --arg window "$window" \
        --arg since "$since_iso" --arg until "$until_iso" \
        --argjson settings "$settings" --argjson analytics "$analytics" \
        --arg analytics_err "$analytics_err" \
    '{ schema: "cfsec.audit-dns", schema_version: 1, generated_at: $ts,
       tool: "audit-dns", zone_id: $zone_id, window: $window, since: $since, until: $until,
       settings: $settings, analytics: $analytics }
     + (if $analytics_err != "" then {analytics_error: $analytics_err} else {} end)'
}
