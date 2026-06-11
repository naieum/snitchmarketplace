# Ecommerce

Detection: Stripe / Square / Adyen SDKs in deps, `cart` / `checkout` / `inventory` paths, PII fields, payment webhook endpoints.

## DigitalOcean overlay

- **PCI scope minimization**: never store card numbers. Use Stripe Elements / Checkout. Tokenize. Skill flags any column / env named `*card*number*`, `*cvv*`, `*pan*` as FAIL.
- **Webhook signing verification**: every payment webhook handler MUST verify the signature.
- **Idempotency keys** on order creation and payment intent endpoints.
- **Inventory locks**: DB-level `SELECT FOR UPDATE` during checkout. Race conditions = oversold.
- **Backups + PITR** on the Managed Postgres / MySQL holding orders.
- **WAF in front**: Cloudflare (DO has no L7 WAF) — protects checkout from credential stuffing / card testing.
- **Rate limit** on `/checkout`, `/api/auth/*`, `/api/coupon/redeem`.
- **CDN cache** purge on price/inventory updates.
- **Staging environment** for migrations — never run schema migrations against prod first.

## Skill checklist

- WAF in front (Cloudflare DNS proxied).
- Webhook signing verified.
- No card numbers in DB.
- Rate limit on auth + checkout.
- Backups + PITR on order DB.
- Idempotency keys on order creation.
- Spaces bucket holding receipts/invoices is private + signed-URL-only.
- Admin paths behind IP allowlist or SSO (Auth0 / WorkOS / Clerk).
