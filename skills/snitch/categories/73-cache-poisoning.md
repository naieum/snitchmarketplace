## CATEGORY 73: Web Cache Poisoning & Cacheability
> Type: posture · Groups: web · CWE: CWE-524

A response that should have been private gets stored by a shared cache, or a response a shared
cache stores gets built from input the cache key ignores. Both halves are caching *policy* bugs,
not injection bugs: the code is usually correct in isolation and wrong once a CDN, a reverse proxy,
or a framework's own data cache sits in front of it.

This is one of the highest-yield categories on AI-written code, for a structural reason. Caching is
where a model's training data is most misleading: `Cache-Control: public, max-age=3600` is the most
common header in every tutorial, `export const revalidate = 60` is the most common Next.js
performance snippet, and neither carries the "unless this response depends on who asked" caveat.
Generated code copies the header and drops the caveat. The result is a route that returns a user's
own dashboard to whoever requests it next — a Broken Access Control outcome reached through a
Security Misconfiguration.

**Read the cache configuration and the handler together.** A cacheability finding is never visible
in one file. The handler decides whether the response body depends on the caller (a session read, a
cookie, an `Authorization` header, a tenant id); the headers, the framework's route segment
config, and the edge config decide whether that response is stored and under what key. Quote both
halves at file:line, or you have a suspicion, not a finding. Where the deciding value is a request
field reflected into a cached body, follow that value from the request to the response the same way
any other user-controlled value is followed, and say which cache key it is absent from.

### Detection
- Any explicit cache directive written by application code: `Cache-Control`, `CDN-Cache-Control`, `Cloudflare-CDN-Cache-Control`, `Surrogate-Control`, `Surrogate-Key`, `Expires`, `ETag`, `Vary`.
- Framework route-segment cache config: Next.js `export const revalidate`, `export const dynamic`, `unstable_cache`, `next: { revalidate }` on `fetch`; Nuxt `routeRules`; SvelteKit `setHeaders`; Remix/React Router `headers` exports; Rails `expires_in` / `fresh_when` / `stale?`; Django `@cache_page` / `cache_control`; Flask `@cache.cached`; FastAPI response-header middleware.
- Edge and proxy config in the repo: `vercel.json` (`headers`, `routes`), `wrangler.toml` / Workers `caches.default` and `cf: { cacheTtl, cacheEverything, cacheKey }`, `netlify.toml`, CloudFront cache-policy Terraform (`aws_cloudfront_cache_policy`, `forwarded_values`), `*.vcl` (Varnish), nginx `proxy_cache` / `proxy_cache_key`, Fastly `beresp.ttl`.
- In-process response caches keyed by URL alone: `apicache`, `@fastify/caching`, `express` middleware writing to a shared `Map`/Redis by `req.originalUrl` or `req.path`.
- Any handler that reads caller identity — `cookies()`, `headers()`, `getSession`, `req.user`, `auth()`, `req.headers.authorization`, a tenant id from a subdomain — and also sits on a route with any of the above.

### What to Search For

**Personalized response marked publicly cacheable (the dominant shape):**
- `res.setHeader("Cache-Control", "public, max-age=...")` or `s-maxage` in a handler whose body includes session, user, tenant, or account data.
- Next.js App Router: `export const revalidate = N` (or a missing `dynamic = "force-dynamic"`) on a route handler or page that resolves per-user data through a client the framework cannot see — a Supabase/Prisma call keyed on a user id read from a custom header, a manually parsed cookie, or a token passed as a function argument rather than through `cookies()`.
- A global `Cache-Control` set in middleware or an `app.use` for every route, including the authenticated ones.
- `vercel.json` / `netlify.toml` / CloudFront behaviors applying a long `s-maxage` to a path prefix that contains authenticated routes (`/api/*`, `/dashboard/*`).
- Workers code calling `caches.default.put(request, response)` or `fetch(request, { cf: { cacheEverything: true } })` on a request that carries a session cookie.

**Missing or wrong `Vary` on a response that does vary:**
- A response whose body changes with `Authorization`, `Cookie`, `Accept-Language`, or a tenant header, served cacheable with no `Vary` naming that header.
- `Vary: *` or `Vary: User-Agent` used as a stand-in for the header that actually matters.
- Content negotiation (JSON vs HTML on the same path) with no `Vary: Accept`.

**Unkeyed request input reflected into a cacheable response:**
- Absolute URLs built from `req.headers.host`, `X-Forwarded-Host`, `X-Forwarded-Proto`, `X-Forwarded-Scheme`, or `X-Original-URL` — script `src`, `link href`, canonical tags, password-reset and invite links, OAuth redirect URIs — on any route a shared cache stores.
- A query parameter or header echoed into the body when the cache key is the path alone (nginx `proxy_cache_key $uri`, a Worker `cacheKey` built from `url.pathname`, an in-process cache keyed on `req.path`).
- Error responses built from request input and served with a cacheable status (404/301/302 are cacheable by default in most CDNs unless told otherwise).

