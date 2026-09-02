# Tool contracts — the JSON every read tool actually returns

Every shape below was captured from a real run of `ads-ready.sh` on 2026-09-01. When the tool
and this file disagree, the tool is right — re-run the subcommand and fix this file.

Read tools emit one JSON document on stdout. `doctor`, `fix`, `verify` and `export` emit
`🔴/🟡/⚪/🟢` badges on stdout instead — parse none of them as JSON. Errors go to stderr as
JSON with a non-zero exit.

## Common header

Every read tool's document opens with:

```json
{
  "schema": "adssec.<name>",
  "schema_version": 1,
  "generated_at": "2026-09-01T23:54:26Z",
  "tool": "<subcommand>"
}
```

## Error shape (stderr)

```json
{
  "error": "unknown platform",
  "code": "E_USAGE",
  "got": "bogus",
  "valid": ["google", "meta", "microsoft", "linkedin", "tiktok", "x", "pinterest", "reddit", "snapchat", "apple"]
}
```

Codes in use: `E_USAGE`, `E_URL`, `E_AUTH`, `E_TEMPLATE`, `E_UNKNOWN_STACK`, `E_PSI`,
`E_LIGHTHOUSE`, `E_LIGHTHOUSE_EMPTY`, `E_LIGHTHOUSE_FALLBACK`. Most errors also carry
`remediation`, and usage errors carry `valid`.

`state site`, `state crux`, `state lighthouse`, `score`, and `export` all require a URL and
fail with `E_USAGE` without one. There is no "audit the last URL" mode.

## `adssec.detect`

Offline; reads the cwd only. Every array is present even when empty.

```json
{
  "schema": "adssec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "node | python | php | ruby | dotnet | jvm | go | rust | static | unknown",
  "stacks": [],
  "pixel_libs": [],
  "pixel_snippets": [],
  "consent_libs": [],
  "vertical_hints": [],
  "structured_data_libs": [],
  "package_managers": [],
  "current_host_provider": null,
  "hostnames": []
}
```

## `adssec.state-site.<slice>`

`state site <url> [slice]`. Slice ∈ `digest` (default) | `html` | `headers` | `pixels` |
`consent` | `structured-data` | `robots` | `sitemap` | `ads-txt` | `lead-capture` | `full`.
Each slice carries the common header plus `slice`, `url`, and only its own sections:

| Slice | Sections it adds |
|---|---|
| `digest` | `origin`, `status`, `pixels`, `consent`, `lead_capture`, `structured_data`, `security_headers`, `robots`, `sitemap`, `ads_txt`, `app_ads_txt`, `security_txt`, `hint` |
| `html` | `status`, `html` (the full body; not written to disk) |
| `headers` | `status`, `raw` (the header text), `security_headers` |
| `pixels` | `pixels` |
| `consent` | `consent` |
| `structured-data` | `structured_data` |
| `robots` | `robots` |
| `sitemap` | `sitemap` |
| `ads-txt` | `ads_txt`, `app_ads_txt` |
| `lead-capture` | `lead_capture` |
| `full` | every section above, plus `headers_raw` |

Digest, verbatim from a real run against `https://example.com`:

```json
{
  "schema": "adssec.state-site.digest", "schema_version": 1,
  "generated_at": "2026-09-01T23:54:26Z", "tool": "state-site",
  "slice": "digest",
  "url": "https://example.com",
  "origin": "https://example.com",
  "status": 200,
  "pixels": {
    "google":    { "platform": "google", "detected": false, "ids": [] },
    "meta":      { "platform": "meta", "detected": false, "ids": [] },
    "microsoft": { "platform": "microsoft", "detected": false, "ids": [] },
    "linkedin":  { "platform": "linkedin", "detected": false, "ids": [] },
    "tiktok":    { "platform": "tiktok", "detected": false, "ids": [] },
    "x":         { "platform": "x", "detected": false, "ids": [] },
    "pinterest": { "platform": "pinterest", "detected": false, "ids": [] },
    "reddit":    { "platform": "reddit", "detected": false, "ids": [] },
    "snapchat":  { "platform": "snapchat", "detected": false, "ids": [] },
    "apple":     { "platform": "apple", "detected": false, "ids": [], "note": "Apple Search Ads is iOS-only; ..." }
  },
  "consent": { "platform": "none", "consent_mode_v2": false, "has_data_layer": false },
  "lead_capture": {
    "tel_links": { "count": 0, "numbers": [] },
    "call_tracking": { "phone_conversion_config": false, "dni_provider": "none" },
    "forms": { "count": 0, "gclid_field": false, "gclid_js_capture": false, "enhanced_conversions_signal": false },
    "gtm_present": false,
    "flags": { "untracked_phone_path": false, "offline_import_not_ready": false },
    "note": "static-HTML heuristics; ..."
  },
  "structured_data": { "jsonld_count": 0, "types": [], "valid": [], "invalid": [] },
  "security_headers": {
    "strict_transport_security": null, "content_security_policy": null,
    "x_frame_options": null, "x_content_type_options": null,
    "referrer_policy": null, "permissions_policy": null,
    "cross_origin_opener_policy": null, "cross_origin_resource_policy": null
  },
  "robots": { "present": false, "status": 404, "crawler_access": {}, "crawler_access_note": "...", "body": "..." },
  "sitemap": { "present": false, "status": 404, "url_count": 0 },
  "ads_txt": { "present": false, "status": 404, "line_count": 0 },
  "app_ads_txt": { "present": false, "status": 404, "line_count": 0 },
  "security_txt": { "present": false, "status": 404 },
  "hint": "for the HTML body, run: state site <url> html  |  for ads.txt body: state site <url> ads-txt"
}
```

