# lib/refresh_docs.sh — refresh authoritative Azure docs into ${REF_DIR}/_cache/.

_refresh_default_sources() {
  cat <<'EOF'
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli
https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation
https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices
https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure
https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction
https://learn.microsoft.com/en-us/azure/sentinel/overview
https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer
https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security
https://learn.microsoft.com/en-us/azure/key-vault/general/security-features
https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview
https://learn.microsoft.com/en-us/azure/app-service/overview-tls
https://learn.microsoft.com/en-us/azure/app-service/configure-basic-auth-disable
https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
https://learn.microsoft.com/en-us/azure/aks/concepts-security
https://learn.microsoft.com/en-us/azure/container-registry/container-registry-content-trust
https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview
https://learn.microsoft.com/en-us/azure/cosmos-db/security-baseline
https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-security
https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-security
https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview
https://learn.microsoft.com/en-us/azure/frontdoor/web-application-firewall
https://learn.microsoft.com/en-us/azure/dns/dnssec
https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
https://learn.microsoft.com/en-us/azure/firewall/overview
https://learn.microsoft.com/en-us/azure/bastion/bastion-overview
https://learn.microsoft.com/en-us/azure/backup/backup-azure-security-feature
https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices
https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-policies
https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log
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
    log_fail "doctor" "curl" "curl not present"
    return 3
  fi
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sSL -A 'snitch-azure-skill/refresh-docs' \
    -o "$tmp" -w '%{http_code}' "$url" 2>/dev/null || printf '000')
  if [[ ! "$code" =~ ^2 ]]; then
    rm -f "$tmp"
    return 3
  fi
  if command -v pandoc >/dev/null 2>&1; then
    pandoc -f html -t gfm "$tmp" -o "$out" 2>/dev/null || cp "$tmp" "$out"
  elif command -v lynx >/dev/null 2>&1; then
    lynx -dump -nolist "$tmp" >"$out" 2>/dev/null || cp "$tmp" "$out"
  else
    log_warn "refresh-docs" "tooling" "pandoc / lynx not installed; saving raw HTML."
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
    log_fail "refresh-docs" "ref-dir" "REF_DIR not set"
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
      log_warn "refresh-docs" "fetch-fail" "${url}"
      fail=$((fail+1))
    fi
  done < <(_refresh_load_sources)

  log_info "refreshed=${ok}  failed=${fail}  log=${log}"
}
