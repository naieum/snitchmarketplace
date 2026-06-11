# Hono on Cloudflare Workers

Verdict + caveats: `fit-matrix hono`. Framework docs: `stack-docs hono`.

The idiomatic Workers-native router. Hono ships first-class security middleware that maps onto the CF surface.

## Cloudflare-specific

- `secureHeaders()` middleware applied globally (HSTS, CSP, X-Content-Type-Options, Referrer-Policy, Permissions-Policy in one call). FAIL if missing. https://hono.dev/docs/middleware/builtin/secure-headers
- `cors()` with explicit `origin` (specific hosts, never `"*"` with credentials). FAIL otherwise.
- `bodyLimit` middleware (e.g. 1 MB cap) — Workers default is unbounded; large `c.req.json()` is a memory DoS. WARN if missing.
- JWT secret from `env`, never literal. FAIL otherwise. Set via `wrangler secret put JWT_SECRET`.
- Cap `Promise.all` over request-derived arrays — Workers subrequest limit is 50 free / 1000 paid.
- For Cloudflare Access in front: read `Cf-Access-Jwt-Assertion`, verify with `jose` against the team JWKS.

## Validation

`@hono/zod-validator` is the canonical body/query/header validator. WARN if any POST route lacks a validator.

## Rate limiting

Workers Rate Limiting binding plugged in as middleware:

```ts
const { success } = await c.env.RATE_LIMITER.limit({ key: `req:${userId}` });
if (!success) return c.json({ error: "rate_limited" }, 429);
```

```toml
[[unsafe.bindings]]
name = "RATE_LIMITER"
type = "ratelimit"
namespace_id = "9001"
simple = { limit = 100, period = 60 }
```

## Skill targets

- `secureHeaders()` middleware: FAIL if missing.
- `cors()` explicit `origin`: FAIL otherwise.
- `bodyLimit`: WARN if missing.
- Validator on POST routes: WARN if missing.
- JWT secret from env: FAIL if literal.
- Rate limit middleware on auth routes: WARN if missing.
