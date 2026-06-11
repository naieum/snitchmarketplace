# Vercel storage: KV / Postgres / Blob / Edge Config

External services with first-party integration:

| Product | Backed by | Best for | Caveats |
|---|---|---|---|
| Vercel KV | Upstash Redis | Sessions, rate-limit counters, cache | Eventually consistent across regions; not for atomic counters |
| Vercel Postgres | Neon | OLTP, relational | Pool via Neon's serverless driver |
| Vercel Blob | Vercel object store | User uploads, generated assets | Not S3-feature-parity; no lifecycle, no Glacier |
| Edge Config | Read-mostly KV at edge | Feature flags, A/B config | Bytes capped (8KB-512KB by plan); writes via API only |

## Vercel KV

```ts
import { kv } from "@vercel/kv";
await kv.set("user:123", { name: "Alice" });
const user = await kv.get("user:123");
```

- Region pinned; replicates eventually. Cross-region rate-limit windows can briefly under-count.
- `KV_URL` auto-injected on create+link. 256-MB plan limits scale up; Pro+ unlocks larger.

## Vercel Postgres

```ts
import { sql } from "@vercel/postgres";
const { rows } = await sql`SELECT id FROM users WHERE email = ${email}`;
```

- Auto-injects `POSTGRES_URL`, `POSTGRES_PRISMA_URL`, `POSTGRES_URL_NON_POOLING`, ...
- `POSTGRES_PRISMA_URL` for Prisma; `POSTGRES_URL` (pooled) for serverless drivers.
- Connection pool is separate from Postgres connection limit; don't paste a non-pooled URL into a high-concurrency function.

## Vercel Blob

```ts
import { put } from "@vercel/blob";
const { url } = await put("avatar.png", file, { access: "public" });
```

- `BLOB_READ_WRITE_TOKEN` for server; client-side uses signed upload URLs.
- Public blobs are world-readable. Private requires presigned URLs.
- Pricing: storage + bandwidth metered per project.

## Edge Config

```ts
import { get } from "@vercel/edge-config";
const flag = await get("feature_x");
```

- ~15ms read at the edge.
- Writes via REST API only. Don't write per request.
- Read tokens are per-config: anyone with the read token fetches the whole config. Treat tokens as secrets.

## Connection pooling for serverless

Cold-start a function → open new DB connection → bottleneck. Solutions:

| Solution | When |
|---|---|
| Vercel Postgres (Neon serverless driver) | Native, handles pooling |
| PgBouncer transaction-pooling | In front of any Postgres |
| Prisma Accelerate | Wraps any Postgres |
| Drizzle + neon-serverless | HTTP, no TCP pool |

Avoid `pg.Pool` or raw TCP drivers in serverless without a pooler — connection storms bring DBs down at scale.

## Env-var injection patterns

When you "Connect Store" in the dashboard, Vercel injects per environment:

| Store | Vars |
|---|---|
| KV | `KV_URL`, `KV_REST_API_URL`, `KV_REST_API_TOKEN`, `KV_REST_API_READ_ONLY_TOKEN` |
| Postgres | `POSTGRES_URL`, `POSTGRES_PRISMA_URL`, `POSTGRES_URL_NON_POOLING`, `POSTGRES_USER`, ... |
| Blob | `BLOB_READ_WRITE_TOKEN` |
| Edge Config | `EDGE_CONFIG` |

The skill flags these as Sensitive on detection. Don't override with custom names — the SDK looks them up by exact name.

## Region

Storage is regional. Pin function region close to storage:

- KV in iad1 + function in iad1 → ~1ms RTT.
- KV in iad1 + function in fra1 → ~80ms RTT per call.

`state storage` lists primary + read regions per store.

## References

- https://vercel.com/docs/storage
- https://vercel.com/docs/storage/vercel-kv
- https://vercel.com/docs/storage/vercel-postgres
- https://vercel.com/docs/storage/vercel-blob
- https://vercel.com/docs/storage/edge-config
