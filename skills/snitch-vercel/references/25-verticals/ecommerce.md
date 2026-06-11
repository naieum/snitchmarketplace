# E-commerce on Vercel

Common stack: Next.js + Stripe + Vercel Postgres (or external) + Vercel Blob (or S3) for product images.

## Hardening checklist

| Area | Action |
|---|---|
| Stripe webhooks | Verify `Stripe-Signature` in the route handler — public POST endpoint accepting payment events is a forgery target |
| Cart sessions | Server-side, signed cookies. Don't trust client-supplied prices, quantities, coupons |
| Inventory | Server-validated. Browser cart is advisory only |
| CSP overlay | Stripe Elements: `script-src https://js.stripe.com`, `frame-src https://js.stripe.com`, `connect-src https://api.stripe.com` |
| Rate-limit | `/api/cart/*`, `/api/checkout/*`, `/api/coupons/validate` at edge middleware. Coupon brute force is real |
| Apple/Google Pay | Domain verification files at apex (e.g., `.well-known/apple-developer-merchantid-domain-association`) |
| PCI | Tokenize via Stripe Elements → out of PCI scope. Don't accept card numbers directly |
| Order emails | Queue them; don't block checkout response on email send |

## Deployment protection

| Env | Setting |
|---|---|
| Production | Open |
| Preview | Vercel Authentication — keep test runs out of drive-by traffic |

## Cost watchlist

- Image Optimization on a 10k-SKU catalog blows the included quota.
- Per-page-view function cost dominates if catalog is fully SSR; use ISR with `revalidate: 60 * 60`.

## References

- https://stripe.com/docs/webhooks/signatures
- https://vercel.com/templates/next.js/nextjs-commerce
