# lib/platforms/snapchat.sh — Snap Marketing API helper.
# Auth: OAuth2 access token + ad account id.
# Docs: https://marketingapi.snapchat.com/docs/
#
# Exports:
#   platform_state [ad-account-id]
#   platform_pixel_signals

ADSSEC_SNAP_API_BASE="${ADSSEC_SNAP_API_BASE:-https://adsapi.snapchat.com/v1}"

_snap_http_get() {
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
  local acct_id="${1:-${SNAPCHAT_AD_ACCOUNT_ID:-}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${SNAPCHAT_ACCESS_TOKEN:-}" || -z "$acct_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.snapchat",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "snapchat",
      locked: "snapchat-api",
      reason: "Snap Marketing API auth env not configured.",
      remediation: "Export SNAPCHAT_ACCESS_TOKEN (OAuth2; scope snapchat-marketing-api) and SNAPCHAT_AD_ACCOUNT_ID. See https://marketingapi.snapchat.com/docs/#authentication",
      env_required: ["SNAPCHAT_ACCESS_TOKEN","SNAPCHAT_AD_ACCOUNT_ID"]
    }'
    return 0
  fi

  local at="$SNAPCHAT_ACCESS_TOKEN"
  local camp_url="${ADSSEC_SNAP_API_BASE}/adaccounts/${acct_id}/campaigns?limit=100"
  local pixel_url="${ADSSEC_SNAP_API_BASE}/adaccounts/${acct_id}/pixels"
  local aud_url="${ADSSEC_SNAP_API_BASE}/adaccounts/${acct_id}/segments?limit=100"

  local camp_resp pix_resp aud_resp
  camp_resp="$(_snap_http_get "$camp_url" "$at" | tail -n +2)"
  pix_resp="$(_snap_http_get "$pixel_url" "$at" | tail -n +2)"
  aud_resp="$(_snap_http_get "$aud_url" "$at" | tail -n +2)"

  local campaigns pixels audiences
  campaigns="$(jq '[(.campaigns // [])[] | .campaign | {id, name, status, objective, daily_budget_micro, lifetime_spend_cap_micro, start_time, end_time}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  pixels="$(jq '[(.pixels // [])[] | .pixel | {id, name, status, effective_status, last_fire_time}]' <<<"$pix_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.segments // [])[] | .segment | {id, name, source_type, status, approximate_number_users: .targetable_status}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg acct "$acct_id" \
    --argjson campaigns "$campaigns" \
    --argjson pixels "$pixels" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.snapchat",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "snapchat",
      account: { ad_account_id: $acct },
      campaigns: $campaigns,
      conversion_goals: { pixels: $pixels, note: "Snap supports CAPI (Conversions API) for server-side events; standard events PURCHASE / SIGN_UP / etc." },
      audiences: $audiences,
      attribution: { default_window: "28d_swipe_1d_view", note: "Common for retail; tune per objective in Snap Ads Manager." },
      hint: "for full state, run: state platform snapchat full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "snapchat",
  "patterns": {
    "init": "snaptr\\s*\\(\\s*[\"']init[\"']\\s*,\\s*[\"']([a-z0-9-]+)[\"']",
    "library": "sc-static\\.net/scevent\\.min\\.js",
    "snaptr_global": "snaptr\\s*=\\s*function"
  },
  "consent_partner": false,
  "consent_method": "Gate scevent.min.js load behind consent. Snap supports user_email / user_phone_number hashed advanced matching."
}
JSON
}
