# lib/apply_headers.sh — emits the ads-aware security header set for the
# detected stack. The header values come from
# templates/security-headers-for-ads.template.txt (the single source of truth
# for the CSP allowlist); the inline builder below is only a fallback for a
# broken install.
#
# The format depends on the detected stack:
#   - Next.js → next.config.js / next.config.ts patch
#   - Cloudflare Pages / Netlify → _headers
#   - Vercel → vercel.json `headers`
#   - Nginx → add_header snippet
#   - Static / unknown → an _headers-style file
#
# This is a PROPOSAL, not a merge: it emits a fresh snippet in the
# `=== FILE/DIFF/CONTENT ===` contract and the caller merges it. It never reads
# or rewrites an existing CSP, so it cannot lower an existing posture — but it
# also cannot combine with one for you.
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

# Emit "Name<TAB>Value" for each header in the template. Comments, blank lines,
# and Cache-Control (a caching decision, not a security one — a blanket
# no-cache would hurt the CWV this skill also grades) are dropped.
_apply_headers_from_template() {
  local tpl="${TPL_DIR}/security-headers-for-ads.template.txt"
  [[ -f "$tpl" ]] || return 1
  local line name value
  local emitted=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" != *:* ]] && continue
    name="${line%%:*}"
    value="${line#*:}"
    value="${value# }"
    [[ "$name" == "Cache-Control" ]] && continue
    printf '%s\t%s\n' "$name" "$value"
    emitted=$((emitted+1))
  done <"$tpl"
  [[ "$emitted" -gt 0 ]]
}

# Fallback header set, used only when the template is missing.
_apply_headers_fallback() {
  printf 'Content-Security-Policy\t%s\n' "$(_apply_headers_build_csp)"
  printf 'Strict-Transport-Security\tmax-age=31536000; includeSubDomains; preload\n'
  printf 'X-Content-Type-Options\tnosniff\n'
  printf 'X-Frame-Options\tDENY\n'
  printf 'Referrer-Policy\tstrict-origin-when-cross-origin\n'
  printf 'Permissions-Policy\tgeolocation=(), microphone=(), camera=()\n'
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

  local headers source_note
  if headers="$(_apply_headers_from_template)"; then
    source_note="templates/security-headers-for-ads.template.txt"
  else
    headers="$(_apply_headers_fallback)"
    source_note="built-in fallback (template not found)"
    log_warn "security-headers" "template" "templates/security-headers-for-ads.template.txt not found; using the built-in header set. Reinstall the skill to get the nonce-based CSP."
  fi

  local uses_nonce=0
  printf '%s' "$headers" | grep -q '{{NONCE}}' && uses_nonce=1

  local rel_path content name value
  case "$fmt" in
    nextjs)
      rel_path="next.config.security-headers.snippet.js"
      content=$'// Add to next.config.js -> headers() function.\nmodule.exports = {\n  async headers() {\n    return [\n      {\n        source: "/(.*)",\n        headers: [\n'
      while IFS=$'\t' read -r name value; do
        [[ -z "$name" ]] && continue
        content+="          { key: \"${name}\", value: \"${value//\"/\\\"}\" },"$'\n'
      done <<<"$headers"
      content+=$'        ],\n      },\n    ];\n  },\n};\n'
      ;;
    vercel)
      rel_path="vercel.headers.snippet.json"
      content=$'{\n  "headers": [\n    {\n      "source": "/(.*)",\n      "headers": [\n'
      local first=1
      while IFS=$'\t' read -r name value; do
        [[ -z "$name" ]] && continue
        [[ "$first" == 1 ]] || content+=$',\n'
        first=0
        content+="        { \"key\": \"${name}\", \"value\": \"${value//\"/\\\"}\" }"
      done <<<"$headers"
      content+=$'\n      ]\n    }\n  ]\n}\n'
      ;;
    pages-headers|netlify-headers)
      rel_path="_headers"
      content="/*"$'\n'
      while IFS=$'\t' read -r name value; do
        [[ -z "$name" ]] && continue
        content+="  ${name}: ${value}"$'\n'
      done <<<"$headers"
      ;;
    nginx)
      rel_path="nginx.security-headers.snippet.conf"
      content=""
      while IFS=$'\t' read -r name value; do
        [[ -z "$name" ]] && continue
        content+="add_header ${name} \"${value//\"/\\\"}\" always;"$'\n'
      done <<<"$headers"
      ;;
    *)
      log_fail "security-headers" "format" "Unknown format: ${fmt}. Valid: nextjs|vercel|pages-headers|netlify-headers|nginx."
      return 2
      ;;
  esac

  log_info "Proposing security-headers in ${fmt} format, from ${source_note}."
  printf '\n=== FILE: %s ===\n' "$rel_path"
  printf '=== DIFF ===\n'
  printf '(new snippet — merge with the existing config; this tool does not read or merge an existing CSP)\n'
  printf '=== CONTENT ===\n'
  printf '%s' "$content"
  printf '\n=== END ===\n'
  if [[ "$uses_nonce" == 1 ]]; then
    log_warn "security-headers" "nonce" "The CSP allows scripts by nonce, not 'unsafe-inline'. Replace {{NONCE}} with a per-request value from your edge layer (Next middleware, a Worker, a Pages Function) and stamp the same value on every inline script tag. Without that the inline pixel snippets will be blocked."
  fi
  log_warn "security-headers" "apply" "Proposed CSP + security headers for ${fmt} format. Merge with the existing config; never overwrite a stricter policy with this one."
}
