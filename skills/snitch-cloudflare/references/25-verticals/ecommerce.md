# Vertical: E-commerce

Detection: `stripe`, `@stripe/*`, `@shopify/*`, `commercetools`, `medusa`, cart routes (`/cart`, `/checkout`, `/api/cart`), webhook routes.

E-commerce sites are Magecart targets. CF defenses: stricter CSP on payment pages, Page Shield for third-party script governance, cache rules tuned for cart/checkout.

## Cloudflare overlay

- Strict CSP on payment pages — merge `templates/csp-stack-overlays.json` `stripe-elements` overlay (adds `https://js.stripe.com`, `https://hooks.stripe.com`, `https://api.stripe.com`). Stripe guide: https://stripe.com/docs/security/guide#content-security-policy. Per-provider tables (Shopify, BigCommerce, Adyen) in `16-page-shield-supply-chain.md`.
- Page Shield strongly recommended (Pro+ minimum, Business preferred): script monitor catches CDN compromise; connection monitor (Biz+) catches active skimming exfil; cookie monitor (Biz+) flags new cookies. https://developers.cloudflare.com/page-shield/
- Cache bypass on cart/checkout/auth:

  ```
  starts_with(http.request.uri.path, "/cart") or
  starts_with(http.request.uri.path, "/checkout") or
  starts_with(http.request.uri.path, "/api/cart") or
  http.cookie contains "shopify_session" or http.cookie contains "session_id"
  → Cache eligibility: bypass
  ```

- Rate-limit auth + checkout: managed_challenge `/login` POST; `/api/discount` (brute force); `/api/checkout` per IP; `/products/*` per IP for inventory scrapers.
- Webhook signatures verified (`stripe.webhooks.constructEvent` Node / `Stripe::Webhook.construct_event` Ruby). Webhook routes on dedicated paths, cache-bypassed, rate-limited. FAIL if a handler skips signature validation.
- Inventory drops: Turnstile on `/checkout`; per-IP reservation locks via Durable Objects.
- PCI-aware logging: no PAN/CVV in logs. No `sk_live_*` Stripe keys in client bundle. Page Shield log mode metadata-only on `/checkout`.

## Plan recommendation

Pro ($25/mo) minimum for Page Shield script monitor. Business ($250/mo) if checkout traffic is significant.

## Skill checklist

- [ ] Strict CSP on `/checkout` (Stripe overlay merged).
- [ ] Page Shield enabled (Pro+).
- [ ] Cache bypass on cart/checkout/auth.
- [ ] Webhook signature validation in code.
- [ ] PCI-aware logging (no PAN/CVV).
- [ ] Rate limit on auth + checkout + discount.
- [ ] No `sk_live_*` in client bundle.
- [ ] Turnstile on checkout for inventory drops.

Sources: https://stripe.com/docs/security/guide · https://developers.cloudflare.com/page-shield/
