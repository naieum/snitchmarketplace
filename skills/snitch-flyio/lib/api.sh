# lib/api.sh — flyctl wrappers.
# Every other lib/*.sh that touches Fly uses these. Most flyctl commands accept
# `--json`. We never write to ~/.fly/ ourselves — `fly auth login` does that.

FLYSEC_LAST_STDOUT=""
FLYSEC_LAST_STDERR=""
FLYSEC_LAST_RC=0
FLYSEC_CALL_LOG="${STATE_DIR:-/tmp}/api-calls.log"

# Resolve the fly binary once. Prefer `flyctl` (canonical), then `fly` (alias).
_fly_bin() {
  if command -v flyctl >/dev/null 2>&1; then
    printf 'flyctl'
    return 0
  fi
  if command -v fly >/dev/null 2>&1; then
    printf 'fly'
    return 0
  fi
  return 3
}

# api_check_auth_env: refuse to run mutations without an authenticated session.
# Read by snitch-flyio.sh before any `fix` or `panic` dispatch.
api_check_auth_env() {
  local bin; bin="$(_fly_bin)" || {
    log_fail "auth" "missing-flyctl" "flyctl not installed. Install: 'curl -L https://fly.io/install.sh | sh' or 'brew install flyctl'." "https://fly.io/docs/flyctl/install/"
    return 2
  }
  local who
  who="$("$bin" auth whoami 2>&1 || true)"
  if [[ -z "$who" || "$who" == *"not logged in"* || "$who" == *"Error"* || "$who" == *"error"* ]]; then
    log_fail "auth" "no-session" "Not logged in. Run: 'fly auth login'. (current whoami: ${who:-empty})" "https://fly.io/docs/flyctl/auth-login/"
    return 2
  fi
  return 0
}

# fly_run <args...> — run flyctl with stdin closed; capture stdout+stderr+rc.
# stdout: process stdout (NOT the call result; caller should also `printf` if needed)
# Sets: FLYSEC_LAST_STDOUT FLYSEC_LAST_STDERR FLYSEC_LAST_RC
fly_run() {
  local bin; bin="$(_fly_bin)" || {
    FLYSEC_LAST_STDOUT=""
    FLYSEC_LAST_STDERR='{"error":"flyctl not installed"}'
    FLYSEC_LAST_RC=3
    return 3
  }
  local out_tmp err_tmp; out_tmp="$(mktemp)"; err_tmp="$(mktemp)"
  "$bin" "$@" >"$out_tmp" 2>"$err_tmp" </dev/null
  FLYSEC_LAST_RC=$?
  FLYSEC_LAST_STDOUT="$(cat "$out_tmp")"
  FLYSEC_LAST_STDERR="$(cat "$err_tmp")"
  rm -f "$out_tmp" "$err_tmp"
  printf '%s\t%s\t%s\t%d\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$bin" "$*" "$FLYSEC_LAST_RC" >> "$FLYSEC_CALL_LOG" 2>/dev/null || true
  printf '%s' "$FLYSEC_LAST_STDOUT"
  return $FLYSEC_LAST_RC
}

# fly_run_json <args...> — same as fly_run, but appends --json and validates parse.
# If parse fails, returns rc=4 and stdout = '{}' / '[]' depending on first non-empty char.
fly_run_json() {
  local stdout
  stdout="$(fly_run "$@" --json 2>/dev/null)"
  local rc=$FLYSEC_LAST_RC
  if [[ $rc -ne 0 ]]; then
    return $rc
  fi
  if ! jq -e . >/dev/null 2>&1 <<<"$stdout"; then
    FLYSEC_LAST_RC=4
    printf '{}'
    return 4
  fi
  printf '%s' "$stdout"
  return 0
}

# auth_verify: surface logged-in identity. Used by `verify`.
auth_verify() {
  local bin; bin="$(_fly_bin)" || {
    log_fail "auth" "verify" "flyctl not installed."
    return 2
  }
  local who
  who="$("$bin" auth whoami 2>/dev/null | head -n1)"
  if [[ -z "$who" ]]; then
    log_fail "auth" "verify" "Could not determine whoami. Run 'fly auth login'."
    return 2
  fi
  log_ok "auth" "verify" "Logged in as ${who}."
  return 0
}

