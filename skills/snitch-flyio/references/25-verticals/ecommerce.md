# E-commerce on Fly.io

Strong fit when you need server-side rendering, payment routes, webhook receivers, long-lived process for connection pooling. Pair with Postgres + Redis + Tigris.

## Architecture

| Component | Fly primitive |
|---|---|
| Web app (Next/Rails/Phoenix) | App + machines, multi-region for low TTFB. |
| Sessions | Postgres-backed (rails) or Redis (Upstash-on-Fly). |
| Cart state | Postgres (durable) or Redis (fast, ephemeral OK). |
| Product images | Tigris (S3-compat) — Cloudflare in front for CDN. |
| Order DB | Managed Postgres with PITR. |
| Payments | Stripe / Braintree via secrets. |
| Search | Postgres FTS for small catalogs; Meilisearch (self-hosted) or Algolia for >100k SKUs. |
| Email | Resend / Postmark / Mailgun via API + secrets. |

## Critical hardening

- [ ] PCI scope: don't store PAN. Use Stripe Elements / Checkout. Confirm in code review.
- [ ] Idempotency keys on payment intents to survive retries.
- [ ] Webhook signature verification (HMAC) on every Stripe / PayPal handler.
- [ ] Rate limit `/checkout`, `/login`, `/signup` at the app layer (no Fly L7 WAF — consider Cloudflare in front).
- [ ] Inventory consistency: Postgres `SELECT FOR UPDATE` on stock during checkout.
- [ ] Order state machine in DB, not app memory.

## Multi-region pattern

| Layer | Strategy |
|---|---|
| Reads | Regional Postgres replicas. |
| Writes | Route to primary region (Fly-Replay header). |
| Cart state | Regional Redis (cheap; cart loss acceptable). |
| Order writes | Primary region. |

Example: primary `iad`, replica `fra`, replica `syd`. App machines colocated.

## Compliance

| Standard | Approach |
|---|---|
| PCI | Stripe / Braintree handle SAQ A scope. Don't accept raw cards. |
| GDPR | Customer data export / deletion tooling. Postgres in EU region for EU residency. |
| Sales tax | TaxJar / Stripe Tax / Avalara. Idempotent webhooks for rate updates. |

## Common mistakes

| Mistake | Cost |
|---|---|
| Treating checkout as fire-and-forget | Restart mid-checkout loses an order. Use queues + idempotency. |
| One Postgres for cart + orders + analytics | Analytics queries lock orders. Split or replica. |
| Storing card details for "future use" | PCI scope. Use Stripe SetupIntents. |
| No webhook idempotency | Duplicate orders / charges. |
| Public images served from Fly bandwidth | CDN (Cloudflare/Bunny) in front of Tigris. |
