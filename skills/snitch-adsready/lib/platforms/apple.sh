# lib/platforms/apple.sh — Apple Search Ads Campaign Management API helper.
# Auth: JWT signed with ES256 (.p8 private key) → bearer token from
#       /auth/oauth2/token. Org-level access scoped to APPLE_SEARCH_ADS_ORG_ID.
# Docs: https://developer.apple.com/documentation/apple_search_ads
#
# Exports:
#   platform_state [org-id]
#   platform_pixel_signals      (Apple has no JS pixel — emits an iOS app marker variant)

ADSSEC_APPLE_API_BASE="${ADSSEC_APPLE_API_BASE:-https://api.searchads.apple.com/api/v5}"
ADSSEC_APPLE_AUTH_URL="${ADSSEC_APPLE_AUTH_URL:-https://appleid.apple.com/auth/oauth2/token}"

# base64url encode (no padding).
_apple_b64url() {
  openssl base64 -A 2>/dev/null | tr '+/' '-_' | tr -d '='
}

# Build the client-secret JWT (ES256). Echoes the JWT on stdout.
_apple_client_secret_jwt() {
  local key_path="$1" team_id="$2" client_id="$3" key_id="$4"
  local now exp header payload header_b64 payload_b64 signing_input sig

  now="$(date +%s)"
  exp=$((now + 3600))   # max ~30 days, but 1h is safe.

  header="$(jq -nc --arg kid "$key_id" '{alg:"ES256", kid:$kid, typ:"JWT"}')"
  payload="$(jq -nc --arg iss "$team_id" --arg sub "$client_id" --arg aud "https://appleid.apple.com" --argjson iat "$now" --argjson exp "$exp" '{iss:$iss, iat:$iat, exp:$exp, aud:$aud, sub:$sub}')"
  header_b64="$(printf '%s' "$header"  | _apple_b64url)"
  payload_b64="$(printf '%s' "$payload" | _apple_b64url)"
  signing_input="${header_b64}.${payload_b64}"

  # ES256 produces a DER signature; JWT spec requires raw R||S of 64 bytes.
  local der
  der="$(printf '%s' "$signing_input" | openssl dgst -sha256 -sign "$key_path" 2>/dev/null | openssl base64 -A 2>/dev/null)"
  if [[ -z "$der" ]]; then return 1; fi

  # Convert DER ECDSA signature → raw R||S.
  # asn1parse, parse INTEGERs.
  local r s rs
  rs="$(printf '%s' "$der" | openssl base64 -d -A 2>/dev/null \
    | openssl asn1parse -inform DER 2>/dev/null \
    | awk -F: '/INTEGER/ {print $NF}')"
  r="$(awk 'NR==1' <<<"$rs")"
  s="$(awk 'NR==2' <<<"$rs")"
  # Pad each to 32 bytes (64 hex chars), trim leading zeros if oversized.
  r="$(printf '%s' "$r" | sed 's/^00//' | awk '{ while(length($0)<64) $0="0"$0; print }')"
  s="$(printf '%s' "$s" | sed 's/^00//' | awk '{ while(length($0)<64) $0="0"$0; print }')"
  sig="$(printf '%s%s' "$r" "$s" | xxd -r -p 2>/dev/null | _apple_b64url)"

  printf '%s.%s\n' "$signing_input" "$sig"
}

# Exchange client_secret JWT for an access token. Echoes access_token.
_apple_access_token() {
  local client_secret="$1" client_id="$2" org_id="$3"
  local body
  body=$(curl -sS -X POST "$ADSSEC_APPLE_AUTH_URL" \
    -H "Host: appleid.apple.com" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "client_id=${client_id}" \
    --data-urlencode "client_secret=${client_secret}" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "scope=searchadsorg" 2>/dev/null)
  printf '%s\n' "$body" | jq -r '.access_token // empty' 2>/dev/null
}

_apple_http_get() {
  local url="$1" tok="$2" org="$3"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -H "Authorization: Bearer ${tok}" \
    -H "X-AP-Context: orgId=${org}" \
    -H "Accept: application/json" \
    "$url" 2>/dev/null || echo "000")
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

