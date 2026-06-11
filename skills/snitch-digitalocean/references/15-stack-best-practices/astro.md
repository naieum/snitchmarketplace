# Astro on DigitalOcean

Verdict: `fit-matrix astro`. Docs: `stack-docs astro`.

## Landing

| Mode | Path |
|---|---|
| Static (`output: 'static'`) | Spaces + CDN |
| SSR (`output: 'server'`) | App Platform with Node adapter |
| Hybrid | App Platform; static where possible, SSR the rest |

## Hardening

- `Astro.cookies.set(...)` with `secure: true`, `httpOnly: true`, `sameSite: 'lax'`.
- CSP and security headers via `astro.config.mjs` middleware.
- Static deploys: CDN endpoint with custom domain + Let's Encrypt.
- SSR: `type: SECRET` envs in App Platform.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | SSR build with plain `type: GENERAL` envs that look secret-shaped |
| 🟡 WARN | Static deploy to Spaces with public-read but no CDN |
| INFO | `@astrojs/sharp` requires `sharp` install on Droplets (fine on App Platform) |
