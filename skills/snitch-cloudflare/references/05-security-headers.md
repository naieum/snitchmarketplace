# 05 — Security Headers

Deploy via Transform Rules → Modify Response Header (`http_response_headers_transform`). Pages: `_headers`.

## Targets

| Header | Target |
|---|---|
| `Strict-Transport-Security` | HSTS toggle (see 02), not Transform Rule |
| `X-Content-Type-Options` | `nosniff` |
| `X-Frame-Options` | `DENY` (legacy fallback) |
| `Content-Security-Policy` `frame-ancestors` | `'none'` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | default-deny sensors (below) |
| `Cross-Origin-Opener-Policy` | `same-origin` |
| `Cross-Origin-Resource-Policy` | `same-origin` (HTML); `cross-origin` for public CDN |
| `Cross-Origin-Embedder-Policy` | `require-corp` — WARN, not auto-applied (breaks third-party embeds) |

Don't set HSTS in both the toggle and Transform Rule — toggle wins.

## CSP starter (`templates/csp-starter.txt`)

```
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';
img-src 'self' data: https:;
font-src 'self' data:;
connect-src 'self';
frame-ancestors 'none';
form-action 'self';
base-uri 'self';
object-src 'none';
upgrade-insecure-requests;
```

Always Report-Only first (24h soak with `report-uri`/`report-to`), then enforce. Pro+ + Page Shield collects violations free.

Per-stack overlays in `templates/csp-stack-overlays.json`. Highlights:

- Next.js prod App Router: `script-src 'self' 'nonce-<RUNTIME>'` if `experimental.cspNonce` on; else `'unsafe-inline'`. Dev needs `'unsafe-eval'` for HMR — never ship dev CSP to prod.
- Astro SSG: strict starter; `view-transitions` may need nonces.
- SvelteKit: nonce out-of-box (`svelte.config.js` `csp.directives`).
- Remix: nonce via `cspNonce` helper.
- WordPress: many themes need `'unsafe-inline'` — Page Shield > strict CSP here.
- Stripe: `frame-src https://js.stripe.com https://hooks.stripe.com; script-src https://js.stripe.com; connect-src https://api.stripe.com`.

Sources: https://developers.cloudflare.com/page-shield/policies/ , https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

## Permissions-Policy default

```
Permissions-Policy: accelerometer=(), autoplay=(), camera=(), display-capture=(), encrypted-media=(), fullscreen=(self), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), midi=(), payment=(), picture-in-picture=(), publickey-credentials-get=(), screen-wake-lock=(), sync-xhr=(self), usb=(), web-share=(), xr-spatial-tracking=()
```

Per-vertical:
- E-commerce w/ Apple Pay / Google Pay: `payment=(self https://pay.google.com https://*.apple.com)`.
- Video: `fullscreen=(self), picture-in-picture=(self)`.
- WebAuthn / Passkeys: `publickey-credentials-get=(self)`.

Source: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Permissions-Policy

## Cookie flags

Sensitive (`session|auth|token|jwt|sid|csrf|access`): `Secure` + `HttpOnly` (except CSRF) + `SameSite` (`Strict`/`Lax`/`None`+Secure). Path narrowest possible. Omit `Domain` for host-only. Explicit `Max-Age`/`Expires`. Prefer `__Host-` / `__Secure-` prefixes.

Missing flag on sensitive = FAIL. See `27-takeover-cookie-probe.md`.

Source: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies

## Pages `_headers` example

```
/*
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: <see above>
  Content-Security-Policy: <see above>
  Cross-Origin-Opener-Policy: same-origin

/api/*
  Content-Security-Policy: default-src 'none'
```

Source: https://developers.cloudflare.com/pages/configuration/headers/

## Validators

- Local header grade (the skill's `score`): A = all 6 headers present. securityheaders.com itself is now behind an anti-bot wall and can't be scraped.
- MDN HTTP Observatory A+: CSP without `'unsafe-inline'`/`'unsafe-eval'` + `frame-ancestors`.

See `20-validator-grading.md`. Source: https://developers.cloudflare.com/rules/transform/response-header-modification/
