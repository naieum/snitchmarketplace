# lib/setup.sh — interactive setup walkthroughs.
# Read-only. Emits a stepped JSON plan that the agent reads, presents, and uses
# to chain `fix` calls per user confirmation. The shell does NOT execute `fix`
# itself; that's the agent's job.
#
# Exports:
#   run_setup <area> [platform]
#
# Areas (must have a matching references/setup/<area>.md):
#   pixel-install consent-mode capi-stub ads-txt structured-data security-headers
#   robots mobile-meta verification-meta

ADSSEC_SETUP_AREAS=(pixel-install consent-mode capi-stub ads-txt structured-data security-headers robots mobile-meta verification-meta)

# _setup_emit_error <error> <code> <remediation>
_setup_emit_error() {
  local err="$1" code="$2" rem="$3"
  jq -n \
    --arg err "$err" \
    --arg code "$code" \
    --arg rem "$rem" \
    --argjson valid "$(printf '%s\n' "${ADSSEC_SETUP_AREAS[@]}" | jq -R . | jq -s .)" \
    '{error: $err, code: $code, remediation: $rem, valid: $valid}' >&2
}

# _setup_steps_pixel_install <platform>
_setup_steps_pixel_install() {
  local platform="${1:-google}"
  jq -n --arg platform "$platform" '
    [
      { id: "precheck-detect",
        kind: "auto",
        title: "Detect current stack",
        description: "Inspect cwd for the host framework (Next.js, Astro, SvelteKit, Vite SPA, WordPress, vanilla HTML).",
        verify_command: "bash ads-ready.sh detect" },
      { id: "precheck-existing",
        kind: "auto",
        title: "Check whether the pixel is already installed",
        description: ("Read the user-supplied URL and look for the platform pixel signature for " + $platform + "."),
        verify_command: "bash ads-ready.sh state site <url> pixels" },
      { id: "platform-create-pixel",
        kind: "external-tool",
        title: ("Create or locate the " + $platform + " pixel / tag in the platform dashboard"),
        description: ("Sign in to the " + $platform + " ads dashboard. Create a new pixel if needed and copy its ID."),
        external_url: "see references/platforms/<platform>.md for the exact URL" },
      { id: "set-pixel-id-env",
        kind: "manual",
        title: "Export the pixel ID for the install step",
        description: ("Set the pixel ID env var the apply step expects (e.g., ADSSEC_META_PIXEL_ID, ADSSEC_GOOGLE_AW_ID, ADSSEC_GA4_MEASUREMENT_ID, ADSSEC_TIKTOK_PIXEL_ID).") },
      { id: "install-snippet",
        kind: "auto",
        title: ("Apply the " + $platform + " pixel snippet to the host stack"),
        description: ("Inserts the platform pixel into the appropriate file (app/layout.tsx, pages/_document.tsx, src/layouts/Layout.astro, theme functions.php, or index.html). Idempotent: re-runs no-op."),
        fix_command: ("bash ads-ready.sh fix pixel-install " + $platform) },
      { id: "verify-firing",
        kind: "manual",
        title: "Verify the pixel fires after deploy",
        description: ("Deploy the change. Use the platform Tag Assistant / Pixel Helper / extension to confirm the pixel fires once on page load. See references/platforms/<platform>.md for the exact tool."),
        external_url: "see references/platforms/<platform>.md" },
      { id: "verify-state",
        kind: "auto",
        title: "Re-run state site to confirm the pixel is detected",
        description: "After deploy, run state site again and confirm the pixel signature appears in the digest.",
        verify_command: "bash ads-ready.sh state site <url> pixels" }
    ]
  '
}

