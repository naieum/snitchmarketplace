# lib/platforms/tiktok.sh — TikTok Business / Marketing API helper.
# Auth: long-term access token + advertiser id.
# Docs: https://business-api.tiktok.com/portal/docs
#
# Exports:
#   platform_state [advertiser-id]
#   platform_pixel_signals

ADSSEC_TT_API_BASE="${ADSSEC_TT_API_BASE:-https://business-api.tiktok.com/open_api/v1.3}"

_tt_http_get() {
  local url="$1" tok="$2"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -H "Access-Token: ${tok}" \
    -H "Content-Type: application/json" \
    "$url" 2>/dev/null || echo "000")
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

platform_state() {
  # Canonical env names are TIKTOK_ADS_* (what doctor/prereqs check); the
  # unprefixed names are accepted as a legacy fallback.
  local token="${TIKTOK_ADS_ACCESS_TOKEN:-${TIKTOK_ACCESS_TOKEN:-}}"
  local adv_id="${1:-${TIKTOK_ADS_ADVERTISER_ID:-${TIKTOK_ADVERTISER_ID:-}}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$token" || -z "$adv_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.tiktok",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "tiktok",
      locked: "tiktok-api",
      reason: "TikTok Business API auth env not configured.",
      remediation: "Export TIKTOK_ADS_ACCESS_TOKEN and TIKTOK_ADS_ADVERTISER_ID. See https://business-api.tiktok.com/portal/docs?id=1738373164380162 for OAuth2 setup.",
      env_required: ["TIKTOK_ADS_ACCESS_TOKEN","TIKTOK_ADS_ADVERTISER_ID"]
    }'
    return 0
  fi

  local at="$token"
  local camp_url="${ADSSEC_TT_API_BASE}/campaign/get/?advertiser_id=${adv_id}&page_size=100"
  local pixel_url="${ADSSEC_TT_API_BASE}/pixel/list/?advertiser_id=${adv_id}"
  local aud_url="${ADSSEC_TT_API_BASE}/dmp/custom_audience/list/?advertiser_id=${adv_id}&page_size=100"

  local camp_resp pixel_resp aud_resp
  camp_resp="$(_tt_http_get "$camp_url" "$at" | tail -n +2)"
  pixel_resp="$(_tt_http_get "$pixel_url" "$at" | tail -n +2)"
  aud_resp="$(_tt_http_get "$aud_url" "$at" | tail -n +2)"

  local campaigns pixels audiences
  campaigns="$(jq '[(.data.list // [])[] | {id: .campaign_id, name: .campaign_name, status: .secondary_status, objective: .objective_type, budget: .budget, budget_mode: .budget_mode}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  pixels="$(jq '[(.data.pixels // .data.list // [])[] | {id: .pixel_id, name: .pixel_name, code: .pixel_code, mode: .pixel_mode}]' <<<"$pixel_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.data.list // [])[] | {id: .audience_id, name: .name, type: .audience_type, size: (.cover_num // 0), status: .audience_sub_type}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg adv "$adv_id" \
    --argjson campaigns "$campaigns" \
    --argjson pixels "$pixels" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.tiktok",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "tiktok",
      account: { advertiser_id: $adv },
      campaigns: $campaigns,
      conversion_goals: { pixels: $pixels, note: "Standard events (CompletePayment, Purchase, AddToCart, etc.) reported via /pixel/event/stats/." },
      audiences: $audiences,
      attribution: { default_window: "7d_click_1d_view", note: "Configure in TikTok Ads Manager > Account Settings > Attribution." },
      hint: "for full state, run: state platform tiktok full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "tiktok",
  "patterns": {
    "init": "ttq\\.load\\s*\\(\\s*[\"']([A-Z0-9]+)[\"']",
    "library": "analytics\\.tiktok\\.com/i18n/pixel/events\\.js",
    "ttq_global": "ttq\\s*=\\s*window\\.ttq"
  },
  "consent_partner": true,
  "consent_method": "ttq.load with disableAutoPageView, gate via cookie consent. Supports Limited Data Use (LDU) flag for CCPA."
}
JSON
}
