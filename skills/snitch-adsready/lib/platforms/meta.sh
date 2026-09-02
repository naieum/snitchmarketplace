# lib/platforms/meta.sh — Meta (Facebook / Instagram) Marketing API helper.
# Auth: long-lived system-user access token (or page/user token) + ad account id.
#       App secret strongly recommended for appsecret_proof (token tamper protection).
# Docs: https://developers.facebook.com/docs/marketing-api/get-started
#
# Exports:
#   platform_state [act-id]
#   platform_pixel_signals

# Graph API version. Single source of truth for the meta calls in this skill;
# the capi-stub templates read META_GRAPH_VERSION from the environment with the
# same default. Latest as of 2026-09-01 (v26.0, released 2026-07-29):
# https://developers.facebook.com/docs/graph-api/changelog
ADSSEC_META_VERSION="${ADSSEC_META_VERSION:-v26.0}"
ADSSEC_META_API_BASE="${ADSSEC_META_API_BASE:-https://graph.facebook.com/${ADSSEC_META_VERSION}}"

# Compute appsecret_proof = HMAC-SHA256(access_token, app_secret) hex.
_meta_appsecret_proof() {
  local tok="$1" secret="$2"
  if [[ -z "$secret" ]]; then return 0; fi
  if command -v openssl >/dev/null 2>&1; then
    printf '%s' "$tok" | openssl dgst -sha256 -hmac "$secret" 2>/dev/null | awk '{print $NF}'
  fi
}

_meta_http_get() {
  local url="$1"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' "$url" 2>/dev/null || echo "000")
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

platform_state() {
  local act_id="${1:-${META_AD_ACCOUNT_ID:-}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${META_ACCESS_TOKEN:-}" || -z "$act_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.meta",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "meta",
      locked: "meta-api",
      reason: "Meta Marketing API auth env not configured.",
      remediation: "Export META_ACCESS_TOKEN (long-lived system-user token) and META_AD_ACCOUNT_ID (act_<id>). META_APP_SECRET optional but recommended for appsecret_proof. See https://developers.facebook.com/docs/marketing-api/system-users",
      env_required: ["META_ACCESS_TOKEN","META_AD_ACCOUNT_ID","META_APP_SECRET"]
    }'
    return 0
  fi

  # Normalize ad account id (must be act_<digits>).
  local act="$act_id"
  [[ "$act" != act_* ]] && act="act_${act}"

  local tok="$META_ACCESS_TOKEN"
  local proof=""
  if [[ -n "${META_APP_SECRET:-}" ]]; then
    proof="$(_meta_appsecret_proof "$tok" "$META_APP_SECRET")"
  fi
  local proof_qs=""
  [[ -n "$proof" ]] && proof_qs="&appsecret_proof=${proof}"

  local camp_url="${ADSSEC_META_API_BASE}/${act}/campaigns?fields=id,name,status,objective,buying_type,bid_strategy,special_ad_categories&limit=200&access_token=${tok}${proof_qs}"
  local pixel_url="${ADSSEC_META_API_BASE}/${act}/adspixels?fields=id,name,code,is_unavailable,last_fired_time&access_token=${tok}${proof_qs}"
  local audience_url="${ADSSEC_META_API_BASE}/${act}/customaudiences?fields=id,name,subtype,approximate_count_lower_bound,delivery_status,operation_status&limit=100&access_token=${tok}${proof_qs}"

  local camp_resp pixel_resp aud_resp
  camp_resp="$(_meta_http_get "$camp_url" | tail -n +2)"
  pixel_resp="$(_meta_http_get "$pixel_url" | tail -n +2)"
  aud_resp="$(_meta_http_get "$audience_url" | tail -n +2)"

  local campaigns pixels audiences
  campaigns="$(jq '[(.data // [])[] | {id, name, status, objective, buying_type, bid_strategy, special_ad_categories}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  pixels="$(jq '[(.data // [])[] | {id, name, last_fired_time, is_unavailable}]' <<<"$pixel_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.data // [])[] | {id, name, subtype, size_lower: .approximate_count_lower_bound, delivery: .delivery_status, op: .operation_status}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg act "$act" \
    --argjson campaigns "$campaigns" \
    --argjson pixels "$pixels" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.meta",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "meta",
      account: { ad_account_id: $act },
      campaigns: $campaigns,
      conversion_goals: { pixels: $pixels, note: "Standard + custom events live under each pixel; query /<pixel-id>/stats for breakdown." },
      audiences: $audiences,
      attribution: { default_window: "7d_click_1d_view", note: "Per-ad-set; see /act_<id>/insights with attribution_windows param." },
      hint: "for full state, run: state platform meta full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "meta",
  "patterns": {
    "init": "fbq\\s*\\(\\s*[\"']init[\"']\\s*,\\s*[\"']([0-9]+)",
    "library": "connect\\.facebook\\.net/[a-z_]+/fbevents\\.js",
    "noscript_pixel": "facebook\\.com/tr\\?id=([0-9]+)"
  },
  "consent_partner": false,
  "consent_method": "fbq('consent','grant'|'revoke') — Meta integrates with Consent Mode v2 via Google's API"
}
JSON
}
