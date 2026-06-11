# lib/events.sh — Cloudflare GraphQL firewallEventsAdaptive for a zone, as JSON.
# Exports: run_events zone <zone-id> [<window>]
#
# Reads CLOUDFLARE_API_TOKEN. Window is one of: 1h | 24h | 7d (default 1h).
# POSTs a single GraphQL query to /graphql (off CFSEC_API_BASE) using cf_post.
# Returns up to 100 most recent firewall events.
#
# On GraphQL/permission failure, emits a JSON error to stderr and a stub on
# stdout (events: [], error: "graphql-unavailable").

run_events() {
  local scope="${1:-}"; shift || true
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  if [[ "$scope" != "zone" ]]; then
    printf '{"error":"unsupported scope","code":"E_ARG","remediation":"usage: events zone <zone-id> [1h|24h|7d]"}\n' >&2
    return 2
  fi

  local zone_id="${1:-}"; shift || true
  local window="${1:-1h}"

  if [[ -z "$zone_id" ]]; then
    zone_id="$(api_pick_zone)" || {
      printf '{"error":"could not resolve zone id","code":"E_ZONE","remediation":"set CFSEC_ZONE_ID or pass zone-id"}\n' >&2
      return 3
    }
  fi

  local since_iso until_iso
  until_iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  case "$window" in
    24h)
      if date -u -v-24H +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
        since_iso="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ)"
      else
        since_iso="$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
      fi
      ;;
    7d)
      if date -u -v-7d +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
        since_iso="$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)"
      else
        since_iso="$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
      fi
      ;;
    1h|*)
      window="1h"
      if date -u -v-1H +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
        since_iso="$(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ)"
      else
        since_iso="$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
      fi
      ;;
  esac

  _events_stub() {
    local err="$1"
    jq -n \
      --arg ts "$ts" \
      --arg zone_id "$zone_id" \
      --arg window "$window" \
      --arg err "$err" \
      '{
        schema: "cfsec.events-zone",
        schema_version: 1,
        generated_at: $ts,
        tool: "events",
        zone_id: $zone_id,
        window: $window,
        error: $err,
        events: []
      }'
  }

  local query
  query=$(cat <<'GRAPHQL'
query ($zoneTag: String!, $since: Time!, $until: Time!) {
  viewer {
    zones(filter: { zoneTag: $zoneTag }) {
      firewallEventsAdaptive(
        limit: 100
        filter: { datetime_geq: $since, datetime_lt: $until }
        orderBy: [datetime_DESC]
      ) {
        datetime
        action
        source
        ruleId
        clientIP
        clientCountryName
        clientASNDescription
        clientAsn
        userAgent
        clientRequestPath
        clientRequestHTTPHost
        clientRequestHTTPMethodName
        rayName
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
    printf '{"error":"graphql request failed","code":"E_API","status":%s,"remediation":"Account Analytics:Read + Zone Analytics:Read required; verify token scopes"}\n' "${CFSEC_LAST_STATUS:-0}" >&2
    _events_stub "graphql-unavailable"
    return 3
  fi

  local gql_errors
  gql_errors="$(jq -r '.errors // [] | length' <<<"$resp" 2>/dev/null)"
  if [[ -z "$gql_errors" || "$gql_errors" != "0" ]]; then
    local first_msg
    first_msg="$(jq -r '.errors[0].message // "unknown graphql error"' <<<"$resp" 2>/dev/null)"
    printf '{"error":"graphql query rejected","code":"E_API","status":200,"detail":%s,"remediation":"Account Analytics:Read + Zone Analytics:Read required; verify token scopes"}\n' \
      "$(jq -Rs . <<<"$first_msg")" >&2
    _events_stub "graphql-unavailable"
    return 3
  fi

  local events
  events="$(jq '
    [(.data.viewer.zones[0].firewallEventsAdaptive // [])[]
      | {
          datetime,
          action,
          source,
          rule_id: .ruleId,
          client_ip: .clientIP,
          client_country: .clientCountryName,
          client_asn: .clientAsn,
          client_asn_description: .clientASNDescription,
          user_agent: .userAgent,
          path: .clientRequestPath,
          host: .clientRequestHTTPHost,
          method: .clientRequestHTTPMethodName,
          ray_name: .rayName
        }]
  ' <<<"$resp" 2>/dev/null)" || events='[]'

  jq -n \
    --arg ts "$ts" \
    --arg zone_id "$zone_id" \
    --arg window "$window" \
    --arg since "$since_iso" \
    --arg until "$until_iso" \
    --argjson events "$events" \
    '{
      schema: "cfsec.events-zone",
      schema_version: 1,
      generated_at: $ts,
      tool: "events",
      zone_id: $zone_id,
      window: $window,
      since: $since,
      until: $until,
      events: $events
    }'
}
