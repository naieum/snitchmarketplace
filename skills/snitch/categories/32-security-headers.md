## CATEGORY 32: Security Headers
> Type: posture · Groups: infra-supply-chain · CWE: CWE-693

### Detection
- Web frameworks: Next.js, Express, Fastify, Koa
- Header configuration: `next.config.js`, `helmet` middleware, `_headers` files
- Response header setting patterns

### What to Search For
- Missing `Content-Security-Policy` header
- Missing `Strict-Transport-Security` (HSTS) header
- Missing `X-Frame-Options` or `frame-ancestors` CSP directive
- Missing `X-Content-Type-Options: nosniff`
- Missing `Referrer-Policy` header
- Overly permissive CSP (`unsafe-inline`, `unsafe-eval`, wildcard `*` sources)

### Actually Vulnerable
- No CSP header configured anywhere (no `next.config.js` headers, no helmet, no `_headers`)
- No HSTS header on production deployment
- No clickjacking protection (missing both `X-Frame-Options` and CSP `frame-ancestors`)
- CSP with `unsafe-inline` and `unsafe-eval` (defeats purpose of CSP)
- CSP with wildcard sources (`*.example.com` or `*`)
- Missing `X-Content-Type-Options` allowing MIME sniffing
- CSP with a script allowlist but no `base-uri` — an injected `<base>` tag re-points every relative script URL, which defeats the allowlist without violating it
- CSP with no `object-src 'none'` (or an equivalent restrictive `default-src`) — plugin content is a script-execution path the script directives do not cover
- A nonce- or hash-based CSP that omits `strict-dynamic`, so every script a trusted script loads must also be enumerated, which in practice pushes teams back to a host allowlist
- A site handling cross-origin-sensitive data with no `Cross-Origin-Opener-Policy` — without it a cross-origin opener keeps a window reference, which is the precondition for several window-handle attacks
- No `Trusted-Types` / `require-trusted-types-for 'script'` directive on an application that assigns to DOM sinks — advisory, and only worth raising where Category 2 already found DOM-sink assignments

### NOT Vulnerable
- **A CSP is present — read it, do not credit it for existing.** `helmet()`, a `next.config.js`
  headers block, or a `_headers` file proves a header is emitted, not that the policy is any good. A
  Pass here quotes the actual directive list and names which of the checks above it satisfies; a
  policy of `default-src *` shipped through `helmet()` is a finding, not a Pass
- CSP whose script directives are nonce- or hash-based, with `base-uri 'self'` (or `'none'`) and
  `object-src 'none'` present — quote all three
- HSTS configured at infrastructure level (Cloudflare, Vercel, load balancer)
- `X-Frame-Options: DENY` or CSP `frame-ancestors 'none'` set
- CSP with nonce-based inline scripts (not blanket `unsafe-inline`)
- Strict `Referrer-Policy` configured

### Context Check
1. Is CSP configured at application level or infrastructure level — and what does the policy actually say? Quote the directives before judging it
2. Is HSTS handled by the hosting platform (Vercel, Cloudflare)?
3. Are `unsafe-inline`/`unsafe-eval` required for the framework (some need it with nonces)?
4. Is this an API-only service (some headers less relevant)?

### Evidence Chain
A finding's Evidence block must show:
- The config file:line where headers are (or should be) set — `next.config.js` `headers()`, `helmet()` call, middleware, `_headers`/`vercel.json`/`netlify.toml` — with the header absent or the weak value quoted
- The specific missing or weak header, quoting the offending directive (`unsafe-inline`, `unsafe-eval`, wildcard `*` sources)
- That the app serves HTML/browser responses (not API-only), so the missing header has real impact
- That no other layer sets it: framework config, middleware, helmet, and platform config files all checked
- For infrastructure-level claims: the hosting platform that would (or would not) inject the header

### Confidence Scoring
- **High**: every header-setting location checked (framework config, middleware, helmet, platform files) and the header is absent or explicitly weak (`unsafe-inline` + `unsafe-eval`, wildcard sources) on a browser-served app
- **Medium**: header absent in code but the hosting platform (Vercel, Cloudflare, load balancer) may inject it, or `unsafe-inline` may be framework-required alongside nonces
- **Low**: infrastructure configuration is not visible from the repo, so the deployed header posture cannot be confirmed — tag `needs human verification`

### Files to Check
- `next.config.js`, `next.config.ts` (check `headers()` function)
- `**/middleware*.ts` (check response header setting)
- Express/Fastify app setup files (check for `helmet()`)
- `public/_headers`, `vercel.json`, `netlify.toml`
- `**/server*.ts`, `**/app*.ts`
