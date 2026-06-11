# lib/wrangler_lint.sh — wrangler.toml / wrangler.jsonc lint + types + dev-vars generator.
# Exposes:
#   wrangler_lint_run — read-only audit.
#   wrangler_lint_fix — bumps compatibility_date (with confirmation), generates .dev.vars.template.

# _wl_find_config -> echoes path to wrangler.toml/.jsonc/.json or empty
_wl_find_config() {
  local f
  for f in wrangler.toml wrangler.jsonc wrangler.json; do
    if [[ -f "$f" ]]; then
      printf '%s' "$f"
      return 0
    fi
  done
  printf ''
}

# _wl_strip_comments <file> -> stdout: comment-stripped content (best-effort)
_wl_strip_comments() {
  local f="$1"
  # Drop // line comments and /* ... */ block comments. Conservative regex.
  # Note: doesn't handle // inside strings perfectly, but good enough for lint.
  sed -E 's://[^"]*$::g' "$f" | awk '
    BEGIN{inblock=0}
    {
      line = $0
      while (match(line, /\/\*.*\*\//)) {
        line = substr(line, 1, RSTART-1) substr(line, RSTART+RLENGTH)
      }
      if (inblock) {
        if (match(line, /\*\//)) {
          line = substr(line, RSTART+RLENGTH); inblock=0
        } else { next }
      }
      if (match(line, /\/\*/)) {
        line = substr(line, 1, RSTART-1); inblock=1
      }
      print line
    }
  '
}

# _wl_to_json <file> -> echo JSON (best-effort)
_wl_to_json() {
  local f="$1"
  case "$f" in
    *.toml)
      if command -v tomlq >/dev/null 2>&1; then
        tomlq -c '.' "$f" 2>/dev/null || printf '{}'
        return
      fi
      if command -v dasel >/dev/null 2>&1; then
        dasel -r toml -w json -f "$f" 2>/dev/null || printf '{}'
        return
      fi
      # Fallback: a very gentle TOML reader for the keys we care about.
      _wl_toml_to_json_fallback "$f"
      ;;
    *.jsonc|*.json)
      _wl_strip_comments "$f" | jq -c '.' 2>/dev/null || printf '{}'
      ;;
    *)
      printf '{}'
      ;;
  esac
}

