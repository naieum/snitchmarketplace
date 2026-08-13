# lib/export.sh — JSON snapshot of ads-readiness state for a URL.
# Captures site-side audit + composite score + cwd detection (if cwd has a
# project). Output goes to ./ads-ready-export-<host>-<ts>.json in cwd.
#
# Exports: run_export <url>

run_export() {
  local url="${1:-}"
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"

  if [[ -z "$url" ]]; then
    printf '{"error":"export requires a URL","code":"E_USAGE","remediation":"usage: export <url>"}\n' >&2
    return 2
  fi
  case "$url" in
    http://*|https://*) ;;
    *)
      printf '{"error":"URL must begin with http:// or https://","code":"E_URL","got":"%s"}\n' "$url" >&2
      return 2 ;;
  esac

  if ! declare -f run_state_site >/dev/null 2>&1; then
    . "$LIB_DIR/state_site.sh"
  fi
  if ! declare -f run_state_crux >/dev/null 2>&1; then
    . "$LIB_DIR/state_crux.sh"
  fi
  if ! declare -f run_score >/dev/null 2>&1; then
    . "$LIB_DIR/score.sh"
  fi
  if ! declare -f run_detect >/dev/null 2>&1; then
    . "$LIB_DIR/detect.sh"
  fi

  local host
  host="$(printf '%s' "$url" | sed -E 's,^https?://([^/]+).*,\1,')"
  local out_file="./ads-ready-export-${host}-${ts}.json"

  log_section "export"
  log_info "snapshotting ${url}"

  local detect digest crux score
  detect="$(run_detect 2>/dev/null || printf '{}')"
  digest="$(run_state_site "$url" digest 2>/dev/null || printf '{}')"
  crux="$(run_state_crux "$url" mobile 2>/dev/null || printf '{}')"
  score="$(run_score "$url" 2>/dev/null || printf '{}')"

  jq -n \
    --arg sv "1" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg url "$url" \
    --arg host "$host" \
    --argjson detect "$detect" \
    --argjson digest "$digest" \
    --argjson crux "$crux" \
    --argjson score "$score" \
    '{
      schema: "adssec.export",
      schema_version: ($sv|tonumber),
      generated_at: $ts,
      url: $url,
      host: $host,
      detect: $detect,
      site_digest: $digest,
      crux: $crux,
      score: $score
    }' > "$out_file"

  log_ok "export" "snapshot" "wrote ${out_file}"
}
