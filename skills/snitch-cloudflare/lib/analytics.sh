# lib/analytics.sh — Cloudflare GraphQL Analytics for a zone, as JSON.
# Exports: run_analytics zone <zone-id> [<window>]
#
# Reads CLOUDFLARE_API_TOKEN. Window is one of: 1h | 24h | 7d (default 24h).
# POSTs a single GraphQL query to /graphql (off CFSEC_API_BASE) using cf_post.
# Returns totals (requests, threats, cached_requests, cache_hit_rate) plus
# top_countries, top_asns, top_paths, and colo_distribution.
#
# On GraphQL/permission failure, emits a JSON error to stderr and a partial
# stub on stdout (zero totals, empty arrays, error: "graphql-unavailable").

run_analytics() {
  local scope="${1:-}"; shift || true
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  if [[ "$scope" != "zone" ]]; then
    printf '{"error":"unsupported scope","code":"E_ARG","remediation":"usage: analytics zone <zone-id> [1h|24h|7d]"}\n' >&2
    return 2
  fi

  local zone_id="${1:-}"; shift || true
  local window="${1:-24h}"

  if [[ -z "$zone_id" ]]; then
    zone_id="$(api_pick_zone)" || {
      printf '{"error":"could not resolve zone id","code":"E_ZONE","remediation":"set CFSEC_ZONE_ID or pass zone-id"}\n' >&2
      return 3
    }
  fi

  local since_iso until_iso
  until_iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  case "$window" in
    1h)
      if date -u -v-1H +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
        since_iso="$(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ)"
      else
        since_iso="$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
      fi
      ;;
    7d)
      if date -u -v-7d +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
        since_iso="$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)"
      else
        since_iso="$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
      fi
      ;;
    24h|*)
      window="24h"
      if date -u -v-24H +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
        since_iso="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ)"
      else
        since_iso="$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
      fi
      ;;
  esac

  local emit_stub=0
  _analytics_stub() {
    local err="$1"
    jq -n \
      --arg ts "$ts" \
      --arg zone_id "$zone_id" \
      --arg window "$window" \
      --arg err "$err" \
      '{
        schema: "cfsec.analytics-zone",
        schema_version: 1,
        generated_at: $ts,
        tool: "analytics",
        zone_id: $zone_id,
        window: $window,
        error: $err,
        totals: { requests: 0, threats: 0, cached_requests: 0, cache_hit_rate: 0 },
        top_countries: [],
        top_asns: [],
        top_paths: [],
        colo_distribution: []
      }'
  }

  # GraphQL query — uses httpRequestsAdaptiveGroups for most breakdowns and
  # httpRequests1hGroups for totals (the latter is the long-standing series).
  local query
  query=$(cat <<'GRAPHQL'
query ($zoneTag: String!, $since: Time!, $until: Time!) {
  viewer {
    zones(filter: { zoneTag: $zoneTag }) {
      totals: httpRequests1hGroups(
        limit: 10000
        filter: { datetime_geq: $since, datetime_lt: $until }
      ) {
        sum {
          requests
          cachedRequests
          threats
        }
      }
      countries: httpRequestsAdaptiveGroups(
        limit: 10
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [count_DESC]
      ) {
        count
        dimensions { clientCountryName }
      }
      asns: httpRequestsAdaptiveGroups(
        limit: 10
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [count_DESC]
      ) {
        count
        dimensions { clientASNDescription clientAsn }
      }
      paths: httpRequestsAdaptiveGroups(
        limit: 10
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [count_DESC]
      ) {
        count
        dimensions { clientRequestPath }
      }
      colos: httpRequestsAdaptiveGroups(
        limit: 50
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [count_DESC]
      ) {
        count
        dimensions { coloCode }
      }
    }
  }
}
GRAPHQL
)

  local body
  body="$(jq -n \
    --arg q "$query" \
    --arg zoneTag "$zone_id" \
    --arg since "$since_iso" \
    --arg until "$until_iso" \
    '{query: $q, variables: {zoneTag: $zoneTag, since: $since, until: $until}}')"

  local resp
  if ! resp="$(cf_post "/graphql" "$body")"; then
    printf '{"error":"graphql request failed","code":"E_API","status":%s,"remediation":"Workers Paid + Account Analytics:Read required for full analytics; verify token scopes"}\n' "${CFSEC_LAST_STATUS:-0}" >&2
    _analytics_stub "graphql-unavailable"
    return 3
  fi

  # GraphQL surfaces query errors inside a 200 OK body.
  local gql_errors
  gql_errors="$(jq -r '.errors // [] | length' <<<"$resp" 2>/dev/null)"
  if [[ -z "$gql_errors" || "$gql_errors" != "0" ]]; then
    local first_msg
    first_msg="$(jq -r '.errors[0].message // "unknown graphql error"' <<<"$resp" 2>/dev/null)"
    printf '{"error":"graphql query rejected","code":"E_API","status":200,"detail":%s,"remediation":"Workers Paid + Account Analytics:Read required for full analytics"}\n' \
      "$(jq -Rs . <<<"$first_msg")" >&2
    _analytics_stub "graphql-unavailable"
    return 3
  fi

  local totals top_countries top_asns top_paths colos
  totals="$(jq '
    .data.viewer.zones[0].totals // []
    | reduce .[] as $r (
        {requests:0, cached_requests:0, threats:0};
        .requests += ($r.sum.requests // 0)
        | .cached_requests += ($r.sum.cachedRequests // 0)
        | .threats += ($r.sum.threats // 0)
      )
    | . + {cache_hit_rate: (if .requests > 0 then (.cached_requests / .requests) else 0 end)}
  ' <<<"$resp" 2>/dev/null)" || totals='{"requests":0,"cached_requests":0,"threats":0,"cache_hit_rate":0}'

  top_countries="$(jq '
    [(.data.viewer.zones[0].countries // [])[]
      | {name: (.dimensions.clientCountryName // null),
         code: (.dimensions.clientCountryName // null),
         requests: (.count // 0)}]
  ' <<<"$resp" 2>/dev/null)" || top_countries='[]'

  top_asns="$(jq '
    [(.data.viewer.zones[0].asns // [])[]
      | {asn: (.dimensions.clientAsn // null),
         name: (.dimensions.clientASNDescription // null),
         requests: (.count // 0)}]
  ' <<<"$resp" 2>/dev/null)" || top_asns='[]'

  top_paths="$(jq '
    [(.data.viewer.zones[0].paths // [])[]
      | {path: (.dimensions.clientRequestPath // null),
         requests: (.count // 0)}]
  ' <<<"$resp" 2>/dev/null)" || top_paths='[]'

  colos="$(jq '
    [(.data.viewer.zones[0].colos // [])[]
      | {colo: (.dimensions.coloCode // null),
         requests: (.count // 0)}]
  ' <<<"$resp" 2>/dev/null)" || colos='[]'

  jq -n \
    --arg ts "$ts" \
    --arg zone_id "$zone_id" \
    --arg window "$window" \
    --arg since "$since_iso" \
    --arg until "$until_iso" \
    --argjson totals "$totals" \
    --argjson top_countries "$top_countries" \
    --argjson top_asns "$top_asns" \
    --argjson top_paths "$top_paths" \
    --argjson colos "$colos" \
    '{
      schema: "cfsec.analytics-zone",
      schema_version: 1,
      generated_at: $ts,
      tool: "analytics",
      zone_id: $zone_id,
      window: $window,
      since: $since,
      until: $until,
      totals: $totals,
      top_countries: $top_countries,
      top_asns: $top_asns,
      top_paths: $top_paths,
      colo_distribution: $colos
    }'
}