Reading it correctly:

- **Pixels** are an object keyed by platform, not a list of detected names. Ask
  `.pixels.<platform>.detected`; the ids found are in `.pixels.<platform>.ids`.
- **Consent** has exactly three fields — `platform` (the CMP vendor or `"none"`),
  `consent_mode_v2`, `has_data_layer`. There is no `cmp_detected` and no `default_state`; read
  the `html` slice if you need the `'default'` call itself.
- **Security headers** are raw values or `null`, one key per header. There are no `*_present`
  booleans — a non-null value is the evidence, and it is the string you quote in a finding.
- **Structured data** is `.structured_data.{jsonld_count, types, valid, invalid}`; there is no
  top-level `structured_data_types`.
- **There is no `verdict`.** The tool extracts; the agent judges. `score` is the only thing
  that renders a number, and it is a heuristic (see below).
- `robots.crawler_access` gives per-agent verdicts (`blocked`, `allowed`,
  `blocked-by-default`, `allowed-by-default`) for ad/presence crawlers (AdsBot-Google,
  AdIdxBot, bingbot, facebookexternalhit, Applebot) and AI crawlers (GPTBot, OAI-SearchBot,
  ChatGPT-User, PerplexityBot, ClaudeBot, Google-Extended, Applebot-Extended). Whole-site
  `Disallow: /` heuristic only — path-level rules are not evaluated. It is `{}` when the site
  serves no robots.txt.
- `lead_capture.flags` are static-HTML heuristics. When `gtm_present` is true, check inside the
  GTM container before reporting `untracked_phone_path` or `offline_import_not_ready` as a
  finding.

## `adssec.state-crux`

`state crux <url> [mobile|desktop]`. Wraps the PageSpeed Insights API, which carries both CrUX
field data and a Lighthouse lab run.

```json
{
  "schema": "adssec.state-crux", "schema_version": 1, "generated_at": "...", "tool": "state-crux",
  "url": "https://example.com",
  "strategy": "mobile",
  "psi_api_key_used": false,
  "data": {
    "requested_url": "https://example.com/",
    "final_url": "https://example.com/",
    "fetch_time": "2026-09-01T23:00:00.000Z",
    "strategy": "mobile",
    "categories": { "performance": 0.99, "accessibility": 0.88, "best-practices": 1, "seo": 0.9 },
    "field_data": {
      "overall_category": "FAST",
      "metrics": {
        "LARGEST_CONTENTFUL_PAINT_MS":     { "percentile": 1900, "category": "FAST" },
        "INTERACTION_TO_NEXT_PAINT":       { "percentile": 120,  "category": "FAST" },
        "CUMULATIVE_LAYOUT_SHIFT_SCORE":   { "percentile": 3,    "category": "FAST" },
        "FIRST_CONTENTFUL_PAINT_MS":       { "percentile": 1100, "category": "FAST" },
        "EXPERIMENTAL_TIME_TO_FIRST_BYTE": { "percentile": 400,  "category": "FAST" }
      }
    },
    "origin_field_data": { "overall_category": "FAST", "metrics": { "...": {} } },
    "audits_summary": [ { "id": "largest-contentful-paint", "score": 1, "title": "Largest Contentful Paint" } ]
  }
}
```

