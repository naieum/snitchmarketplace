# lib/platforms/x.sh — X (Twitter) Ads API helper.
# Auth: OAuth 1.0a (consumer key/secret + access token/secret) — bearer alone is insufficient
#       for Ads API. Some read endpoints accept bearer; mutating + most reads require OAuth1.
# Docs: https://developer.x.com/en/docs/x-ads-api
#
# Exports:
#   platform_state [account-id]
#   platform_pixel_signals

ADSSEC_X_API_BASE="${ADSSEC_X_API_BASE:-https://ads-api.x.com/12}"

# OAuth1 signature (HMAC-SHA1) helper. Inline because bash-friendly OAuth1 libs are rare.
# Args: method url consumer_key consumer_secret access_token access_token_secret
# Echoes the value of the Authorization: header.
_x_oauth1_header() {
  local method="$1" url="$2" ck="$3" cs="$4" at="$5" ats="$6"
  local nonce ts
  nonce="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom 2>/dev/null | head -c 32 || printf '%s' "$(date +%s%N)")"
  ts="$(date +%s)"

  # Split URL into base + query string.
  local base_url qs
  base_url="${url%%\?*}"
  qs=""
  [[ "$url" == *\?* ]] && qs="${url#*\?}"

  # Collect oauth_* params + query params, percent-encode keys+values, sort, join with '&'.
  local params=()
  params+=("oauth_consumer_key=${ck}")
  params+=("oauth_nonce=${nonce}")
  params+=("oauth_signature_method=HMAC-SHA1")
  params+=("oauth_timestamp=${ts}")
  params+=("oauth_token=${at}")
  params+=("oauth_version=1.0")

  if [[ -n "$qs" ]]; then
    local IFS='&'
    local pair
    for pair in $qs; do params+=("$pair"); done
  fi

  # Percent-encode each param's key and value separately, then sort.
  local enc_params=() raw k v ek ev
  for raw in "${params[@]}"; do
    k="${raw%%=*}"
    v=""
    [[ "$raw" == *=* ]] && v="${raw#*=}"
    ek="$(printf '%s' "$k" | jq -sRr @uri)"
    ev="$(printf '%s' "$v" | jq -sRr @uri)"
    enc_params+=("${ek}=${ev}")
  done
  local sorted; sorted="$(printf '%s\n' "${enc_params[@]}" | LC_ALL=C sort | paste -sd'&' -)"

  # Build signature base string.
  local enc_base_url enc_params_str sig_base
  enc_base_url="$(printf '%s' "$base_url" | jq -sRr @uri)"
  enc_params_str="$(printf '%s' "$sorted" | jq -sRr @uri)"
  sig_base="${method}&${enc_base_url}&${enc_params_str}"

  # Signing key = encode(cs)&encode(ats)
  local enc_cs enc_ats key
  enc_cs="$(printf '%s' "$cs" | jq -sRr @uri)"
  enc_ats="$(printf '%s' "$ats" | jq -sRr @uri)"
  key="${enc_cs}&${enc_ats}"

  # HMAC-SHA1, base64.
  local sig
  sig="$(printf '%s' "$sig_base" | openssl dgst -sha1 -hmac "$key" -binary 2>/dev/null | base64)"
  local sig_enc; sig_enc="$(printf '%s' "$sig" | jq -sRr @uri)"

  printf 'OAuth oauth_consumer_key="%s", oauth_nonce="%s", oauth_signature="%s", oauth_signature_method="HMAC-SHA1", oauth_timestamp="%s", oauth_token="%s", oauth_version="1.0"' \
    "$ck" "$nonce" "$sig_enc" "$ts" "$at"
}

_x_http_get_oauth1() {
  local url="$1"
  local hdr; hdr="$(_x_oauth1_header GET "$url" "$X_ADS_CONSUMER_KEY" "$X_ADS_CONSUMER_SECRET" "$X_ADS_BEARER_TOKEN" "$X_ADS_ACCESS_TOKEN_SECRET")"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -H "Authorization: ${hdr}" \
    "$url" 2>/dev/null || echo "000")
  local body; body="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$body"
}

