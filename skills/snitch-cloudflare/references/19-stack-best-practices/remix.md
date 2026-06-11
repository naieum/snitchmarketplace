# Remix on Cloudflare

Verdict + caveats: `fit-matrix remix`. Framework docs: `stack-docs remix`.

## Cloudflare integration

- New: Vite + `@remix-run/dev` `vitePlugin` + `cloudflareDevProxyVitePlugin`.
- Older: `@remix-run/cloudflare-pages`.
- Bindings: `context.cloudflare.env` (type via `wrangler types` → `worker-configuration.d.ts`).
- FAIL if a non-Cloudflare adapter is configured for a CF deploy.

https://developers.cloudflare.com/pages/framework-guides/deploy-a-remix-site/

## Cloudflare-specific

- Loaders/actions run on the edge by default — long-running side effects must move to Workers Queues or a Durable Object.
- `createCookieSessionStorage` cookie config: `httpOnly: true`, `secure: true`, `sameSite: "lax"`, `secrets: [env.SESSION_SECRET]`. FAIL if any flag missing or `secrets` is a literal.
- Set `SESSION_SECRET` with `wrangler pages secret put SESSION_SECRET --project-name=...`.
- Validate `?next=` / `?redirectTo=` against a same-origin allowlist (open-redirect class).

## CSP

No first-class CSP; set headers in `entry.server.tsx`. Remix overlay (`csp-stack-overlays.json` `remix`) keeps `'unsafe-inline'` on script-src for hydration. For nonces: generate per-request, attach to `context.cspNonce`, pass to `<Scripts nonce={...}>` and `<ScrollRestoration nonce={...}>`. https://remix.run/docs/en/main/guides/csp

## Skill targets

- Cloudflare adapter (Vite plugin or `@remix-run/cloudflare-pages`): FAIL if other deploy target.
- Session cookie flags `httpOnly` + `secure` + `sameSite`: FAIL if missing.
- `secrets` array sourced from env, not literal: FAIL otherwise.
- CSRF middleware (`remix-utils/csrf`) on actions: WARN if missing.
- ErrorBoundary not rendering `error.stack` in prod: WARN.
