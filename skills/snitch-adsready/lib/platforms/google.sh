# lib/platforms/google.sh — Google Ads Marketing API helper.
# Auth: Google Ads API requires developer token + OAuth2 refresh token + customer id.
# Docs: https://developers.google.com/google-ads/api/docs/start
#
# Exports:
#   platform_state [customer-id]   — emits adssec.state-platform.google JSON
#   platform_pixel_signals          — emits pixel detection regex JSON

ADSSEC_GOOGLE_API_BASE="${ADSSEC_GOOGLE_API_BASE:-https://googleads.googleapis.com/v25}"
ADSSEC_GOOGLE_OAUTH_BASE="${ADSSEC_GOOGLE_OAUTH_BASE:-https://oauth2.googleapis.com}"

# Inline HTTP helper: this platform needs three extra headers, so it does not
# use the generic wrappers in api.sh.
_google_http_get() {
  local url="$1" auth="$2" dev_token="$3" login_cust="${4:-}"
  local tmp; tmp="$(mktemp)"
  local code
  if [[ -n "$login_cust" ]]; then
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -H "Authorization: Bearer ${auth}" \
      -H "developer-token: ${dev_token}" \
      -H "login-customer-id: ${login_cust}" \
      "$url" 2>/dev/null || echo "000")
  else
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -H "Authorization: Bearer ${auth}" \
      -H "developer-token: ${dev_token}" \
      "$url" 2>/dev/null || echo "000")
  fi
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

_google_http_post() {
  local url="$1" auth="$2" dev_token="$3" body="$4" login_cust="${5:-}"
  local tmp; tmp="$(mktemp)"
  local code
  if [[ -n "$login_cust" ]]; then
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -X POST \
      -H "Authorization: Bearer ${auth}" \
      -H "developer-token: ${dev_token}" \
      -H "login-customer-id: ${login_cust}" \
      -H "Content-Type: application/json" \
      --data "$body" \
      "$url" 2>/dev/null || echo "000")
  else
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -X POST \
      -H "Authorization: Bearer ${auth}" \
      -H "developer-token: ${dev_token}" \
      -H "Content-Type: application/json" \
      --data "$body" \
      "$url" 2>/dev/null || echo "000")
  fi
  local resp; resp="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$resp"
}

# Mint an OAuth2 access token from refresh token. Echoes token on stdout, empty on failure.
_google_oauth_token() {
  local rt="$1" cid="$2" cs="$3"
  local body
  body=$(curl -sS -X POST "${ADSSEC_GOOGLE_OAUTH_BASE}/token" \
    -d "client_id=${cid}" \
    -d "client_secret=${cs}" \
    -d "refresh_token=${rt}" \
    -d "grant_type=refresh_token" 2>/dev/null)
  printf '%s\n' "$body" | jq -r '.access_token // empty' 2>/dev/null
}