platform_state() {
  local acct_id="${1:-${X_ADS_ACCOUNT_ID:-}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${X_ADS_BEARER_TOKEN:-}" \
     || -z "${X_ADS_CONSUMER_KEY:-}" \
     || -z "${X_ADS_CONSUMER_SECRET:-}" \
     || -z "${X_ADS_ACCESS_TOKEN_SECRET:-}" \
     || -z "$acct_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.x",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "x",
      locked: "x-api",
      reason: "X Ads API auth env not configured. X Ads API uses OAuth 1.0a — bearer alone is insufficient.",
      remediation: "Export X_ADS_BEARER_TOKEN (= access token), X_ADS_ACCOUNT_ID, X_ADS_CONSUMER_KEY, X_ADS_CONSUMER_SECRET, X_ADS_ACCESS_TOKEN_SECRET. Apply for Ads API access: https://developer.x.com/en/docs/x-ads-api/getting-started",
      env_required: ["X_ADS_BEARER_TOKEN","X_ADS_ACCOUNT_ID","X_ADS_CONSUMER_KEY","X_ADS_CONSUMER_SECRET","X_ADS_ACCESS_TOKEN_SECRET"]
    }'
    return 0
  fi

  if ! command -v openssl >/dev/null 2>&1; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.x",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "x",
      locked: "x-api",
      reason: "openssl required for OAuth 1.0a HMAC-SHA1 signing; not found on PATH.",
      remediation: "Install openssl (brew install openssl@3 / apt-get install openssl)."
    }'
    return 0
  fi

  local camp_url="${ADSSEC_X_API_BASE}/accounts/${acct_id}/campaigns?count=200"
  local fund_url="${ADSSEC_X_API_BASE}/accounts/${acct_id}/funding_instruments"
  local aud_url="${ADSSEC_X_API_BASE}/accounts/${acct_id}/custom_audiences?count=100"

  local camp_resp fund_resp aud_resp
  camp_resp="$(_x_http_get_oauth1 "$camp_url" | tail -n +2)"
  fund_resp="$(_x_http_get_oauth1 "$fund_url" | tail -n +2)"
  aud_resp="$(_x_http_get_oauth1 "$aud_url" | tail -n +2)"

  local campaigns funding audiences
  campaigns="$(jq '[(.data // [])[] | {id, name, entity_status, daily_budget_amount_local_micro, total_budget_amount_local_micro, start_time, end_time, servable, paused: .paused}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  funding="$(jq '[(.data // [])[] | {id, type, description, currency, paused, account_balance_local_micro: .funded_amount_local_micro}]' <<<"$fund_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.data // [])[] | {id, name, audience_size, audience_type, targetable, list_type: .list_type}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg acct "$acct_id" \
    --argjson campaigns "$campaigns" \
    --argjson funding "$funding" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.x",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "x",
      account: { account_id: $acct },
      campaigns: $campaigns,
      conversion_goals: { note: "Web conversions configured per pixel event; query /accounts/<id>/web_event_tags for tag inventory." },
      audiences: $audiences,
      funding: $funding,
      attribution: { default_window: "7d", note: "Configurable per-conversion-event 1d / 7d / 14d windows." },
      hint: "for full state, run: state platform x full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "x",
  "patterns": {
    "init": "twq\\s*\\(\\s*[\"']config[\"']\\s*,\\s*[\"']([a-z0-9]+)[\"']",
    "legacy_init": "twq\\s*\\(\\s*[\"']init[\"']\\s*,\\s*[\"']([a-z0-9]+)[\"']",
    "library": "static\\.ads-twitter\\.com/uwt\\.js"
  },
  "consent_partner": false,
  "consent_method": "Gate uwt.js load behind consent; X does not expose a runtime consent API."
}
JSON
}
