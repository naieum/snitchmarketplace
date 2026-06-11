# lib/apply_headers.sh — emit a vercel.json `headers` block with security headers.
# Per CONVENTIONS.md, never writes inside the user's project; emits stdout File-writes
# contract for the agent to apply via Edit/Write.

# _emit_file <relative_path> <full_body>
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

# Build the security headers block.
_headers_block_jq() {
  cat <<'JQ'
[
  {
    "source": "/(.*)",
    "headers": [
      { "key": "Strict-Transport-Security",       "value": "max-age=63072000; includeSubDomains; preload" },
      { "key": "X-Content-Type-Options",          "value": "nosniff" },
      { "key": "X-Frame-Options",                 "value": "DENY" },
      { "key": "Referrer-Policy",                 "value": "strict-origin-when-cross-origin" },
      { "key": "Permissions-Policy",              "value": "geolocation=(), microphone=(), camera=()" },
      { "key": "Cross-Origin-Opener-Policy",      "value": "same-origin" },
      { "key": "Cross-Origin-Resource-Policy",    "value": "same-site" },
      { "key": "Content-Security-Policy",         "value": "default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'" }
    ]
  }
]
JQ
}

apply_headers() {
  log_section "headers apply (cwd: $(pwd))"

  local existing target merged body
  if [[ -f "vercel.json" ]]; then
    existing="$(cat vercel.json)"
  else
    existing='{}'
  fi
  target="$(_headers_block_jq)"

  # Merge: keep existing keys (functions, redirects, ...); set our headers if absent,
  # else preserve an existing user-edited headers block but warn about overlaps.
  local has_headers; has_headers="$(jq 'has("headers")' <<<"$existing" 2>/dev/null)"
  if [[ "$has_headers" == "true" ]]; then
    log_warn "headers" "merge" "vercel.json already has a 'headers' key. Review the proposed block below and merge entries by hand if needed." "https://vercel.com/docs/projects/project-configuration#headers"
    body="$existing"
  else
    merged="$(jq --argjson h "$target" '. + {"headers": $h}' <<<"$existing")"
    body="$merged"
  fi

  _emit_file "vercel.json" "$body"

  log_info "After applying, redeploy: 'vercel --prod'. Vercel re-issues headers on each deploy."
  log_info "If a stack-specific CSP is needed, see references/15-stack-best-practices/<stack>.md and templates/csp-stack-overlays.json."

  return 0
}
