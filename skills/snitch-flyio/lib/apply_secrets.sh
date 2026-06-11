# lib/apply_secrets.sh — recommend fly secrets set for any high-entropy env var.
# Exports: apply_secrets [app]
#
# Idempotency: never types secret values. Emits the canonical command for each
# at-risk key and (when the agent has the value handy) suggests rotation. Never
# writes inside the project; only emits stdout.

apply_secrets() {
  local target="${1:-}"
  local app
  app="$(api_pick_app 2>/dev/null || printf '')"
  [[ -n "$target" ]] && app="$target"

  if [[ ! -f "fly.toml" ]]; then
    log_warn "secrets" "no-toml" "No fly.toml in cwd; nothing to scan locally. Use: fly secrets list -a <app>."
    return 0
  fi

  log_section "secrets: ${app:-(unset)}"

  local plain_keys
  plain_keys="$(grep -E -A 200 '^\[env\]' fly.toml 2>/dev/null \
    | grep -E '^[[:space:]]*[A-Z_][A-Z0-9_]*[[:space:]]*=[[:space:]]*"[^"]{24,}"' \
    | grep -E -i '(KEY|SECRET|TOKEN|PASS(WORD)?|DSN|URL|CONN)' \
    | sed -E 's/^[[:space:]]*([A-Z_][A-Z0-9_]*).*/\1/' \
    | sort -u)"

  if [[ -z "$plain_keys" ]]; then
    log_ok "secrets" "scan-env" "No likely-plaintext secrets in fly.toml [env]."
  else
    log_fail "secrets" "scan-env" "Plaintext-looking secret values in fly.toml [env] (see below). Move each to \`fly secrets set\`."
    local k
    while IFS= read -r k; do
      [[ -z "$k" ]] && continue
      printf '  fly secrets set %s=<NEW_VALUE> -a %s\n' "$k" "${app:-<app>}"
    done <<<"$plain_keys"
    log_info "After moving, delete each key from fly.toml [env] and redeploy. The agent applies via Edit."
  fi

  # --- check overlap between fly secrets list and [env] keys ---
  if [[ -n "$app" ]]; then
    local secrets_json env_keys overlap
    secrets_json="$(fly_run_json secrets list -a "$app" 2>/dev/null || printf '[]')"
    env_keys="$(grep -E -A 200 '^\[env\]' fly.toml 2>/dev/null \
      | grep -E '^[[:space:]]*[A-Z_][A-Z0-9_]*[[:space:]]*=' \
      | sed -E 's/^[[:space:]]*([A-Z_][A-Z0-9_]*).*/\1/' \
      | sort -u | jq -R . | jq -s . 2>/dev/null || printf '[]')"
    overlap="$(jq -c --argjson e "$env_keys" \
      '[ .[] | (.Name // .name) as $n | select($e | index($n)) | $n ]' \
      <<<"$secrets_json" 2>/dev/null)"
    local n; n="$(jq -r 'length' <<<"$overlap" 2>/dev/null || printf '0')"
    if [[ "$n" -gt 0 ]]; then
      log_fail "secrets" "overlap" "Keys present in BOTH fly.toml [env] and \`fly secrets list\`: $(jq -r '. | join(", ")' <<<"$overlap"). The secret value wins at runtime, but the [env] copy leaks into git."
      log_info "Recommended: delete these keys from fly.toml [env]; the secret stays."
    else
      log_ok "secrets" "no-overlap" "No keys overlap between fly.toml [env] and fly secrets."
    fi
  fi

  log_info "Set new secret: fly secrets set NAME=value -a ${app:-<app>}"
  log_info "Stage without deploy:    fly secrets set --stage NAME=value -a ${app:-<app>}; then fly deploy."
  log_info "Remove a secret:        fly secrets unset NAME -a ${app:-<app>}"

  return 0
}
