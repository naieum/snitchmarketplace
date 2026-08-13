# lib/apply_capi.sh — idempotent server-side Conversions API stub installer.
# Reads templates/capi-stubs/<platform>/<lang>.template; emits a `=== FILE ===`
# block targeting the right path for the detected server framework.
# Idempotent: checks for an existing CAPI endpoint signature first.
#
# Exports:
#   apply_capi <platform>

ADSSEC_CAPI_PLATFORMS=(google meta microsoft linkedin tiktok x pinterest reddit snapchat apple)

# _capi_template <platform> <lang> -> path or empty
_capi_template() {
  local platform="$1" lang="$2"
  local skill_dir="${ADSSEC_SKILL_DIR:-${HOME}/.claude/skills/ads-ready}"
  local p="${skill_dir}/templates/capi-stubs/${platform}/${lang}.template"
  if [[ -f "$p" ]]; then
    printf '%s' "$p"
    return 0
  fi
  return 1
}

# _capi_detect_lang -> node | python | unknown
_capi_detect_lang() {
  if [[ -f "package.json" ]]; then
    printf 'node'; return
  fi
  if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "manage.py" || -f "Pipfile" ]]; then
    printf 'python'; return
  fi
  printf 'unknown'
}

# _capi_detect_framework <lang> -> express | fastify | hono | nextjs-api | flask | fastapi | django | unknown
_capi_detect_framework() {
  local lang="$1"
  if [[ "$lang" == "node" ]]; then
    if [[ -f "next.config.js" || -f "next.config.ts" || -f "next.config.mjs" ]]; then
      printf 'nextjs-api'; return
    fi
    if [[ -f "package.json" ]]; then
      if grep -q '"hono"' package.json 2>/dev/null; then printf 'hono'; return; fi
      if grep -q '"fastify"' package.json 2>/dev/null; then printf 'fastify'; return; fi
      if grep -q '"express"' package.json 2>/dev/null; then printf 'express'; return; fi
    fi
    printf 'unknown'; return
  fi
  if [[ "$lang" == "python" ]]; then
    if [[ -f "manage.py" ]] || (grep -q '^[[:space:]]*[Dd]jango' requirements.txt 2>/dev/null); then printf 'django'; return; fi
    if grep -q '^[[:space:]]*fastapi' requirements.txt pyproject.toml 2>/dev/null; then printf 'fastapi'; return; fi
    if grep -q '^[[:space:]]*[Ff]lask' requirements.txt pyproject.toml 2>/dev/null; then printf 'flask'; return; fi
    printf 'unknown'; return
  fi
  printf 'unknown'
}

# _capi_target_file <framework> <platform> -> file path the stub should land in.
_capi_target_file() {
  local framework="$1" platform="$2"
  case "$framework" in
    nextjs-api)
      if   [[ -d "src/app/api" || -d "app/api" ]]; then
        local base="app/api"; [[ -d "src/app/api" ]] && base="src/app/api"
        printf '%s/capi/%s/route.ts' "$base" "$platform"
      elif [[ -d "src/pages/api" || -d "pages/api" ]]; then
        local base="pages/api"; [[ -d "src/pages/api" ]] && base="src/pages/api"
        printf '%s/capi/%s.ts' "$base" "$platform"
      else
        printf 'app/api/capi/%s/route.ts' "$platform"
      fi ;;
    express|fastify|hono)
      if   [[ -d "src/routes" ]]; then printf 'src/routes/capi-%s.ts' "$platform"
      elif [[ -d "routes" ]];     then printf 'routes/capi-%s.ts' "$platform"
      else printf 'src/capi-%s.ts' "$platform"; fi ;;
    flask|fastapi)
      printf 'capi_%s.py' "$platform" ;;
    django)
      printf 'capi/views_%s.py' "$platform" ;;
    *)
      printf 'capi-%s.txt' "$platform" ;;
  esac
}

# _capi_signature <platform> — search expression to detect an existing endpoint.
_capi_signature() {
  local platform="$1"
  case "$platform" in
    google)    printf 'measurement_protocol|google_ads.*conversion|googleads/v[0-9]+:upload' ;;
    meta)      printf 'graph\\.facebook\\.com.*events|capi.*meta|/events\\?access_token' ;;
    microsoft) printf 'bingads.*offline|bingads.*conversion' ;;
    linkedin)  printf 'api\\.linkedin\\.com.*conversion|conversionEvents' ;;
    tiktok)    printf 'business-api\\.tiktok\\.com/open_api/[v0-9.]+/event' ;;
    x)         printf 'ads-api\\.twitter\\.com.*measurement|twitter.*capi' ;;
    pinterest) printf 'api\\.pinterest\\.com.*events|conversion_events' ;;
    reddit)    printf 'ads-api\\.reddit\\.com.*conversion' ;;
    snapchat)  printf 'tr\\.snapchat\\.com/v[0-9]+/conversion|snap.*capi' ;;
    apple)     printf 'SKAdNetwork|skadnetwork|attribution-postback' ;;
    *)         printf 'NO_SIGNATURE' ;;
  esac
}

# apply_capi <platform>
apply_capi() {
  local platform="${1:-}"
  if [[ -z "$platform" ]]; then
    log_fail "capi" "apply" "Missing <platform>. Valid: ${ADSSEC_CAPI_PLATFORMS[*]}."
    return 2
  fi
  local known=0 v
  for v in "${ADSSEC_CAPI_PLATFORMS[@]}"; do
    [[ "$platform" == "$v" ]] && known=1 && break
  done
  if [[ "$known" != "1" ]]; then
    log_fail "capi" "apply" "Unknown platform '${platform}'. Valid: ${ADSSEC_CAPI_PLATFORMS[*]}."
    return 2
  fi

  local lang framework
  lang="$(_capi_detect_lang)"
  if [[ "$lang" == "unknown" ]]; then
    log_fail "capi" "apply" "Could not detect server-side language (no package.json, requirements.txt, or pyproject.toml in cwd). Run from your server's project root."
    return 2
  fi
  framework="$(_capi_detect_framework "$lang")"

  local tpl
  if ! tpl="$(_capi_template "$platform" "$lang")"; then
    log_fail "capi" "apply" "templates/capi-stubs/${platform}/${lang}.template not found. The skill ships Node + Python stubs only — PHP / Ruby / Go are out of scope. See references/recommendations/capi-helpers.md."
    return 2
  fi

  local sig target
  sig="$(_capi_signature "$platform")"
  target="$(_capi_target_file "$framework" "$platform")"

  if [[ -d "." ]]; then
    if grep -RIEl --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude-dir=.git --exclude-dir=__pycache__ --exclude-dir=.venv "$sig" . >/dev/null 2>&1; then
      log_ok "capi" "apply" "${platform} CAPI endpoint signature already present in source — no changes."
      return 0
    fi
  fi

  local stub
  stub="$(cat "$tpl")"

  log_info "lang: ${lang}; framework: ${framework}; target: ${target}; platform: ${platform}"
  printf '\n=== FILE: %s ===\n' "$target"
  printf '=== DIFF ===\n'
  printf '# Add a new server-side CAPI endpoint for %s. Adapter shape: receives a webhook/event, hashes PII (SHA-256), signs the request, POSTs to the platform CAPI endpoint, returns confirmation. Replace {{PLACEHOLDER}} values with secrets from your environment (NEVER commit them).\n' "$platform"
  printf '=== CONTENT ===\n'
  printf '%s\n' "$stub"
  printf '=== END ===\n'

  log_ok "capi" "apply" "${platform} CAPI ${lang} stub emitted for ${framework} (target: ${target})."
}
