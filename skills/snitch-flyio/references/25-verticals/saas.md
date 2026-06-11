# SaaS on Fly.io

Multi-tenant B2B SaaS is a strong fit. Long-lived processes for WebSockets / real-time, low-latency same-region Postgres, multi-region for global users.

## Architecture

| Component | Fly primitive |
|---|---|
| Web app | App + machines, multi-region. |
| API | Same app or separate; both behind anycast IPs. |
| WebSockets / real-time | Phoenix + Channels OR Node + ws + Redis pub/sub. |
| Auth | NextAuth / Clerk / WorkOS / Devise / Phoenix. |
| Tenant DB | Single Postgres + `tenant_id` rows OR per-tenant schemas OR per-tenant DBs. |
| Background jobs | Sidekiq / Oban / Celery as separate process_group. |
| File uploads | Tigris with per-tenant prefixes. |
| Email | Resend / Postmark / SES. |
| Search | Postgres FTS or self-hosted Meilisearch. |
| Notifications | Knock / Novu via API. |

## Tenant isolation

| Pattern | Tradeoff |
|---|---|
| Row-level (`tenant_id` everywhere) | Easy. Works for most B2B SaaS up to ~100k tenants. |
| Schema-per-tenant | Better isolation; harder migrations. |
| DB-per-tenant | Strong isolation; expensive operationally. |

Most pick row-level. Postgres RLS auto-filters every query by `current_setting('app.tenant_id')`.

## Critical hardening

- [ ] Authn rate limit on `/login`, `/signup`, `/forgot-password`.
- [ ] Authz: every endpoint checks tenant ownership. Avoid raw "by ID" lookups.
- [ ] Webhook URLs per-tenant: HMAC-signed; verify on receipt.
- [ ] Per-tenant rate limits.
- [ ] Tenant data export / deletion tooling (GDPR + churn).
- [ ] Audit log per tenant — every config change, every admin action.

## Connection pooling

Many machines × Postgres connections = quick limits.

| Option | When |
|---|---|
| PgBouncer (Fly app, transaction-pooling mode) | Standard. Watch prepared-statement gotchas. |
| Hyperdrive / Supabase Pooler | Cross-cloud poolers. |
| App-level pools, careful sizing | `(machines × pool_size) ≤ pg.max_connections × 0.8`. |

## Real-time

| Stack | Approach |
|---|---|
| Phoenix Channels | Redis adapter for fanout. |
| Action Cable | Redis. |
| Socket.io / ws | Redis pub/sub. |

`min_machines_running >= 1` per region — keeps WebSockets warm.

## Multi-region writes

Hard. Most pick ONE write region and route via `fly-replay` from edge. Reads from regional replicas. For true multi-region writes: CRDTs (e.g., ElectricSQL) or accept eventual consistency.

## Compliance

| Standard | Approach |
|---|---|
| SOC 2 | Audit log + change management + access reviews. Fly's audit log + your app log. |
| HIPAA | Enterprise tier + signed BAA. |
| GDPR | Region selection for data residency. Per-tenant region overrides for EU. |

## Common mistakes

| Mistake | Cost |
|---|---|
| Single Postgres connection per machine | Idle waste; use pool. |
| Forgetting tenant filter on a query | Cross-tenant data leak. Use RLS. |
| Hardcoding webhook URLs | Tenant changes break. |
| Sharing Redis namespace across tenants | Key collision; use prefixes. |
| No tenant rate limit | Noisy customer takes down everyone. |
