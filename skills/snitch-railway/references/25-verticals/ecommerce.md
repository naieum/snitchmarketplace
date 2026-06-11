# E-commerce on Railway

Common shape: Next.js / Rails / Laravel storefront + Postgres + Redis + Stripe + S3-compatible asset bucket.

## Architecture

| Component | Where |
|---|---|
| Storefront (Next.js / Rails) | Railway service, numReplicas ≥ 2, sleep off |
| Background jobs (Sidekiq / queue worker) | Railway service, separate from web |
| Postgres | Railway add-on |
| Redis (sessions / cache / queues) | Railway add-on |
| Asset bucket (R2/S3) | external — Railway volumes won't scale across replicas |
| Search (Meilisearch / Typesense / Elastic) | Railway service or external managed |
| Email (Postmark / SendGrid) | external |
| CDN | Cloudflare/Fastly in front of Railway custom domain |

## Security must-haves

- HSTS preloaded on apex domain.
- Rate-limit `POST /login`, `/signup`, `/reset-password`, `/api/checkout`.
- CSRF tokens on every form (Rails/Next.js middleware).
- Signed Stripe webhooks (`STRIPE_WEBHOOK_SECRET` as shared variable).
- Audit log all admin actions to a separate, append-only store.
- `pg_dump` of orders table at least daily to R2/S3.

## Cost shape

- ~$30–80/mo for small storefront (1 web + 1 worker + Postgres + Redis).
- Bandwidth scales with product images — put a CDN in front and serve images from the bucket directly.

## Migration from Shopify / WooCommerce

If migrating from a hosted commerce stack, Railway path is "rebuild on a code-first stack". Don't lift-and-shift Shopify plugins.
