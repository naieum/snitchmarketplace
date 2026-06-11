# lib/api.sh — Cloudflare REST API helpers.
# Every other lib/*.sh that touches the API uses these. Reads $CLOUDFLARE_API_TOKEN.
# Refuses to operate with the legacy global API key (CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL).

CFSEC_API_BASE="${CFSEC_API_BASE:-https://api.cloudflare.com/client/v4}"
CFSEC_LAST_STATUS=""
CFSEC_LAST_BODY=""
CFSEC_CALL_LOG="${STATE_DIR:-/tmp}/api-calls.log"

# Refuse the legacy auth scheme. Called from doctor.
api_check_auth_env() {
  if [[ -n "${CLOUDFLARE_API_KEY:-}" && -n "${CLOUDFLARE_EMAIL:-}" ]]; then
    log_fail "auth" "global-api-key" "CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL detected. The skill refuses to use the global API key. Create a scoped token at https://dash.cloudflare.com/profile/api-tokens and unset CLOUDFLARE_API_KEY / CLOUDFLARE_EMAIL." "https://developers.cloudflare.com/fundamentals/api/get-started/create-token/"
    return 2
  fi
  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    log_fail "auth" "missing-token" "CLOUDFLARE_API_TOKEN not set. Create a scoped token (see ${TPL_DIR}/token-permissions.checklist.md) and export it." "https://dash.cloudflare.com/profile/api-tokens"
    return 2
  fi
  return 0
}

_api_call() {
  local method="$1" path="$2" body="${3:-}"
  local url="${CFSEC_API_BASE}${path}"
  local tok="${CLOUDFLARE_API_TOKEN:-}"
  if [[ -z "$tok" ]]; then
    CFSEC_LAST_STATUS="000"
    CFSEC_LAST_BODY='{"errors":[{"code":0,"message":"CLOUDFLARE_API_TOKEN not set"}]}'
    printf '%s\n' "$CFSEC_LAST_BODY"
    return 3
  fi
  local tmp; tmp="$(mktemp)"
  local code
  if [[ -n "$body" ]]; then
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -X "$method" \
      -H "Authorization: Bearer ${tok}" \
      -H "Content-Type: application/json" \
      --data "$body" \
      "$url" 2>/dev/null || echo "000")
  else
    code=$(curl -sS -o "$tmp" -w '%{http_code}' \
      -X "$method" \
      -H "Authorization: Bearer ${tok}" \
      "$url" 2>/dev/null || echo "000")
  fi
  CFSEC_LAST_STATUS="$code"
  CFSEC_LAST_BODY="$(cat "$tmp")"
  rm -f "$tmp"
  # Persist status to a file too: callers invoke us as body="$(cf_get ...)", and a
  # global set inside command substitution is lost to the caller — a file survives.
  printf '%s' "$code" > "${STATE_DIR:-/tmp}/.cfsec-last-status" 2>/dev/null || true
  printf '%s\t%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$method" "$url" "$code" >> "$CFSEC_CALL_LOG" 2>/dev/null || true
  if [[ "$code" =~ ^2 ]]; then
    printf '%s\n' "$CFSEC_LAST_BODY"
    return 0
  fi
  printf '%s\n' "$CFSEC_LAST_BODY"
  return 3
}

cf_get()    { _api_call GET    "$1"; }
cf_post()   { _api_call POST   "$1" "${2:-}"; }
cf_patch()  { _api_call PATCH  "$1" "${2:-}"; }
cf_put()    { _api_call PUT    "$1" "${2:-}"; }
cf_delete() { _api_call DELETE "$1"; }

# Pretty-print the last API error if any.
cf_last_error() {
  jq -r '.errors // [] | .[] | "[\(.code)] \(.message)"' <<<"$CFSEC_LAST_BODY" 2>/dev/null
}

# cf_last_status: HTTP status of the most recent cf_* call, read from a file so it
# is correct even after body="$(cf_get ...)" (where the CFSEC_LAST_STATUS global,
# set inside the subshell, would not propagate to the caller). Echoes e.g. "200",
# "403", or "000" if unknown. Use this — not $CFSEC_LAST_STATUS — for gating.
cf_last_status() {
  cat "${STATE_DIR:-/tmp}/.cfsec-last-status" 2>/dev/null || printf '000'
}

# api_surface_gate <last_status> <body_json> [empty_jq_filter]
# Classifies a surface probe so an audit lens can skip gracefully instead of
# erroring. The caller captures status as: body="$(cf_get …)" && st=ok || st="$CFSEC_LAST_STATUS".
# Echoes exactly one verdict on stdout:
#   forbidden : HTTP 403 — token scope / plan entitlement missing
#   notfound  : HTTP 404 — surface not present on this account/plan
#   empty     : 2xx body where <empty_jq_filter> is truthy (e.g. '.result|length==0')
#   ok        : 2xx and not empty — caller should parse the body
#   error     : anything else (5xx, 000, network) — caller should emit E_API
api_surface_gate() {
  local http_status="$1" body="${2:-}" empty_filter="${3:-}"
  case "$http_status" in
    403) printf 'forbidden\n'; return 0 ;;
    404) printf 'notfound\n';  return 0 ;;
  esac
  if [[ "$http_status" == "ok" || "$http_status" =~ ^2 ]]; then
    if [[ -n "$empty_filter" ]] && jq -e "$empty_filter" <<<"$body" >/dev/null 2>&1; then
      printf 'empty\n'; return 0
    fi
    printf 'ok\n'; return 0
  fi
  printf 'error\n'
}

