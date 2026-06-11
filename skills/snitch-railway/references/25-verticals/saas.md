# SaaS on Railway

Common shape: Next.js / Remix / Rails app + Postgres + Redis + Stripe billing + multi-tenant.

## Architecture

| Component | Where |
|---|---|
| App (web) | Railway, numReplicas ≥ 2 |
| Worker | Railway, separate service |
| Postgres | Railway add-on (or external Neon/RDS for HA) |
| Redis | Railway add-on |
| Auth (Clerk / WorkOS / homegrown) | external |
| Billing | Stripe |
| Email | Resend / Postmark / SendGrid |
| Search/analytics | external (Algolia / PostHog) |

## Security must-haves

- 2FA on all admin accounts.
- Tenant isolation in Postgres via row-level security (RLS) or per-tenant schemas.
- Per-tenant rate limits to prevent noisy-neighbor abuse.
- Webhook signature verification (Stripe, GitHub).
- Audit log persisted to a separate datastore.
- Customer data export endpoint (GDPR / CCPA).
- Soft-delete patterns + retention policy documented.

## Multi-environment hygiene

| Env | Settings |
|---|---|
| production | always-on, `numReplicas: 2+`, log drain to SIEM (Pro+) |
| staging | always-on optional, mirror production schema |
| preview | per-PR, sleep on, auto-delete on PR close |

## Backup strategy

`pg_dump` daily to R2/S3 with 30-day retention is the minimum. For compliance-heavy SaaS, layer logical replication to managed Postgres outside Railway.
