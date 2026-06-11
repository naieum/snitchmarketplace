# lib/refresh_docs.sh — re-fetch canonical AWS docs into references/_cache/.
# Exports: run_refresh_docs

run_refresh_docs() {
  local cache="${REF_DIR}/_cache"
  mkdir -p "$cache"
  local sources="${REF_DIR}/_doc-sources.json"
  if [[ ! -f "$sources" ]]; then
    log_fail "refresh-docs" "sources" "Missing ${sources}."
    return 2
  fi
  local urls
  urls="$(jq -r '.[] | .url' "$sources" 2>/dev/null)"
  local n=0 ok=0
  while IFS= read -r u; do
    [[ -z "$u" ]] && continue
    n=$((n+1))
    local fname="${u//[^A-Za-z0-9]/_}.html"
    if curl -sS -o "${cache}/${fname}" "$u" >/dev/null 2>&1; then
      ok=$((ok+1))
    fi
  done <<<"$urls"
  printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ) refreshed=${ok}/${n}" > "${REF_DIR}/_refresh-log.json"
  log_ok "refresh-docs" "done" "fetched ${ok}/${n} docs into ${cache}"
}