# emit_locked_doc <schema> <tool> <id_field> <id_value> <locked_value> <reason> [extra_json]
# Prints a consistent "locked" JSON doc on stdout (the data-lens equivalent of
# log_locked; see state_pageshield.sh for the original hand-rolled form). rc 0.
#   <locked_value> : a plan tier ("enterprise"|"business"|"pro") OR a reason token
#                    ("not-configured"|"mcp-absent").
#   <id_field>     : e.g. "account_id" or "zone_id" ("" to omit).
#   <extra_json>   : a JSON object merged into the doc (e.g. '{"jobs":[]}'); '{}' if none.
emit_locked_doc() {
  local schema="$1" tool="$2" id_field="$3" id_value="$4" locked="$5" reason="$6" extra="${7:-}"
  [[ -z "$extra" ]] && extra='{}'
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  jq -n \
    --arg schema "$schema" --arg tool "$tool" \
    --arg idf "$id_field" --arg idv "$id_value" \
    --arg locked "$locked" --arg reason "$reason" \
    --arg ts "$ts" --argjson extra "$extra" \
    '{ schema: $schema, schema_version: 1, generated_at: $ts, tool: $tool,
       locked: $locked, reason: $reason }
     + (if $idf != "" then {($idf): $idv} else {} end)
     + $extra'
}

# True when the token can read /user/tokens/verify (good auth).
auth_verify() {
  local body
  body="$(cf_get /user/tokens/verify)" || {
    log_fail "auth" "verify" "Token verification failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    return 2
  }
  local status
  status="$(jq -r '.result.status // "unknown"' <<<"$body" 2>/dev/null)"
  if [[ "$status" != "active" ]]; then
    log_fail "auth" "verify" "Token status is '$status' (expected 'active')."
    return 2
  fi
  log_ok "auth" "verify" "API token is active."

  # Surface the token's permission groups so the user knows what it can do.
  local perms
  perms="$(jq -r '[.result.policies[]? | .permission_groups[]? | .name] | unique | join(", ")' <<<"$body" 2>/dev/null)"
  if [[ -n "$perms" && "$perms" != "null" ]]; then
    log_info "token scopes: $perms"
  fi
  return 0
}

# Account selection helper: caches in $STATE_DIR/account.json
api_pick_account() {
  local cache="${STATE_DIR}/account.json"
  if [[ -f "$cache" ]]; then
    jq -r '.id' "$cache" 2>/dev/null && return 0
  fi
  local body; body="$(cf_get /accounts)" || return 3
  local count; count="$(jq -r '.result | length' <<<"$body")"
  if [[ "$count" == "1" ]]; then
    jq -r '.result[0]' <<<"$body" > "$cache"
    jq -r '.id' "$cache"
    return 0
  fi
  log_warn "auth" "multi-account" "Token sees $count accounts. Pass account id explicitly via CFSEC_ACCOUNT_ID."
  jq -r '.result[] | "  - \(.id)  \(.name)"' <<<"$body"
  if [[ -n "${CFSEC_ACCOUNT_ID:-}" ]]; then
    jq --arg id "$CFSEC_ACCOUNT_ID" '.result[] | select(.id==$id)' <<<"$body" > "$cache"
    jq -r '.id' "$cache"
    return 0
  fi
  return 3
}

# Zone selection helper.
# If CFSEC_ZONE_ID is set, use it. Else if exactly one zone, use it. Else list and fail.
api_pick_zone() {
  local cache="${STATE_DIR}/zone.json"
  if [[ -n "${CFSEC_ZONE_ID:-}" ]]; then
    cf_get "/zones/${CFSEC_ZONE_ID}" > "$cache"
    jq -r '.result.id' "$cache"
    return 0
  fi
  if [[ -f "$cache" ]]; then
    jq -r '.result.id // .id' "$cache" 2>/dev/null && return 0
  fi
  local body; body="$(cf_get /zones)" || return 3
  local count; count="$(jq -r '.result | length' <<<"$body")"
  if [[ "$count" == "1" ]]; then
    jq -r '.result[0]' <<<"$body" > "$cache"
    jq -r '.id' "$cache"
    return 0
  fi
  log_warn "auth" "multi-zone" "Token sees $count zones. Pass zone id explicitly via CFSEC_ZONE_ID."
  jq -r '.result[] | "  - \(.id)  \(.name)  [\(.plan.legacy_id // "?")]"' <<<"$body"
  return 3
}

