# lib/analytics_ga4.sh — GA4 Data API report.
# Requires GA4_AUTH (JSON: {"refresh_token":..., "client_id":..., "client_secret":...});
# else emits {locked:"ga4-api"} to stdout.
#
# Exports: run_analytics_ga4 <property-id>

# _ga4_access_token -> mints an access token from GA4_AUTH or returns empty.
_ga4_access_token() {
  local cfg="${GA4_AUTH:-}"
  [[ -z "$cfg" ]] && return 1
  local refresh client_id client_secret
  refresh="$(jq -r '.refresh_token // empty' <<<"$cfg" 2>/dev/null)"
  client_id="$(jq -r '.client_id // empty' <<<"$cfg" 2>/dev/null)"
  client_secret="$(jq -r '.client_secret // empty' <<<"$cfg" 2>/dev/null)"
  if [[ -z "$refresh" || -z "$client_id" || -z "$client_secret" ]]; then
    return 1
  fi
  local body
  body="$(curl -sS \
    --max-time 15 \
    -X POST \
    -d "client_id=${client_id}" \
    -d "client_secret=${client_secret}" \
    -d "refresh_token=${refresh}" \
    -d "grant_type=refresh_token" \
    "https://oauth2.googleapis.com/token" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    return 1
  fi
  jq -r '.access_token // empty' <<<"$body" 2>/dev/null
}

run_analytics_ga4() {
  local prop="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$prop" ]]; then
    printf '{"error":"analytics ga4 requires a property id","code":"E_USAGE","remediation":"usage: analytics ga4 <property-id>"}\n' >&2
    return 2
  fi

  if ! has_ga4_auth; then
    jq -n --arg ts "$ts" --arg property "$prop" \
      '{
        schema: "adssec.analytics-ga4",
        schema_version: 1,
        generated_at: $ts,
        tool: "analytics-ga4",
        property: $property,
        locked: "ga4-api",
        remediation: "set GA4_AUTH (JSON: {\"refresh_token\":..., \"client_id\":..., \"client_secret\":...}) — see references/01-auth-and-tokens.md"
      }'
    return 0
  fi

  local token; token="$(_ga4_access_token 2>/dev/null)"
  if [[ -z "$token" ]]; then
    printf '{"error":"could not exchange GA4_AUTH for an access token","code":"E_GA4_AUTH","remediation":"verify the refresh_token is still valid"}\n' >&2
    return 3
  fi

  # 28-day report: sessions, conversions, totalUsers by date.
  local body
  body='{
    "dateRanges":[{"startDate":"28daysAgo","endDate":"today"}],
    "dimensions":[{"name":"date"}],
    "metrics":[{"name":"sessions"},{"name":"conversions"},{"name":"totalUsers"},{"name":"engagedSessions"}]
  }'
  local resp
  resp="$(curl -sS \
    --max-time 30 \
    -A "$ADSEC_USER_AGENT" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    -X POST --data "$body" \
    "https://analyticsdata.googleapis.com/v1beta/properties/${prop}:runReport" 2>/dev/null)"

  jq -n --arg ts "$ts" --arg property "$prop" --argjson report "${resp:-{}}" \
    '{
      schema: "adssec.analytics-ga4",
      schema_version: 1,
      generated_at: $ts,
      tool: "analytics-ga4",
      property: $property,
      window: "last_28_days",
      report: $report
    }'
}