platform_state() {
  local org_id="${1:-${APPLE_SEARCH_ADS_ORG_ID:-}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${APPLE_SEARCH_ADS_PRIVATE_KEY:-}" \
     || -z "${APPLE_SEARCH_ADS_KEY_ID:-}" \
     || -z "${APPLE_SEARCH_ADS_TEAM_ID:-}" \
     || -z "$org_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.apple",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "apple",
      locked: "apple-api",
      reason: "Apple Search Ads API auth env not configured.",
      remediation: "Export APPLE_SEARCH_ADS_PRIVATE_KEY (path to .p8), APPLE_SEARCH_ADS_KEY_ID, APPLE_SEARCH_ADS_TEAM_ID (= client_id), APPLE_SEARCH_ADS_ORG_ID. See https://developer.apple.com/documentation/apple_search_ads/implementing_oauth_for_the_apple_search_ads_api",
      env_required: ["APPLE_SEARCH_ADS_PRIVATE_KEY","APPLE_SEARCH_ADS_KEY_ID","APPLE_SEARCH_ADS_TEAM_ID","APPLE_SEARCH_ADS_ORG_ID"]
    }'
    return 0
  fi

  if [[ ! -r "$APPLE_SEARCH_ADS_PRIVATE_KEY" ]]; then
    jq -n --arg ts "$ts" --arg p "$APPLE_SEARCH_ADS_PRIVATE_KEY" '{
      schema: "adssec.state-platform.apple",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "apple",
      locked: "apple-api",
      reason: ("Private key not readable at " + $p),
      remediation: "Verify path to .p8 is correct and readable."
    }'
    return 0
  fi

  if ! command -v openssl >/dev/null 2>&1 || ! command -v xxd >/dev/null 2>&1; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.apple",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "apple",
      locked: "apple-api",
      reason: "openssl and xxd are required for ES256 JWT signing; one or both missing.",
      remediation: "Install openssl and xxd (vim-common on Debian/Ubuntu)."
    }'
    return 0
  fi

  # Apple uses team_id as both iss and client_id (per current docs).
  local jwt access
  jwt="$(_apple_client_secret_jwt "$APPLE_SEARCH_ADS_PRIVATE_KEY" "$APPLE_SEARCH_ADS_TEAM_ID" "$APPLE_SEARCH_ADS_TEAM_ID" "$APPLE_SEARCH_ADS_KEY_ID")"
  if [[ -z "$jwt" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.apple",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "apple",
      locked: "apple-api",
      reason: "Failed to sign client_secret JWT (ES256).",
      remediation: "Verify .p8 file is a valid ES256 private key and key id matches."
    }'
    return 0
  fi

  access="$(_apple_access_token "$jwt" "$APPLE_SEARCH_ADS_TEAM_ID" "$org_id")"
  if [[ -z "$access" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.apple",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "apple",
      locked: "apple-api",
      reason: "Apple OAuth2 token exchange returned no access_token.",
      remediation: "Verify org membership, client_id (= Team ID for the API user), and that the .p8 key corresponds to the same Team."
    }'
    return 0
  fi

  local camp_url="${ADSSEC_APPLE_API_BASE}/campaigns?limit=200"
  # No conversion endpoint is queried: Apple Search Ads conversions are app-side
  # (SKAdNetwork / AdAttributionKit postbacks), reported in conversion_goals.note below.
  local aud_url="${ADSSEC_APPLE_API_BASE}/audiences"

  local camp_resp aud_resp
  camp_resp="$(_apple_http_get "$camp_url" "$access" "$org_id" | tail -n +2)"
  aud_resp="$(_apple_http_get "$aud_url" "$access" "$org_id" | tail -n +2)"

  local campaigns audiences
  campaigns="$(jq '[(.data // [])[] | {id, name, status, servingStatus, adChannelType, supplySources, budgetAmount: .budgetAmount.amount, dailyBudgetAmount: .dailyBudgetAmount.amount, startTime, endTime}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.data // [])[] | {id, name, type, status}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg org "$org_id" \
    --argjson campaigns "$campaigns" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.apple",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "apple",
      account: { org_id: $org },
      campaigns: $campaigns,
      conversion_goals: { note: "Apple Search Ads conversions are app-side via SKAdNetwork postbacks (and AdAttributionKit on iOS 17.4+). Configure conversion-value mapping in the app and deliver postbacks to your server endpoint." },
      audiences: $audiences,
      attribution: { default_window: "30d_tap", note: "SKAdNetwork supports up to 3 postbacks at 0-2/3-7/8-35 day windows." },
      hint: "for full state, run: state platform apple full"
    }'
}

# Apple Search Ads has no JS pixel. Emit iOS-app markers instead.
platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "apple",
  "kind": "ios-app-marker",
  "patterns": {
    "smart_banner_meta": "<meta\\s+name=[\"']apple-itunes-app[\"']\\s+content=[\"']app-id=([0-9]+)",
    "aap_library": "aap\\.apple\\.com/[a-z0-9/_.-]+\\.js"
  },
  "consent_partner": false,
  "consent_method": "iOS App Tracking Transparency (ATT) prompt; SKAdNetwork postbacks are aggregate by design and do not require user consent. App-side privacy manifest (PrivacyInfo.xcprivacy) declares tracking domains."
}
JSON
}
