# Next.js on DigitalOcean

Verdict: `fit-matrix nextjs`. Docs: `stack-docs nextjs`.

## Landing options

| Option | When |
|---|---|
| App Platform (Node buildpack) | Easiest; auto-detected from `package.json` |
| DOKS (Docker image) | Multi-service mesh |
| Droplet + Docker / PM2 | Full control |
| Static export (`output: 'export'`) | Spaces + CDN |

## Hardening

- `type: SECRET` for any env containing tokens / DB URLs / API keys. Plain envs ship in build artifact.
- `NODE_ENV=production` at runtime.
- `productionBrowserSourceMaps: false` in `next.config.js`.
- CSP via `middleware.ts` — App Platform doesn't add headers.
- Rate-limit auth routes via middleware + Managed Redis.
- ISR / `revalidate*`: data source must be reachable from the App Platform region.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `NEXT_PUBLIC_*` containing secrets |
| 🟡 WARN | Missing `health_check` on the Next.js service |
| 🟡 WARN | Single instance for prod |
| 🟡 WARN | No CSP middleware |
