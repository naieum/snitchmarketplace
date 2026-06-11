# lib/apply_project.sh — emits stdout-only file diffs for project-side changes.
# Exposes:
#   apply_project [args]   — emits proposed file paths + bodies + diffs per
#                            CONVENTIONS.md "File writes" template. Never
#                            mutates user files.
# Side effects:
#   - Reads cwd files only. Writes nothing in cwd.
#   - Stdout is the contract; Claude (the agent) applies via Edit/Write.

# _emit_file <relative_path> <full_body>
# Per CONVENTIONS.md "File writes" template:
#   === FILE: <path> ===
#   === DIFF ===
#   <diff>
#   === CONTENT ===
#   <body>
#   === END ===
_emit_file() {
  local path="$1" body="$2"
  printf '\n=== FILE: %s ===\n' "$path"
  printf '=== DIFF ===\n'
  if [[ -f "$path" ]]; then
    diff -u "$path" <(printf '%s' "$body") || true
  else
    printf '(new file)\n'
    printf '%s' "$body" | sed 's/^/+/'
    printf '\n'
  fi
  printf '=== CONTENT ===\n'
  printf '%s' "$body"
  printf '\n=== END ===\n'
}

# _emit_headers_template — _headers body merged with existing entries (existing wins for headers we don't set).
_emit_headers_template() {
  local existing=""
  if [[ -f "_headers" ]]; then
    existing="$(cat _headers)"
  fi
  local template
  template="$(cat <<'EOF'
/*
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: geolocation=(), microphone=(), camera=()
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Resource-Policy: same-site
  Content-Security-Policy: default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'
EOF
)"
  if [[ -n "$existing" ]]; then
    # Naive merge: keep existing, append our block under a new path-match if /* not already present.
    if grep -qE '^/\*[[:space:]]*$' <<<"$existing"; then
      _emit_file "_headers" "$existing"
      return 0
    fi
    _emit_file "_headers" "$(printf '%s\n\n%s\n' "$existing" "$template")"
  else
    _emit_file "_headers" "$(printf '%s\n' "$template")"
  fi
}

# _emit_gitignore_additions
_emit_gitignore_additions() {
  local additions=()
  local pat
  for pat in ".dev.vars" ".env" ".env.*" ".wrangler/" "node_modules/"; do
    if [[ -f ".gitignore" ]]; then
      if ! grep -Fxq "$pat" .gitignore 2>/dev/null && ! grep -Fxq "${pat%/}" .gitignore 2>/dev/null; then
        additions+=("$pat")
      fi
    else
      additions+=("$pat")
    fi
  done
  if [[ "${#additions[@]}" -eq 0 ]]; then
    log_ok "project" "gitignore" ".gitignore already covers .dev.vars / .env / .env.* / .wrangler/ / node_modules/."
    return 0
  fi
  local existing="" body
  [[ -f ".gitignore" ]] && existing="$(cat .gitignore)"
  if [[ -n "$existing" ]]; then
    body="$(printf '%s\n\n# snitch-cloudflare additions\n%s\n' "$existing" "$(printf '%s\n' "${additions[@]}")")"
  else
    body="$(printf '# snitch-cloudflare baseline\n%s\n' "$(printf '%s\n' "${additions[@]}")")"
  fi
  _emit_file ".gitignore" "$body"
}

# _detect_secret_names — scans wrangler.toml/jsonc + .env* for secret-like keys.
# Echoes one name per line, sorted unique.
_detect_secret_names() {
  local out=""
  local f line key val
  if [[ -f "wrangler.toml" ]]; then
    local in_vars=0
    while IFS= read -r line; do
      if [[ "$line" =~ ^\[vars\]$ ]]; then in_vars=1; continue; fi
      if [[ "$line" =~ ^\[ ]]; then in_vars=0; continue; fi
      [[ "$in_vars" -eq 1 ]] || continue
      if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]]; then
        key="${BASH_REMATCH[1]}"
        val="${BASH_REMATCH[2]}"
        local lkey="${key,,}"
        case "$lkey" in
          *secret*|*token*|*api_key*|*apikey*|*password*|*passwd*|*private_key*|*dsn*|*connection_string*|*database_url*)
            out="${out}${key}"$'\n'
            ;;
          *)
            if [[ "${#val}" -gt 20 && "$val" =~ [A-Z] && "$val" =~ [a-z] && "$val" =~ [0-9] ]]; then
              out="${out}${key}"$'\n'
            fi
            ;;
        esac
      fi
    done < "wrangler.toml"
  fi
  for f in .dev.vars .env .env.local .env.development .env.production; do
    [[ -f "$f" ]] || continue
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=(.*)$ ]]; then
        out="${out}${BASH_REMATCH[1]}"$'\n'
      fi
    done < "$f"
  done
  printf '%s' "$out" | awk 'NF' | sort -u
}

# _emit_dev_vars_template
_emit_dev_vars_template() {
  local names body line
  names="$(_detect_secret_names)"
  if [[ -z "$names" ]]; then
    log_ok "project" "dev-vars" "No secret names detected; .dev.vars.template not needed."
    return 0
  fi
  body="# .dev.vars.template — populated by snitch-cloudflare"$'\n'
  body+="# Copy to .dev.vars (gitignored) and fill in values for local Wrangler dev."$'\n'
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    body+="${line}="$'\n'
  done <<<"$names"
  _emit_file ".dev.vars.template" "$body"
}

# _emit_wrangler_secret_commands
_emit_wrangler_secret_commands() {
  if [[ ! -f "wrangler.toml" ]]; then
    return 0
  fi
  local in_vars=0 line key val to_migrate=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^\[vars\]$ ]]; then in_vars=1; continue; fi
    if [[ "$line" =~ ^\[ ]]; then in_vars=0; continue; fi
    [[ "$in_vars" -eq 1 ]] || continue
    if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]]; then
      key="${BASH_REMATCH[1]}"
      val="${BASH_REMATCH[2]}"
      local lkey="${key,,}"
      case "$lkey" in
        *secret*|*token*|*api_key*|*apikey*|*password*|*passwd*|*private_key*|*dsn*|*connection_string*|*database_url*)
          to_migrate+=("$key")
          continue
          ;;
      esac
      if [[ "${#val}" -gt 20 && "$val" =~ [A-Z] && "$val" =~ [a-z] && "$val" =~ [0-9] ]]; then
        to_migrate+=("$key")
      fi
    fi
  done < "wrangler.toml"
  if [[ "${#to_migrate[@]}" -eq 0 ]]; then
    return 0
  fi
  printf '\n=== WRANGLER SECRETS TO MIGRATE ===\n'
  printf 'Run each of the following, then DELETE the value from wrangler.toml [vars]:\n'
  local k
  for k in "${to_migrate[@]}"; do
    printf '  wrangler secret put %s\n' "$k"
  done
  printf '=== END ===\n'
}

# apply_project [args] — main entry.
apply_project() {
  local kind="static"
  if [[ -f "${STATE_DIR}/project-kind.txt" ]]; then
    kind="$(cat "${STATE_DIR}/project-kind.txt" 2>/dev/null)"
  elif [[ -f "_headers" || -f "_redirects" ]]; then
    kind="pages"
  elif [[ -f "wrangler.toml" ]] && grep -qE '^[[:space:]]*main[[:space:]]*=' wrangler.toml 2>/dev/null; then
    kind="workers"
  fi

  log_section "project apply (kind: ${kind}, cwd: $(pwd))"

  log_subsection "_headers (Pages)"
  if [[ "$kind" == "pages" || "$kind" == "static" ]]; then
    _emit_headers_template
  else
    log_info "_headers is Pages-only; skipping for kind=${kind}."
  fi

  log_subsection ".gitignore"
  _emit_gitignore_additions

  log_subsection ".dev.vars.template"
  _emit_dev_vars_template

  if [[ "$kind" == "workers" ]]; then
    log_subsection "wrangler secret migration"
    _emit_wrangler_secret_commands
  fi

  return 0
}
