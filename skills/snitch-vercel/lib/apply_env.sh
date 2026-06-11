# lib/apply_env.sh — env-var hygiene.
# - Flag NEXT_PUBLIC_* with secret-shaped names.
# - Flag plaintext (non-Sensitive) vars with secret-shaped names/values.
# - Emit `vercel env rm` + `vercel env add ... --sensitive` instructions for migration.
# Never types secret values; emits CLI invocations the user runs themselves.

apply_env() {
  local project_id="${1:-}"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    log_fail "env" "pick" "No project selected. Set VRCSEC_PROJECT_ID or run inside a linked project."
    return 3
  fi

  log_section "env apply (project_id: ${project_id})"

  local body; body="$(vrc_get "/v9/projects/${project_id}/env?decrypt=false")" || {
    log_fail "env" "read" "Could not list env vars. $(vrc_last_error)"
    return 3
  }

  # Plaintext + secret-shaped name → recommend Sensitive type.
  local plaintext_secrets
  plaintext_secrets="$(jq -r '
    [(.envs // [])[]
      | select((.type // "plain") | test("^(plain|encrypted)$"))
      | select((.type // "plain") != "secret" and (.type // "plain") != "sensitive")
      | select(.key | test("(?i)(secret|token|api[_-]?key|password|passwd|private_key|dsn|connection|database_url)"))
      | .key
    ] | unique | .[]' <<<"$body" 2>/dev/null)"

  local k
  if [[ -n "$plaintext_secrets" ]]; then
    log_warn "env" "plaintext-secrets" "The following plaintext env vars have secret-shaped names. Re-add them as Sensitive type so values are write-once and not visible in the UI."
    printf '\n=== ENV VARS TO MIGRATE TO SENSITIVE ===\n'
    while IFS= read -r k; do
      [[ -z "$k" ]] && continue
      printf '  vercel env rm  %s production   # then add with --sensitive\n' "$k"
      printf '  vercel env add %s production --sensitive\n' "$k"
    done <<<"$plaintext_secrets"
    printf '=== END ===\n'
  else
    log_ok "env" "plaintext-secrets" "No plaintext vars with secret-shaped names detected."
  fi

  # NEXT_PUBLIC_* with secret-shaped names — these are SHIPPED TO BROWSER.
  local public_leaks
  public_leaks="$(jq -r '
    [(.envs // [])[]
      | select(.key | startswith("NEXT_PUBLIC_"))
      | select(.key | test("(?i)(secret|token|api[_-]?key|password|passwd|private_key|dsn|connection|database_url)"))
      | .key
    ] | unique | .[]' <<<"$body" 2>/dev/null)"
  if [[ -n "$public_leaks" ]]; then
    log_fail "env" "next-public-leak" "NEXT_PUBLIC_* vars with secret-shaped names detected — these are bundled into the browser by Next.js. Move to a non-public name and access server-side only."
    printf '\n=== NEXT_PUBLIC_* SECRET LEAKS ===\n'
    while IFS= read -r k; do
      [[ -z "$k" ]] && continue
      printf '  - %s   (rename to drop NEXT_PUBLIC_ prefix; only use server-side)\n' "$k"
    done <<<"$public_leaks"
    printf '=== END ===\n'
  else
    log_ok "env" "next-public-leak" "No NEXT_PUBLIC_* secret-shape leaks in Vercel env."
  fi

  # cwd .env files: flag committed-looking secrets.
  if compgen -G ".env*" >/dev/null 2>&1; then
    log_warn "env" "cwd-dotenv" ".env* files detected in cwd. Verify .gitignore excludes .env.local / .env / .env.production. Never commit values; use 'vercel env add' instead." "https://vercel.com/docs/projects/environment-variables"
  fi

  return 0
}
