# lib/apply_headers.sh — emits a CSP allowlist covering all 10 platforms' domains.
# The format depends on the detected stack:
#   - Next.js → next.config.js / next.config.ts patch
#   - Cloudflare Pages → _headers
#   - Vercel → vercel.json `headers`
#   - Nginx → add_header snippet
#   - Static / unknown → an _headers-style file
#
# Generates the ads-aware header set inline per detected stack format.
#
# Exports: apply_headers [format]

# Per-platform CSP source domains (script + img + frame).
_apply_headers_csp_sources() {
  cat <<'EOF'
# Google
script-src: https://www.googletagmanager.com https://www.google-analytics.com https://googleads.g.doubleclick.net https://www.google.com https://www.googleadservices.com
img-src:    https://www.google-analytics.com https://www.googletagmanager.com https://www.google.com https://googleads.g.doubleclick.net https://stats.g.doubleclick.net
frame-src:  https://td.doubleclick.net https://www.googletagmanager.com
connect-src: https://www.google-analytics.com https://analytics.google.com https://stats.g.doubleclick.net https://region1.google-analytics.com

# Meta
script-src: https://connect.facebook.net
img-src:    https://www.facebook.com https://*.facebook.com
connect-src: https://*.facebook.com

# Microsoft
script-src: https://bat.bing.com
img-src:    https://bat.bing.com https://*.bing.com
connect-src: https://bat.bing.com

# LinkedIn
script-src: https://snap.licdn.com
img-src:    https://px.ads.linkedin.com https://*.linkedin.com
connect-src: https://px.ads.linkedin.com

# TikTok
script-src: https://analytics.tiktok.com
img-src:    https://analytics.tiktok.com
connect-src: https://analytics.tiktok.com

# X (Twitter)
script-src: https://static.ads-twitter.com
img-src:    https://t.co https://analytics.twitter.com
connect-src: https://analytics.twitter.com

# Pinterest
script-src: https://s.pinimg.com
img-src:    https://ct.pinterest.com https://*.pinimg.com
connect-src: https://ct.pinterest.com

# Reddit
script-src: https://www.redditstatic.com
img-src:    https://alb.reddit.com https://*.redd.it
connect-src: https://alb.reddit.com

# Snapchat
script-src: https://sc-static.net
img-src:    https://tr.snapchat.com
connect-src: https://tr.snapchat.com
EOF
}

# Build a single CSP string from the source list.
_apply_headers_build_csp() {
  local data; data="$(_apply_headers_csp_sources)"
  local script_src img_src frame_src connect_src
  script_src="$(printf '%s' "$data" | grep -E '^script-src:'  | sed -E 's/^script-src:[[:space:]]*//'  | tr '\n' ' ')"
  img_src="$(printf '%s'    "$data" | grep -E '^img-src:'     | sed -E 's/^img-src:[[:space:]]*//'     | tr '\n' ' ')"
  frame_src="$(printf '%s'  "$data" | grep -E '^frame-src:'   | sed -E 's/^frame-src:[[:space:]]*//'   | tr '\n' ' ')"
  connect_src="$(printf '%s' "$data" | grep -E '^connect-src:' | sed -E 's/^connect-src:[[:space:]]*//' | tr '\n' ' ')"
  local csp
  csp="default-src 'self'; "
  csp+="script-src 'self' 'unsafe-inline' 'unsafe-eval' ${script_src}; "
  csp+="img-src 'self' data: https: ${img_src}; "
  csp+="frame-src 'self' ${frame_src}; "
  csp+="connect-src 'self' ${connect_src}; "
  csp+="style-src 'self' 'unsafe-inline'; "
  csp+="font-src 'self' data: https:; "
  csp+="object-src 'none'; "
  csp+="base-uri 'self';"
  # Collapse repeated whitespace.
  printf '%s' "$csp" | tr -s ' '
}

