# 16 — Page Shield + Supply-Chain

CF's client-side security product. Inventories scripts, alerts on changes, monitors connections. CSP enforces; Page Shield is observability + alerts.

## Plan-tier matrix

| Feature | Free | Pro | Business | Enterprise |
|---|---|---|---|---|
| Script monitor | no | yes | yes | yes |
| Script-change alerts | no | yes | yes | yes |
| Connection monitor | no | no | yes | yes |
| CSP report-uri delivery | no | yes | yes | yes |
| Authorized-scripts enforcement | no | no | yes | yes |
| Cookie monitor | no | no | yes | yes |

Pro = entry; Business = enforcement.

Source: https://developers.cloudflare.com/page-shield/reference/availability/

## CSP rollout

Per `05-security-headers.md`: `Content-Security-Policy-Report-Only` (24h+ soak), then enforce. Pro+ Page Shield collects violations free.

Source: https://developers.cloudflare.com/page-shield/policies/csp-monitoring/

## Third-party script CSP allowlist

| Vendor | `script-src` | `connect-src` | `frame-src` |
|---|---|---|---|
| GA4 / GTM | `*.googletagmanager.com` | `*.google-analytics.com *.googletagmanager.com` | `*.googletagmanager.com` |
| Stripe | `https://js.stripe.com` | `https://api.stripe.com` | `https://js.stripe.com https://hooks.stripe.com` |
| Intercom | `https://widget.intercom.io https://js.intercomcdn.com` | `wss://*.intercom.io https://*.intercom.io` | — |
| Hotjar | `https://*.hotjar.com` | `https://*.hotjar.com wss://*.hotjar.com` | `https://*.hotjar.com` |
| HubSpot | `https://*.hubspot.com https://*.hs-scripts.com` | `https://*.hubspot.com` | — |
| Facebook Pixel | `https://connect.facebook.net` | `https://www.facebook.com` | — |
| CF Turnstile | `https://challenges.cloudflare.com` | `https://challenges.cloudflare.com` | `https://challenges.cloudflare.com` |
| CF Web Analytics | `https://static.cloudflareinsights.com` | `https://cloudflareinsights.com` | — |
| Sentry | `https://*.sentry.io` | `https://*.ingest.sentry.io` | — |
| YouTube embeds | `https://www.youtube.com` | `https://www.youtube.com` | `https://www.youtube.com https://www.youtube-nocookie.com` |
| Vimeo | `https://player.vimeo.com` | — | `https://player.vimeo.com` |

Sources: https://stripe.com/docs/security/guide ; https://developers.google.com/tag-platform/tag-manager/csp .

## Subresource Integrity (SRI)

`<script src="..." integrity="sha384-..." crossorigin="anonymous">`. Browser refuses on hash mismatch.

Limits: only static versioned assets; doesn't apply to dynamically-loaded scripts; Stripe / GTM don't support SRI — rely on Page Shield change alerts.

Source: https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity

## Magecart-aware patterns

Skimmer attacks target compromised JS on origin/CDN, third-party tags, ad scripts. Defenses by value:

1. Strict CSP on payment pages — `script-src 'self' https://js.stripe.com`, no `'unsafe-inline'`.
2. Page Shield script-change alerts (Pro+) — catches CDN swaps.
3. Iframe payment fields (Stripe Elements, Adyen iframe) — card data never enters DOM.
4. CORP/COEP/COOP on checkout.
5. Per-session token rotation + signed forms.

See `25-verticals/ecommerce.md`.

## Patterns Page Shield catches

- CDN compromise (file changes overnight) → hash mismatch alert.
- `document.write` injection → new script-source alert.
- DOM-XSS via vulnerable lib → version visibility for upgrade.
- Polyfill.io-style supply-chain → connection-destination alert (Biz+).
- Magecart skimmer (POSTed form data → attacker domain) → connection monitor (Biz+).

## API endpoints

```sh
GET  /zones/{id}/page_shield/policies
POST /zones/{id}/page_shield/policies
GET  /zones/{id}/page_shield/scripts
GET  /zones/{id}/page_shield/connections    # Biz+
```

Authorized-scripts policy body: `{expression, action, value, description}`. Source: https://developers.cloudflare.com/page-shield/

## Skill targets

- Pro+: Page Shield enabled on every zone with frontend (`script-monitor: true`).
- Pro+ + e-commerce: strict CSP on `/checkout/*`.
- Free: `[locked: pro+]` with one-line value statement.
- Always: print third-party CSP allowlist for the detected stack.