# _wl_toml_to_json_fallback <file>
# Extracts: name, compatibility_date, compatibility_flags (array), nodejs_compat (in flags),
# routes (array of strings or table arrays), vars (table), keep_vars (bool).
_wl_toml_to_json_fallback() {
  local f="$1"
  local name compat_date keep_vars
  name="$(grep -E '^[[:space:]]*name[[:space:]]*=' "$f" | head -1 | sed -E 's/^[^=]*=[[:space:]]*"([^"]*)".*/\1/')"
  compat_date="$(grep -E '^[[:space:]]*compatibility_date[[:space:]]*=' "$f" | head -1 | sed -E 's/^[^=]*=[[:space:]]*"([^"]*)".*/\1/')"
  keep_vars="$(grep -E '^[[:space:]]*keep_vars[[:space:]]*=' "$f" | head -1 | sed -E 's/^[^=]*=[[:space:]]*([^[:space:]#]+).*/\1/')"

  # compatibility_flags: read array on a single line.
  local flags_line flags_json="[]"
  flags_line="$(grep -E '^[[:space:]]*compatibility_flags[[:space:]]*=' "$f" | head -1 || true)"
  if [[ -n "$flags_line" ]]; then
    local items
    items="$(printf '%s' "$flags_line" | sed -E 's/.*=[[:space:]]*\[(.*)\].*/\1/')"
    flags_json="$(printf '%s' "$items" | tr ',' '\n' | sed -E 's/^[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/' \
      | jq -R . 2>/dev/null | jq -s -c '.' 2>/dev/null || echo '[]')"
  fi

  # routes: best-effort — string assignments and tables under [[routes]] not parsed deeply.
  local routes_json="[]"
  if grep -qE '^[[:space:]]*routes?[[:space:]]*=' "$f"; then
    local rline
    rline="$(grep -E '^[[:space:]]*routes?[[:space:]]*=' "$f" | head -1)"
    local rcontent
    rcontent="$(printf '%s' "$rline" | sed -E 's/.*=[[:space:]]*\[(.*)\].*/\1/')"
    routes_json="$(printf '%s' "$rcontent" | tr ',' '\n' | sed -E 's/^[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/' \
      | jq -R . 2>/dev/null | jq -s -c '.' 2>/dev/null || echo '[]')"
  fi

  # vars: pull keys + values from [vars] section.
  local vars_json="{}"
  if grep -qE '^\[vars\]' "$f"; then
    vars_json="$(awk '
      /^\[vars\]/{ insec=1; next }
      /^\[/{ insec=0 }
      insec && /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/{
        line=$0
        sub(/^[[:space:]]*/,"",line)
        eq=index(line,"=")
        k=substr(line,1,eq-1); gsub(/[[:space:]]*$/,"",k)
        v=substr(line,eq+1); gsub(/^[[:space:]]*/,"",v); gsub(/[[:space:]]*$/,"",v)
        gsub(/^"/, "", v); gsub(/"$/, "", v)
        gsub(/"/, "\\\"", v)
        printf "%s\"%s\":\"%s\"", (n++?",":""), k, v
      }
      END{ print "" }
    ' "$f" | sed 's/^/{/' | sed 's/$/}/' )"
    [[ -z "$vars_json" || "$vars_json" == "{}" ]] && vars_json="{}"
  fi

  jq -n \
    --arg name "$name" \
    --arg cd "$compat_date" \
    --arg kv "$keep_vars" \
    --argjson flags "$flags_json" \
    --argjson routes "$routes_json" \
    --argjson vars "$vars_json" \
    '{
      name: ($name|select(length>0)),
      compatibility_date: ($cd|select(length>0)),
      compatibility_flags: $flags,
      routes: $routes,
      vars: $vars,
      keep_vars: ($kv == "true")
    }'
}

# _wl_six_months_ago_iso
_wl_six_months_ago_iso() {
  if date -u -v-6m +%Y-%m-%d >/dev/null 2>&1; then
    date -u -v-6m +%Y-%m-%d
  else
    date -u -d '6 months ago' +%Y-%m-%d 2>/dev/null || date -u +%Y-%m-%d
  fi
}

# _wl_high_entropy <value> -> 0 if looks like a secret
_wl_high_entropy() {
  local v="$1"
  local len="${#v}"
  [[ "$len" -lt 20 ]] && return 1
  printf '%s' "$v" | grep -qE '[A-Z]' || return 1
  printf '%s' "$v" | grep -qE '[a-z]' || return 1
  printf '%s' "$v" | grep -qE '[0-9]' || return 1
  printf '%s' "$v" | grep -qE '[^A-Za-z0-9]|[+/=_-]' || return 1
  return 0
}

# _wl_node_api_used -> 0 if any Node-only API import detectable in src/
_wl_node_api_used() {
  [[ -d src ]] || return 1
  grep -REn --include='*.ts' --include='*.tsx' --include='*.js' --include='*.mjs' --include='*.cjs' \
    -e "from ['\"]node:" \
    -e "require\(['\"]node:" \
    -e "from ['\"]fs['\"]" \
    -e "from ['\"]path['\"]" \
    -e "from ['\"]crypto['\"]" \
    -e "from ['\"]buffer['\"]" \
    -e "from ['\"]stream['\"]" \
    -e "Buffer\." \
    -e "process\.env" \
    src/ >/dev/null 2>&1
}

# wrangler_lint_run — audit
wrangler_lint_run() {
  log_section "wrangler lint"
  local cfg
  cfg="$(_wl_find_config)"
  if [[ -z "$cfg" ]]; then
    log_info "no wrangler.toml/jsonc/json in cwd; skipping wrangler lint."
    return 0
  fi
  log_info "linting ${cfg}"

  local j
  j="$(_wl_to_json "$cfg")"

  local cd_val
  cd_val="$(jq -r '.compatibility_date // empty' <<<"$j" 2>/dev/null)"
  if [[ -z "$cd_val" ]]; then
    log_warn "wrangler" "compat-date" "compatibility_date is missing in ${cfg}. Set to today's date." \
      "https://developers.cloudflare.com/workers/configuration/compatibility-dates/"
  else
    local cutoff
    cutoff="$(_wl_six_months_ago_iso)"
    if [[ "$cd_val" < "$cutoff" ]]; then
      log_warn "wrangler" "compat-date-stale" \
        "compatibility_date '${cd_val}' is older than 6 months (${cutoff}). Consider bumping after testing." \
        "https://developers.cloudflare.com/workers/configuration/compatibility-dates/"
    else
      log_ok "wrangler" "compat-date" "compatibility_date '${cd_val}' is recent."
    fi
  fi

  # nodejs_compat flag check.
  local has_node_flag
  has_node_flag="$(jq -r '(.compatibility_flags // []) | index("nodejs_compat") // empty' <<<"$j" 2>/dev/null)"
  if [[ -n "$has_node_flag" && "$has_node_flag" != "null" ]]; then
    if _wl_node_api_used; then
      log_ok "wrangler" "nodejs-compat" "nodejs_compat flag set; Node-only APIs detected in src/."
    else
      log_warn "wrangler" "nodejs-compat-unused" \
        "nodejs_compat flag set in ${cfg} but no Node-only API import detected in src/. Consider removing the flag." \
        "https://developers.cloudflare.com/workers/runtime-apis/nodejs/"
    fi
  fi

  # routes for production.
  local routes_count
  routes_count="$(jq -r '(.routes // []) | length' <<<"$j" 2>/dev/null)"
  if [[ "${routes_count:-0}" == "0" ]]; then
    log_warn "wrangler" "routes" \
      "No 'routes' configured in ${cfg}. Production traffic should be bound to a route or zone_id." \
      "https://developers.cloudflare.com/workers/configuration/routing/routes/"
  else
    log_ok "wrangler" "routes" "${routes_count} route(s) configured."
  fi

  # vars: high-entropy values look like secrets.
  local secret_names=()
  while IFS=$'\t' read -r k v; do
    [[ -z "$k" ]] && continue
    if _wl_high_entropy "$v"; then
      secret_names+=("$k")
    fi
  done < <(jq -r '(.vars // {}) | to_entries[]? | [.key, (.value|tostring)] | @tsv' <<<"$j" 2>/dev/null)

  if [[ "${#secret_names[@]}" -gt 0 ]]; then
    local joined="${secret_names[*]}"
    log_fail "wrangler" "vars-secret-shaped" \
      "These [vars] keys have high-entropy values that look like secrets: ${joined}. Move them to secrets: 'wrangler secret put <NAME>'." \
      "https://developers.cloudflare.com/workers/configuration/secrets/"
    printf '%s\n' "${secret_names[@]}" > "${STATE_DIR}/wrangler-secret-candidates.txt"
  else
    log_ok "wrangler" "vars-secret-shaped" "No [vars] values look like secrets."
  fi

  # keep_vars info-level.
  local has_vars keep_vars_set
  has_vars="$(jq -r '(.vars // {}) | length' <<<"$j" 2>/dev/null)"
  keep_vars_set="$(jq -r '.keep_vars // false' <<<"$j" 2>/dev/null)"
  if [[ "${has_vars:-0}" -gt 0 && "$keep_vars_set" != "true" ]]; then
    log_info "wrangler/keep_vars: vars are present but keep_vars is not true. If you depend on dashboard-set vars surviving deploys, add keep_vars=true."
  fi

  # wrangler types.
  if command -v wrangler >/dev/null 2>&1; then
    log_info "running 'wrangler types' to refresh worker-configuration.d.ts..."
    if wrangler types >/dev/null 2>&1; then
      log_ok "wrangler" "types" "worker-configuration.d.ts regenerated."
    else
      log_warn "wrangler" "types" "wrangler types failed. Run manually: wrangler types"
    fi
  else
    log_warn "wrangler" "types" "wrangler not installed; cannot regenerate worker-configuration.d.ts. Install: npm install -g wrangler" \
      "https://developers.cloudflare.com/workers/wrangler/install-and-update/"
  fi
}

# _wl_emit_dev_vars_template <names...>
_wl_emit_dev_vars_template() {
  local body="# .dev.vars — local dev secrets. Do NOT commit.
# Each name was detected from your wrangler.toml [vars] block as high-entropy.
# Move the production value to: wrangler secret put <NAME>
"
  local n
  for n in "$@"; do
    body+=$'\n'"${n}="
  done

  printf '\n=== FILE: .dev.vars.template ===\n'
  printf '=== DIFF ===\n'
  printf -- '--- /dev/null\n+++ .dev.vars.template\n'
  printf '%s\n' "$body" | sed 's/^/+/'
  printf '=== CONTENT ===\n'
  printf '%s\n' "$body"
  printf '=== END ===\n'
}

# _wl_emit_compat_date_bump <cfg> <today>
_wl_emit_compat_date_bump() {
  local cfg="$1" today="$2"
  case "$cfg" in
    *.toml)
      printf '\n=== FILE: %s ===\n' "$cfg"
      printf '=== DIFF ===\n'
      printf -- "--- %s\n+++ %s\n" "$cfg" "$cfg"
      printf -- '@@\n-compatibility_date = "<old>"\n+compatibility_date = "%s"\n' "$today"
      printf '=== CONTENT ===\n'
      printf '(only the compatibility_date line should change to: compatibility_date = "%s")\n' "$today"
      printf '=== END ===\n'
      ;;
    *)
      printf '\n=== FILE: %s ===\n' "$cfg"
      printf '=== DIFF ===\n'
      printf -- "--- %s\n+++ %s\n" "$cfg" "$cfg"
      printf -- '@@\n-  "compatibility_date": "<old>",\n+  "compatibility_date": "%s",\n' "$today"
      printf '=== CONTENT ===\n'
      printf '(only the "compatibility_date" key should change to: "%s")\n' "$today"
      printf '=== END ===\n'
      ;;
  esac
}

# wrangler_lint_fix
# - Emits compat-date bump (only with CFSEC_WRANGLER_BUMP_CONFIRMED=1).
# - Emits .dev.vars.template from secret-candidates.txt.
wrangler_lint_fix() {
  local cfg
  cfg="$(_wl_find_config)"
  if [[ -z "$cfg" ]]; then
    log_info "no wrangler config in cwd; nothing to fix."
    return 0
  fi

  local j today
  j="$(_wl_to_json "$cfg")"
  today="$(date -u +%Y-%m-%d)"
  local cd_val
  cd_val="$(jq -r '.compatibility_date // empty' <<<"$j" 2>/dev/null)"

  if [[ -z "$cd_val" || "$cd_val" != "$today" ]]; then
    if [[ "${CFSEC_WRANGLER_BUMP_CONFIRMED:-0}" == "1" ]]; then
      log_info "bumping compatibility_date to ${today}."
      _wl_emit_compat_date_bump "$cfg" "$today"
    else
      log_info "compatibility_date bump skipped. Re-run with CFSEC_WRANGLER_BUMP_CONFIRMED=1 to emit the diff."
    fi
  else
    log_ok "wrangler" "compat-date" "compatibility_date already at ${today}; no bump needed."
  fi

  # .dev.vars.template generation.
  local cand="${STATE_DIR}/wrangler-secret-candidates.txt"
  if [[ -f "$cand" && -s "$cand" ]]; then
    local names=()
    while IFS= read -r n; do
      [[ -n "$n" ]] && names+=("$n")
    done < "$cand"
    if [[ "${#names[@]}" -gt 0 ]]; then
      _wl_emit_dev_vars_template "${names[@]}"
      log_ok "wrangler" "dev-vars" "Emitted .dev.vars.template with ${#names[@]} key(s)."
    fi
  else
    log_info "no secret-shaped vars detected; .dev.vars.template not generated."
  fi
}
