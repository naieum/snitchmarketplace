# 07 — Storage: R2, KV, D1, Hyperdrive, Durable Objects

## R2 (S3-compatible, zero egress)

Tokens: scope to specific buckets. Use Read or Read+Write — never "Admin Read & Write" for app code.
- API token (`Account.Workers R2 Storage:Edit`) — management.
- S3-compatible access keys (per-bucket) — for `aws s3` / `rclone` / SDKs.

Source: https://developers.cloudflare.com/r2/api/s3/tokens/

CORS: per-bucket. `AllowedOrigins: ["*"]` on a write-capable bucket = FAIL. https://developers.cloudflare.com/r2/buckets/cors/

Presigned URLs: prefer over public buckets for browser uploads/downloads. TTL: 5–15 min uploads, hours max for downloads. Skill flags `expiresIn > 24h`. https://developers.cloudflare.com/r2/api/s3/presigned-urls/

Public buckets: anyone can GET any known key. Use private + presigned by default. Public via custom domain is fine for static assets. https://developers.cloudflare.com/r2/buckets/public-buckets/

Lifecycle / Object Lock: lifecycle = auto-delete after N days; Object Lock = WORM. https://developers.cloudflare.com/r2/buckets/object-lifecycles/

## KV — eventually consistent (~60s)

Use for: feature flags, sessions tolerating ~1min stale reads, infrequent config.

Don't use for:
- Secrets — use `wrangler secret put`. Skill flags high-entropy or `*key*|*token*|*secret*` names.
- Real-time auth tokens needing instant invalidation → Durable Objects.
- Hot keys (writes 1/sec/key).
- Atomic counters → Durable Objects.

Limits: 25 MiB value, 512-byte key, 1000 keys/list, 1/s write per key.

Sources: https://developers.cloudflare.com/kv/api/ , https://developers.cloudflare.com/kv/concepts/how-kv-works/

## D1 — SQLite at the edge

D1 is SQLite, not MySQL, not Postgres.

- Dialect: `AUTOINCREMENT`, no `ENUM`, JSON via `json1`, no stored procs, FK off by default.
- Single-writer; reads scale via edge replicas.
- FTS5 for full-text.

Always parameterize. Skill greps for raw concat in `prepare(...)` → SQL-injection FAIL.

```ts
await env.DB.prepare("SELECT * FROM users WHERE id = ?").bind(userId).all();
```

Pin region via `wrangler d1 create my-db --location=weur`.

Time Travel: 30-day point-in-time restore. Recommend periodic `wrangler d1 export` to R2.

Sources: https://developers.cloudflare.com/d1/build-with-d1/d1-client-api/ , https://developers.cloudflare.com/d1/configuration/data-location/ , https://developers.cloudflare.com/d1/reference/time-travel/

D1 → MySQL/Postgres translation: don't. Hyperdrive in front of the existing DB instead.

## Hyperdrive

Connection pooling + query caching for external Postgres/MySQL. Free with Workers Paid.

```sh
wrangler hyperdrive create my-db --connection-string="postgres://USER:PASS@host:5432/db"
```

Connection string is stored as a secret. Skill flags raw `postgres://` in `[vars]`.

```toml
[[hyperdrive]]
binding = "HYPERDRIVE"
id = "<hyperdrive-id>"
```

Caveats: helps reads (cached at edge), not transactions. Origin DB must accept Cloudflare egress IPs (allowlist or Tunnel + private network).

Source: https://developers.cloudflare.com/hyperdrive/

## Durable Objects

Single-threaded, globally-unique stateful actors. Use for: per-room collab/presence, atomic counters, WS sessions, coordinated rate limits, per-user state.

Storage (~1 MB recommended/object): `state.storage.put/get`, transactional. Alarms (`setAlarm(when)` + `async alarm()`) for TTL eviction / periodic cleanup.

Bills on requests + active duration + storage. Long-lived WS = whole-connection duration billing — see `23-cost-cliffs.md`. Hibernation API reduces idle cost.

Source: https://developers.cloudflare.com/durable-objects/

## API endpoints

See `11-api-cheatsheet.md`. Account-level: `/r2/buckets`, `/r2/buckets/{b}/cors`, `/storage/kv/namespaces`, `/d1/database`, `/hyperdrive/configs`.
