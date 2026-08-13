# lib/platforms/microsoft.sh — Microsoft Advertising (Bing Ads) Campaign Management API helper.
# Auth: developer token + customer/account id + OAuth2 access token.
# Docs: https://learn.microsoft.com/en-us/advertising/guides/get-started
#
# Exports:
#   platform_state [customer-id]
#   platform_pixel_signals

ADSSEC_MS_API_BASE="${ADSSEC_MS_API_BASE:-https://campaign.api.bingads.microsoft.com/CampaignManagement/v13}"

_ms_http_post() {
  local url="$1" auth="$2" dev_token="$3" cust="$4" body="$5" acct="${6:-}"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -o "$tmp" -w '%{http_code}' \
    -X POST \
    -H "Authorization: Bearer ${auth}" \
    -H "DeveloperToken: ${dev_token}" \
    -H "CustomerId: ${cust}" \
    ${acct:+-H "CustomerAccountId: ${acct}"} \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    --data "$body" \
    "$url" 2>/dev/null || echo "000")
  local resp; resp="$(cat "$tmp")"
  rm -f "$tmp"
  printf '%s\n%s\n' "$code" "$resp"
}

platform_state() {
  local cust_id="${1:-${MICROSOFT_ADS_CUSTOMER_ID:-}}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${MICROSOFT_ADS_DEVELOPER_TOKEN:-}" \
     || -z "${MICROSOFT_ADS_ACCESS_TOKEN:-}" \
     || -z "$cust_id" ]]; then
    jq -n --arg ts "$ts" '{
      schema: "adssec.state-platform.microsoft",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "microsoft",
      locked: "microsoft-api",
      reason: "Microsoft Advertising API auth env not configured.",
      remediation: "Export MICROSOFT_ADS_DEVELOPER_TOKEN, MICROSOFT_ADS_CUSTOMER_ID, MICROSOFT_ADS_ACCESS_TOKEN. Optionally MICROSOFT_ADS_ACCOUNT_ID for sub-account context. See https://learn.microsoft.com/en-us/advertising/guides/get-started",
      env_required: ["MICROSOFT_ADS_DEVELOPER_TOKEN","MICROSOFT_ADS_CUSTOMER_ID","MICROSOFT_ADS_ACCESS_TOKEN"]
    }'
    return 0
  fi

  local at="$MICROSOFT_ADS_ACCESS_TOKEN"
  local dt="$MICROSOFT_ADS_DEVELOPER_TOKEN"
  local acct="${MICROSOFT_ADS_ACCOUNT_ID:-0}"

  # REST binding of Campaign Management v13 (SOAP is feature-frozen Oct 1 2026,
  # decommissioned Jan 31 2027). Paths follow Get<Entity>ByX → <Entity>/QueryByX.
  local camp_body
  camp_body="$(jq -n --arg acct "$acct" '{AccountId:($acct|tonumber? // 0), CampaignType:"Search Shopping DynamicSearchAds Audience PerformanceMax"}')"
  local goal_body='{"ConversionGoalIds":null,"ConversionGoalTypes":"Url Duration PagesViewedPerVisit Event AppInstall OfflineConversion InStoreTransaction"}'
  local aud_body='{"AudienceIds":null,"Type":"RemarketingList Custom InMarket Product SimilarRemarketingList CombinedList CustomerList ImpressionBasedRemarketingList CustomSegment"}'

  local camp_resp goal_resp aud_resp
  camp_resp="$(_ms_http_post "${ADSSEC_MS_API_BASE}/Campaigns/QueryByAccountId" "$at" "$dt" "$cust_id" "$camp_body" "$acct" | tail -n +2)"
  goal_resp="$(_ms_http_post "${ADSSEC_MS_API_BASE}/ConversionGoals/QueryByIds" "$at" "$dt" "$cust_id" "$goal_body" "$acct" | tail -n +2)"
  aud_resp="$(_ms_http_post "${ADSSEC_MS_API_BASE}/Audiences/QueryByIds" "$at" "$dt" "$cust_id" "$aud_body" "$acct" | tail -n +2)"

  local campaigns goals audiences
  campaigns="$(jq '[(.Campaigns // [])[] | {id: .Id, name: .Name, status: .Status, type: .CampaignType, budget: .DailyBudget, bidStrategy: (.BiddingScheme.Type // null)}]' <<<"$camp_resp" 2>/dev/null || printf '[]')"
  goals="$(jq '[(.ConversionGoals // [])[] | {id: .Id, name: .Name, status: .Status, type: .Type, scope: .Scope, category: .Category, isOfflineConversion: (.IsOfflineConversion // false)}]' <<<"$goal_resp" 2>/dev/null || printf '[]')"
  audiences="$(jq '[(.Audiences // [])[] | {id: .Id, name: .Name, type: .Type, scope: .Scope, size: .MembershipDuration}]' <<<"$aud_resp" 2>/dev/null || printf '[]')"

  jq -n \
    --arg ts "$ts" \
    --arg cust "$cust_id" \
    --arg acct "$acct" \
    --argjson campaigns "$campaigns" \
    --argjson goals "$goals" \
    --argjson audiences "$audiences" \
    '{
      schema: "adssec.state-platform.microsoft",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-platform",
      platform: "microsoft",
      account: { customer_id: $cust, account_id: $acct },
      campaigns: $campaigns,
      conversion_goals: $goals,
      audiences: $audiences,
      attribution: { note: "Microsoft uses last-click by default; configure in account-level Conversion Goals." },
      hint: "for full state, run: state platform microsoft full"
    }'
}

platform_pixel_signals() {
  cat <<'JSON'
{
  "platform": "microsoft",
  "patterns": {
    "init": "uetq\\.push\\s*\\(",
    "tag_id": "[\"']ti[\"']\\s*:\\s*[\"']([0-9]+)[\"']",
    "library": "bat\\.bing\\.com/bat\\.js",
    "uetq_global": "var\\s+uetq\\s*="
  },
  "consent_partner": true,
  "consent_method": "window.uetq.push('consent', 'update', { ad_storage: 'granted'|'denied' }) — UET integrates with Google Consent Mode v2"
}
JSON
}
