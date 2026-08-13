# lib/prereqs.sh — list local CLI tools, optional helpers, and per-platform auth env vars.
# Read-only. Reports which capabilities are unlocked.
#
# Exports:
#   run_prereqs

# _prereqs_have <cmd> -> "true" / "false"
_prereqs_have() {
  command -v "$1" >/dev/null 2>&1 && printf 'true' || printf 'false'
}

# _prereqs_env_present <var...> -> "true" if all set non-empty.
_prereqs_env_present() {
  local v
  for v in "$@"; do
    if [[ -z "${!v:-}" ]]; then
      printf 'false'
      return 0
    fi
  done
  printf 'true'
}

run_prereqs() {
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  local curl_present jq_present lighthouse_present pup_present htmlq_present gh_present openssl_present
  curl_present="$(_prereqs_have curl)"
  jq_present="$(_prereqs_have jq)"
  lighthouse_present="$(_prereqs_have lighthouse)"
  pup_present="$(_prereqs_have pup)"
  htmlq_present="$(_prereqs_have htmlq)"
  gh_present="$(_prereqs_have gh)"
  openssl_present="$(_prereqs_have openssl)"

  local psi_key_present ga4_auth_present gsc_auth_present
  psi_key_present="$(_prereqs_env_present PSI_API_KEY)"
  ga4_auth_present="$(_prereqs_env_present GA4_AUTH)"
  gsc_auth_present="$(_prereqs_env_present GOOGLE_GSC_AUTH)"

  # Per-platform auth (one canonical env var per platform; some platforms need more — listed in env_vars).
  local google_present meta_present microsoft_present linkedin_present tiktok_present x_present pinterest_present reddit_present snapchat_present apple_present
  google_present="$(_prereqs_env_present GOOGLE_ADS_DEVELOPER_TOKEN GOOGLE_ADS_REFRESH_TOKEN GOOGLE_ADS_CLIENT_ID GOOGLE_ADS_CLIENT_SECRET)"
  meta_present="$(_prereqs_env_present META_ACCESS_TOKEN META_AD_ACCOUNT_ID)"
  microsoft_present="$(_prereqs_env_present MICROSOFT_ADS_DEVELOPER_TOKEN MICROSOFT_ADS_REFRESH_TOKEN MICROSOFT_ADS_CLIENT_ID)"
  linkedin_present="$(_prereqs_env_present LINKEDIN_ADS_ACCESS_TOKEN)"
  tiktok_present="$(_prereqs_env_present TIKTOK_ADS_ACCESS_TOKEN TIKTOK_ADS_ADVERTISER_ID)"
  x_present="$(_prereqs_env_present X_ADS_ACCESS_TOKEN X_ADS_ACCESS_TOKEN_SECRET X_ADS_CONSUMER_KEY X_ADS_CONSUMER_SECRET X_ADS_ACCOUNT_ID)"
  pinterest_present="$(_prereqs_env_present PINTEREST_ADS_ACCESS_TOKEN PINTEREST_ADS_ADVERTISER_ID)"
  reddit_present="$(_prereqs_env_present REDDIT_ADS_ACCESS_TOKEN REDDIT_ADS_ACCOUNT_ID)"
  snapchat_present="$(_prereqs_env_present SNAPCHAT_ADS_ACCESS_TOKEN SNAPCHAT_ADS_AD_ACCOUNT_ID)"
  apple_present="$(_prereqs_env_present APPLE_SEARCH_ADS_PRIVATE_KEY APPLE_SEARCH_ADS_TEAM_ID APPLE_SEARCH_ADS_KEY_ID APPLE_SEARCH_ADS_CLIENT_ID)"

  jq -n \
    --arg ts "$ts" \
    --argjson curl_present "$curl_present" \
    --argjson jq_present "$jq_present" \
    --argjson lighthouse_present "$lighthouse_present" \
    --argjson pup_present "$pup_present" \
    --argjson htmlq_present "$htmlq_present" \
    --argjson gh_present "$gh_present" \
    --argjson openssl_present "$openssl_present" \
    --argjson psi_key_present "$psi_key_present" \
    --argjson ga4_auth_present "$ga4_auth_present" \
    --argjson gsc_auth_present "$gsc_auth_present" \
    --argjson google_present "$google_present" \
    --argjson meta_present "$meta_present" \
    --argjson microsoft_present "$microsoft_present" \
    --argjson linkedin_present "$linkedin_present" \
    --argjson tiktok_present "$tiktok_present" \
    --argjson x_present "$x_present" \
    --argjson pinterest_present "$pinterest_present" \
    --argjson reddit_present "$reddit_present" \
    --argjson snapchat_present "$snapchat_present" \
    --argjson apple_present "$apple_present" \
    '{
      schema: "adssec.prereqs",
      schema_version: 1,
      generated_at: $ts,
      tool: "prereqs",
      required: [
        { tool: "curl", present: $curl_present,
          install_hint: { macos: "brew install curl",
                          linux: "apt-get install curl  (Debian/Ubuntu)  or  dnf install curl  (Fedora)",
                          windows: "winget install curl  (or use WSL)" } },
        { tool: "jq", present: $jq_present,
          install_hint: { macos: "brew install jq",
                          linux: "apt-get install jq  or  dnf install jq",
                          windows: "winget install jqlang.jq  (or use WSL)" } }
      ],
      optional: [
        { tool: "lighthouse", present: $lighthouse_present,
          install_hint: { macos: "npm i -g lighthouse",
                          linux: "npm i -g lighthouse",
                          windows: "npm i -g lighthouse" },
          unlocks: ["state lighthouse <url> (full audit JSON instead of PSI fallback)"] },
        { tool: "pup", present: $pup_present,
          install_hint: { macos: "brew install pup",
                          linux: "go install github.com/ericchiang/pup@latest",
                          windows: "go install github.com/ericchiang/pup@latest" },
          unlocks: ["state site <url> richer HTML parsing for pixel signature detection"] },
        { tool: "htmlq", present: $htmlq_present,
          install_hint: { macos: "brew install htmlq",
                          linux: "cargo install htmlq",
                          windows: "cargo install htmlq" },
          unlocks: ["state site <url> CSS-selector parsing alongside pup"] },
        { tool: "gh", present: $gh_present,
          install_hint: { macos: "brew install gh",
                          linux: "see https://github.com/cli/cli/blob/trunk/docs/install_linux.md",
                          windows: "winget install GitHub.cli" },
          unlocks: ["fix gha (drop-in GitHub Actions workflow)"] },
        { tool: "openssl", present: $openssl_present,
          install_hint: { macos: "preinstalled (/usr/bin/openssl) or brew install openssl",
                          linux: "preinstalled or apt-get install openssl",
                          windows: "winget install ShiningLight.OpenSSL  (or use WSL)" },
          unlocks: ["Meta CAPI appsecret_proof, Apple Search Ads JWT signing"] },
        { tool: "PSI_API_KEY (env)", present: $psi_key_present,
          install_hint: { macos: "Get a key at https://developers.google.com/speed/docs/insights/v5/get-started; export PSI_API_KEY=<key>",
                          linux: "Same as macOS",
                          windows: "Same as macOS" },
          unlocks: ["Higher PSI API quota for state crux (works without a key, just lower quota)"] },
        { tool: "GA4_AUTH (env)", present: $ga4_auth_present,
          install_hint: { macos: "Service-account JSON or OAuth refresh-token JSON; set GA4_AUTH to the path or the JSON itself",
                          linux: "Same",
                          windows: "Same" },
          unlocks: ["analytics ga4 <property-id>"] },
        { tool: "GOOGLE_GSC_AUTH (env)", present: $gsc_auth_present,
          install_hint: { macos: "Service-account JSON or OAuth refresh-token JSON; set GOOGLE_GSC_AUTH",
                          linux: "Same",
                          windows: "Same" },
          unlocks: ["state gsc [property]"] }
      ],
      platform_auth: [
        { platform: "google", env_vars: ["GOOGLE_ADS_DEVELOPER_TOKEN","GOOGLE_ADS_REFRESH_TOKEN","GOOGLE_ADS_CLIENT_ID","GOOGLE_ADS_CLIENT_SECRET","GOOGLE_ADS_LOGIN_CUSTOMER_ID"], present: $google_present, signup_url: "https://developers.google.com/google-ads/api/docs/first-call/dev-token" },
        { platform: "meta", env_vars: ["META_ACCESS_TOKEN","META_AD_ACCOUNT_ID","META_APP_SECRET"], present: $meta_present, signup_url: "https://developers.facebook.com/docs/marketing-api/system-users" },
        { platform: "microsoft", env_vars: ["MICROSOFT_ADS_DEVELOPER_TOKEN","MICROSOFT_ADS_REFRESH_TOKEN","MICROSOFT_ADS_CLIENT_ID","MICROSOFT_ADS_CUSTOMER_ID","MICROSOFT_ADS_ACCOUNT_ID"], present: $microsoft_present, signup_url: "https://learn.microsoft.com/en-us/advertising/guides/get-started" },
        { platform: "linkedin", env_vars: ["LINKEDIN_ADS_ACCESS_TOKEN","LINKEDIN_ADS_ACCOUNT_ID"], present: $linkedin_present, signup_url: "https://learn.microsoft.com/en-us/linkedin/marketing/getting-access" },
        { platform: "tiktok", env_vars: ["TIKTOK_ADS_ACCESS_TOKEN","TIKTOK_ADS_ADVERTISER_ID"], present: $tiktok_present, signup_url: "https://business-api.tiktok.com/portal/docs?id=1738373141733378" },
        { platform: "x", env_vars: ["X_ADS_CONSUMER_KEY","X_ADS_CONSUMER_SECRET","X_ADS_ACCESS_TOKEN","X_ADS_ACCESS_TOKEN_SECRET","X_ADS_ACCOUNT_ID"], present: $x_present, signup_url: "https://developer.twitter.com/en/docs/twitter-ads-api/getting-started" },
        { platform: "pinterest", env_vars: ["PINTEREST_ADS_ACCESS_TOKEN","PINTEREST_ADS_ADVERTISER_ID"], present: $pinterest_present, signup_url: "https://developers.pinterest.com/docs/api/v5/" },
        { platform: "reddit", env_vars: ["REDDIT_ADS_ACCESS_TOKEN","REDDIT_ADS_ACCOUNT_ID"], present: $reddit_present, signup_url: "https://ads-api.reddit.com/docs/v3/" },
        { platform: "snapchat", env_vars: ["SNAPCHAT_ADS_ACCESS_TOKEN","SNAPCHAT_ADS_AD_ACCOUNT_ID"], present: $snapchat_present, signup_url: "https://marketingapi.snapchat.com/docs/" },
        { platform: "apple", env_vars: ["APPLE_SEARCH_ADS_PRIVATE_KEY","APPLE_SEARCH_ADS_TEAM_ID","APPLE_SEARCH_ADS_KEY_ID","APPLE_SEARCH_ADS_CLIENT_ID","APPLE_SEARCH_ADS_ORG_ID"], present: $apple_present, signup_url: "https://developer.apple.com/documentation/apple_search_ads" }
      ]
    }'
}
