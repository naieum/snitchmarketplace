# lib/api.sh — generic HTTP helpers + per-capability gating for ads-ready.
# Other libs use these for non-platform-specific HTTP calls (PSI, GSC, generic
# fetches) and to test which API capabilities are available.
#
# Per-platform request signing lives in lib/platforms/<name>.sh.

ADSEC_USER_AGENT="${ADSEC_USER_AGENT:-ads-ready-skill/1}"
ADSEC_LAST_STATUS=""
ADSEC_LAST_BODY=""
ADSEC_CALL_LOG="${STATE_DIR:-${TMPDIR:-/tmp}}/api-calls.log"
ADSEC_HTTP_TIMEOUT="${ADSEC_HTTP_TIMEOUT:-20}"
# A status assigned inside $(…) does not reach the parent shell, so every
# wrapper also writes it here and callers read it with http_last_status.
ADSEC_LAST_STATUS_FILE="${TMPDIR:-/tmp}/adsec_api_status_$$"
adsec_tmp_register "$ADSEC_LAST_STATUS_FILE"

# _api_record_status <code>
_api_record_status() {
  ADSEC_LAST_STATUS="$1"
  printf '%s' "$1" > "$ADSEC_LAST_STATUS_FILE" 2>/dev/null || true
}

# http_last_status — the status of the most recent http_* call, readable after
# the call ran inside a command substitution.
http_last_status() {
  cat "$ADSEC_LAST_STATUS_FILE" 2>/dev/null || printf '000'
}

# --- low-level HTTP wrappers ---

# http_get <url>
# Generic GET. Body on stdout. Status readable via http_last_status.
# Non-2xx returns rc=3.
http_get() {
  local url="$1"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -L \
    --max-time "$ADSEC_HTTP_TIMEOUT" \
    -A "$ADSEC_USER_AGENT" \
    -o "$tmp" -w '%{http_code}' \
    "$url" 2>/dev/null || echo "000")
  _api_record_status "$code"
  ADSEC_LAST_BODY="$(cat "$tmp" 2>/dev/null || printf '')"
  rm -f "$tmp"
  printf '%s\t%s\t%s\t%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "GET" "$url" "$code" \
    >> "$ADSEC_CALL_LOG" 2>/dev/null || true
  printf '%s\n' "$ADSEC_LAST_BODY"
  if [[ "$code" =~ ^2 ]]; then
    return 0
  fi
  return 3
}

# http_post_json <url> <json> [extra_header]
# Generic JSON POST. Body on stdout.
http_post_json() {
  local url="$1" body="$2" hdr="${3:-}"
  local tmp; tmp="$(mktemp)"
  local code
  if [[ -n "$hdr" ]]; then
    code=$(curl -sS -L \
      --max-time "$ADSEC_HTTP_TIMEOUT" \
      -A "$ADSEC_USER_AGENT" \
      -H "Content-Type: application/json" \
      -H "$hdr" \
      -X POST --data "$body" \
      -o "$tmp" -w '%{http_code}' \
      "$url" 2>/dev/null || echo "000")
  else
    code=$(curl -sS -L \
      --max-time "$ADSEC_HTTP_TIMEOUT" \
      -A "$ADSEC_USER_AGENT" \
      -H "Content-Type: application/json" \
      -X POST --data "$body" \
      -o "$tmp" -w '%{http_code}' \
      "$url" 2>/dev/null || echo "000")
  fi
  _api_record_status "$code"
  ADSEC_LAST_BODY="$(cat "$tmp" 2>/dev/null || printf '')"
  rm -f "$tmp"
  printf '%s\t%s\t%s\t%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "POST" "$url" "$code" \
    >> "$ADSEC_CALL_LOG" 2>/dev/null || true
  printf '%s\n' "$ADSEC_LAST_BODY"
  if [[ "$code" =~ ^2 ]]; then
    return 0
  fi
  return 3
}

