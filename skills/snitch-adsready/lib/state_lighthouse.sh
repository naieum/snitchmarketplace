# lib/state_lighthouse.sh — full Lighthouse audit when CLI is available.
# If `lighthouse` is not on PATH, fall back to the PSI Lighthouse subset and
# include a hint to install the CLI for deeper data.
#
# Exports: run_state_lighthouse <url>

run_state_lighthouse() {
  local url="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$url" ]]; then
    printf '{"error":"state lighthouse requires a URL","code":"E_USAGE","remediation":"usage: state lighthouse <url>"}\n' >&2
    return 2
  fi
  case "$url" in
    http://*|https://*) ;;
    *)
      printf '{"error":"URL must begin with http:// or https://","code":"E_URL","got":"%s"}\n' "$url" >&2
      return 2 ;;
  esac

  if has_lighthouse_cli; then
    local tmp; tmp="$(mktemp)"
    # Run lighthouse, JSON output only, headless. Quiet to avoid stdout chatter.
    if ! lighthouse "$url" \
        --output=json \
        --output-path="$tmp" \
        --quiet \
        --chrome-flags="--headless --no-sandbox" \
        >/dev/null 2>&1; then
      rm -f "$tmp"
      printf '{"error":"lighthouse CLI failed","code":"E_LIGHTHOUSE","url":"%s","remediation":"check that headless Chrome can run; try: lighthouse <url> --view"}\n' "$url" >&2
      return 3
    fi
    local audit; audit="$(cat "$tmp" 2>/dev/null)"
    rm -f "$tmp"
    if [[ -z "$audit" ]]; then
      printf '{"error":"lighthouse produced no JSON","code":"E_LIGHTHOUSE_EMPTY","url":"%s"}\n' "$url" >&2
      return 3
    fi
    jq -n --arg ts "$ts" --arg url "$url" \
      --argjson audit "$audit" \
      '{
        schema: "adssec.state-lighthouse",
        schema_version: 1,
        generated_at: $ts,
        tool: "state-lighthouse",
        url: $url,
        source: "lighthouse-cli",
        audit: $audit
      }'
    return 0
  fi

  # Fallback: PSI category scores.
  log_info "lighthouse CLI not installed; falling back to PSI subset. Install: npm i -g lighthouse"
  if ! declare -f run_state_crux >/dev/null 2>&1; then
    . "$LIB_DIR/state_crux.sh"
  fi
  local crux; crux="$(run_state_crux "$url" mobile 2>/dev/null)"
  if [[ -z "$crux" ]]; then
    printf '{"error":"lighthouse CLI missing AND PSI fallback failed","code":"E_LIGHTHOUSE_FALLBACK","url":"%s","remediation":"install lighthouse: npm i -g lighthouse"}\n' "$url" >&2
    return 3
  fi
  jq -n --arg ts "$ts" --arg url "$url" --argjson crux "$crux" \
    '{
      schema: "adssec.state-lighthouse",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-lighthouse",
      url: $url,
      source: "psi-fallback",
      hint: "install lighthouse CLI for full audit JSON: npm i -g lighthouse",
      psi: $crux
    }'
}