# _setup_steps_consent_mode
_setup_steps_consent_mode() {
  jq -n '
    [
      { id: "precheck-detect",
        kind: "auto",
        title: "Detect existing consent / CMP",
        description: "Inspect HTML for OneTrust, Cookiebot, CookieYes, Klaro, Termly, Osano, IUbenda, Didomi, Usercentrics signatures plus inline gtag consent calls.",
        verify_command: "bash ads-ready.sh state site <url> consent" },
      { id: "choose-cmp",
        kind: "external-tool",
        title: "Pick a CMP if none is installed",
        description: "Compare CMP options: pricing, scale, and engineering effort.",
        verify_command: "bash ads-ready.sh recommend cmp" },
      { id: "install-cmp",
        kind: "manual",
        title: "Install the chosen CMP",
        description: "Follow the CMP vendor signup. Get the embed snippet. Add the snippet to the page head BEFORE any pixel snippets so consent state is initialized first.",
        external_url: "see references/recommendations/cmp.md" },
      { id: "default-deny",
        kind: "manual",
        title: "Set Consent Mode v2 defaults to denied",
        description: "Before the CMP loads, gtag(\"consent\", \"default\", {ad_storage:\"denied\", ad_user_data:\"denied\", ad_personalization:\"denied\", analytics_storage:\"denied\"}). The CMP then upgrades grants on user action via gtag(\"consent\",\"update\",...)." },
      { id: "apply-glue",
        kind: "auto",
        title: "Apply Consent Mode v2 glue",
        description: "Adds the default-deny snippet plus per-platform partner integrations (fbq consent, ttq consent, etc.) where the CMP doesn’t already wire them.",
        fix_command: "bash ads-ready.sh fix consent-mode" },
      { id: "verify-signals",
        kind: "manual",
        title: "Verify consent signals reach the platforms",
        description: "Use Tag Assistant for Google, Pixel Helper for Meta, TikTok Pixel Helper, etc. Confirm the consent state values are forwarded.",
        external_url: "https://tagassistant.google.com/" },
      { id: "verify-state",
        kind: "auto",
        title: "Re-run state site to confirm consent integration",
        description: "After deploy, the state site digest should report consent_libs[] non-empty and per-platform consent integration true.",
        verify_command: "bash ads-ready.sh state site <url> consent" }
    ]
  '
}

# _setup_steps_capi_stub <platform>
_setup_steps_capi_stub() {
  local platform="${1:-meta}"
  jq -n --arg platform "$platform" '
    [
      { id: "precheck-stack",
        kind: "auto",
        title: "Detect server-side language and framework",
        description: "Inspect package.json, requirements.txt, or pyproject.toml. Identify Express / Fastify / Hono / Next API route / Flask / FastAPI / Django.",
        verify_command: "bash ads-ready.sh detect" },
      { id: "platform-secret",
        kind: "external-tool",
        title: ("Create a Conversions API access token in the " + $platform + " dashboard"),
        description: ("In the platform dashboard, generate a system-user / long-lived access token scoped to the ad account. Copy it and the pixel/dataset id."),
        external_url: "see references/platforms/<platform>.md for the dashboard path" },
      { id: "set-env",
        kind: "manual",
        title: "Set CAPI env vars in the user’s deployment",
        description: ("Set the platform-specific access token and pixel/dataset id env vars in your hosting platform (Vercel, Cloudflare, Render, etc.). Never commit these to source.") },
      { id: "install-stub",
        kind: "auto",
        title: ("Render the " + $platform + " CAPI server-side stub for the detected framework"),
        description: ("Emits a working endpoint stub (Node or Python) that hashes PII (email, phone) with SHA-256, signs/posts to the platform CAPI, and returns confirmation. Ready to wire to your purchase / signup hooks."),
        fix_command: ("bash ads-ready.sh fix capi-stub " + $platform) },
      { id: "deploy-and-test",
        kind: "manual",
        title: "Deploy and send a test event",
        description: "Deploy the change. POST a test event to the new endpoint with a known order or signup. Confirm the platform Test Events tool shows it." },
      { id: "deduplicate",
        kind: "manual",
        title: "Set the deduplication ID",
        description: "Both client pixel and server CAPI should send the same event_id (Meta), gclid/wbraid (Google), or platform-equivalent. Otherwise events count twice." },
      { id: "verify-state",
        kind: "external-tool",
        title: "Verify in the platform Events Manager / Conversion Tracking dashboard",
        description: "Confirm the platform shows server-side events arriving and dedup ratio is healthy.",
        external_url: "see references/platforms/<platform>.md" }
    ]
  '
}

