# lib/verticals.sh — vertical playbook detection (e-commerce / SaaS / marketing / blog).
# Exposes:
#   verticals_run — read-only. Adds vertical-tagged recommendations to findings.
# No _fix.

_VRT_GREP_INCLUDES=(
  --include='*.html'
  --include='*.htm'
  --include='*.js'
  --include='*.ts'
  --include='*.tsx'
  --include='*.jsx'
  --include='*.mjs'
  --include='*.cjs'
  --include='*.vue'
  --include='*.svelte'
  --include='*.astro'
  --include='*.liquid'
  --include='*.njk'
  --include='*.ejs'
  --include='*.md'
  --include='*.json'
)

# _vrt_grep <pattern> -> 0 if match
_vrt_grep() {
  local pat="$1"
  grep -REq "${_VRT_GREP_INCLUDES[@]}" -e "$pat" . 2>/dev/null
}

# _vrt_grep_pkg <name> -> 0 if listed in package.json deps
_vrt_grep_pkg() {
  local name="$1"
  [[ -f package.json ]] || return 1
  jq -e --arg n "$name" '
    ((.dependencies // {}) + (.devDependencies // {}) + (.peerDependencies // {}))
    | to_entries[]
    | select(.key == $n or (.key | test("^" + $n + "$")) or (.key | startswith($n + "/")))
  ' package.json >/dev/null 2>&1
}

# _vrt_detect_ecommerce -> 0 if e-commerce
_vrt_detect_ecommerce() {
  _vrt_grep_pkg "stripe" && return 0
  _vrt_grep_pkg "@stripe/stripe-js" && return 0
  _vrt_grep '@stripe/' && return 0
  _vrt_grep '@shopify/' && return 0
  _vrt_grep_pkg "commercetools" && return 0
  _vrt_grep '@commercetools/' && return 0
  _vrt_grep_pkg "medusa" && return 0
  _vrt_grep '@medusajs/' && return 0
  # Cart/checkout routes.
  if _vrt_grep '/cart' || _vrt_grep '/checkout' || _vrt_grep '/api/cart'; then
    return 0
  fi
  return 1
}

# _vrt_detect_saas -> 0 if SaaS / multi-tenant
_vrt_detect_saas() {
  _vrt_grep '@workos-inc/' && return 0
  _vrt_grep_pkg "clerk" && return 0
  _vrt_grep '@clerk/' && return 0
  _vrt_grep 'firebase-auth' && return 0
  _vrt_grep 'firebase/auth' && return 0
  if _vrt_grep '\btenantId\b' || _vrt_grep '\btenant_id\b' || _vrt_grep '\bworkspaceId\b'; then
    return 0
  fi
  # Subdomain routing patterns (very rough).
  if _vrt_grep 'host\.split.*\.' || _vrt_grep 'subdomain'; then
    return 0
  fi
  return 1
}

# _vrt_detect_marketing -> 0 if marketing site
_vrt_detect_marketing() {
  # Static-site generators.
  if [[ -f config.toml || -f config.yaml || -f hugo.toml || -f hugo.yaml ]]; then
    grep -qiE 'hugo|theme' config.toml hugo.toml 2>/dev/null && return 0
  fi
  [[ -f astro.config.mjs || -f astro.config.ts || -f astro.config.js ]] && return 0
  [[ -f .eleventy.js || -f eleventy.config.js || -f eleventy.config.cjs ]] && return 0
  # Lead-form patterns.
  if _vrt_grep '/api/lead' || _vrt_grep '/contact-us' || _vrt_grep '/api/subscribe'; then
    return 0
  fi
  return 1
}

# _vrt_detect_blog -> 0 if blog
_vrt_detect_blog() {
  _vrt_grep_pkg "ghost" && return 0
  _vrt_grep_pkg "@tryghost/content-api" && return 0
  _vrt_grep_pkg "hashnode" && return 0
  [[ -d _posts ]] && return 0
  [[ -d content/posts || -d content/blog ]] && return 0
  if _vrt_grep 'rss|atom|feed\.xml'; then
    return 0
  fi
  return 1
}

# _vrt_emit <vertical> <key> <message> [docs_url]
_vrt_emit() {
  local v="$1" key="$2" msg="$3" url="${4:-}"
  log_warn "verticals" "${v}/${key}" "[${v}] ${msg}" "${url}"
}

# _vrt_recs_ecommerce
_vrt_recs_ecommerce() {
  log_subsection "ecommerce playbook"
  _vrt_emit "ecommerce" "csp-payment" \
    "Strict CSP recommended; allowlist payment iframes (js.stripe.com, hooks.stripe.com) only." \
    "https://developers.cloudflare.com/page-shield/"
  _vrt_emit "ecommerce" "page-shield" \
    "Page Shield strongly recommended — Magecart-style attacks specifically target ecom checkout flows." \
    "https://developers.cloudflare.com/page-shield/"
  _vrt_emit "ecommerce" "cache-checkout" \
    "Add Cache Rule: bypass cache for /api/checkout, /cart, /api/cart, /api/orders." \
    "https://developers.cloudflare.com/cache/how-to/cache-rules/"
  _vrt_emit "ecommerce" "bot-cart-scrape" \
    "Tune Bot Fight Mode for cart-abandonment scrapers; consider Super Bot Fight Mode (Pro+)." \
    "https://developers.cloudflare.com/bots/"
  _vrt_emit "ecommerce" "pci-logging" \
    "Audit logs and headers — never log PAN/CVV; redact card-number patterns from headers and Workers logs." \
    "https://www.pcisecuritystandards.org/"
}

# _vrt_recs_saas
_vrt_recs_saas() {
  log_subsection "saas playbook"
  _vrt_emit "saas" "tenant-rate-limit" \
    "Per-tenant rate limits keyed on tenantId cookie/header; protects noisy tenants from impacting others." \
    "https://developers.cloudflare.com/waf/rate-limiting-rules/"
  _vrt_emit "saas" "takeover-paranoid" \
    "Subdomain-takeover scan extra-paranoid for tenant subdomains — one dangling = a customer compromise." \
    "https://developers.cloudflare.com/dns/manage-dns-records/"
  _vrt_emit "saas" "access-admin" \
    "Cloudflare Access in front of /admin, /staff, internal tooling — even if app has its own auth, Access is a hard outer gate." \
    "https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/"
  _vrt_emit "saas" "audit-logs" \
    "Retain audit logs longer (90+ days) for SOC2/ISO/customer DSRs. Logpush -> R2/S3." \
    "https://developers.cloudflare.com/logs/logpush/"
}

# _vrt_recs_marketing
_vrt_recs_marketing() {
  log_subsection "marketing playbook"
  _vrt_emit "marketing" "long-cache" \
    "Long cache TTLs on assets (1 year for fingerprinted, 1 hour for HTML). Cache Rule on /assets/, /_next/static/, /_astro/." \
    "https://developers.cloudflare.com/cache/how-to/cache-rules/"
  _vrt_emit "marketing" "lead-form-bot" \
    "Turnstile on lead-capture forms — invisible CAPTCHA, replaces Recaptcha, blocks form-spam bots." \
    "https://developers.cloudflare.com/turnstile/"
  _vrt_emit "marketing" "redirect-cleanup" \
    "Consolidate Redirect Rules vs old Page Rules; Page Rules are deprecated in favor of Redirect/Cache/Configuration Rules." \
    "https://developers.cloudflare.com/rules/"
  _vrt_emit "marketing" "cf-web-analytics" \
    "Cloudflare Web Analytics for first-party page-view + Core Web Vitals; no cookies, no consent banner needed." \
    "https://developers.cloudflare.com/web-analytics/"
}

# _vrt_recs_blog
_vrt_recs_blog() {
  log_subsection "blog playbook"
  _vrt_emit "blog" "comment-spam" \
    "Turnstile on comment forms; blocks comment-spam bots without user friction." \
    "https://developers.cloudflare.com/turnstile/"
  _vrt_emit "blog" "rss-allowlist" \
    "RSS readers should be allowlisted via WAF Custom Rule (user-agent contains 'Feedbin', 'Inoreader', etc.) so bot rules don't block them." \
    "https://developers.cloudflare.com/waf/custom-rules/"
  _vrt_emit "blog" "image-opt" \
    "Polish + Mirage (Pro+) compress and lazy-load images automatically; meaningful for blog galleries." \
    "https://developers.cloudflare.com/images/polish/"
}

# verticals_run — detection + recommendations.
verticals_run() {
  log_section "vertical playbooks"

  local detected=()

  if _vrt_detect_ecommerce; then
    detected+=("ecommerce")
    _vrt_recs_ecommerce
  fi
  if _vrt_detect_saas; then
    detected+=("saas")
    _vrt_recs_saas
  fi
  if _vrt_detect_marketing; then
    detected+=("marketing")
    _vrt_recs_marketing
  fi
  if _vrt_detect_blog; then
    detected+=("blog")
    _vrt_recs_blog
  fi

  if [[ "${#detected[@]}" -eq 0 ]]; then
    log_info "no vertical signals detected (ecommerce / saas / marketing / blog)."
    return 0
  fi

  local joined="${detected[*]}"
  log_ok "verticals" "detected" "Verticals detected: ${joined}. Recommendations above are tagged [<vertical>]."
}
