# 12 — Migration

`fit-matrix` reads `templates/migration-fit-matrix.json` (verdict + caveats per stack).

## Verdict legend

| Verdict | Meaning |
|---|---|
| `strong` | Cloudflare is the right home; ship today |
| `partial` | workable with caveats per dependency |
| `proxy-only` | don't replatform; orange-cloud DNS + WAF + Tunnel in front |
| `not-recommended` | pick a different stack or stay where you are |

## DB migration paths

### MySQL / Postgres

- Hyperdrive in front of existing DB — recommended. Connection string as Workers Secret. Works with Neon, Supabase, RDS, self-hosted, CockroachDB. pgBouncer transaction-pooling caveats apply.
- D1 = SQLite, full rewrite. Audit: `AUTO_INCREMENT` → `AUTOINCREMENT`, datetime types, `ENUM`, `JSON`/`JSONB` semantics, `ON DUPLICATE KEY UPDATE` → `ON CONFLICT`, FK cascades, triggers, stored procs, FTS5, charsets.

### MongoDB

- Keep MongoDB Atlas; Workers call Atlas Data API or driver over TCP sockets.
- DO + storage = rewrite, not a real Mongo replacement.

### Redis

- Workers TCP sockets to Redis (ioredis / redis 4) — works; connection setup latency per call.
- KV: eventually consistent ~60s, fine for sessions, NOT atomic counters.
- Durable Objects: right answer for atomic state.
- Upstash Redis HTTP: works from Workers, not Cloudflare-native.

Source: https://developers.cloudflare.com/workers/runtime-apis/tcp-sockets/

## Storage: S3 → R2

Pattern: dual-write window → switch reads → stop writes to S3 → archive S3.

```sh
rclone sync --transfers=20 --checkers=20 --fast-list \
  s3:my-bucket r2:my-bucket
```

Or `aws s3 sync s3://src s3://dst --endpoint-url=https://${ACCOUNT_ID}.r2.cloudflarestorage.com`.

For >1 TB use R2 Super Slurper (managed migration with progress tracking).

Egress savings = observed `aws-sdk` GET volume × AWS egress (~$0.09/GB to internet, varies). R2 egress = $0.

Source: https://developers.cloudflare.com/r2/data-migration/super-slurper/

## DNS cutover (4 steps)

1. **Lower TTL (T-48h)**: drop existing-provider TTL on records-to-cut to 120s. Wait one full TTL cycle. Verify with `dig +nostats +nocomments A example.com`.
2. **Add zone to Cloudflare (no traffic yet)**: add domain at `dash.cloudflare.com`. Audit imported records, mark public hostnames `proxied: true`. Pre-create WAF rules / SSL settings via skill. Confirm CF NS matches what you'll set at registrar.
3. **Switch nameservers at registrar**: traffic shifts within ~24h. Watch CF Analytics, origin logs (CF egress IPs), RUM.
4. **Validate, raise TTL**: after 24h with no regression, raise TTL to 3600+; activate DNSSEC + DS at registrar; enable Always Use HTTPS, HSTS starting `max-age=86400`; deploy WAF foreign-tech rule.

Rollback: switch NS back at registrar; wait one TTL cycle; monitor traffic returning to old origin. Worst case ~5 min for fast-reflecting registrars.

Source: https://developers.cloudflare.com/dns/zone-setups/full-setup/

## Output

Skill doesn't write inside the user's project. Migration plan goes to stdout (agent relays) plus a copy at `.state/migration-plan-<hash>-<ts>.md`. Provisioning via `fix <area>` after user confirms.

## "Be honest" enforcement

If verdict is `proxy-only` or `not-recommended`, the plan opens with that verdict and ends after the proxy alternative — no "but if you really want to..." footer.
