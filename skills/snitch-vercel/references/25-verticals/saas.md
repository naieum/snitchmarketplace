# SaaS on Vercel

Common stack: Next.js + Auth.js / Clerk / Auth0 + Vercel Postgres + Vercel KV for sessions/rate-limits.

## Hardening checklist

| Area | Action |
|---|---|
| Tenant isolation | Every DB query must include `WHERE tenant_id = ?`. RLS on Postgres strongly recommended |
| Auth | Enforce 2FA at the auth provider for owner accounts. Verify session at edge middleware |
| User API tokens | Scope per-tenant. Hash them; never store the token itself |
| Outbound webhooks | Sign with HMAC; document verification path so customers can verify on their end |
| CSP | Tighten over time; baseline + analytics overlay → nonce-only |
| Audit log | Log every mutation with `actor_id`, `tenant_id`, `action`, `before`, `after`. Pipe to log drains |
| Rate-limit per tenant | Not just per IP. A noisy customer shouldn't degrade everyone else |

## Deployment protection

| Env | Setting |
|---|---|
| Production | Open (paying customers) |
| Preview | Vercel Authentication |
| Production (B2B portal) | Trusted IPs (Enterprise) |

## Multi-region

For latency-critical SaaS:

- Static assets: Vercel CDN handles globally.
- Function regions: pin per-route to nearest user (multi-region requires Pro/Enterprise + careful DB design).
- Database: Postgres read-replicas; route reads to nearest replica.

## Cost watchlist

- Edge middleware on every request can dwarf function cost; bound the matcher.
- Function memory: 1024MB usually enough for SaaS CRUD; bump only when profiling shows OOM.

## References

- https://vercel.com/templates/next.js/saas-starter
- https://www.postgresql.org/docs/current/ddl-rowsecurity.html