# _setup_steps_ads_txt
_setup_steps_ads_txt() {
  jq -n '
    [
      { id: "precheck",
        kind: "auto",
        title: "Check for existing /ads.txt",
        description: "Fetch /ads.txt from the host and parse current entries.",
        verify_command: "bash ads-ready.sh state site <url> ads-txt" },
      { id: "list-platforms",
        kind: "manual",
        title: "Identify which ad platforms run inventory on this site",
        description: "Only sites that monetize via display / video ads need ads.txt. Confirm whether the user is a publisher (running ads to monetize) vs advertiser (running ads to acquire users). Advertisers don’t need ads.txt." },
      { id: "apply-entries",
        kind: "auto",
        title: "Merge platform-specific publisher lines",
        description: "Reads templates/ads-txt-entries.template.txt; emits a merged ads.txt covering Google AdSense / AdX, Meta Audience Network, Microsoft, TikTok, etc., depending on detected platforms.",
        fix_command: "bash ads-ready.sh fix ads-txt" },
      { id: "deploy-and-verify",
        kind: "manual",
        title: "Deploy /ads.txt at the site root",
        description: "Confirm /ads.txt is served at the apex domain. Use https://adstxt.guru/ or the IAB Tech Lab ads.txt validator for syntax.",
        external_url: "https://adstxt.guru/" },
      { id: "app-ads-txt",
        kind: "manual",
        title: "If you ship a mobile app, also add /app-ads.txt",
        description: "Mobile in-app inventory uses app-ads.txt (same format, different file). Required for AdMob / Audience Network in-app monetization." },
      { id: "verify-state",
        kind: "auto",
        title: "Re-run state site to confirm",
        description: "ads-txt slice should report all required publisher lines present.",
        verify_command: "bash ads-ready.sh state site <url> ads-txt" }
    ]
  '
}

# _setup_steps_structured_data
_setup_steps_structured_data() {
  jq -n '
    [
      { id: "precheck",
        kind: "auto",
        title: "Inspect existing Product/Offer JSON-LD",
        description: "Parse <script type=\"application/ld+json\"> blocks on a product page; report whether Product and Offer are present. Other schema types are a search surface, not a feed input — call the Skill tool with \"snitch-marketing\" for those.",
        verify_command: "bash ads-ready.sh state site <product-url> structured-data" },
      { id: "confirm-feed-need",
        kind: "manual",
        title: "Confirm the catalog and how the feed is built",
        description: "No catalog, or a complete file/API feed that never falls back to a crawl, means on-page markup is not an ads blocker — Skip with that reason. Crawl-based or automatic feeds read Product/Offer off the page. Also confirm whether the target markets mandate shipping and return-policy disclosure." },
      { id: "apply-product",
        kind: "auto",
        title: "Apply the Product + Offer JSON-LD starter",
        description: "Renders templates/structured-data/product.starter.json with {{PLACEHOLDER}} values left in place, targeting the product-page template.",
        fix_command: "bash ads-ready.sh fix structured-data ecommerce" },
      { id: "bind-placeholders",
        kind: "manual",
        title: "Bind every placeholder to the product record",
        description: "Price and currency from the field checkout charges from; priceValidUntil computed at build, never a literal; SKU/MPN/GTIN from the same identifiers the feed uses; shipping and return fields from the shipping table for the target market. Delete the aggregateRating block unless real review data backs it." },
      { id: "validate",
        kind: "external-tool",
        title: "Validate in Merchant Center Diagnostics and the Rich Results Test",
        description: "After deploy, check item-level disapprovals in Merchant Center Diagnostics after the next crawl, and confirm the block parses in the Rich Results Test. Price and availability in the markup must match the feed for the same item.",
        external_url: "https://merchants.google.com/" },
      { id: "verify-state",
        kind: "auto",
        title: "Re-run state site to confirm Product is present",
        description: "structured-data slice should list Product in .structured_data.types on the product page.",
        verify_command: "bash ads-ready.sh state site <product-url> structured-data" }
    ]
  '
}

