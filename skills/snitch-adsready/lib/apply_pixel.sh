# lib/apply_pixel.sh — idempotent ad-platform pixel install.
# Reads templates/pixel-snippets/<platform>.html.
# Detects cwd stack and emits a `=== FILE/DIFF/CONTENT ===` block targeted at
# the right host file. Idempotent: searches source for an existing pixel
# signature first; logs OK + exits if already present.
#
# Exports:
#   apply_pixel <platform>

ADSSEC_PIXEL_PLATFORMS=(google meta microsoft linkedin tiktok x pinterest reddit snapchat apple)

# _pixel_template <platform> -> path to template (or empty + return 1)
_pixel_template() {
  local platform="$1"
  local skill_dir="${ADSSEC_SKILL_DIR:-${HOME}/.claude/skills/ads-ready}"
  local p="${skill_dir}/templates/pixel-snippets/${platform}.html"
  if [[ -f "$p" ]]; then
    printf '%s' "$p"
    return 0
  fi
  return 1
}

# _pixel_signature <platform> — regex that detects an existing install in source.
_pixel_signature() {
  local platform="$1"
  case "$platform" in
    google)    printf 'gtag\\(|googletagmanager\\.com|GTM-|AW-|G-' ;;
    meta)      printf 'fbq\\(|connect\\.facebook\\.net|facebook\\.com/tr' ;;
    microsoft) printf 'uetq|bat\\.bing\\.com' ;;
    linkedin)  printf '_linkedin_partner_id|snap\\.licdn\\.com' ;;
    tiktok)    printf 'ttq\\.|analytics\\.tiktok\\.com' ;;
    x)         printf 'twq\\(|static\\.ads-twitter\\.com' ;;
    pinterest) printf 'pintrk\\(|s\\.pinimg\\.com/ct/core' ;;
    reddit)    printf 'rdt\\(|www\\.redditstatic\\.com/ads' ;;
    snapchat)  printf 'snaptr\\(|sc-static\\.net/scevent' ;;
    apple)     printf 'AdAttributionKit|SKAdNetwork' ;;
    *)         printf 'NO_SIGNATURE' ;;
  esac
}

# _pixel_detect_stack — emits one of: nextjs-app | nextjs-pages | astro | sveltekit | nuxt | wordpress | vite-spa | vanilla-html | unknown
_pixel_detect_stack() {
  if [[ -f "next.config.js" || -f "next.config.ts" || -f "next.config.mjs" ]]; then
    if [[ -f "app/layout.tsx" || -f "app/layout.jsx" || -f "app/layout.js" || -f "src/app/layout.tsx" ]]; then
      printf 'nextjs-app'; return
    fi
    if [[ -f "pages/_document.tsx" || -f "pages/_document.jsx" || -f "pages/_document.js" || -f "src/pages/_document.tsx" ]]; then
      printf 'nextjs-pages'; return
    fi
    printf 'nextjs-app'; return
  fi
  if [[ -f "astro.config.mjs" || -f "astro.config.ts" || -f "astro.config.js" ]]; then
    printf 'astro'; return
  fi
  if [[ -f "svelte.config.js" || -f "svelte.config.ts" ]]; then
    printf 'sveltekit'; return
  fi
  if [[ -f "nuxt.config.js" || -f "nuxt.config.ts" ]]; then
    printf 'nuxt'; return
  fi
  if [[ -f "wp-config.php" ]] || ls wp-content/themes/*/functions.php >/dev/null 2>&1; then
    printf 'wordpress'; return
  fi
  if [[ -f "vite.config.js" || -f "vite.config.ts" ]] && [[ -f "index.html" ]]; then
    printf 'vite-spa'; return
  fi
  if [[ -f "index.html" ]]; then
    printf 'vanilla-html'; return
  fi
  printf 'unknown'
}

# _pixel_target_file <stack> — emits the file path to insert into.
_pixel_target_file() {
  local stack="$1"
  case "$stack" in
    nextjs-app)
      if   [[ -f "src/app/layout.tsx" ]]; then printf 'src/app/layout.tsx'
      elif [[ -f "app/layout.tsx" ]];     then printf 'app/layout.tsx'
      elif [[ -f "src/app/layout.jsx" ]]; then printf 'src/app/layout.jsx'
      elif [[ -f "app/layout.jsx" ]];     then printf 'app/layout.jsx'
      else printf 'app/layout.tsx'; fi ;;
    nextjs-pages)
      if   [[ -f "src/pages/_document.tsx" ]]; then printf 'src/pages/_document.tsx'
      elif [[ -f "pages/_document.tsx" ]];     then printf 'pages/_document.tsx'
      else printf 'pages/_document.tsx'; fi ;;
    astro)
      if   [[ -f "src/layouts/Layout.astro" ]];    then printf 'src/layouts/Layout.astro'
      elif [[ -f "src/layouts/BaseLayout.astro" ]];then printf 'src/layouts/BaseLayout.astro'
      else printf 'src/layouts/Layout.astro'; fi ;;
    sveltekit)
      if   [[ -f "src/app.html" ]]; then printf 'src/app.html'
      else printf 'src/app.html'; fi ;;
    nuxt)
      if   [[ -f "app.vue" ]]; then printf 'app.vue'
      elif [[ -f "nuxt.config.ts" ]]; then printf 'nuxt.config.ts'
      else printf 'app.vue'; fi ;;
    wordpress)
      local theme
      theme="$(ls -d wp-content/themes/*/ 2>/dev/null | head -n1)"
      if [[ -n "$theme" && -f "${theme}functions.php" ]]; then
        printf '%s' "${theme}functions.php"
      else
        printf 'wp-content/themes/<your-theme>/functions.php'
      fi ;;
    vite-spa|vanilla-html)
      printf 'index.html' ;;
    *)
      printf 'index.html' ;;
  esac
}

