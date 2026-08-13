# lib/platforms/reddit.sh — Reddit Ads API helper.
# Auth: OAuth2 access token + ad account id.
# Docs: https://ads-api.reddit.com/docs/v3/
#
# Exports:
#   platform_state [ad-account-id]
#   platform_pixel_signals

ADSSEC_RDT_API_BASE="${ADSSEC_RDT_API_BASE:-https://ads-api.reddit.com/api/v3}"

_rdt_http_get() {
  local url="$1" tok="$2"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -H "Authorization: Bearer ${tok}" \
    -H "Accept: application/json" \
    -A "ads-ready-skill/1.0" \
    "$url" 2>/dev/null || echo "000")
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

platform_state() {
  # Canonical env names are REDDIT_ADS_* (what doctor/prereqs check); the
  # unprefixed names are accepted as a legacy fallback.
  local token="${REDDIT_ADS_ACCESS_TOKEN:-${REDDIT_ACCESS_TOKEN:-}}"
  local acct_id="${1:-${REDDIT_ADS_ACCOUNT_ID:-${REDDIT_AD_ACCOUNT_ID:-}}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$token" || -z "$acct_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.reddit",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "reddit",
      locked: "reddit-api",
      reason: "Reddit Ads API auth env not configured.",
      remediation: "Export REDDIT_ADS_ACCESS_TOKEN (OAuth2; scopes adsread + adsedit) and REDDIT_ADS_ACCOUNT_ID. See https://ads-api.reddit.com/docs/v3/oauth2/",
      env_required: ["REDDIT_ADS_ACCESS_TOKEN","REDDIT_ADS_ACCOUNT_ID"]
    }'
    return 0
  fi

  local at="$token"
  local camp_url="${ADSSEC_RDT_API_BASE}/ad_accounts/${acct_id}/campaigns?page.size=100"
  local conv_url="${ADSSEC_RDT_API_BASE}/ad_accounts/${acct_id}/custom_events"
  local aud_url="${ADSSEC_RDT_API_BASE}/ad_accounts/${acct_id}/custom_audiences?page.size=100"

  local camp_resp conv_resp aud_resp
  camp_resp="$(_rdt_http_get "$camp_url" "$at" | tail -n +2)"
  conv_resp="$(_rdt_http_get "$conv_url" "$at" | tail -n +2)"
  aud_resp="$(_rdt_http_get "$aud_url" "$at" | tail -n +2)"

  local campaigns conversions audiences
  campaigns="$(jq '[(.data // [])[] | {id, name, configured_status, effective_status, objective, funding_instrument_id, spend_cap, start_time, end_time}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  conversions="$(jq '[(.data // [])[] | {id, event_name, event_type, status, click_through_window, view_through_window}]' <<<"$conv_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.data // [])[] | {id, name, type, status, size: (.size // null)}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg acct "$acct_id" \
    --argjson campaigns "$campaigns" \
    --argjson conversions "$conversions" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.reddit",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "reddit",
      account: { ad_account_id: $acct },
      campaigns: $campaigns,
      conversion_goals: $conversions,
      audiences: $audiences,
      attribution: { default_window: "7d_click_1d_view", note: "Subreddit-targeted campaigns may have longer consideration windows; tune per campaign." },
      hint: "for full state, run: state platform reddit full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "reddit",
  "patterns": {
    "init": "rdt\\s*\\(\\s*[\"']init[\"']\\s*,\\s*[\"']([a-zA-Z0-9_]+)[\"']",
    "library": "www\\.redditstatic\\.com/ads/pixel\\.js",
    "rdt_global": "rdt\\s*=\\s*window\\.rdt"
  },
  "consent_partner": false,
  "consent_method": "Gate pixel.js load behind consent. Reddit Pixel supports advanced matching (email/phone SHA-256)."
}
JSON
}