platform_state() {
  local cust_id="${1:-${GOOGLE_ADS_CUSTOMER_ID:-}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local platform="google"

  # Auth check
  if [[ -z "${GOOGLE_ADS_DEVELOPER_TOKEN:-}" \
     || -z "${GOOGLE_ADS_REFRESH_TOKEN:-}" \
     || -z "${GOOGLE_ADS_CLIENT_ID:-}" \
     || -z "${GOOGLE_ADS_CLIENT_SECRET:-}" \
     || -z "$cust_id" ]]; then
    jq -n \
      --arg ts "$ts" \
      --arg p "$platform" \
      '{
        schema: "adssec.state-platform.google",
        schema_version: 1,
        generated_at: $ts,
        tool: "state-platform",
        platform: $p,
        locked: "google-api",
        reason: "Google Ads API auth env not configured.",
        remediation: "Export GOOGLE_ADS_DEVELOPER_TOKEN, GOOGLE_ADS_CUSTOMER_ID, GOOGLE_ADS_REFRESH_TOKEN, GOOGLE_ADS_CLIENT_ID, GOOGLE_ADS_CLIENT_SECRET. See https://developers.google.com/google-ads/api/docs/oauth/cloud-project",
        env_required: ["GOOGLE_ADS_DEVELOPER_TOKEN","GOOGLE_ADS_CUSTOMER_ID","GOOGLE_ADS_REFRESH_TOKEN","GOOGLE_ADS_CLIENT_ID","GOOGLE_ADS_CLIENT_SECRET"]
      }'
    return 0
  fi

  # Strip dashes from customer id (Google Ads API expects pure digits).
  local cust_clean; cust_clean="${cust_id//-/}"
  local login_cust="${GOOGLE_ADS_LOGIN_CUSTOMER_ID:-}"; login_cust="${login_cust//-/}"

  # Get OAuth2 access token.
  local access_tok
  access_tok="$(_google_oauth_token "$GOOGLE_ADS_REFRESH_TOKEN" "$GOOGLE_ADS_CLIENT_ID" "$GOOGLE_ADS_CLIENT_SECRET")"
  if [[ -z "$access_tok" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.google",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "google",
      locked: "google-api",
      reason: "OAuth2 token mint failed (check refresh token / client credentials).",
      remediation: "Re-mint the refresh token with scope https://www.googleapis.com/auth/adwords."
    }'
    return 0
  fi

  # GAQL queries via /customers/<id>/googleAds:search
  local search_url="${ADSSEC_GOOGLE_API_BASE}/customers/${cust_clean}/googleAds:search"
  local dt="$GOOGLE_ADS_DEVELOPER_TOKEN"

  local campaigns_body='{"query":"SELECT campaign.id, campaign.name, campaign.status, campaign.advertising_channel_type, campaign.bidding_strategy_type FROM campaign LIMIT 200"}'
  local goals_body='{"query":"SELECT conversion_action.id, conversion_action.name, conversion_action.status, conversion_action.type, conversion_action.category, conversion_action.primary_for_goal FROM conversion_action LIMIT 100"}'
  local audiences_body='{"query":"SELECT user_list.id, user_list.name, user_list.size_for_display, user_list.size_for_search, user_list.membership_status FROM user_list LIMIT 100"}'

  local campaigns_resp goals_resp audiences_resp
  campaigns_resp="$(_google_http_post "$search_url" "$access_tok" "$dt" "$campaigns_body" "$login_cust" | tail -n +2)"
  goals_resp="$(_google_http_post "$search_url" "$access_tok" "$dt" "$goals_body" "$login_cust" | tail -n +2)"
  audiences_resp="$(_google_http_post "$search_url" "$access_tok" "$dt" "$audiences_body" "$login_cust" | tail -n +2)"

  local campaigns goals audiences
  campaigns="$(jq '[(.results // [])[] | {id: .campaign.id, name: .campaign.name, status: .campaign.status, channel: .campaign.advertisingChannelType, bidding: .campaign.biddingStrategyType}]' <<<"$campaigns_resp" 2>/dev/null || printf '[]')"
  goals="$(jq '[(.results // [])[] | {id: .conversionAction.id, name: .conversionAction.name, status: .conversionAction.status, type: .conversionAction.type, category: .conversionAction.category, primary_for_goal: .conversionAction.primaryForGoal}]' <<<"$goals_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.results // [])[] | {id: .userList.id, name: .userList.name, size_display: .userList.sizeForDisplay, size_search: .userList.sizeForSearch, status: .userList.membershipStatus}]' <<<"$audiences_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg cust "$cust_id" \
    --argjson campaigns "$campaigns" \
    --argjson goals "$goals" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.google",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "google",
      account: { customer_id: $cust },
      campaigns: $campaigns,
      conversion_goals: $goals,
      audiences: $audiences,
      attribution: { note: "Per-conversion-action; see conversion_action.attribution_model_settings via full slice." },
      hint: "for full state, run: state platform google full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "google",
  "patterns": {
    "gtag_init": "gtag\\s*\\(\\s*[\"']config[\"']\\s*,\\s*[\"']([A-Z0-9-]+)[\"']",
    "gtag_library": "googletagmanager\\.com/gtag/js\\?id=([A-Z0-9-]+)",
    "gtm_init": "GTM-[A-Z0-9]+",
    "gtm_library": "googletagmanager\\.com/gtm\\.js\\?id=(GTM-[A-Z0-9]+)",
    "ga4_id": "G-[A-Z0-9]{8,12}",
    "ads_id": "AW-[0-9]+"
  },
  "consent_partner": true,
  "consent_method": "gtag('consent','default'|'update',{ad_storage,analytics_storage,ad_user_data,ad_personalization})"
}
JSON
}