# api_pick_org: cache + return the active org slug.
# Reads $FLYSEC_ORG from env; else picks the first/personal org.
api_pick_org() {
  local cache="${STATE_DIR}/org.txt"
  if [[ -n "${FLYSEC_ORG:-}" ]]; then
    printf '%s' "${FLYSEC_ORG}" > "$cache"
    printf '%s' "${FLYSEC_ORG}"
    return 0
  fi
  if [[ -f "$cache" ]]; then
    cat "$cache" 2>/dev/null && return 0
  fi
  local body; body="$(fly_run_json orgs list 2>/dev/null)" || return 3
  local count; count="$(jq -r '. | length' <<<"$body" 2>/dev/null || printf '0')"
  if [[ "$count" == "1" ]]; then
    local slug; slug="$(jq -r '.[0].Slug // .[0].slug // empty' <<<"$body" 2>/dev/null)"
    [[ -n "$slug" ]] && { printf '%s' "$slug" > "$cache"; printf '%s' "$slug"; return 0; }
  fi
  # Prefer 'personal' as default if present.
  local personal; personal="$(jq -r '.[] | select((.Slug // .slug // "") == "personal") | (.Slug // .slug)' <<<"$body" 2>/dev/null | head -n1)"
  if [[ -n "$personal" ]]; then
    printf '%s' "$personal" > "$cache"
    printf '%s' "$personal"
    return 0
  fi
  log_warn "auth" "multi-org" "Multiple orgs visible. Pass org slug explicitly via FLYSEC_ORG."
  jq -r '.[] | "  - \(.Slug // .slug)  \(.Name // .name)"' <<<"$body" 2>/dev/null
  return 3
}

# api_pick_app: resolve app name. Reads $FLYSEC_APP, else looks at fly.toml in cwd.
api_pick_app() {
  local cache="${STATE_DIR}/app.txt"
  if [[ -n "${FLYSEC_APP:-}" ]]; then
    printf '%s' "${FLYSEC_APP}" > "$cache"
    printf '%s' "${FLYSEC_APP}"
    return 0
  fi
  if [[ -f "fly.toml" ]]; then
    local app
    app="$(grep -E '^app[[:space:]]*=' fly.toml 2>/dev/null | head -n1 | sed -E 's/^app[[:space:]]*=[[:space:]]*"?([^"#]+)"?.*/\1/' | tr -d '[:space:]')"
    if [[ -n "$app" ]]; then
      printf '%s' "$app" > "$cache"
      printf '%s' "$app"
      return 0
    fi
  fi
  if [[ -f "$cache" ]]; then
    cat "$cache" 2>/dev/null && return 0
  fi
  return 3
}

# doctor_run: env health check; emits OK/WARN/FAIL.
doctor_run() {
  local rc=0
  local bin
  if bin="$(_fly_bin)"; then
    local v; v="$("$bin" version 2>/dev/null | head -n1)"
    log_ok "doctor" "flyctl" "${bin} present (${v:-unknown})"
  else
    log_fail "doctor" "flyctl" "flyctl missing. Install: 'curl -L https://fly.io/install.sh | sh' or 'brew install flyctl'." "https://fly.io/docs/flyctl/install/"
    rc=2
  fi

  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required. brew install jq (macOS) or apt-get install jq (Linux)."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi

  if [[ -n "$bin" ]]; then
    local who; who="$("$bin" auth whoami 2>&1 || true)"
    if [[ -z "$who" || "$who" == *"not logged in"* || "$who" == *"Error"* ]]; then
      log_fail "doctor" "auth" "Not logged in. Run: 'fly auth login'." "https://fly.io/docs/flyctl/auth-login/"
      rc=2
    else
      log_ok "doctor" "auth" "Logged in as ${who}."
    fi
  fi

  if [[ -n "${FLYSEC_MCP_PRESENT:-}" ]]; then
    log_ok "doctor" "mcp" "Fly MCP detected — agent will prefer it for typed reads."
  else
    log_warn "doctor" "mcp" "No Fly MCP detected. flyctl is the primary tool. The skill works fine without an MCP."
  fi

  return $rc
}