# _setup_steps_security_headers
_setup_steps_security_headers() {
  jq -n '
    [
      { id: "precheck",
        kind: "auto",
        title: "Inspect current response headers",
        description: "Fetch HEAD on the URL; report CSP, HSTS, X-Frame-Options, Referrer-Policy, Permissions-Policy.",
        verify_command: "bash ads-ready.sh state site <url> headers" },
      { id: "list-platforms",
        kind: "manual",
        title: "Confirm which ad platforms run on the site",
        description: "The CSP allowlist must cover script-src + img-src + frame-src for every active ad platform plus the consent CMP. Over-allowing bloats CSP; under-allowing breaks tags." },
      { id: "apply-headers",
        kind: "auto",
        title: "Apply the ads-aware security header set",
        description: "Renders templates/security-headers-for-ads.template.txt into the format for the detected stack (next.config.js headers(), _headers for Pages and Netlify, vercel.json headers, nginx add_header). The CSP allowlists every platform script, iframe, and img domain and allows inline scripts by nonce — replace {{NONCE}} with a per-request value from your edge layer. This proposes a snippet; it does not merge with an existing CSP.",
        fix_command: "bash ads-ready.sh fix security-headers" },
      { id: "deploy-and-test",
        kind: "manual",
        title: "Deploy and watch the browser console",
        description: "After deploy, open DevTools → Console + Network. Any `Refused to load` or `Refused to execute inline script because it violates the following Content Security Policy directive` errors point to a missing CSP entry. Add then redeploy." },
      { id: "validate",
        kind: "external-tool",
        title: "Validate with securityheaders.com + Mozilla Observatory",
        description: "Aim for an A on securityheaders.com and 90+ on Observatory.",
        external_url: "https://securityheaders.com/" },
      { id: "verify-state",
        kind: "auto",
        title: "Re-run state site to confirm",
        description: "headers slice should report the full set present.",
        verify_command: "bash ads-ready.sh state site <url> headers" }
    ]
  '
}

# _setup_steps_robots
_setup_steps_robots() {
  jq -n '
    [
      { id: "precheck",
        kind: "auto",
        title: "Fetch and parse the current /robots.txt",
        description: "Report whether robots.txt exists and which User-agent rules it carries.",
        verify_command: "bash ads-ready.sh state site <url> robots" },
      { id: "list-crawlers",
        kind: "manual",
        title: "Confirm which platform crawlers must reach the site",
        description: "Ad platforms verify landing pages with their own crawlers (AdsBot-Google / AdsBot-Google-Mobile, bingbot + AdIdxBot, facebookexternalhit, LinkedInBot, Bytespider, …). A Disallow that catches one of them fails ad review or hurts Quality Score. Also check the three OpenAI agents separately: blocking OAI-SearchBot removes the site from ChatGPT answers and the contextual ad surface, while GPTBot is training-only. Access policy for the other AI crawlers is a search decision — call the Skill tool with \"snitch-marketing\".",
        reference: "references/setup/robots.md" },
      { id: "apply-rules",
        kind: "auto",
        title: "Propose the robots.txt fix",
        description: "If no robots.txt exists, proposes a permissive starter; if a Disallow blocks a canonical ad crawler, proposes a targeted Allow override. Never loosens rules beyond the affected user-agents.",
        fix_command: "bash ads-ready.sh fix robots" },
      { id: "verify-state",
        kind: "auto",
        title: "Re-run the robots slice to confirm",
        description: "robots slice should report no ad-platform crawler blocked.",
        verify_command: "bash ads-ready.sh state site <url> robots" }
    ]
  '
}

# _setup_steps_mobile_meta
_setup_steps_mobile_meta() {
  jq -n '
    [
      { id: "precheck",
        kind: "auto",
        title: "Inspect current mobile meta tags",
        description: "Check the page for viewport, theme-color, and format-detection meta tags. Missing viewport fails mobile-friendliness checks that ad Quality Score and landing-page experience depend on.",
        verify_command: "bash ads-ready.sh state site <url> html" },
      { id: "apply-tags",
        kind: "auto",
        title: "Propose the mobile meta set",
        description: "Emits viewport, theme-color, apple-mobile-web-app, and format-detection tags for the detected stack. Note: format-detection telephone=no disables auto-linked numbers — keep explicit tel: links (tracked ones; see the lead-capture slice) for call-first businesses.",
        fix_command: "bash ads-ready.sh fix mobile-meta" },
      { id: "verify-state",
        kind: "auto",
        title: "Re-check the page",
        description: "Confirm the tags render in the served HTML, not just in source.",
        verify_command: "bash ads-ready.sh state site <url> html" }
    ]
  '
}

