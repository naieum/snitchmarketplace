# lib/platforms/pinterest.sh — Pinterest Marketing API helper.
# Auth: OAuth2 access token + ad account id.
# Docs: https://developers.pinterest.com/docs/api/v5/
#
# Exports:
#   platform_state [ad-account-id]
#   platform_pixel_signals

ADSSEC_PIN_API_BASE="${ADSSEC_PIN_API_BASE:-https://api.pinterest.com/v5}"

_pin_http_get() {
  local url="$1" tok="$2"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -H "Authorization: Bearer ${tok}" \
    -H "Accept: application/json" \
    "$url" 2>/dev/null || echo "000")
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

platform_state() {
  local acct_id="${1:-${PINTEREST_AD_ACCOUNT_ID:-}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${PINTEREST_ACCESS_TOKEN:-}" || -z "$acct_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.pinterest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "pinterest",
      locked: "pinterest-api",
      reason: "Pinterest API auth env not configured.",
      remediation: "Export PINTEREST_ACCESS_TOKEN (OAuth2; scopes ads:read pins:read user_accounts:read) and PINTEREST_AD_ACCOUNT_ID. See https://developers.pinterest.com/docs/getting-started/authentication/",
      env_required: ["PINTEREST_ACCESS_TOKEN","PINTEREST_AD_ACCOUNT_ID"]
    }'
    return 0
  fi

  local at="$PINTEREST_ACCESS_TOKEN"
  local camp_url="${ADSSEC_PIN_API_BASE}/ad_accounts/${acct_id}/campaigns?page_size=100"
  local convtag_url="${ADSSEC_PIN_API_BASE}/ad_accounts/${acct_id}/conversion_tags"
  local aud_url="${ADSSEC_PIN_API_BASE}/ad_accounts/${acct_id}/audiences?page_size=100"

  local camp_resp tag_resp aud_resp
  camp_resp="$(_pin_http_get "$camp_url" "$at" | tail -n +2)"
  tag_resp="$(_pin_http_get "$convtag_url" "$at" | tail -n +2)"
  aud_resp="$(_pin_http_get "$aud_url" "$at" | tail -n +2)"

  local campaigns tags audiences
  campaigns="$(jq '[(.items // [])[] | {id, name, status, objective_type, daily_spend_cap, lifetime_spend_cap, start_time, end_time}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  tags="$(jq '[(.items // [])[] | {id, name, status, code_snippet_type, last_fired_time_ms, enhanced_match_status}]' <<<"$tag_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.items // [])[] | {id, name, audience_type, size, rule, status}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg acct "$acct_id" \
    --argjson campaigns "$campaigns" \
    --argjson tags "$tags" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.pinterest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "pinterest",
      account: { ad_account_id: $acct },
      campaigns: $campaigns,
      conversion_goals: { tags: $tags, note: "Standard events: PageVisit, ViewCategory, Search, AddToCart, Checkout, Signup, Lead, etc." },
      audiences: $audiences,
      attribution: { default_window: "30d_click_1d_engagement_1d_view", note: "Configurable in Pinterest Ads Manager > Conversions." },
      hint: "for full state, run: state platform pinterest full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "pinterest",
  "patterns": {
    "init": "pintrk\\s*\\(\\s*[\"']load[\"']\\s*,\\s*[\"']([0-9]+)[\"']",
    "library": "s\\.pinimg\\.com/ct/core\\.js",
    "noscript_pixel": "ct\\.pinterest\\.com/v3/?\\?tid=([0-9]+)"
  },
  "consent_partner": false,
  "consent_method": "Gate core.js load behind consent. Pinterest supports Enhanced Match via SHA-256 email/phone hashing."
}
JSON
}
