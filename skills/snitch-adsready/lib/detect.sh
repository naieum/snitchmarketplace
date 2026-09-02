# lib/detect.sh — single-call cwd JSON for ads-ready.
# Detects: stacks, pixel libs, pixel snippets in source, consent libs,
# vertical hints, hostnames, package managers, current host provider.
#
# Exports: run_detect

# --- low-level helpers ---

_det_grep_files() {
  local pattern="$1"; shift
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || continue
    if grep -E -q "$pattern" "$f" 2>/dev/null; then
      printf '1'; return 0
    fi
  done
  printf '0'
}

_det_pkg_has() {
  local pattern="$1"
  if [[ -f "package.json" ]] && grep -E -q "$pattern" package.json 2>/dev/null; then
    printf '1'; return
  fi
  printf '0'
}

_det_py_has() {
  local pattern="$1"
  if [[ -f "requirements.txt" ]] && grep -E -q "$pattern" requirements.txt 2>/dev/null; then
    printf '1'; return
  fi
  if [[ -f "pyproject.toml" ]] && grep -E -q "$pattern" pyproject.toml 2>/dev/null; then
    printf '1'; return
  fi
  printf '0'
}

# Search for a pattern across a project's source files (limit depth 4 to avoid
# scanning vendored code; skip common build / dep dirs).
_det_src_has() {
  local pattern="$1"
  local hit
  hit="$(grep -r -E -l "$pattern" \
    --include='*.ts' --include='*.tsx' \
    --include='*.js' --include='*.jsx' --include='*.mjs' --include='*.cjs' \
    --include='*.html' --include='*.htm' --include='*.vue' --include='*.svelte' --include='*.astro' \
    --include='*.php' --include='*.py' --include='*.rb' --include='*.go' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
    --exclude-dir=.nuxt --exclude-dir=.svelte-kit --exclude-dir=.astro \
    --exclude-dir=dist --exclude-dir=build --exclude-dir=out --exclude-dir=coverage \
    --exclude-dir=vendor --exclude-dir=.cache \
    . 2>/dev/null | head -n 1)"
  if [[ -n "$hit" ]]; then
    printf '1'
  else
    printf '0'
  fi
}

# --- stacks ---

