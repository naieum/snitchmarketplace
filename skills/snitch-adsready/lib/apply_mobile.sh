# lib/apply_mobile.sh — emits viewport + theme-color + manifest meta tags.
#
# Exports: apply_mobile

apply_mobile() {
  log_section "apply mobile-meta"

  local rel_path="src/components/mobile-meta.html"
  local content
  content=$'<!-- mobile + viewport — managed by ads-ready -->\n'
  content+=$'<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
  content+=$'<meta name="theme-color" content="#000000">\n'
  content+=$'<meta name="apple-mobile-web-app-capable" content="yes">\n'
  content+=$'<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">\n'
  content+=$'<meta name="format-detection" content="telephone=no">\n'
  content+=$'<link rel="manifest" href="/manifest.webmanifest">\n'
  content+=$'<link rel="icon" type="image/svg+xml" href="/favicon.svg">\n'
  content+=$'<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">\n'

  log_info "Proposing mobile/viewport meta block."
  printf '\n=== FILE: %s ===\n' "$rel_path"
  printf '=== DIFF ===\n(new file)\n'
  printf '=== CONTENT ===\n%s\n=== END ===\n' "$content"
  log_warn "mobile-meta" "apply" "Proposed mobile-meta block. Insert into <head> alongside other meta tags."
}
