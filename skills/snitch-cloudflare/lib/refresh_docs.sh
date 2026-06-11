# lib/refresh_docs.sh — refresh authoritative Cloudflare docs into ${REF_DIR}/_cache/.
# Exposes:
#   run_refresh_docs    — entry point for `snitch-cloudflare.sh refresh-docs`.
# Side effects:
#   - Writes ONLY inside ${REF_DIR}/_cache/ and ${REF_DIR}/_refresh-log.json.
#   - Does NOT touch the user's project.

# _refresh_default_sources -> emits one URL per line.
_refresh_default_sources() {
  cat <<'EOF'
https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/
https://developers.cloudflare.com/ssl/edge-certificates/additional-options/minimum-tls/
https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/
https://developers.cloudflare.com/waf/managed-rules/
https://developers.cloudflare.com/waf/rate-limiting-rules/
https://developers.cloudflare.com/waf/custom-rules/
https://developers.cloudflare.com/bots/concepts/bot-management/
https://developers.cloudflare.com/bots/get-started/free/
https://developers.cloudflare.com/rules/transform/response-header-modification/
https://developers.cloudflare.com/workers/platform/pricing/
https://developers.cloudflare.com/workers/wrangler/configuration/
https://developers.cloudflare.com/pages/configuration/headers/
https://developers.cloudflare.com/r2/pricing/
https://developers.cloudflare.com/kv/api/
https://developers.cloudflare.com/d1/platform/pricing/
https://developers.cloudflare.com/hyperdrive/
https://developers.cloudflare.com/durable-objects/platform/pricing/
https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/self-hosted-apps/
https://developers.cloudflare.com/page-shield/
https://developers.cloudflare.com/ai-gateway/
https://developers.cloudflare.com/workers-ai/models/
https://developers.cloudflare.com/vectorize/
https://developers.cloudflare.com/autorag/
https://developers.cloudflare.com/browser-rendering/
https://developers.cloudflare.com/fundamentals/setup/account/account-security/review-audit-logs/
https://developers.cloudflare.com/dns/dnssec/
https://developers.cloudflare.com/email-routing/
https://developers.cloudflare.com/dmarc-management/
EOF
}

# _refresh_load_sources -> emits URLs from _doc-sources.json or defaults.
_refresh_load_sources() {
  local f="${REF_DIR:-}/_doc-sources.json"
  if [[ -f "$f" ]]; then
    jq -r '.[]?' "$f" 2>/dev/null
    return 0
  fi
  _refresh_default_sources
}

# _refresh_slug <url> -> a filesystem-safe slug.
_refresh_slug() {
  local u="$1"
  printf '%s' "$u" | sed -e 's,^https\?://,,' -e 's,[^A-Za-z0-9._-],_,g'
}

# _refresh_save <url> <out_path> -> 0 on success, non-zero on failure. Uses MCP if available; else curl.
_refresh_save() {
  local url="$1" out="$2"

  if [[ -n "${CFSEC_MCP_PRESENT:-}" ]]; then
    # The skill cannot directly invoke MCP from bash; emit a hint for Claude to run the MCP search and persist.
    log_info "MCP present — recommend invoking mcp__claude_ai_Cloudflare_Developer_Platform__search_cloudflare_documentation for: ${url}"
    # Continue with curl fallback so the cache still populates.
  fi

  if ! command -v curl >/dev/null 2>&1; then
    log_fail "doctor" "curl" "curl not present; cannot refresh docs."
    return 3
  fi

  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sSL -A 'snitch-cloudflare-skill/refresh-docs' \
    -o "$tmp" -w '%{http_code}' "$url" 2>/dev/null || printf '000')
  if [[ ! "$code" =~ ^2 ]]; then
    rm -f "$tmp"
    return 3
  fi

  # Prefer pandoc (HTML -> markdown). Fall back to lynx -dump. Else save raw HTML.
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

# _refresh_log_append <log_path> <url> <out_path>
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
    log_fail "refresh-docs" "ref-dir" "REF_DIR not set in env. snitch-cloudflare.sh should export it."
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
