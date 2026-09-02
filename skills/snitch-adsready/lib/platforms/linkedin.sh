# lib/platforms/linkedin.sh — LinkedIn Marketing API helper.
# Auth: OAuth2 access token (member or 3-legged) + ad account id.
# Versioned API requires a `LinkedIn-Version: YYYYMM` header; ADSSEC_LI_VERSION
# below is the single source of truth for it in this skill.
# Docs: https://learn.microsoft.com/en-us/linkedin/marketing/
#
# Exports:
#   platform_state [account-id]
#   platform_pixel_signals

ADSSEC_LI_API_BASE="${ADSSEC_LI_API_BASE:-https://api.linkedin.com/rest}"
# Latest version as of 2026-09-01; LinkedIn supports each version for at least
# 12 months. https://learn.microsoft.com/en-us/linkedin/marketing/versioning
ADSSEC_LI_VERSION="${ADSSEC_LI_VERSION:-202608}"

_li_http_get() {
  local url="$1" auth="$2"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -H "Authorization: Bearer ${auth}" \
    -H "LinkedIn-Version: ${ADSSEC_LI_VERSION}" \
    -H "X-Restli-Protocol-Version: 2.0.0" \
    -H "Accept: application/json" \
    "$url" 2>/dev/null || echo "000")
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

platform_state() {
  # Canonical env names are LINKEDIN_ADS_* (what doctor/prereqs check); the
  # unprefixed account id is accepted as a legacy fallback.
  local token="${LINKEDIN_ADS_ACCESS_TOKEN:-}"
  local acct_id="${1:-${LINKEDIN_ADS_ACCOUNT_ID:-${LINKEDIN_ACCOUNT_ID:-}}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$token" || -z "$acct_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.linkedin",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "linkedin",
      locked: "linkedin-api",
      reason: "LinkedIn Marketing API auth env not configured.",
      remediation: "Export LINKEDIN_ADS_ACCESS_TOKEN (OAuth2 access token, scopes r_ads + r_ads_reporting) and LINKEDIN_ADS_ACCOUNT_ID. Apply for Marketing Developer Platform access first: https://learn.microsoft.com/en-us/linkedin/marketing/getting-access",
      env_required: ["LINKEDIN_ADS_ACCESS_TOKEN","LINKEDIN_ADS_ACCOUNT_ID"]
    }'
    return 0
  fi

  local at="$token"
  local urn="urn:li:sponsoredAccount:${acct_id}"
  local urn_enc; urn_enc=$(printf '%s' "$urn" | jq -sRr @uri)

  local camp_url="${ADSSEC_LI_API_BASE}/adAccounts/${acct_id}/adCampaigns?q=search&search=(status:(values:List(ACTIVE,PAUSED,DRAFT)))&pageSize=100"
  local conv_url="${ADSSEC_LI_API_BASE}/conversions?q=account&account=${urn_enc}&pageSize=100"
  local aud_url="${ADSSEC_LI_API_BASE}/adAccounts/${acct_id}/dmpSegments?q=account&pageSize=100"

  local camp_resp conv_resp aud_resp
  camp_resp="$(_li_http_get "$camp_url" "$at" | tail -n +2)"
  conv_resp="$(_li_http_get "$conv_url" "$at" | tail -n +2)"
  aud_resp="$(_li_http_get "$aud_url" "$at" | tail -n +2)"

  local campaigns goals audiences
  campaigns="$(jq '[(.elements // [])[] | {id, name, status, type, costType, dailyBudget: (.dailyBudget.amount // null), objective: .objectiveType}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  goals="$(jq '[(.elements // [])[] | {id, name, type, enabled, attributionType: .attributionType, postClickWindow: .postClickAttributionWindowSize, viewThroughWindow: .viewThroughAttributionWindowSize}]' <<<"$conv_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.elements // [])[] | {id, name, type, status, sourceSegmentId: .sourceSegmentId, audienceCount: .audienceCount}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg acct "$acct_id" \
    --argjson campaigns "$campaigns" \
    --argjson goals "$goals" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.linkedin",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "linkedin",
      account: { account_id: $acct, urn: ("urn:li:sponsoredAccount:" + $acct) },
      campaigns: $campaigns,
      conversion_goals: $goals,
      audiences: $audiences,
      attribution: { note: "Per-conversion postClick + viewThrough windows; configurable 1/7/30/90 days." },
      hint: "for full state, run: state platform linkedin full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "linkedin",
  "patterns": {
    "partner_id": "_linkedin_partner_id\\s*=\\s*[\"']([0-9]+)[\"']",
    "data_partner_ids": "_linkedin_data_partner_ids",
    "library": "snap\\.licdn\\.com/li\\.lms-analytics/insight\\.min\\.js",
    "noscript_pixel": "px\\.ads\\.linkedin\\.com/collect/?\\?pid=([0-9]+)"
  },
  "consent_partner": false,
  "consent_method": "Manual gate before loading insight.min.js; Insight Tag itself does not honor automatic consent signals."
}
JSON
}