**Web cache deception (extension and path confusion):**
- A router that resolves `/account/settings.css`, `/account/settings/x.js`, or `/account;foo.css` to the same authenticated handler as `/account/settings` — Express wildcards, Next.js catch-all segments, `trailingSlash` rewrites, and permissive `rewrites` are the usual causes.
- A CDN rule that caches by file extension (`*.css`, `*.js`, `*.jpg`) with no origin check that the response was actually static.

**Cache-key narrowing that drops a security-relevant field:**
- `aws_cloudfront_cache_policy` / `forwarded_values` with `cookies { forward = "none" }` or a header allowlist that omits `Authorization` on a behavior covering authenticated paths.
- A Worker building `cacheKey` from a normalized URL that strips the query string or the auth cookie.
- Varnish VCL that unconditionally `unset req.http.Cookie` before lookup.

### Actually Vulnerable
- A Next.js route handler at `app/api/me/route.ts` reads the user from a token passed in a custom header and returns profile data, with `export const revalidate = 300`. The framework does not know the response is per-user, so the first caller's profile is served to everyone for five minutes.
- An Express dashboard route sets `Cache-Control: public, s-maxage=600` "for performance"; the handler renders `req.user.email` and the account balance. A shared CDN in front of the app serves one tenant's page to the next tenant.
- A password-reset email builds its link from `req.headers["x-forwarded-host"]`, and the route that generates the confirmation page is cacheable with a path-only cache key. An attacker seeds the cache with an attacker-controlled host, and the next user's page points the reset link at the attacker's domain.
- `vercel.json` applies `s-maxage=86400` to `/api/(.*)`, and `/api/orders` returns the caller's orders. The path prefix does not distinguish public API routes from authenticated ones.
- An Express app mounts `app.get("/account/*", requireAuth, renderAccount)` and the CDN caches every `*.css` request for a day. Requesting `/account/settings.css` returns the authenticated HTML body with a `.css` extension, and it lands in the shared cache where any unauthenticated user can fetch it.
- A CloudFront behavior for `/app/*` sets `cookies { forward = "none" }` while the origin returns per-session content — the cache key cannot distinguish sessions, so whichever response is stored first is served to all of them.
- A Worker does `cache.put(new Request(url.pathname), response)` for an API that returns tenant-scoped rows; the tenant id lives in a header that the constructed cache key discards.

