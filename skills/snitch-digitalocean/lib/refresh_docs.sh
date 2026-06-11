# lib/refresh_docs.sh — refresh DigitalOcean docs into ${REF_DIR}/_cache/.
# Exports: run_refresh_docs

_refresh_default_sources() {
  cat <<'EOF'
https://docs.digitalocean.com/products/api/
https://docs.digitalocean.com/reference/doctl/how-to/install/
https://docs.digitalocean.com/products/networking/firewalls/
https://docs.digitalocean.com/products/networking/vpc/
https://docs.digitalocean.com/products/droplets/how-to/back-up/
https://docs.digitalocean.com/products/monitoring/
https://docs.digitalocean.com/products/databases/
https://docs.digitalocean.com/products/databases/postgresql/how-to/secure-cluster/
https://docs.digitalocean.com/products/spaces/
https://docs.digitalocean.com/products/spaces/how-to/manage-cors/
https://docs.digitalocean.com/products/app-platform/concepts/app-spec/
https://docs.digitalocean.com/products/app-platform/how-to/use-environment-variables/
https://docs.digitalocean.com/products/networking/load-balancers/
https://docs.digitalocean.com/products/networking/dns/
https://docs.digitalocean.com/products/container-registry/
https://docs.digitalocean.com/products/kubernetes/
https://docs.digitalocean.com/products/kubernetes/how-to/upgrade-cluster/
https://docs.digitalocean.com/products/functions/
https://docs.digitalocean.com/platform/security/two-factor-authentication/
https://docs.digitalocean.com/products/billing/notifications/
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
  code=$(curl -sSL -A 'snitch-digitalocean-skill/refresh-docs' \
    -o "$tmp" -w '%{http_code}' "$url" 2>/dev/null || printf '000')
  if [[ ! "$code" =~ ^2 ]]; then
    rm -f "$tmp"; return 3
  fi
  if command -v pandoc >/dev/null 2>&1; then
    pandoc -f html -t gfm "$tmp" -o "$out" 2>/dev/null || cp "$tmp" "$out"
  elif command -v lynx >/dev/null 2>&1; then
    lynx -dump -nolist "$tmp" >"$out" 2>/dev/null || cp "$tmp" "$out"
  else
    cp "$tmp" "$out"
  fi
  rm -f "$tmp"
  return 0
}

_refresh_log_append() {
  local log="$1" url="$2" out="$3"
  local size hash now entry
  size="$(wc -c <"$out" 2>/dev/null | tr -d ' ')"
  if command -v shasum >/dev/null 2>&1; then
    hash="$(shasum -a 256 "$out" 2>/dev/null | awk '{print $1}')"
  elif command -v sha256sum >/dev/null 2>&1; then
    hash="$(sha256sum "$out" 2>/dev/null | awk '{print $1}')"
  else
    hash=""
  fi
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  entry=$(jq -nc --arg url "$url" --arg ts "$now" --arg h "$hash" --argjson s "${size:-0}" \
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
    log_fail "refresh-docs" "ref-dir" "REF_DIR not set."
    return 2
  fi
  mkdir -p "${REF_DIR}/_cache"
  local log="${REF_DIR}/_refresh-log.json"

  local ok=0 fail=0 url
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
      log_warn "refresh-docs" "fetch-fail" "${url}"
      fail=$((fail+1))
    fi
  done < <(_refresh_load_sources)
  log_info "refreshed=${ok}  failed=${fail}  log=${log}"
}