# Detect stack/format by reading detect.sh output.
_apply_headers_detect_format() {
  if ! declare -f run_detect >/dev/null 2>&1; then
    . "$LIB_DIR/detect.sh"
  fi
  local d; d="$(run_detect 2>/dev/null)"
  local stacks host
  stacks="$(jq -r '.stacks // [] | .[]' <<<"$d" 2>/dev/null)"
  host="$(jq -r '.current_host_provider // empty' <<<"$d" 2>/dev/null)"
  if printf '%s' "$stacks" | grep -q '^nextjs$'; then printf 'nextjs'; return; fi
  if [[ "$host" == "vercel" ]]; then printf 'vercel'; return; fi
  if [[ "$host" == "cloudflare" || -f "_headers" ]]; then printf 'pages-headers'; return; fi
  if [[ "$host" == "netlify" ]]; then printf 'netlify-headers'; return; fi
  printf 'pages-headers'
}

apply_headers() {
  log_section "apply security-headers"

  local fmt="${1:-}"
  if [[ -z "$fmt" ]]; then
    fmt="$(_apply_headers_detect_format)"
  fi

  local csp; csp="$(_apply_headers_build_csp)"
  local rel_path content

  case "$fmt" in
    nextjs)
      rel_path="next.config.security-headers.snippet.js"
      content=$'// Add to next.config.js -> headers() function.\nmodule.exports = {\n  async headers() {\n    return [\n      {\n        source: "/(.*)",\n        headers: [\n'
      content+="          { key: \"Content-Security-Policy\", value: \"${csp}\" },"$'\n'
      content+=$'          { key: "Strict-Transport-Security", value: "max-age=31536000; includeSubDomains; preload" },\n'
      content+=$'          { key: "X-Content-Type-Options", value: "nosniff" },\n'
      content+=$'          { key: "X-Frame-Options", value: "DENY" },\n'
      content+=$'          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },\n'
      content+=$'          { key: "Permissions-Policy", value: "geolocation=(), microphone=(), camera=()" },\n'
      content+=$'        ],\n      },\n    ];\n  },\n};\n'
      ;;
    vercel)
      rel_path="vercel.headers.snippet.json"
      content=$'{\n  "headers": [\n    {\n      "source": "/(.*)",\n      "headers": [\n'
      content+="        { \"key\": \"Content-Security-Policy\", \"value\": \"${csp}\" },"$'\n'
      content+=$'        { "key": "Strict-Transport-Security", "value": "max-age=31536000; includeSubDomains; preload" },\n'
      content+=$'        { "key": "X-Content-Type-Options", "value": "nosniff" },\n'
      content+=$'        { "key": "X-Frame-Options", "value": "DENY" },\n'
      content+=$'        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },\n'
      content+=$'        { "key": "Permissions-Policy", "value": "geolocation=(), microphone=(), camera=()" }\n'
      content+=$'      ]\n    }\n  ]\n}\n'
      ;;
    pages-headers|netlify-headers)
      rel_path="_headers"
      content="/*"$'\n'
      content+="  Content-Security-Policy: ${csp}"$'\n'
      content+=$'  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload\n'
      content+=$'  X-Content-Type-Options: nosniff\n'
      content+=$'  X-Frame-Options: DENY\n'
      content+=$'  Referrer-Policy: strict-origin-when-cross-origin\n'
      content+=$'  Permissions-Policy: geolocation=(), microphone=(), camera=()\n'
      ;;
    nginx)
      rel_path="nginx.security-headers.snippet.conf"
      content="add_header Content-Security-Policy \"${csp}\" always;"$'\n'
      content+=$'add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;\n'
      content+=$'add_header X-Content-Type-Options "nosniff" always;\n'
      content+=$'add_header X-Frame-Options "DENY" always;\n'
      content+=$'add_header Referrer-Policy "strict-origin-when-cross-origin" always;\n'
      content+=$'add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;\n'
      ;;
    *)
      log_fail "security-headers" "format" "Unknown format: ${fmt}. Valid: nextjs|vercel|pages-headers|netlify-headers|nginx."
      return 2
      ;;
  esac

  log_info "Proposing security-headers in ${fmt} format."
  printf '\n=== FILE: %s ===\n' "$rel_path"
  printf '=== DIFF ===\n'
  printf '(new snippet — merge with existing config)\n'
  printf '=== CONTENT ===\n'
  printf '%s' "$content"
  printf '\n=== END ===\n'
  log_warn "security-headers" "apply" "Proposed CSP + security headers for ${fmt} format. Merge with existing config; do not blindly overwrite."
}