### NOT Vulnerable
- `Cache-Control: private`, `no-store`, or `no-cache` on any response carrying caller-specific data. `private` alone is correct for browser-cacheable personalized responses and must not be reported as a shared-cache exposure.
- Next.js App Router routes that call `cookies()`, `headers()`, `draftMode()`, or `connection()` — these opt the segment into dynamic rendering, so `revalidate` does not apply and the response is not statically cached. Read the handler before flagging a `revalidate` export; this is the most common false positive in this category. Likewise, an explicit `export const dynamic = "force-dynamic"` or `fetch(..., { cache: "no-store" })` on the data call is the correct control, named in the Pass.
- Genuinely public content served with a long `s-maxage`: marketing pages, blog posts, public product listings, static assets with hashed filenames, public JSON that is identical for every caller.
- A cacheable response that varies on a header, with a correct `Vary` naming that header and a cache configuration that keys on it.
- Session-dependent responses behind an origin the CDN is configured to bypass on cookie presence (Cloudflare's default bypass on `Set-Cookie`, a `Cache-Control: private` origin response the CDN honors) — name the bypass in the Pass rather than assuming it.
- Framework defaults that are already safe: Rails sets `Cache-Control: no-store` on responses in an authenticated session by default; Django's `SessionMiddleware` adds `Vary: Cookie` and `Cache-Control: private` when the session is accessed; Next.js 15 defaults uncached `fetch`. A finding against one of these needs the code that *overrode* the default, quoted.
- Test fixtures, mocks, local dev config (`*.test.*`, `*.spec.*`, `__tests__/`, a dev-only `docker-compose` Varnish), and cache directives on routes gated behind a dev-only environment check.

### Context Check
1. Does the response body actually depend on who asked? Trace one concrete caller-specific value — a session read, `req.user`, a tenant id, a token claim — into the body at file:line. No caller-specific value in the response means no exposure, however aggressive the directive.
2. Is there a shared cache in the path at all? `Cache-Control: public` with no CDN, no reverse proxy, and no `s-maxage` is a browser-cache question (lower severity, still real on shared devices), not a cross-user exposure. Say which one you found and what evidence put a shared cache in the path (a `vercel.json`, a Cloudflare config, an nginx `proxy_cache`, a documented CDN).
3. Does the framework already opt this route out? For Next.js App Router the dynamic-API check in NOT Vulnerable decides the finding. For Rails and Django the session middleware may have already set the right headers. Check the default before reporting the override.
4. What is the cache key, and is the deciding field in it? For a poisoning or key-narrowing finding, name the key explicitly — from the CDN policy, the VCL, the Worker `cacheKey`, or the cache middleware — and name the field it omits.
5. Is the reflected value actually attacker-controlled at the edge? `Host` and `X-Forwarded-*` are frequently rewritten or pinned by the proxy in front of the app. If the proxy config is in the repo and pins the host, that is a Pass with the pin quoted; if it is not in the repo, the finding stands at Medium confidence with the gap stated.
6. Is the route reachable unauthenticated after caching? The whole impact of a cache exposure is that the *stored* copy is served without the original credentials. If the CDN would still require auth at the edge (signed URLs, Access in front), say so and rate accordingly.

### Evidence Chain
- The cache directive or config quoted at file:line: the header write, the route-segment export, the `vercel.json` / `wrangler.toml` / Terraform / VCL / nginx block, or the cache middleware registration.
- The handler's caller-specific value quoted at file:line: the session read, `req.user` access, tenant id, or token claim that makes the body per-caller — and the line where it reaches the response body.
- The cache key as configured, and the specific field it omits (`Cookie`, `Authorization`, a tenant header, the query string), or the explicit statement that the key is the path alone.
- For poisoning findings: the request field reflected into the body, its path from request to response with each hop at file:line, and the confirmation that the field is absent from the cache key.
- For deception findings: the route pattern that matches the decorated path, quoted, plus the CDN rule that caches by extension.
- The `Vary` header's presence or absence, stated explicitly. "No `Vary` found" is evidence; silence is not.
- What is exposed, concretely: which fields of which user's data a second caller receives. "Could leak data" with no named field is not a finding.

### Confidence Scoring
- **High**: the handler's per-caller value and the cacheable directive are both quoted, the framework's dynamic-opt-out is confirmed absent, and a shared cache is evidenced in the repo (CDN config, proxy config, or an explicit `s-maxage`).
- **Medium**: the directive and the per-caller body are confirmed, but the shared cache in front of the origin is inferred from deployment conventions rather than a config file in scope; or the reflected field's controllability at the edge could not be confirmed. Name which half is unconfirmed.
- **Low**: the route's data dependence could not be established (the per-user read happens behind a helper the scan could not resolve), or the cache configuration lives entirely outside the repository — tag `needs human verification` and keep the finding rather than dropping it.

### Files to Check
- `vercel.json`, `netlify.toml`, `wrangler.toml`, `wrangler.jsonc`, `*.vcl`, `nginx.conf`, `**/nginx/**`, `**/cloudfront*.tf`, `**/cdn*.tf`
- `next.config.{js,ts,mjs}` (`headers`, `rewrites`, `trailingSlash`), `nuxt.config.ts` (`routeRules`), `svelte.config.js`
- `app/**/route.{ts,js}` and `app/**/page.{tsx,jsx}` for `export const revalidate` / `export const dynamic`
- `**/middleware.{ts,js}`, `**/middleware/**` (global header writers)
- Any handler on an authenticated path: `**/api/**`, `**/dashboard/**`, `**/account/**`, `**/admin/**`
- Worker/edge entrypoints using `caches.default`, `cf: { cacheEverything }`, or a constructed `cacheKey`
- Response-cache middleware registrations (`apicache`, `@fastify/caching`, custom Redis response caches)

### Reference

OWASP: A02:2025 Security Misconfiguration. CWE selection by finding shape: a personalized or
authenticated response stored in a shared cache → CWE-524 (Use of Cache Containing Sensitive
Information, the manifest anchor); the browser-cache-only variant → CWE-525; unkeyed request input
reflected into a cached response → CWE-349 (Acceptance of Extraneous Untrusted Data With Trusted
Data); a cache key that fails to distinguish authorization context → CWE-639 is wrong here, use
CWE-524 and state the key omission in the evidence.

Severity guidance: cross-user exposure of authenticated data through a shared cache is High by
default and Critical where the exposed fields include credentials, tokens, or regulated data
(PHI, cardholder data, government identifiers). A poisoning finding that only affects a public,
non-authenticated page is Medium unless the reflected value reaches a link users are expected to
trust (a reset link, a login redirect, a script `src`), which restores High.

The fix shape is almost always one line and almost never a code rewrite: mark the response
`private, no-store`, opt the route out of static rendering through the framework's own dynamic
API, or add the missing field to the cache key. Say which of the three applies. Recommending a
cache be removed entirely is rarely the right fix and should not be the default advice.
