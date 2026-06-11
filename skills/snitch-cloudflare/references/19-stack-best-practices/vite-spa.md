# Vite SPA on Cloudflare Pages

Verdict + caveats: `fit-matrix vite-spa`. Framework docs: `stack-docs vite-spa`.

For React / Vue / Solid / Preact SPAs built with Vite. Output → `dist/` → Pages.

## Cloudflare-specific

- SPA routing fallback in `_redirects`:

  ```
  /*  /index.html  200
  ```

  Status 200 = rewrite. 301/302 would loop. WARN if missing (404s on deep links).
- `_headers` in `public/` carries the security set. FAIL if missing — see `05-security-headers.md`.
- `import.meta.env.VITE_*` ships to the client bundle. FAIL on `VITE_.*(KEY|SECRET|TOKEN|PRIVATE)`.
- `build.sourcemap: false` (or `'hidden'`) for prod.
- Token-in-localStorage is XSS-readable. Prefer HttpOnly + Secure + SameSite=Lax cookies issued by your backend; CORS `origin` must be explicit (not `*`) when credentials are sent.

## CSP

Static SPA → strict CSP achievable. Vite emits hashed scripts; baseline `'self'` works. If you embed Stripe / Turnstile / GTM, merge the relevant overlay from `templates/csp-stack-overlays.json` (`stripe-elements`, `cloudflare-turnstile`).

## Pages Functions backend

If `functions/` exists, evaluated as Workers — same review as `workers-native.md`.

## Skill targets

- `_headers` with security set: FAIL if missing.
- `_redirects` SPA fallback: WARN if missing.
- `VITE_*` secret-shaped: FAIL.
- `build.sourcemap` exposed in prod: WARN.
- localStorage JWT pattern: WARN — recommend cookie-based auth.