# fetch_url_html <url>
# GET with redirect following (max 5). Echo body on stdout.
# Status readable via http_last_status; rc=3 on non-2xx; rc=4 on hard transport failure.
fetch_url_html() {
  local url="$1"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -L --max-redirs 5 \
    --max-time "$ADSEC_HTTP_TIMEOUT" \
    -A "$ADSEC_USER_AGENT" \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
    -o "$tmp" -w '%{http_code}' \
    "$url" 2>/dev/null || echo "000")
  _api_record_status "$code"
  ADSEC_LAST_BODY=""
  printf '%s\t%s\t%s\t%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "GET" "$url" "$code" \
    >> "$ADSEC_CALL_LOG" 2>/dev/null || true
  if [[ "$code" == "000" ]]; then
    rm -f "$tmp"
    return 4
  fi
  cat "$tmp"
  rm -f "$tmp"
  if [[ "$code" =~ ^2 ]]; then
    return 0
  fi
  return 3
}

# fetch_url_headers <url>
# Print response headers as text on stdout. Follows redirects.
fetch_url_headers() {
  local url="$1"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -I -L --max-redirs 5 \
    --max-time "$ADSEC_HTTP_TIMEOUT" \
    -A "$ADSEC_USER_AGENT" \
    -o "$tmp" -w '%{http_code}' \
    "$url" 2>/dev/null || echo "000")
  _api_record_status "$code"
  printf '%s\t%s\t%s\t%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "HEAD" "$url" "$code" \
    >> "$ADSEC_CALL_LOG" 2>/dev/null || true
  if [[ "$code" == "000" ]]; then
    rm -f "$tmp"
    return 4
  fi
  cat "$tmp"
  rm -f "$tmp"
  if [[ "$code" =~ ^2 ]]; then
    return 0
  fi
  return 3
}

# --- capability checks (return 0 = present, 1 = missing) ---

has_psi_api_key()         { [[ -n "${PSI_API_KEY:-}" ]]; }
has_lighthouse_cli()      { command -v lighthouse >/dev/null 2>&1; }
has_ga4_auth()            { [[ -n "${GA4_AUTH:-}" ]]; }
has_gsc_auth()            { [[ -n "${GOOGLE_GSC_AUTH:-}" ]]; }

# Per-platform Marketing API auth.
has_google_ads_api() {
  [[ -n "${GOOGLE_ADS_DEVELOPER_TOKEN:-}" \
     && -n "${GOOGLE_ADS_REFRESH_TOKEN:-}" \
     && -n "${GOOGLE_ADS_CLIENT_ID:-}" \
     && -n "${GOOGLE_ADS_CLIENT_SECRET:-}" ]]
}
has_meta_marketing_api() {
  [[ -n "${META_ACCESS_TOKEN:-}" ]]
}
has_microsoft_ads_api() {
  [[ -n "${MICROSOFT_ADS_DEVELOPER_TOKEN:-}" \
     && -n "${MICROSOFT_ADS_ACCESS_TOKEN:-}" ]]
}
has_linkedin_ads_api() {
  [[ -n "${LINKEDIN_ADS_ACCESS_TOKEN:-}" ]]
}
has_tiktok_marketing_api() {
  [[ -n "${TIKTOK_ADS_ACCESS_TOKEN:-${TIKTOK_ACCESS_TOKEN:-}}" ]]
}
has_x_ads_api() {
  [[ -n "${X_ADS_ACCESS_TOKEN:-${X_ADS_BEARER_TOKEN:-}}" \
     && -n "${X_ADS_ACCESS_TOKEN_SECRET:-}" \
     && -n "${X_ADS_CONSUMER_KEY:-}" \
     && -n "${X_ADS_CONSUMER_SECRET:-}" ]]
}
has_pinterest_ads_api() {
  [[ -n "${PINTEREST_ADS_ACCESS_TOKEN:-${PINTEREST_ACCESS_TOKEN:-}}" ]]
}
has_reddit_ads_api() {
  [[ -n "${REDDIT_ADS_ACCESS_TOKEN:-${REDDIT_ACCESS_TOKEN:-}}" ]]
}
has_snapchat_marketing_api() {
  [[ -n "${SNAPCHAT_ADS_ACCESS_TOKEN:-${SNAPCHAT_ACCESS_TOKEN:-}}" ]]
}
has_apple_search_ads_api() {
  # Apple uses JWT with a private-key file. The four names below are exactly
  # what lib/platforms/apple.sh reads — TEAM_ID doubles as the client_id, and
  # ORG_ID scopes the token, so both are required.
  [[ -n "${APPLE_SEARCH_ADS_PRIVATE_KEY:-}" \
     && -n "${APPLE_SEARCH_ADS_KEY_ID:-}" \
     && -n "${APPLE_SEARCH_ADS_TEAM_ID:-}" \
     && -n "${APPLE_SEARCH_ADS_ORG_ID:-}" ]]
}

