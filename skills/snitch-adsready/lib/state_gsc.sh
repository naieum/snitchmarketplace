# lib/state_gsc.sh — Google Search Console state.
# Requires GOOGLE_GSC_AUTH (a JSON env var with refresh_token + client_id +
# client_secret); else emits {locked:"gsc-api"} to stdout.
#
# Exports: run_state_gsc [property]

# _gsc_access_token  -> echoes a freshly minted access token, or empty on failure.
_gsc_access_token() {
  local cfg="${GOOGLE_GSC_AUTH:-}"
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

run_state_gsc() {
  local property="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! has_gsc_auth; then
    jq -n --arg ts "$ts" --arg property "$property" \
      '{
        schema: "adssec.state-gsc",
        schema_version: 1,
        generated_at: $ts,
        tool: "state-gsc",
        property: ($property|select(length>0) // null),
        locked: "gsc-api",
        remediation: "set GOOGLE_GSC_AUTH (JSON: {\"refresh_token\":..., \"client_id\":..., \"client_secret\":...}) — see references/01-auth-and-tokens.md"
      }'
    return 0
  fi

  local token; token="$(_gsc_access_token 2>/dev/null)"
  if [[ -z "$token" ]]; then
    printf '{"error":"could not exchange GOOGLE_GSC_AUTH for an access token","code":"E_GSC_AUTH","remediation":"verify the refresh_token is still valid; rotate via the Google Cloud Console OAuth flow"}\n' >&2
    return 3
  fi

  # If property not given, list all properties the token can see.
  local sites
  sites="$(curl -sS \
    --max-time 15 \
    -A "$ADSEC_USER_AGENT" \
    -H "Authorization: Bearer ${token}" \
    "https://searchconsole.googleapis.com/webmasters/v3/sites" 2>/dev/null)"

  if [[ -z "$property" ]]; then
    jq -n --arg ts "$ts" --argjson sites "${sites:-{}}" \
      '{
        schema: "adssec.state-gsc",
        schema_version: 1,
        generated_at: $ts,
        tool: "state-gsc",
        sites: ($sites.siteEntry // []),
        hint: "to fetch performance data, run: state gsc <siteUrl-from-list>"
      }'
    return 0
  fi

  # Fetch a 28-day search analytics report for the requested property.
  local end start
  end="$(date -u +%Y-%m-%d)"
  if start="$(date -u -d '28 days ago' +%Y-%m-%d 2>/dev/null)"; then :; else
    start="$(date -u -v-28d +%Y-%m-%d 2>/dev/null)"
  fi
  local body
  body="$(printf '%s' "{\"startDate\":\"${start}\",\"endDate\":\"${end}\",\"dimensions\":[\"query\"],\"rowLimit\":50}")"
  local url
  # Property may be a sc-domain:foo.com or https://foo.com/ — URL-encode forward slashes.
  local prop_enc
  prop_enc="$(printf '%s' "$property" | sed -e 's,:,%3A,g' -e 's,/,%2F,g')"
  url="https://searchconsole.googleapis.com/webmasters/v3/sites/${prop_enc}/searchAnalytics/query"
  local resp
  resp="$(curl -sS \
    --max-time 30 \
    -A "$ADSEC_USER_AGENT" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    -X POST --data "$body" "$url" 2>/dev/null)"

  jq -n --arg ts "$ts" --arg property "$property" --arg start "$start" --arg end "$end" \
    --argjson sites "${sites:-{}}" \
    --argjson report "${resp:-{}}" \
    '{
      schema: "adssec.state-gsc",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-gsc",
      property: $property,
      window: {start: $start, end: $end},
      sites: ($sites.siteEntry // []),
      top_queries: ($report.rows // [])
    }'
}
