# lib/refresh_docs.sh — re-pull canonical Vercel doc URLs into references/_cache/.
# Exports: run_refresh_docs

run_refresh_docs() {
  local sources="${REF_DIR}/_doc-sources.json"
  local cache_dir="${REF_DIR}/_cache"
  local logf="${REF_DIR}/_refresh-log.json"
  mkdir -p "$cache_dir"
  if [[ ! -f "$sources" ]]; then
    log_fail "refresh" "sources" "Missing ${sources}"
    return 4
  fi
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local urls; urls="$(jq -r '.urls[]?' "$sources" 2>/dev/null)"
  if [[ -z "$urls" ]]; then
    log_warn "refresh" "urls" "No URLs in ${sources}."
    return 0
  fi
  local results='[]'
  local u
  while IFS= read -r u; do
    [[ -z "$u" ]] && continue
    local name; name="$(printf '%s' "$u" | sed -E 's|https?://||; s|[^a-zA-Z0-9._-]+|_|g')"
    local out="${cache_dir}/${name}.html"
    local code
    code=$(curl -sS -o "$out" -w '%{http_code}' "$u" 2>/dev/null || echo "000")
    results="$(jq --arg u "$u" --arg c "$code" --arg p "$out" '. + [{ url: $u, status: $c, path: $p }]' <<<"$results")"
    log_info "refresh ${u} → ${code}"
  done <<<"$urls"
  jq -n --arg ts "$ts" --argjson r "$results" '{ generated_at: $ts, results: $r }' > "$logf"
  log_ok "refresh" "done" "Refreshed $(jq -r 'length' <<<"$results") URLs → ${logf}"
}
