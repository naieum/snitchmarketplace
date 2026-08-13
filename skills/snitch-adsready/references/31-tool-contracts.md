# Tool contracts — JSON schemas every read tool returns

Each `ads-ready.sh` read tool emits one JSON document on stdout with a stable header. Errors go to stderr as JSON `{error, code, ...}` with non-zero exit. Mutating tools (`fix`) emit `🔴/🟡/⚪/🟢` badges instead of JSON.

## Common header

```json
{
  "schema": "adssec.<name>",
  "schema_version": 1,
  "generated_at": "<ISO8601>",
  "tool": "<subcommand>"
}
```

## Error shape (stderr)

```json
{
  "error": "<short description>",
  "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_UNKNOWN_PLATFORM | E_TIMEOUT",
  "remediation": "<concrete next step>",
  "valid": ["<list>"]
}
```

On partial success: stdout has partial JSON, stderr has the per-call error, exit non-zero.

## `adssec.detect`

Offline. No API calls.

```json
{
  "schema": "adssec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "node | python | php | ruby | dotnet | jvm | go | rust | static | unknown",
  "stacks": ["nextjs", "astro", ...],
  "pixel_libs": ["@next/third-parties", "react-ga4", ...],
  "pixel_snippets": ["fbq", "gtag", "ttq", ...],
  "consent_libs": ["cookiebot", "onetrust", ...],
  "vertical_hints": ["ecommerce", "saas", "blog", ...],
  "package_managers": ["npm", "pnpm", ...],
  "current_host_provider": "vercel | cloudflare | netlify | ... | null",
  "hostnames": ["example.com"]
}
```

## `adssec.state-site.*`

`state site <url> [slice]` — slice ∈ `digest` (default) | `html` | `headers` | `pixels` | `consent` | `structured-data` | `robots` | `sitemap` | `ads-txt` | `lead-capture` | `full`. The `robots` slice reports `crawler_access`: per-agent verdicts (blocked / allowed / *-by-default) for ad/presence crawlers (AdsBot-Google, AdIdxBot, bingbot, facebookexternalhit, Applebot) and AI crawlers (GPTBot, OAI-SearchBot, ChatGPT-User, PerplexityBot, ClaudeBot, Google-Extended, Applebot-Extended) — whole-site Disallow heuristic only. Applebot governs Siri/Spotlight/Apple Maps presence; Applebot-Extended is only the Apple AI-training opt-out. The `lead-capture` slice (also embedded in `digest`/`full`) audits call-tracking + offline-conversion readiness: `tel:` links vs `phone_conversion_number` config / DNI provider scripts, form count vs gclid capture + Enhanced Conversions signals. Flags are static-HTML heuristics — when `gtm_present` is true, verify inside the GTM container before reporting `untracked_phone_path` or `offline_import_not_ready` as findings.

Digest (`adssec.state-site.digest`):

```json
{
  "schema": "adssec.state-site.digest", "slice": "digest", "url": "...",
  "fetch": { "status": 200, "final_url": "...", "elapsed_ms": 234, "size": 87432 },
  "pixels_detected": ["google", "meta", "tiktok"],
  "pixels_signals": {
    "google":    { "gtm_id": "GTM-XXX", "ga4_id": "G-XXX", "google_ads_id": "AW-XXX", "init_order_ok": true, "consent_default_set": true },
    "meta":      { "pixel_id": "1234567890", "init_order_ok": true, "noscript_present": true },
    "microsoft": null, "linkedin": null, "tiktok": { "pixel_id": "C..." }
  },
  "consent": { "cmp_detected": "cookiebot", "consent_mode_v2": true, "default_state": "denied" },
  "structured_data_types": ["Organization", "WebSite", "BreadcrumbList"],
  "headers": { "csp_present": true, "hsts_present": true, "x_frame_options": "DENY" },
  "ads_txt": { "present": true, "lines": 18 },
  "robots": { "present": true, "sitemap_url": "https://.../sitemap.xml" },
  "verdict": { "pixel_coverage": "partial", "consent_ok": true, "ads_txt_ok": true }
}
```

Slices add the heavy data:
- `adssec.state-site.html`: `{ ..., html: "<full body>" }` (not cached to disk).
- `adssec.state-site.headers`: full HEAD response.
- `adssec.state-site.pixels`: per-platform extracted snippets.
- `adssec.state-site.full`: every section combined.

## `adssec.state-crux`

```json
{
  "schema": "adssec.state-crux", "url": "...", "form_factor": "MOBILE | DESKTOP",
  "field_data": {
    "lcp_ms_p75": 2400, "inp_ms_p75": 180, "cls_p75": 0.05,
    "fcp_ms_p75": 1200, "ttfb_ms_p75": 350,
    "data_period_days": 28, "available": true
  },
  "lighthouse_categories": {
    "performance": 0.92, "accessibility": 0.95, "best_practices": 0.88, "seo": 0.95
  }
}
```

