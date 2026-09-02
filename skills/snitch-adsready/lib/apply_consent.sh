# lib/apply_consent.sh — emits a Consent Mode v2 starter snippet.
# Reads templates/consent-mode-v2.starter.html. Inserts
# default-deny + per-platform mapping notes for any pixels detected in cwd.
#
# Idempotent: if the cwd already contains gtag('consent', 'default', ...) in
# any HTML / JS / TS source file, no-op with [OK].
#
# Exports: apply_consent [platform...]

# Detect existing consent setup in cwd source.
_apply_consent_already_present() {
  if grep -r -E -q "gtag\\('consent'" \
    --include='*.html' --include='*.htm' \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    --include='*.mjs' --include='*.cjs' --include='*.vue' --include='*.svelte' --include='*.astro' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
    --exclude-dir=dist --exclude-dir=build --exclude-dir=out \
    . 2>/dev/null; then
    return 0
  fi
  return 1
}

apply_consent() {
  log_section "apply consent-mode"

  if _apply_consent_already_present; then
    log_ok "consent" "apply" "Consent Mode v2 default snippet already present in this project. No changes."
    return 0
  fi

  local tpl="${TPL_DIR}/consent-mode-v2.starter.html"
  if [[ ! -f "$tpl" ]]; then
    log_fail "consent" "template" "consent-mode-v2 starter template missing at ${tpl}. Reinstall the skill — the templates/ directory beside ads-ready.sh is incomplete."
    return 4
  fi

  local rel_path="src/components/consent-mode.html"
  log_info "Consent Mode v2 not detected; proposing a starter snippet."
  log_info "Apply via Edit/Write after the user agrees. Insert the snippet BEFORE any pixel script."

  printf '\n=== FILE: %s ===\n' "$rel_path"
  printf '=== DIFF ===\n'
  printf '(new file)\n'
  printf '=== CONTENT ===\n'
  cat "$tpl"
  printf '\n=== END ===\n'

  log_warn "consent" "apply" "Proposed Consent Mode v2 snippet for ${rel_path}. User confirmation required before write."
}
