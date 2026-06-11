# lib/refresh_docs.sh — refresh canonical Fly docs into references/_cache/.
# Exports: run_refresh_docs
#
# This is a stub — the actual refresh happens in the agent layer (WebFetch).
# We just maintain references/_doc-sources.json + references/_refresh-log.json.

run_refresh_docs() {
  local sources="${REF_DIR}/_doc-sources.json"
  local log="${REF_DIR}/_refresh-log.json"
  if [[ ! -f "$sources" ]]; then
    printf '{"error":"missing _doc-sources.json","code":"E_TEMPLATE","path":"%s"}\n' "$sources" >&2
    return 2
  fi
  log_section "refresh-docs"
  log_info "Doc sources defined in ${sources}."
  log_info "The agent should iterate the entries and WebFetch each URL, then update ${log}."
  jq '.' "$sources"
  return 0
}