# apply_pixel <platform>
apply_pixel() {
  local platform="${1:-}"
  if [[ -z "$platform" ]]; then
    log_fail "pixels" "apply" "Missing <platform>. Valid: ${ADSSEC_PIXEL_PLATFORMS[*]}."
    return 2
  fi
  local known=0 v
  for v in "${ADSSEC_PIXEL_PLATFORMS[@]}"; do
    [[ "$platform" == "$v" ]] && known=1 && break
  done
  if [[ "$known" != "1" ]]; then
    log_fail "pixels" "apply" "Unknown platform '${platform}'. Valid: ${ADSSEC_PIXEL_PLATFORMS[*]}."
    return 2
  fi

  local tpl
  if ! tpl="$(_pixel_template "$platform")"; then
    log_fail "pixels" "apply" "templates/pixel-snippets/${platform}.html not found."
    return 2
  fi

  local stack target sig
  stack="$(_pixel_detect_stack)"
  target="$(_pixel_target_file "$stack")"
  sig="$(_pixel_signature "$platform")"

  # Idempotency: if any source file already contains the signature, no-op.
  if [[ -d "." ]]; then
    if grep -RIEl --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude-dir=.git "$sig" . >/dev/null 2>&1; then
      log_ok "pixels" "apply" "${platform} pixel signature already present in source — no changes."
      return 0
    fi
  fi

  local snippet
  snippet="$(cat "$tpl")"

  log_info "stack: ${stack}; target file: ${target}; platform: ${platform}"
  log_info "Idempotency: ${platform} signature not found in cwd; emitting File-write contract."
  printf '\n=== FILE: %s ===\n' "$target"
  printf '=== DIFF ===\n'
  printf '# Insert the following snippet into the document <head> (or wp_head action for WordPress) so it loads BEFORE any page-specific scripts. Replace {{PLACEHOLDER}} values with your platform IDs.\n'
  printf '=== CONTENT ===\n'
  case "$stack" in
    wordpress)
      printf 'add_action(%squp_head%s, function() { ?>\n%s\n<?php }, 1);\n' "'" "'" "$snippet"
      ;;
    nextjs-app)
      printf '// Insert inside the <head> of app/layout.tsx — after <head> opening, before any <script src=...> children:\n%s\n' "$snippet"
      ;;
    nextjs-pages)
      printf '// Insert inside <Head> in pages/_document.tsx (use Next/Script with strategy="afterInteractive" for next/script):\n%s\n' "$snippet"
      ;;
    astro)
      printf '<!-- Inside <head> of src/layouts/Layout.astro: -->\n%s\n' "$snippet"
      ;;
    sveltekit)
      printf '<!-- Inside <head> of src/app.html, BEFORE %%sveltekit.head%%: -->\n%s\n' "$snippet"
      ;;
    nuxt)
      printf '<!-- Use useHead() in app.vue or nuxt.config.ts head.script[]: -->\n%s\n' "$snippet"
      ;;
    *)
      printf '<!-- Inside <head> of index.html: -->\n%s\n' "$snippet"
      ;;
  esac
  printf '=== END ===\n'

  log_ok "pixels" "apply" "${platform} pixel proposal emitted for ${stack} (target: ${target})."
}