# _setup_steps_verification_meta
_setup_steps_verification_meta() {
  jq -n '
    [
      { id: "precheck",
        kind: "auto",
        title: "Check for existing verification tags",
        description: "Look for google-site-verification, facebook-domain-verification, msvalidate.01, p:domain_verify meta tags in the served HTML.",
        verify_command: "bash ads-ready.sh state site <url> html" },
      { id: "get-token",
        kind: "manual",
        title: "Copy the verification token from the platform dashboard",
        description: "Google: Search Console → Settings → Ownership verification. Meta: Business Manager → Brand Safety → Domains. Microsoft: Bing Webmaster Tools → Settings. Pinterest: Settings → Claimed accounts. LinkedIn / TikTok / X / Reddit / Snapchat verify by file upload instead of a meta tag.",
        reference: "references/setup/verification-meta.md" },
      { id: "apply-tag",
        kind: "auto",
        title: "Propose the verification meta tag",
        description: "Emits the platform-correct meta tag with a REPLACE_WITH_TOKEN placeholder the user fills with the real token before deploy.",
        fix_command: "bash ads-ready.sh fix verification-meta" },
      { id: "confirm-in-dashboard",
        kind: "manual",
        title: "Complete verification in the platform dashboard",
        description: "After deploy, click Verify in the platform UI. Domain verification unlocks conversion-domain settings (Meta), Search Console data (Google), and UET ownership (Microsoft)." }
    ]
  '
}

# run_setup <area> [platform]
run_setup() {
  local area="${1:-}"
  local platform="${2:-}"
  if [[ -z "$area" ]]; then
    _setup_emit_error "missing area argument" "E_USAGE" "Usage: setup <area> [platform]. Valid areas: ${ADSSEC_SETUP_AREAS[*]}."
    return 2
  fi

  local steps_json
  case "$area" in
    pixel-install)     steps_json="$(_setup_steps_pixel_install "${platform:-google}")" ;;
    consent-mode)      steps_json="$(_setup_steps_consent_mode)" ;;
    capi-stub)         steps_json="$(_setup_steps_capi_stub "${platform:-meta}")" ;;
    ads-txt)           steps_json="$(_setup_steps_ads_txt)" ;;
    structured-data)   steps_json="$(_setup_steps_structured_data)" ;;
    security-headers)  steps_json="$(_setup_steps_security_headers)" ;;
    robots)            steps_json="$(_setup_steps_robots)" ;;
    mobile-meta)       steps_json="$(_setup_steps_mobile_meta)" ;;
    verification-meta) steps_json="$(_setup_steps_verification_meta)" ;;
    *)
      _setup_emit_error "unknown setup area: ${area}" "E_USAGE" "Valid areas: ${ADSSEC_SETUP_AREAS[*]}"
      return 2
      ;;
  esac

  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -n "$platform" ]]; then
    jq -n \
      --arg ts "$ts" \
      --arg area "$area" \
      --arg platform "$platform" \
      --argjson steps "$steps_json" \
      '{
        schema: "adssec.setup",
        schema_version: 1,
        generated_at: $ts,
        tool: "setup",
        area: $area,
        platform: $platform,
        steps: $steps,
        require_confirmation: true,
        note: "Agent: present each step in order; chain fix_command calls only after the user confirms; treat external-tool steps as out-of-shell (link to external_url)."
      }'
  else
    jq -n \
      --arg ts "$ts" \
      --arg area "$area" \
      --argjson steps "$steps_json" \
      '{
        schema: "adssec.setup",
        schema_version: 1,
        generated_at: $ts,
        tool: "setup",
        area: $area,
        steps: $steps,
        require_confirmation: true,
        note: "Agent: present each step in order; chain fix_command calls only after the user confirms; treat external-tool steps as out-of-shell (link to external_url)."
      }'
  fi
}
