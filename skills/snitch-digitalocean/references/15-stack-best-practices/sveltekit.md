# SvelteKit on DigitalOcean

Verdict: `fit-matrix sveltekit`. Docs: `stack-docs sveltekit`.

## Landing

| Adapter | Path |
|---|---|
| `@sveltejs/adapter-node` | App Platform |
| `@sveltejs/adapter-static` | Spaces + CDN |
| Docker | DOKS / Droplet |

## Hardening

- `$env/static/private` for build-time secrets, `$env/dynamic/private` for runtime — never `$env/static/public` for sensitive values.
- CSP via `handle` hook in `hooks.server.ts`.
- Form actions are POST-heavy → rate-limit via Redis-backed middleware or Cloudflare in front.
- Session cookies: `httpOnly`, `secure`, `sameSite: 'lax'`.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `$env/static/public` containing tokens |
| 🟡 WARN | No `health_check` in `app.yaml` |
| 🟡 WARN | Adapter-static deployed to public-read Spaces without CDN |
