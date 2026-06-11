# Nuxt 3 on Cloudflare

Verdict + caveats: `fit-matrix nuxt`. Framework docs: `stack-docs nuxt`.

## Cloudflare integration

- `nitro.preset: "cloudflare-pages"` (Pages) or `"cloudflare"` (Workers).
- Bindings: `event.context.cloudflare.env` in server routes.
- FAIL if a non-Cloudflare Nitro preset is set on a CF deploy.

https://developers.cloudflare.com/pages/framework-guides/deploy-a-nuxt-site/

## Cloudflare-specific

- `runtimeConfig.public.*` ships to the client. FAIL on secret-shaped `public.*`. Server-only secrets in `runtimeConfig.<key>`.
- Set runtime secrets with `wrangler pages secret put NAME --project-name=...`. Nuxt picks them up via `NUXT_<KEY>` env mapping.
- `nuxt-auth-utils` requires `NUXT_SESSION_PASSWORD` (32+ chars) — Worker secret.
- `server/middleware/*` runs on every request; slow middleware = whole-site latency.

## CSP

Use `nuxt-security` module — covers CSP, HSTS, CSRF, rate-limit helpers, request size limits in one config. Stack overlay (`csp-stack-overlays.json` `nuxt`) keeps `'unsafe-inline'` on script-src for Nitro hydration; tighten via Nitro nonce hook. https://nuxt-security.vercel.app/

## Skill targets

- `nitro.preset` is `cloudflare-pages` or `cloudflare`: FAIL otherwise on CF.
- `nuxt-security` configured: WARN if missing.
- `runtimeConfig.public.*` secret-shaped: FAIL.
- Server route input validation (`readValidatedBody` + zod): WARN if absent on POST.
- Session cookie config sane (secure/httpOnly/sameSite): WARN otherwise.