# Map a capability name to its has_* function.
# Returns 0 if the capability is available; 1 otherwise.
capability_present() {
  local cap="$1"
  case "$cap" in
    psi-api)        has_psi_api_key ;;
    lighthouse)     has_lighthouse_cli ;;
    ga4-api)        has_ga4_auth ;;
    gsc-api)        has_gsc_auth ;;
    google-api)     has_google_ads_api ;;
    meta-api)       has_meta_marketing_api ;;
    microsoft-api)  has_microsoft_ads_api ;;
    linkedin-api)   has_linkedin_ads_api ;;
    tiktok-api)     has_tiktok_marketing_api ;;
    x-api)          has_x_ads_api ;;
    pinterest-api)  has_pinterest_ads_api ;;
    reddit-api)     has_reddit_ads_api ;;
    snapchat-api)   has_snapchat_marketing_api ;;
    apple-api)      has_apple_search_ads_api ;;
    *) return 1 ;;
  esac
}

# doctor_run: foundation check.
doctor_run() {
  local rc=0
  log_section "doctor"
  if ! command -v curl >/dev/null 2>&1; then
    log_fail "doctor" "curl" "curl is required. Install via: brew install curl  (macOS) or apt-get install curl  (Linux)."
    rc=2
  else
    log_ok "doctor" "curl" "curl present."
  fi
  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required. Install via: brew install jq  (macOS) or apt-get install jq  (Linux)."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi

  log_subsection "optional capabilities"

  if has_psi_api_key; then
    log_ok "doctor" "psi-api" "PSI_API_KEY set — higher PageSpeed Insights quota."
  else
    log_warn "doctor" "psi-api" "PSI_API_KEY not set — anonymous PSI calls work but are rate-limited. Get a key at https://developers.google.com/speed/docs/insights/v5/get-started" "https://developers.google.com/speed/docs/insights/v5/get-started"
  fi

  if has_lighthouse_cli; then
    local v; v="$(lighthouse --version 2>/dev/null | head -n1)"
    log_ok "doctor" "lighthouse" "lighthouse CLI present (${v})."
  else
    log_warn "doctor" "lighthouse" "lighthouse CLI not installed. Recommended: 'npm install -g lighthouse'. Without it, 'state lighthouse' falls back to PSI category scores." "https://github.com/GoogleChrome/lighthouse"
  fi

  if has_ga4_auth; then
    log_ok "doctor" "ga4-api" "GA4_AUTH set — analytics ga4 enabled."
  else
    log_warn "doctor" "ga4-api" "GA4_AUTH not set — analytics ga4 will return {locked:'ga4-api'}. See references/01-auth-and-tokens.md."
  fi

  if has_gsc_auth; then
    log_ok "doctor" "gsc-api" "GOOGLE_GSC_AUTH set — Search Console reads enabled."
  else
    log_warn "doctor" "gsc-api" "GOOGLE_GSC_AUTH not set — state gsc will return {locked:'gsc-api'}."
  fi

  log_subsection "per-platform Marketing API auth (all optional)"
  local p
  for p in google meta microsoft linkedin tiktok x pinterest reddit snapchat apple; do
    if capability_present "${p}-api"; then
      log_ok "doctor" "platform-${p}" "${p} Marketing API auth detected."
    else
      log_warn "doctor" "platform-${p}" "${p} Marketing API auth not set — state platform ${p} will return {locked:'${p}-api'}."
    fi
  done

  return $rc
}
