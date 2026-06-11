# Workers (native handler) on Cloudflare

Verdict + caveats: `fit-matrix workers-native`. Framework docs: `stack-docs workers-native`.

For projects with `wrangler.toml` + `src/index.ts` exporting a `fetch` handler.

## `wrangler.toml` essentials

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2025-04-01"      # WARN if > 6 months stale
compatibility_flags = ["nodejs_compat"]
workers_dev = false                     # FAIL if true in prod
keep_vars = false

[[routes]]
pattern = "api.example.com/*"
zone_name = "example.com"

[observability.logs]
enabled = true
head_sampling_rate = 0.1
```

https://developers.cloudflare.com/workers/wrangler/configuration/

## Cloudflare-specific

- Secrets via `wrangler secret put NAME` — never in `[vars]`. FAIL on high-entropy values in `[vars]`.
- `workers_dev = false` for prod.
- `globalThis` reused across requests in the same isolate — don't store per-user state there.
- Subrequest fan-out capped (50 free / 1000 paid). Cap any `Promise.all` over a request-derived array.
- 10 ms CPU free / 30 s paid. Synchronous work over user-controlled regex / huge JSON parse is a DoS vector.
- Wrap external `fetch` in try/catch — never echo `err.stack` to clients.

## Compatibility flags

| Flag | Use |
|---|---|
| `nodejs_compat` | Node API polyfills. Required for `pg`, `mysql2` |
| `nodejs_als` | `AsyncLocalStorage` for request-scoped context |
| `streams_enable_constructors` / `transformstream_enable_standard_constructor` | strict Streams API |

https://developers.cloudflare.com/workers/configuration/compatibility-flags/

## Auth patterns

- Bearer JWT: validate via `jose`; signing key as Worker secret.
- Cookie session: signed cookies via `hono/cookie`.
- Cloudflare Access: read `Cf-Access-Jwt-Assertion`, verify against team JWKS.
- API key: HMAC + constant-time compare; rotate via `wrangler secret put`.

## Database access

| DB | Pattern |
|---|---|
| D1 | `env.DB.prepare(sql).bind(...).all()` |
| External Postgres / MySQL | Hyperdrive binding |
| MongoDB Atlas | Data API or `node-mongodb-native` over TCP sockets |
| Redis | `ioredis` over TCP sockets, or Upstash HTTP |

Always parameterize.

## Headers

`withSecurityHeaders` helper, or Hono `secureHeaders` (`hono.md`), or set them at edge via Transform Rules.

## Skill targets

- `compatibility_date` < 6 months: WARN if older.
- `workers_dev = false` in prod: FAIL otherwise.
- `keep_vars = false`: WARN if missing.
- High-entropy values in `[vars]`: FAIL.
- `[observability.logs]` configured: WARN if missing.
- Try/catch around external fetches: WARN if absent.
- Subrequest count caps in code: INFO.
