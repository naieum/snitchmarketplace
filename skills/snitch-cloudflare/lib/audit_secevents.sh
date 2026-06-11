# lib/audit_secevents.sh — aggregated WAF/security-event analytics for a zone, JSON.
# Exports: run_audit_secevents [zone-id] [window]
#   window ∈ 1h | 24h (default) | 7d
#
# Deeper than `events` (which lists raw rows): this aggregates
# firewallEventsAdaptiveGroups by action / source / rule / country / host so the
# agent sees *shape* (what's firing, where from). Stub-on-error mirrors analytics.sh.

run_audit_secevents() {
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
    1h) since_iso="$(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
    7d) since_iso="$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
    24h|*) window="24h"; since_iso="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
  esac

  _se_stub() {
    local err="$1"
    jq -n --arg ts "$ts" --arg zone_id "$zone_id" --arg window "$window" --arg err "$err" \
      '{ schema: "cfsec.audit-secevents", schema_version: 1, generated_at: $ts,
         tool: "audit-secevents", zone_id: $zone_id, window: $window, error: $err,
         totals: {events:0, blocked:0, challenged:0, other:0},
         by_action: [], by_source: [], top_rules: [], by_country: [], by_host: [] }'
  }

  local query
  query=$(cat <<'GRAPHQL'
query ($zoneTag: String!, $since: Time!, $until: Time!) {
  viewer {
    zones(filter: { zoneTag: $zoneTag }) {
      byAction: firewallEventsAdaptiveGroups(
        limit: 20 filter: { datetime_geq: $since, datetime_lt: $until } orderBy: [count_DESC]
      ) { count dimensions { action } }
      bySource: firewallEventsAdaptiveGroups(
        limit: 20 filter: { datetime_geq: $since, datetime_lt: $until } orderBy: [count_DESC]
      ) { count dimensions { source } }
      byRule: firewallEventsAdaptiveGroups(
        limit: 15 filter: { datetime_geq: $since, datetime_lt: $until } orderBy: [count_DESC]
      ) { count dimensions { ruleId source } }
      byCountry: firewallEventsAdaptiveGroups(
        limit: 15 filter: { datetime_geq: $since, datetime_lt: $until } orderBy: [count_DESC]
      ) { count dimensions { clientCountryName } }
      byHost: firewallEventsAdaptiveGroups(
        limit: 15 filter: { datetime_geq: $since, datetime_lt: $until } orderBy: [count_DESC]
      ) { count dimensions { clientRequestHTTPHost } }
    }
  }
}
GRAPHQL
)
  local gql_body resp gql_errors
  gql_body="$(jq -n --arg q "$query" --arg zoneTag "$zone_id" --arg since "$since_iso" --arg until "$until_iso" \
    '{query: $q, variables: {zoneTag: $zoneTag, since: $since, until: $until}}')"

  if ! resp="$(cf_post "/graphql" "$gql_body")"; then
    printf '{"error":"graphql request failed","code":"E_API","status":%s,"remediation":"Account/Zone Analytics:Read required; verify token scopes"}\n' "${CFSEC_LAST_STATUS:-0}" >&2
    _se_stub "graphql-unavailable"; return 3
  fi
  gql_errors="$(jq -r '.errors // [] | length' <<<"$resp" 2>/dev/null)"
  if [[ -z "$gql_errors" || "$gql_errors" != "0" ]]; then
    local first_msg; first_msg="$(jq -r '.errors[0].message // "unknown graphql error"' <<<"$resp" 2>/dev/null)"
    printf '{"error":"graphql query rejected","code":"E_API","status":200,"detail":%s,"remediation":"Account/Zone Analytics:Read required"}\n' "$(jq -Rs . <<<"$first_msg")" >&2
    _se_stub "graphql-unavailable"; return 3
  fi

  jq -n --arg ts "$ts" --arg zone_id "$zone_id" --arg window "$window" \
        --arg since "$since_iso" --arg until "$until_iso" --argjson resp "$resp" '
    ($resp.data.viewer.zones[0] // {}) as $z
    | ([($z.byAction // [])[] | {action: (.dimensions.action // null), count: .count}]) as $byAction
    | {
        schema: "cfsec.audit-secevents", schema_version: 1, generated_at: $ts,
        tool: "audit-secevents", zone_id: $zone_id, window: $window, since: $since, until: $until,
        totals: {
          events: ($byAction | map(.count) | add // 0),
          blocked: ([$byAction[] | select((.action | tostring) | test("block"; "i")) | .count] | add // 0),
          challenged: ([$byAction[] | select((.action | tostring) | test("challenge"; "i")) | .count] | add // 0),
          other: ([$byAction[] | select((.action | tostring) | test("block|challenge"; "i") | not) | .count] | add // 0)
        },
        by_action: $byAction,
        by_source: [($z.bySource // [])[] | {source: (.dimensions.source // null), count: .count}],
        top_rules: [($z.byRule // [])[] | {rule_id: (.dimensions.ruleId // null), source: (.dimensions.source // null), count: .count}],
        by_country: [($z.byCountry // [])[] | {country: (.dimensions.clientCountryName // null), count: .count}],
        by_host: [($z.byHost // [])[] | {host: (.dimensions.clientRequestHTTPHost // null), count: .count}]
      }'
}
