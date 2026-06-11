# lib/apply_apps.sh — idempotent fly.toml hardening (force_https, env hygiene).
# Exports: apply_apps [app]
#
# Reads fly.toml from cwd. Emits proposed file diffs to stdout per the skill
# convention; never writes inside the user's project. The agent applies via Edit/Write.

apply_apps() {
  local target="${1:-}"
  local toml="fly.toml"
  if [[ ! -f "$toml" ]]; then
    log_warn "apps" "no-toml" "No fly.toml in cwd. Skipping fly.toml hardening. Pass cwd that contains a fly.toml, or run \`fly config save -a <app>\` first."
    return 0
  fi

  local app
  app="$(grep -E '^app[[:space:]]*=' "$toml" 2>/dev/null | head -n1 \
    | sed -E 's/^app[[:space:]]*=[[:space:]]*"?([^"#]+)"?.*/\1/' | tr -d '[:space:]')"
  if [[ -n "$target" && -n "$app" && "$target" != "$app" ]]; then
    log_warn "apps" "app-mismatch" "fly.toml app=${app} but you passed app=${target}. Continuing with fly.toml's app."
  fi

  log_section "apps: ${app:-unknown} (fly.toml)"

  # --- 1. force_https ---
  local fh="unset"
  if grep -E -q '^[[:space:]]*force_https[[:space:]]*=[[:space:]]*true' "$toml" 2>/dev/null; then
    fh="true"
  elif grep -E -q '^[[:space:]]*force_https[[:space:]]*=[[:space:]]*false' "$toml" 2>/dev/null; then
    fh="false"
  fi
  if [[ "$fh" == "true" ]]; then
    log_ok "apps" "force-https" "force_https=true in fly.toml."
  else
    log_warn "apps" "force-https" "force_https is ${fh} in fly.toml. Recommended: true. The agent should propose an Edit." \
      "https://fly.io/docs/reference/configuration/#the-http_service-section"
    _emit_force_https_patch "$toml"
  fi

  # --- 2. plaintext-secret heuristic ---
  local plain_keys
  plain_keys="$(grep -E -A 200 '^\[env\]' "$toml" 2>/dev/null \
    | grep -E '^[[:space:]]*[A-Z_][A-Z0-9_]*[[:space:]]*=[[:space:]]*"[^"]{24,}"' \
    | grep -E -i '(KEY|SECRET|TOKEN|PASS(WORD)?|DSN|URL|CONN)' \
    | sed -E 's/^[[:space:]]*([A-Z_][A-Z0-9_]*).*/\1/' \
    | sort -u)"
  if [[ -z "$plain_keys" ]]; then
    log_ok "apps" "no-plaintext-secrets" "No high-entropy values look like plaintext secrets in [env]."
  else
    local k
    while IFS= read -r k; do
      [[ -z "$k" ]] && continue
      log_fail "apps" "plaintext-secret" "[env] ${k} looks like a secret. Move it: fly secrets set ${k}=<value> -a ${app:-<app>} (then delete from fly.toml [env])." \
        "https://fly.io/docs/apps/secrets/"
    done <<<"$plain_keys"
  fi

  # --- 3. checks present? ---
  if grep -E -q '^\[\[http_service\.checks\]\]|^\[\[services\..*checks\]\]|^\[\[checks\.' "$toml" 2>/dev/null; then
    log_ok "apps" "health-checks" "Health checks defined in fly.toml."
  else
    log_warn "apps" "health-checks" "No [[http_service.checks]] / [[checks]] block found. Add a /health probe so machines that fail come up dead."
  fi

  # --- 4. internal_port set on services ---
  if grep -E -q '^[[:space:]]*internal_port[[:space:]]*=' "$toml" 2>/dev/null; then
    log_ok "apps" "internal-port" "internal_port set on at least one service."
  else
    log_warn "apps" "internal-port" "No internal_port set. Required for HTTP services on Machines."
  fi

  return 0
}

_emit_force_https_patch() {
  local toml="$1"
  local rel="${toml#"$PWD/"}"
  printf '\n=== FILE: %s ===\n' "$rel"
  printf '=== DIFF ===\n'
  if grep -E -q '^\[http_service\]' "$toml" 2>/dev/null; then
    printf '@@ inside [http_service] @@\n'
    if grep -E -q '^[[:space:]]*force_https[[:space:]]*=' "$toml"; then
      printf -- '-force_https = false\n+force_https = true\n'
    else
      printf -- '+force_https = true\n'
    fi
  else
    printf '+[http_service]\n+  force_https = true\n+  auto_stop_machines = "stop"\n+  auto_start_machines = true\n+  min_machines_running = 0\n'
  fi
  printf '=== CONTENT ===\n'
  printf 'Apply the diff above to fly.toml. Re-run \`bash snitch-flyio.sh fix apps\` to verify.\n'
  printf '=== END ===\n\n'
}
