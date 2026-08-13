# lib/refresh_docs.sh — refresh authoritative docs into ${REF_DIR}/_cache/.
# Pulls per-platform developer docs + Consent Mode v2 + ads.txt + CWV thresholds.
#
# Exposes: run_refresh_docs
# Side effects:
#   - Writes ONLY inside ${REF_DIR}/_cache/ and ${REF_DIR}/_refresh-log.json.
#   - Does NOT touch the user's project.

# _refresh_default_sources -> emits one URL per line.
_refresh_default_sources() {
  cat <<'EOF'
https://support.google.com/google-ads/answer/12821543
https://developers.google.com/tag-platform/security/guides/consent
https://developers.google.com/tag-platform/gtagjs/install
https://developers.google.com/tag-manager/quickstart
https://developers.google.com/analytics/devguides/collection/ga4
https://developers.google.com/analytics/devguides/reporting/data/v1
https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview
https://developers.facebook.com/docs/meta-pixel/get-started
https://developers.facebook.com/docs/marketing-api/conversions-api/get-started
https://about.ads.microsoft.com/en-us/help/56684/the-uet-tag
https://learn.microsoft.com/en-us/advertising/guides/universal-event-tracking
https://www.linkedin.com/help/lms/answer/a418880
https://learn.microsoft.com/en-us/linkedin/marketing/integrations/ads-reporting/conversions-tracking
https://ads.tiktok.com/help/article/get-started-pixel
https://ads.tiktok.com/help/article/events-api
https://business.x.com/en/help/campaign-measurement-and-analytics/website-tag-for-ads.html
https://help.pinterest.com/en/business/article/install-the-pinterest-tag
https://help.pinterest.com/en/business/article/the-pinterest-api-for-conversions
https://business.reddithelp.com/s/article/Reddit-pixel
https://businesshelp.snapchat.com/s/article/snap-pixel-about
https://businesshelp.snapchat.com/s/article/conversions-api
https://searchads.apple.com/help
https://developer.apple.com/documentation/storekit/skadnetwork
https://web.dev/articles/vitals
https://iabtechlab.com/wp-content/uploads/2017/09/IABOpenRTB_Ads.txt_Public_Spec_V1-0-2.pdf
https://llmstxt.org/
EOF
}

_refresh_load_sources() {
  local f="${REF_DIR:-}/_doc-sources.json"
  if [[ -f "$f" ]]; then
    jq -r '.[]?' "$f" 2>/dev/null
    return 0
  fi
  _refresh_default_sources
}

_refresh_slug() {
  local u="$1"
  printf '%s' "$u" | sed -e 's,^https\?://,,' -e 's,[^A-Za-z0-9._-],_,g'
}

_refresh_save() {
  local url="$1" out="$2"

  if ! command -v curl >/dev/null 2>&1; then
    log_fail "doctor" "curl" "curl not present; cannot refresh docs."
    return 3
  fi

  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sSL -A 'ads-ready-skill/refresh-docs' \
    --max-time 30 \
    -o "$tmp" -w '%{http_code}' "$url" 2>/dev/null || printf '000')
  if [[ ! "$code" =~ ^2 ]]; then
    rm -f "$tmp"
    return 3
  fi

  if command -v pandoc >/dev/null 2>&1; then
    pandoc -f html -t gfm "$tmp" -o "$out" 2>/dev/null \
      || cp "$tmp" "$out"
  elif command -v lynx >/dev/null 2>&1; then
    lynx -dump -nolist "$tmp" >"$out" 2>/dev/null \
      || cp "$tmp" "$out"
  else
    log_warn "refresh-docs" "tooling" "pandoc / lynx not installed; saving raw HTML. brew install pandoc lynx for cleaner cache."
    cp "$tmp" "$out"
  fi
  rm -f "$tmp"
  return 0
}

_refresh_log_append() {
  local log="$1" url="$2" out="$3"
  local size hash now
  size="$(wc -c <"$out" 2>/dev/null | tr -d ' ')"
  if command -v shasum >/dev/null 2>&1; then
    hash="$(shasum -a 256 "$out" 2>/dev/null | awk '{print $1}')"
  elif command -v sha256sum >/dev/null 2>&1; then
    hash="$(sha256sum "$out" 2>/dev/null | awk '{print $1}')"
  else
    hash=""
  fi
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local entry
  entry=$(jq -nc \
    --arg url "$url" --arg ts "$now" --arg h "$hash" --argjson s "${size:-0}" \
    '{source_url:$url, fetched_at:$ts, hash:$h, size_bytes:$s}')
  if [[ -f "$log" ]]; then
    local merged
    merged="$(jq --argjson e "$entry" '. + [$e]' "$log" 2>/dev/null || printf '[%s]' "$entry")"
    printf '%s' "$merged" >"$log"
  else
    printf '[%s]' "$entry" >"$log"
  fi
}

run_refresh_docs() {
  log_section "refresh-docs"
  if [[ -z "${REF_DIR:-}" ]]; then
    log_fail "refresh-docs" "ref-dir" "REF_DIR not set in env. ads-ready.sh should export it."
    return 2
  fi
  mkdir -p "${REF_DIR}/_cache"
  local log="${REF_DIR}/_refresh-log.json"

  local ok=0 fail=0
  local url
  while IFS= read -r url; do
    [[ -z "$url" ]] && continue
    [[ "$url" =~ ^# ]] && continue
    local slug out
    slug="$(_refresh_slug "$url")"
    out="${REF_DIR}/_cache/${slug}.md"
    if _refresh_save "$url" "$out"; then
      _refresh_log_append "$log" "$url" "$out"
      log_ok "refresh-docs" "fetch" "${url} -> ${out}"
      ok=$((ok+1))
    else
      log_warn "refresh-docs" "fetch-fail" "${url} (no cache update)"
      fail=$((fail+1))
    fi
  done < <(_refresh_load_sources)

  log_info "refreshed=${ok}  failed=${fail}  log=${log}"
}