# doctor_run: foundation check; called by `check`.
doctor_run() {
  local rc=0
  if ! command -v curl >/dev/null 2>&1; then
    log_fail "doctor" "curl" "curl is required. Install via: brew install curl  (macOS) or apt-get install curl  (Linux)."
    rc=2
  else
    log_ok "doctor" "curl" "curl present."
  fi
  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required. Install via: brew install jq  (macOS) or apt-get install jq  (Linux)."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi

  api_check_auth_env || rc=$?

  if command -v wrangler >/dev/null 2>&1; then
    local v; v="$(wrangler --version 2>/dev/null | head -n1)"
    log_ok "doctor" "wrangler" "$v"
  else
    log_warn "doctor" "wrangler" "wrangler not installed. Recommended: 'npm install -g wrangler'. Used for secret put, tail, pages deploy, project hardening." "https://developers.cloudflare.com/workers/wrangler/install-and-update/"
  fi

  if [[ -n "${CFSEC_MCP_PRESENT:-}" ]]; then
    log_ok "doctor" "mcp" "Cloudflare Developer Platform MCP detected — agent will prefer it for D1/KV/R2/Workers/Hyperdrive reads and search_cloudflare_documentation."
  else
    log_warn "doctor" "mcp" "Cloudflare Developer Platform MCP not detected. Recommended: install it for typed access to D1 databases, KV namespaces, R2 buckets, Workers (list/get/code), Hyperdrive configs, and search_cloudflare_documentation — fewer tokens than this skill's curl reads. Install: 'claude mcp add cloudflare-dev-platform' or via the Anthropic Connectors UI. The skill works fine without it." "https://github.com/cloudflare/mcp-server-cloudflare"
  fi

  # Audit-lens MCPs. The curl lenses (auditlog/logpush/dns/ai-gateway/secevents)
  # work without these; casb/dex/builds REQUIRE the matching MCP (no curl path).
  local mcp_audit_present=0
  local f
  for f in CASB:casb DEX:dex BUILDS:builds BROWSER:browser OBSERVABILITY:observability; do
    local var="CFSEC_MCP_${f%%:*}" lens="${f##*:}"
    if [[ -n "${!var:-}" ]]; then
      log_ok "doctor" "mcp-${lens}" "${lens} MCP flagged present — 'audit ${lens}' will use it."
      mcp_audit_present=1
    fi
  done
  if [[ "$mcp_audit_present" == "0" ]]; then
    log_info "audit-lens MCPs (casb/dex/builds/browser/observability) not flagged. 'audit casb|dex|builds' need them (no curl path) and will report locked:\"mcp-absent\". Install the relevant remote MCP, then export CFSEC_MCP_<NAME>=1. See references/32-mcp-surfaces.md."
  fi

  return $rc
}

# discover_run: list account / zones / project type.
discover_run() {
  local body
  body="$(cf_get /accounts)" || { log_fail "discover" "accounts" "Could not list accounts. $(cf_last_error)"; return 3; }
  local n; n="$(jq -r '.result | length' <<<"$body")"
  log_ok "discover" "accounts" "$n account(s) visible to this token."
  jq -r '.result[] | "  - \(.id)  \(.name)"' <<<"$body" >&2

  local zones; zones="$(cf_get /zones)" || { log_warn "discover" "zones" "Could not list zones."; return 0; }
  local zn; zn="$(jq -r '.result | length' <<<"$zones")"
  log_ok "discover" "zones" "$zn zone(s) visible to this token."
  jq -r '.result[] | "  - \(.id)  \(.name)  plan=\(.plan.legacy_id // "?")  status=\(.status // "?")"' <<<"$zones" >&2

  # Project type from cwd.
  local pt="unknown"
  if [[ -f "wrangler.toml" || -f "wrangler.jsonc" || -f "wrangler.json" ]]; then pt="cloudflare-workers-or-pages"; fi
  if [[ -f "next.config.js" || -f "next.config.ts" || -f "next.config.mjs" ]]; then pt="${pt}+nextjs"; fi
  if [[ -f "astro.config.mjs" || -f "astro.config.ts" || -f "astro.config.js" ]]; then pt="${pt}+astro"; fi
  if [[ -f "svelte.config.js" || -f "svelte.config.ts" ]]; then pt="${pt}+sveltekit"; fi
  if [[ -f "remix.config.js" || -f "remix.config.ts" ]]; then pt="${pt}+remix"; fi
  if [[ -f "nuxt.config.js" || -f "nuxt.config.ts" ]]; then pt="${pt}+nuxt"; fi
  if [[ -f "vite.config.js" || -f "vite.config.ts" ]]; then pt="${pt}+vite"; fi
  if [[ -f "package.json" ]]; then pt="${pt}+node"; fi
  if [[ -f "composer.json" || -f "wp-config.php" ]]; then pt="${pt}+php"; fi
  if [[ -f "Gemfile" ]]; then pt="${pt}+ruby"; fi
  if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "manage.py" ]]; then pt="${pt}+python"; fi
  if [[ -f "vercel.json" ]]; then pt="${pt}+vercel"; fi
  if [[ -f "netlify.toml" ]]; then pt="${pt}+netlify"; fi
  log_ok "discover" "project" "cwd project type: ${pt}"

  printf '%s\n' "$pt" > "${STATE_DIR}/project-type.txt"
}
