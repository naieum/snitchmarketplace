# Setup — Security headers (ads-aware)

Walkthrough for `setup security-headers`. Goal: emit a CSP allowlist covering the 10 ad platforms' script + iframe + img domains, plus HSTS, X-Frame, Referrer-Policy, Permissions-Policy.

## Pre-checks

1. **Run `bash ads-ready.sh state site <url> headers`.** Reports current Strict-Transport-Security, Content-Security-Policy, X-Frame-Options.
2. **Confirm active ad platforms.** CSP allowlist must cover script-src + img-src + frame-src for every platform; over-allowing bloats CSP, under-allowing breaks tags.
3. **Identify the CMP.** OneTrust, Cookiebot, Klaro each need their own connect-src + script-src additions.

## Steps

### 1. Apply the ads-aware header set (auto)

```bash
bash ads-ready.sh fix security-headers
```

The apply step:
- Reads the header values from `templates/security-headers-for-ads.template.txt` — the single
  source of truth for the CSP allowlist. `Cache-Control` in that file is not emitted (a blanket
  no-cache would hurt the Core Web Vitals this skill also grades).
- Detects the host stack and renders that file's format:
  - Next.js → a `next.config.js` `headers()` snippet.
  - Cloudflare Pages / Netlify → `_headers`.
  - Vercel → a `vercel.json` `headers` array.
  - Nginx → `add_header ... always;` lines.
- Emits `=== FILE/DIFF/CONTENT ===` targeting the right file.
- **Proposes, does not merge.** It never reads your existing CSP, so it cannot lower your
  posture — and cannot combine with it either. You merge. If you already ship a CSP, take the
  new source domains from this snippet rather than replacing the whole policy.
- The CSP allows scripts **by nonce**, not `'unsafe-inline'`: replace `{{NONCE}}` with a
  per-request value from your edge layer and stamp the same value on each inline pixel tag.
  Without that, the inline snippets are blocked. The tool warns about this on every run.

### 2. Customize CSP for your CMP (manual)

| CMP | Add to CSP |
|---|---|
| OneTrust | `https://cdn.cookielaw.org`, `https://*.onetrust.com` |
| Cookiebot | `https://consent.cookiebot.com`, `https://*.cookiebot.com` |
| CookieYes | `https://cdn-cookieyes.com` |
| Klaro | self-hosted; just `'self'` covers it |
| Termly | `https://app.termly.io` |
| Osano | `https://cmp.osano.com` |

### 3. Generate per-request nonces (manual)

For maximum CSP strictness (no `'unsafe-inline'`), every inline `<script>` needs a per-request nonce:

| Stack | Where to generate |
|---|---|
| Next.js | Edge middleware (`middleware.ts`) — `crypto.randomUUID()`, set `x-nonce` header, read in layout |
| SvelteKit | `hooks.server.ts` — same pattern |
| Cloudflare Workers / Pages | Pages Functions or Worker handler — generate, write to `x-nonce`, inject via HTML transform |
| WordPress | Filter `wp_head` to inject nonces; pair with `.htaccess` CSP |

Template uses `{{NONCE}}` — replace with your nonce variable.

### 4. Deploy + watch the browser console (manual)

After deploy, DevTools → Console + Network on deployed site. Browse a few pages including ad-heavy ones. Watch for:

- `Refused to load the script 'https://...'` → add domain to CSP `script-src`.
- `Refused to display 'https://...' in a frame because an ancestor violates...` → add to `frame-src`.
- `Refused to load image 'https://...'` → add to `img-src`.
- `Refused to connect to 'https://...'` → add to `connect-src`.

Iterate. Most sites need 2-3 CSP refinements after first deploy.

### 5. Validate (external-tool)

| Tool | URL | Target |
|---|---|---|
| securityheaders.com | https://securityheaders.com/ | A or A+ |
| Mozilla Observatory | https://observatory.mozilla.org/ | 90+ score |
| HSTS Preload | https://hstspreload.org/ | "Eligible", then submit |

### 6. Re-run state site (auto)

```bash
bash ads-ready.sh state site <url> headers
```

The `headers` slice reports each header's raw value under `.security_headers`, or `null` when
absent: `content_security_policy`, `strict_transport_security`, `x_frame_options`,
`x_content_type_options`, `referrer_policy`, `permissions_policy`,
`cross_origin_opener_policy`, `cross_origin_resource_policy`. There are no `*_present`
booleans — a non-null value is the evidence.

## Trade-offs

- **`unsafe-eval`**: Some pixels (Meta historically) need it. Avoid where possible. If unavoidable, gate behind a per-page CSP override.
- **`unsafe-inline`**: Required if you can't generate nonces. Less strict but functional. Many sites ship `'unsafe-inline'` indefinitely.
- **report-uri / report-to**: Add a CSP violation reporting endpoint to monitor rejected loads (custom or Report URI service free tier).

## Common mistakes

- Forgetting CMP domain → consent banner doesn't load → all tags stay denied → conversions vanish.
- `'self'` only on script-src → no third-party tags load.
- Missing `connect-src` for CAPI endpoints (your own /api/capi/* routes).
- HSTS without `preload` directive.
- `default-src 'self'` without `data:` for img-src → SVG data URIs break.

## See also

- `templates/security-headers-for-ads.template.txt` — the template.
- your CDN or host's own header configuration — headers set at the edge override anything the app sends.
- securityheaders.com docs: https://securityheaders.com/