- Metric keys are the CrUX names, and CLS is reported as an integer percentile (3 = 0.03).
- `categories` values are Lighthouse **lab** scores, 0-1. `field_data` is real-user data — cite
  field data in a finding and label lab scores as lab.
- `field_data.metrics` is `{}` when CrUX has too little traffic for the URL. Fall back to
  `origin_field_data`, and say which one you used.
- Failure: `{"error":"PSI API call failed","code":"E_PSI","status":"429",...}` on stderr,
  exit 3. A 429 is the exhausted anonymous quota (set `PSI_API_KEY`); a 000 is a timeout (raise
  `ADSEC_HTTP_TIMEOUT` — a PSI run often takes 30s or more).

## `adssec.state-lighthouse`

`state lighthouse <url>`. Two shapes, told apart by `source`:

```json
{ "schema": "adssec.state-lighthouse", "schema_version": 1, "generated_at": "...",
  "tool": "state-lighthouse", "url": "...",
  "source": "lighthouse-cli",
  "audit": { "<the full Lighthouse JSON report>": "..." } }
```

```json
{ "schema": "adssec.state-lighthouse", "schema_version": 1, "generated_at": "...",
  "tool": "state-lighthouse", "url": "...",
  "source": "psi-fallback",
  "hint": "install lighthouse CLI for full audit JSON: npm i -g lighthouse",
  "psi": { "<a whole adssec.state-crux document>": "..." } }
```

There are no `tool_used`, `categories`, or `audits` keys at this level — `source` selects
between `audit` (the raw CLI report) and `psi` (a nested `state-crux` document). The
"falling back to PSI" line goes to stderr, so stdout stays parseable.

## `adssec.state-platform.<platform>`

`state platform <name> [account-id]`. With auth, the document carries that platform's
account / campaign / conversion / audience reads. Without it:

```json
{
  "schema": "adssec.state-platform.meta", "schema_version": 1, "generated_at": "...",
  "tool": "state-platform",
  "platform": "meta",
  "locked": "meta-api",
  "reason": "Meta Marketing API auth env not configured.",
  "remediation": "Export META_ACCESS_TOKEN ... and META_AD_ACCOUNT_ID ...",
  "env_required": ["META_ACCESS_TOKEN", "META_AD_ACCOUNT_ID", "META_APP_SECRET"]
}
```

A `locked` document is a **Skip with a reason**, not a Finding: report the reason and
`env_required` as what would unblock it. Exit code is still 0.

`state gsc` and `analytics ga4 <property-id>` lock the same way, with `locked: "gsc-api"` /
`"ga4-api"`.

## `adssec.fit-matrix` / `adssec.fit-matrix-entry`

```json
{ "schema": "adssec.fit-matrix", "schema_version": 1, "generated_at": "...",
  "tool": "fit-matrix", "matrix": { "<stack>": { "verdict": "...", "notes": "...", "best_for": [] } } }
```

```json
{ "schema": "adssec.fit-matrix-entry", "schema_version": 1, "generated_at": "...",
  "tool": "fit-matrix", "stack": "nextjs",
  "entry": { "verdict": "strong | partial | weak", "notes": "...", "best_for": ["Google Ads + GA4", "..."] } }
```

Errors: `E_TEMPLATE` if `templates/migration-fit-matrix.json` is missing; `E_UNKNOWN_STACK`
with `remediation: "run ads-ready.sh fit-matrix without args to see all stack keys"`.

## `adssec.stack-docs` / `adssec.stack-docs-entry`

```json
{ "schema": "adssec.stack-docs", "schema_version": 1, "generated_at": "...",
  "tool": "stack-docs", "registry": { "<stack>": { "framework_docs": [], "ads_tracking_docs": [] } } }
```

```json
{ "schema": "adssec.stack-docs-entry", "schema_version": 1, "generated_at": "...",
  "tool": "stack-docs", "stack": "nextjs",
  "entry": { "framework_docs": ["https://nextjs.org/docs", "..."], "ads_tracking_docs": ["..."] } }
```

`WebFetch` those URLs for fresh ground truth.

## `adssec.score`