_det_stacks() {
  local out=()
  compgen -G "next.config.*" >/dev/null 2>&1 && out+=("nextjs")
  compgen -G "astro.config.*" >/dev/null 2>&1 && out+=("astro")
  compgen -G "svelte.config.*" >/dev/null 2>&1 && out+=("sveltekit")
  compgen -G "remix.config.*" >/dev/null 2>&1 && out+=("remix")
  compgen -G "nuxt.config.*" >/dev/null 2>&1 && out+=("nuxt")
  [[ -f "vite.config.js" || -f "vite.config.ts" ]] && out+=("vite")
  [[ -f "wp-config.php" ]] && out+=("wordpress")
  [[ -f "artisan" ]] && out+=("laravel")
  [[ -f "Gemfile" && -f "config/routes.rb" ]] && out+=("rails")
  [[ -f "manage.py" ]] && out+=("django")
  [[ -f "gatsby-config.js" || -f "gatsby-config.ts" ]] && out+=("gatsby")
  [[ -f "vue.config.js" || -f "vue.config.ts" ]] && out+=("vue")
  if [[ -f "package.json" ]]; then
    [[ "$(_det_pkg_has '"@?nestjs')" == "1" ]] && out+=("nestjs")
    [[ "$(_det_pkg_has '"fastify"')" == "1" ]] && out+=("fastify")
    [[ "$(_det_pkg_has '"express"')" == "1" ]] && out+=("express")
    [[ "$(_det_pkg_has '"hono"')" == "1" ]] && out+=("hono")
    # Shopify / Webflow are often surfaced via package.json deps for theme dev.
    [[ "$(_det_pkg_has '"@shopify/')" == "1" ]] && out+=("shopify")
    [[ "$(_det_pkg_has '"webflow-')" == "1" ]] && out+=("webflow")
  fi
  if [[ -f "config.toml" || -f "hugo.toml" || -f "hugo.yaml" ]]; then out+=("hugo"); fi
  [[ -f "_config.yml" ]] && out+=("jekyll")
  [[ -f ".eleventy.js" || -f "eleventy.config.js" ]] && out+=("eleventy")
  if [[ ${#out[@]} -eq 0 && -f "index.html" ]]; then
    out+=("static")
  fi
  printf '%s' "$(_det_to_json_array "${out[@]+"${out[@]}"}")"
}

# --- pixel libs (npm / source) ---

_det_pixel_libs() {
  local out=()
  if [[ -f "package.json" ]]; then
    [[ "$(_det_pkg_has '"react-gtm-module"')" == "1" ]] && out+=("react-gtm-module")
    [[ "$(_det_pkg_has '"@next/third-parties"')" == "1" ]] && out+=("next-third-parties")
    [[ "$(_det_pkg_has '"next-google-analytics"')" == "1" ]] && out+=("next-google-analytics")
    [[ "$(_det_pkg_has '"@vercel/analytics"')" == "1" ]] && out+=("vercel-analytics")
    [[ "$(_det_pkg_has '"react-facebook-pixel"')" == "1" ]] && out+=("react-facebook-pixel")
    [[ "$(_det_pkg_has '"react-pixel"')" == "1" ]] && out+=("react-pixel")
    [[ "$(_det_pkg_has '"nuxt-meta-pixel"')" == "1" ]] && out+=("nuxt-meta-pixel")
    [[ "$(_det_pkg_has '"@analytics/google-tag-manager"')" == "1" ]] && out+=("analytics-gtm")
    [[ "$(_det_pkg_has '"@types/gtag.js"')" == "1" ]] && out+=("gtag-types")
    [[ "$(_det_pkg_has '"@vue/gtag"')" == "1" ]] && out+=("vue-gtag")
    [[ "$(_det_pkg_has '"vue-gtm"')" == "1" ]] && out+=("vue-gtm")
    [[ "$(_det_pkg_has '"@gtm-support/')" == "1" ]] && out+=("gtm-support")
    [[ "$(_det_pkg_has '"react-tiktok-pixel"')" == "1" ]] && out+=("react-tiktok-pixel")
    [[ "$(_det_pkg_has '"react-snapchat-pixel"')" == "1" ]] && out+=("react-snapchat-pixel")
    [[ "$(_det_pkg_has '"react-pinterest-tag"')" == "1" ]] && out+=("react-pinterest-tag")
  fi
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

# --- pixel snippets in source ---

_det_pixel_snippets() {
  local out=()
  [[ "$(_det_src_has 'gtag\(')" == "1" ]] && out+=("google-gtag")
  [[ "$(_det_src_has 'GTM-[A-Z0-9]+')" == "1" ]] && out+=("google-tag-manager")
  [[ "$(_det_src_has 'AW-[0-9]+')" == "1" ]] && out+=("google-ads-conversion")
  [[ "$(_det_src_has 'fbq\(')" == "1" ]] && out+=("meta-pixel")
  [[ "$(_det_src_has '_linkedin_partner_id')" == "1" ]] && out+=("linkedin-insight")
  [[ "$(_det_src_has 'uetq')" == "1" ]] && out+=("microsoft-uet")
  [[ "$(_det_src_has '_uet[a-zA-Z]*\(')" == "1" ]] && out+=("microsoft-uet")
  [[ "$(_det_src_has 'ttq\.')" == "1" ]] && out+=("tiktok-pixel")
  [[ "$(_det_src_has 'twq\(')" == "1" ]] && out+=("x-pixel")
  [[ "$(_det_src_has 'pintrk\(')" == "1" ]] && out+=("pinterest-tag")
  [[ "$(_det_src_has 'rdt\(')" == "1" ]] && out+=("reddit-pixel")
  [[ "$(_det_src_has 'snaptr\(')" == "1" ]] && out+=("snapchat-pixel")
  [[ "$(_det_src_has 'apple-itunes-app')" == "1" ]] && out+=("apple-itunes-meta")
  [[ "$(_det_src_has "gtag\\('consent'")" == "1" ]] && out+=("consent-mode")
  [[ "$(_det_src_has 'dataLayer\.push')" == "1" ]] && out+=("data-layer")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

# --- consent platforms ---

_det_consent_libs() {
  local out=()
  if [[ -f "package.json" ]]; then
    [[ "$(_det_pkg_has '"@onetrust/')" == "1" ]] && out+=("onetrust")
    [[ "$(_det_pkg_has '"cookiebot"')" == "1" ]] && out+=("cookiebot")
    [[ "$(_det_pkg_has '"iubenda"')" == "1" ]] && out+=("iubenda")
    [[ "$(_det_pkg_has '"cookieyes"')" == "1" ]] && out+=("cookieyes")
    [[ "$(_det_pkg_has '"termly"')" == "1" ]] && out+=("termly")
    [[ "$(_det_pkg_has '"osano"')" == "1" ]] && out+=("osano")
    [[ "$(_det_pkg_has '"klaro"')" == "1" ]] && out+=("klaro")
    [[ "$(_det_pkg_has '"tarteaucitron"')" == "1" ]] && out+=("tarteaucitron")
    [[ "$(_det_pkg_has '"quantcast-cmp"')" == "1" ]] && out+=("quantcast")
    [[ "$(_det_pkg_has '"@cookieconsent/')" == "1" ]] && out+=("cookieconsent")
  fi
  [[ "$(_det_src_has 'OneTrust|optanon')" == "1" ]] && out+=("onetrust")
  [[ "$(_det_src_has 'cookiebot\.com|Cookiebot')" == "1" ]] && out+=("cookiebot")
  [[ "$(_det_src_has 'iubenda\.com|_iub')" == "1" ]] && out+=("iubenda")
  [[ "$(_det_src_has 'cookieyes\.com')" == "1" ]] && out+=("cookieyes")
  [[ "$(_det_src_has 'termly\.io')" == "1" ]] && out+=("termly")
  [[ "$(_det_src_has 'osano\.com')" == "1" ]] && out+=("osano")
  [[ "$(_det_src_has 'klaroConfig|klaro\.js')" == "1" ]] && out+=("klaro")
  [[ "$(_det_src_has 'tarteaucitron')" == "1" ]] && out+=("tarteaucitron")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

# --- vertical hints ---

_det_vertical_hints() {
  local out=()
  if [[ -f "package.json" ]]; then
    [[ "$(_det_pkg_has '"stripe"')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"@stripe/')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"shopify"')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"@shopify/')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"woocommerce"')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"medusa-')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"@commerce/')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"saleor')" == "1" ]] && out+=("ecommerce")
    [[ "$(_det_pkg_has '"clerk"')" == "1" ]] && out+=("saas")
    [[ "$(_det_pkg_has '"@clerk/')" == "1" ]] && out+=("saas")
    [[ "$(_det_pkg_has '"next-auth"')" == "1" ]] && out+=("saas")
    [[ "$(_det_pkg_has '"supabase"')" == "1" ]] && out+=("saas")
    [[ "$(_det_pkg_has '"workos"')" == "1" ]] && out+=("saas")
    [[ "$(_det_pkg_has '"@workos-inc/')" == "1" ]] && out+=("saas")
    [[ "$(_det_pkg_has '"@auth0/')" == "1" ]] && out+=("saas")
    [[ "$(_det_pkg_has '"contentful"')" == "1" ]] && out+=("marketing")
    [[ "$(_det_pkg_has '"@sanity/')" == "1" ]] && out+=("marketing")
    [[ "$(_det_pkg_has '"prismic"')" == "1" ]] && out+=("marketing")
    [[ "$(_det_pkg_has '"@portabletext/')" == "1" ]] && out+=("marketing")
    [[ "$(_det_pkg_has '"gray-matter"')" == "1" ]] && out+=("blog")
    [[ "$(_det_pkg_has '"contentlayer"')" == "1" ]] && out+=("blog")
    [[ "$(_det_pkg_has '"@next/mdx"')" == "1" ]] && out+=("blog")
    [[ "$(_det_pkg_has '"unified"')" == "1" ]] && out+=("blog")
  fi
  [[ -f "wp-config.php" ]] && out+=("blog")
  [[ -f "_config.yml" ]] && out+=("blog")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

# --- structured data libs ---

_det_structured_data_libs() {
  local out=()
  if [[ -f "package.json" ]]; then
    [[ "$(_det_pkg_has '"next-seo"')" == "1" ]] && out+=("next-seo")
    [[ "$(_det_pkg_has '"react-schemaorg"')" == "1" ]] && out+=("react-schemaorg")
    [[ "$(_det_pkg_has '"schema-dts"')" == "1" ]] && out+=("schema-dts")
    [[ "$(_det_pkg_has '"vue-meta"')" == "1" ]] && out+=("vue-meta")
    [[ "$(_det_pkg_has '"@nuxtjs/seo"')" == "1" ]] && out+=("nuxt-seo")
    [[ "$(_det_pkg_has '"astro-seo"')" == "1" ]] && out+=("astro-seo")
  fi
  [[ "$(_det_src_has 'application/ld\+json')" == "1" ]] && out+=("jsonld-inline")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

# --- common helpers (project_kind, package managers, host provider, hostnames) ---

_det_project_kind() {
  if [[ -f "package.json" ]]; then printf 'node'; return; fi
  if [[ -f "composer.json" || -f "wp-config.php" ]]; then printf 'php'; return; fi
  if [[ -f "Gemfile" ]]; then printf 'ruby'; return; fi
  if [[ -f "manage.py" || -f "requirements.txt" || -f "pyproject.toml" ]]; then printf 'python'; return; fi
  if compgen -G "*.csproj" >/dev/null 2>&1; then printf 'dotnet'; return; fi
  if [[ -f "pom.xml" || -f "build.gradle" ]]; then printf 'jvm'; return; fi
  if [[ -f "go.mod" ]]; then printf 'go'; return; fi
  if [[ -f "Cargo.toml" ]]; then printf 'rust'; return; fi
  if [[ -f "index.html" ]]; then printf 'static'; return; fi
  printf 'unknown'
}

_det_package_managers() {
  local out=()
  [[ -f "package-lock.json" ]] && out+=("npm")
  [[ -f "yarn.lock" ]] && out+=("yarn")
  [[ -f "pnpm-lock.yaml" ]] && out+=("pnpm")
  [[ -f "bun.lockb" || -f "bun.lock" ]] && out+=("bun")
  [[ -f "composer.lock" ]] && out+=("composer")
  [[ -f "Gemfile.lock" ]] && out+=("bundler")
  [[ -f "Pipfile.lock" || -f "uv.lock" || -f "poetry.lock" ]] && out+=("python")
  [[ -f "go.sum" ]] && out+=("go-modules")
  [[ -f "Cargo.lock" ]] && out+=("cargo")
  printf '%s' "$(_det_to_json_array "${out[@]+"${out[@]}"}")"
}

_det_current_host_provider() {
  if [[ -f "vercel.json" ]]; then printf '"vercel"'; return; fi
  if [[ -f "netlify.toml" || -f "netlify.yaml" ]]; then printf '"netlify"'; return; fi
  if [[ -f "fly.toml" ]]; then printf '"fly"'; return; fi
  if [[ -f "railway.json" || -f "railway.toml" ]]; then printf '"railway"'; return; fi
  if [[ -f "render.yaml" ]]; then printf '"render"'; return; fi
  if [[ -f "wrangler.toml" || -f "wrangler.jsonc" || -f "wrangler.json" ]]; then printf '"cloudflare"'; return; fi
  if [[ -f "Procfile" ]]; then printf '"heroku-style"'; return; fi
  printf 'null'
}

_det_hostnames() {
  local out=()
  if [[ -f "vercel.json" ]] && command -v jq >/dev/null 2>&1; then
    while IFS= read -r line; do [[ -n "$line" ]] && out+=("$line"); done < <(jq -r '.alias // [] | .[]' vercel.json 2>/dev/null)
  fi
  if [[ -f "wrangler.toml" ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] && out+=("$line")
    done < <(grep -E -o 'pattern[[:space:]]*=[[:space:]]*"[^"]+"' wrangler.toml 2>/dev/null \
      | sed -E 's/.*"([^"]+)".*/\1/' | sed -E 's|/.*||' | sed -E 's|^\*\.||')
  fi
  if [[ -f "package.json" ]] && command -v jq >/dev/null 2>&1; then
    local h
    h="$(jq -r '.homepage // empty' package.json 2>/dev/null \
      | sed -E 's,^https?://,,' | sed -E 's,/.*,,')"
    [[ -n "$h" ]] && out+=("$h")
  fi
  if [[ -f "CNAME" ]]; then
    local cn; cn="$(head -n1 CNAME 2>/dev/null | tr -d '\r\n')"
    [[ -n "$cn" ]] && out+=("$cn")
  fi
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

# --- JSON helpers ---

_det_to_json_array() {
  if [[ $# -eq 0 ]]; then printf '[]'; return; fi
  local s=""
  local i
  for i in "$@"; do
    [[ -n "$s" ]] && s+=","
    s+="\"${i//\"/\\\"}\""
  done
  printf '[%s]' "$s"
}

_det_dedupe_to_json() {
  if [[ $# -eq 0 ]]; then printf '[]'; return; fi
  local seen=""
  local out=()
  local i
  for i in "$@"; do
    case " $seen " in *" $i "*) continue ;; esac
    seen+=" $i"
    out+=("$i")
  done
  _det_to_json_array "${out[@]+"${out[@]}"}"
}

# --- entrypoint ---

run_detect() {
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local stacks pixel_libs pixel_snippets consent_libs vertical_hints structured_libs project_kind pms host_provider hostnames

  stacks="$(_det_stacks)"
  pixel_libs="$(_det_pixel_libs)"
  pixel_snippets="$(_det_pixel_snippets)"
  consent_libs="$(_det_consent_libs)"
  vertical_hints="$(_det_vertical_hints)"
  structured_libs="$(_det_structured_data_libs)"
  project_kind="$(_det_project_kind)"
  pms="$(_det_package_managers)"
  host_provider="$(_det_current_host_provider)"
  hostnames="$(_det_hostnames)"

  if ! command -v jq >/dev/null 2>&1; then
    # Fallback: emit a hand-built JSON if jq isn't present.
    printf '{"schema":"adssec.detect","schema_version":1,"generated_at":"%s","tool":"detect","cwd":"%s","project_kind":"%s","stacks":%s,"pixel_libs":%s,"pixel_snippets":%s,"consent_libs":%s,"vertical_hints":%s,"structured_data_libs":%s,"package_managers":%s,"current_host_provider":%s,"hostnames":%s}\n' \
      "$ts" "$(pwd)" "$project_kind" \
      "$stacks" "$pixel_libs" "$pixel_snippets" "$consent_libs" \
      "$vertical_hints" "$structured_libs" "$pms" "$host_provider" "$hostnames"
    return 0
  fi

  jq -n \
    --arg ts "$ts" \
    --arg cwd "$(pwd)" \
    --arg project_kind "$project_kind" \
    --argjson stacks               "$stacks" \
    --argjson pixel_libs           "$pixel_libs" \
    --argjson pixel_snippets       "$pixel_snippets" \
    --argjson consent_libs         "$consent_libs" \
    --argjson vertical_hints       "$vertical_hints" \
    --argjson structured_data_libs "$structured_libs" \
    --argjson package_managers     "$pms" \
    --argjson current_host_provider "$host_provider" \
    --argjson hostnames            "$hostnames" \
    '{
      schema: "adssec.detect",
      schema_version: 1,
      generated_at: $ts,
      tool: "detect",
      cwd: $cwd,
      project_kind: $project_kind,
      stacks: $stacks,
      pixel_libs: $pixel_libs,
      pixel_snippets: $pixel_snippets,
      consent_libs: $consent_libs,
      vertical_hints: $vertical_hints,
      structured_data_libs: $structured_data_libs,
      package_managers: $package_managers,
      current_host_provider: $current_host_provider,
      hostnames: $hostnames
    }'
}