If CrUX has insufficient data (< 5,000 unique visitors / 28 days): `{ ..., field_data: { available: false, reason: "..." } }`.

## `adssec.state-lighthouse`

```json
{
  "schema": "adssec.state-lighthouse", "url": "...",
  "tool_used": "lighthouse-cli | psi-fallback",
  "categories": { "performance": 0.92, ... },
  "audits": { "largest-contentful-paint": { ... }, "cumulative-layout-shift": { ... } },
  "warnings": [ ... ]
}
```

If `lighthouse` CLI not installed: `{ ..., tool_used: "psi-fallback", hint: "Install: npm i -g lighthouse" }`.

## `adssec.state-platform.<platform>`

```json
{
  "schema": "adssec.state-platform.<platform>", "platform": "<name>",
  "account": { ... },
  "campaigns": [ ... ],
  "conversion_goals": { ... },
  "audiences": [ ... ],
  "attribution": { "default_window": "...", "note": "..." }
}
```

If platform auth env not set:

```json
{
  "schema": "adssec.state-platform.<platform>", "platform": "<name>",
  "locked": "<platform>-api",
  "reason": "Env not configured.",
  "remediation": "Export <ENV_VARS>",
  "env_required": ["..."]
}
```

## `adssec.fit-matrix` / `adssec.fit-matrix-entry`

```json
{ "schema": "adssec.fit-matrix", "matrix": { "<stack>": { ... } } }
{ "schema": "adssec.fit-matrix-entry", "stack": "...",
  "entry": { "verdict": "strong | partial | weak", "notes": "...", "best_for": [...] } }
```

Errors: `E_TEMPLATE` if `templates/migration-fit-matrix.json` missing. `E_UNKNOWN_STACK` if stack not in matrix.

## `adssec.stack-docs` / `adssec.stack-docs-entry`

```json
{ "schema": "adssec.stack-docs", "registry": { "<stack>": { ... } } }
{ "schema": "adssec.stack-docs-entry", "stack": "...",
  "entry": { "framework_docs": [...], "ads_tracking_docs": [...] } }
```

`WebFetch` `entry.framework_docs` and `entry.ads_tracking_docs` for fresh ground truth.

## `adssec.score`

```json
{
  "schema": "adssec.score", "url": "...",
  "components": {
    "pixel_coverage": { "grade": "B", "points": 12, "max": 20, "notes": "..." },
    "cwv_mobile":     { "grade": "A", "points": 18, "max": 20, "notes": "..." },
    "consent":        { "grade": "D", "points": 2,  "max": 15, "notes": "..." },
    "structured_data":{ "grade": "B", "points": 8,  "max": 10, "notes": "..." },
    "security_headers":{ "grade": "A", "points": 14, "max": 15, "notes": "..." },
    "ads_txt":        { "grade": "n/a", "points": 0,  "max": 0,  "notes": "advertiser, not publisher" }
  },
  "composite_grade": "C+",
  "composite_points": 54,
  "composite_max": 80
}
```

## `adssec.setup`

```json
{
  "schema": "adssec.setup", "tool": "setup",
  "area": "pixel-install | consent-mode | capi-stub | ads-txt | structured-data | security-headers",
  "platform": "<name>",
  "steps": [
    {
      "id": "<short-slug>",
      "kind": "auto | manual | external-tool",
      "title": "...",
      "description": "...",
      "fix_command": "bash ads-ready.sh fix ...",
      "external_url": "https://...",
      "verify_command": "bash ads-ready.sh state site ..."
    }
  ],
  "require_confirmation": true,
  "note": "Agent: present each step in order; chain fix_command calls only after the user confirms."
}
```

## `adssec.recommend`

```json
{
  "schema": "adssec.recommend", "tool": "recommend",
  "area": "cmp | gtm-server | capi-helpers | lighthouse-runner | cwv-monitoring | listings",
  "options": [
    { "name": "...", "vendor": "...", "pricing": "...", "url": "https://...",
      "install_command": "...", "pros": ["..."], "cons": ["..."], "recommended_for": ["..."] }
  ],
  "note": "Agent: render as a comparison table; let the user pick."
}
```

## `adssec.prereqs`

```json
{
  "schema": "adssec.prereqs", "tool": "prereqs",
  "required": [
    { "tool": "curl", "present": true, "install_hint": { "macos": "...", "linux": "...", "windows": "..." } }
  ],
  "optional": [
    { "tool": "lighthouse", "present": false,
      "install_hint": { ... }, "unlocks": ["state lighthouse <url>"] }
  ],
  "platform_auth": [
    { "platform": "google", "env_vars": ["..."], "present": false, "signup_url": "https://..." }
  ]
}
```

## Mutating tools

`fix <area> [platform]` emits `🔴/🟡/⚪/🟢` badges to stdout, plus per-API-call records to `.state/api-calls.log`. Idempotent. For project-side fixes, emits a `=== FILE/DIFF/CONTENT ===` block — agent applies via `Edit` / `Write` after user confirmation.