```json
{
  "schema": "adssec.score", "schema_version": 1, "generated_at": "...", "tool": "score",
  "url": "https://example.com",
  "components": {
    "pixel_coverage": 0, "cwv": 100, "consent": 0,
    "structured_data": 0, "security_headers": 0, "ads_txt": 0
  },
  "weights": {
    "pixel_coverage": 25, "cwv": 20, "consent": 20,
    "structured_data": 15, "security_headers": 15, "ads_txt": 5
  },
  "overall_score": 20,
  "overall_grade": "F",
  "evidence": {
    "pixels": {}, "consent": {}, "structured_data": {}, "security_headers": {}, "ads_txt": {}
  }
}
```

- `components` are flat integers 0-100. `weights` are percentages summing to 100.
- `overall_score` is 0-100; `overall_grade` is a letter (A ≥ 90, B ≥ 75, C ≥ 60, D ≥ 40, else
  F). **There are no `composite_grade`, `composite_points`, or `composite_max` keys, and no
  `/80` denominator.**
- `evidence` carries the digest sections the score was computed from — cite those, not the
  letter.
- `score` is a **heuristic composite, not a finding**: `pixel_coverage` treats 3 detected
  platforms as full marks, and the letter thresholds are arbitrary. Its value is the delta
  between two runs. Never report the grade in place of an evidenced Finding.

## `adssec.setup`

```json
{
  "schema": "adssec.setup", "schema_version": 1, "generated_at": "...", "tool": "setup",
  "area": "pixel-install",
  "platform": "meta",
  "steps": [
    {
      "id": "precheck-detect",
      "kind": "auto | manual | external-tool",
      "title": "...",
      "description": "...",
      "verify_command": "bash ads-ready.sh detect",
      "fix_command": "bash ads-ready.sh fix pixel-install meta",
      "external_url": "https://...",
      "reference": "references/setup/robots.md"
    }
  ],
  "require_confirmation": true,
  "note": "Agent: present each step in order; ..."
}
```

`fix_command`, `external_url`, `verify_command`, and `reference` appear only on the steps that
have them. Nine areas: `pixel-install`, `consent-mode`, `capi-stub`, `ads-txt`,
`structured-data`, `security-headers`, `robots`, `mobile-meta`, `verification-meta`.

## `adssec.recommend`

```json
{
  "schema": "adssec.recommend", "schema_version": 1, "generated_at": "...", "tool": "recommend",
  "area": "cmp",
  "options": [
    { "name": "...", "vendor": "...", "pricing": "...", "url": "https://...",
      "install_command": "...", "pros": ["..."], "cons": ["..."], "recommended_for": ["..."] }
  ],
  "note": "Agent: render as a comparison table; let the user pick."
}
```

**`options` is not always an array.** For `capi-helpers` it is an object keyed by platform, and
each platform is an object keyed by language:

```json
{ "area": "capi-helpers",
  "options": { "meta": { "node": [ { "name": "...", "url": "...", "install_command": "...",
                                    "pros": [], "cons": [], "recommended_for": [] } ],
                         "python": [ ... ] },
               "google": { "node": [...], "python": [...] } } }
```

Check `.options | type` before iterating. Areas: `cmp`, `gtm-server`, `capi-helpers`,
`lighthouse-runner`, `cwv-monitoring`.

## `adssec.prereqs`

```json
{
  "schema": "adssec.prereqs", "schema_version": 1, "generated_at": "...", "tool": "prereqs",
  "required": [
    { "tool": "curl", "present": true, "install_hint": { "macos": "...", "linux": "...", "windows": "..." } },
    { "tool": "jq", "present": true, "install_hint": { "...": "..." } }
  ],
  "optional": [
    { "tool": "lighthouse", "present": false, "install_hint": { "...": "..." },
      "unlocks": ["state lighthouse <url> (full audit JSON instead of PSI fallback)"] }
  ],
  "platform_auth": [
    { "platform": "google", "env_vars": ["GOOGLE_ADS_DEVELOPER_TOKEN", "..."], "present": false,
      "signup_url": "https://..." }
  ]
}
```

`platform_auth` has one row per supported platform, in the order the capability matrix lists
them.

## `adssec.state-gsc`

`state gsc [property]`. Locked without `GOOGLE_GSC_AUTH`:

```json
{ "schema": "adssec.state-gsc", "schema_version": 1, "generated_at": "...",
  "tool": "state-gsc", "property": null, "locked": "gsc-api",
  "remediation": "set GOOGLE_GSC_AUTH (JSON: {\"refresh_token\":..., \"client_id\":..., \"client_secret\":...}) ..." }
```

With auth and no property, it lists what the token can see:

```json
{ "schema": "adssec.state-gsc", "schema_version": 1, "generated_at": "...",
  "tool": "state-gsc",
  "sites": [ { "siteUrl": "sc-domain:example.com", "permissionLevel": "siteOwner" } ],
  "hint": "to fetch performance data, run: state gsc <siteUrl-from-list>" }
```

With a property, it adds a 28-day query report:

```json
{ "schema": "adssec.state-gsc", "schema_version": 1, "generated_at": "...",
  "tool": "state-gsc", "property": "sc-domain:example.com",
  "window": { "start": "2026-08-04", "end": "2026-09-01" },
  "sites": [],
  "top_queries": [ { "keys": ["<query>"], "clicks": 0, "impressions": 0, "ctr": 0.0, "position": 0.0 } ] }
```

`sites[]` and `top_queries[]` are Search Console's own rows, passed through unedited — the
fields inside them are the API's, not this skill's, so read them defensively. Errors:
`E_GSC_AUTH` (exit 3) when the refresh token no longer exchanges.

## `adssec.analytics-ga4`

`analytics ga4 <property-id>`. Locked without `GA4_AUTH` (same shape as `state-gsc`, with
`locked: "ga4-api"` and the `property` echoed back). With auth:

```json
{ "schema": "adssec.analytics-ga4", "schema_version": 1, "generated_at": "...",
  "tool": "analytics-ga4", "property": "123456789",
  "window": "last_28_days",
  "report": { "dimensionHeaders": [], "metricHeaders": [], "rows": [], "rowCount": 0 } }
```

`report` is the GA4 Data API `runReport` body verbatim — dimension `date`, metrics `sessions`,
`conversions`, `totalUsers`, `engagedSessions`. Nothing is reshaped, so an API error surfaces
as GA4's own `{"error": {...}}` inside `report`. Errors: `E_USAGE` (no property id, exit 2),
`E_GA4_AUTH` (exit 3).

## `adssec.export`

`export <url>`. Writes `./ads-ready-export-<host>-<ts>.json` in the cwd — the only tool that
writes a file into the user's directory — and emits badges, not JSON, on stdout. The file:

```json
{ "schema": "adssec.export", "schema_version": 1, "generated_at": "...",
  "url": "https://example.com", "host": "example.com",
  "detect": { }, "site_digest": { }, "crux": { }, "score": { } }
```

Each of the four keys holds one nested document — `adssec.detect`, `adssec.state-site.digest`,
`adssec.state-crux`, `adssec.score`, each with its own `schema` field. A sub-tool that fails is
`{}` rather than a missing key, so check for the nested `schema` before reading into it.
Errors: `E_USAGE` (no URL), `E_URL` (URL without an `http://` / `https://` scheme), both exit 2.

## Badge tools

`doctor`, `fix <area> [platform]`, `verify <url>` and `export <url>` emit `🟢 [OK]` /
`🟡 [WARN]` / `🔴 [FAIL]` / `⚪ [SKIP]` / `ℹ️ [INFO]` lines on stdout — **not JSON.** Do not
pipe any of them into `jq`.

- `doctor` reports curl, jq, lighthouse, `PSI_API_KEY`, GA4 / GSC auth, and per-platform
  Marketing API auth, one badge each, and exits non-zero only when curl or jq is missing.
- `verify <url>` runs the site audit, diffs it against the last snapshot, and writes a new one.
  It swallows the audit JSON and prints a `== verify ==` section plus drift badges. A usage
  error (no URL, or a URL with no scheme) is JSON on stderr with `code: E_USAGE` / `E_URL` and
  no badge header.
- `export <url>` prints badges and writes its JSON to a file — see `adssec.export` above.
- `fix` is idempotent: it logs `OK` and stops when the target state is already met. For a
  project-side change it emits the file contract:

```
=== FILE: <relative-path> ===
=== DIFF ===
<unified diff, or a note when the file is new>
=== CONTENT ===
<full proposed file body>
=== END ===
```

The agent applies that with `Edit` / `Write` after the user confirms. The skill never writes
inside the user's project.

## Where the tools write

Nothing lands in the skill folder. Runtime state goes to
`${XDG_STATE_HOME:-$HOME/.local/state}/snitch-adsready` (override with `ADSEC_STATE_DIR`):
`findings.tsv`, `api-calls.log`, `snapshot-*.tsv`, and `doc-cache/` for `refresh-docs`. If that
path is not writable the tools fall back to the temp dir rather than failing.
