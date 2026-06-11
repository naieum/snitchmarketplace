# Next.js on Cloudflare

Verdict + caveats: `fit-matrix nextjs`. Framework docs: `stack-docs nextjs`.

## Cloudflare integration

| Adapter | Notes |
|---|---|
| `@cloudflare/next-on-pages` | official, edge runtime focus, most mature |
| `@opennextjs/cloudflare` (OpenNext) | broader Node-compat, deploys to Workers |
| `output: 'export'` | pure static; loses ISR, on-demand revalidate, server actions, route handlers |

Skill detection parses `next.config.{js,ts,mjs}` for `output`, `experimental.*`, runtime annotations.

## Cloudflare-specific

- Every route file: `export const runtime = "edge"` (omitting it forces Node runtime + `nodejs_compat`).
- ISR / `revalidatePath` / `revalidateTag` require a KV binding for the incremental cache. Without it, calls no-op. FAIL if `revalidate` is used and no KV bound.
- `next/image`: needs `unoptimized: true`, the Cloudflare Images binding, or a custom loader. https://developers.cloudflare.com/images/transform-images/integrate-with-frameworks/
- `productionBrowserSourceMaps: false` in prod.

## Secrets

- Server env via Pages: `wrangler pages secret put NAME --project-name=...`
- `NEXT_PUBLIC_*` ships to client bundle. FAIL on `NEXT_PUBLIC_.*(KEY|SECRET|TOKEN)`.

## CSP

Production overlay: `templates/csp-stack-overlays.json` `nextjs.prod`. Nonce-based CSP requires middleware injecting `'nonce-${nonce}'` per request and reading via `headers().get("x-nonce")`. Dev needs `'unsafe-eval'` for HMR — never ship dev CSP to prod.

https://nextjs.org/docs/app/building-your-application/configuring/content-security-policy

## Server Actions

Each is a hashed POST endpoint. Treat as API: validate body with zod, rate-limit via Workers Rate Limiting binding in `middleware.ts`, verify same-origin `Origin` header.

## Skill targets

- `runtime = "edge"` declared on routes: WARN if not.
- KV binding when `revalidate` is used: FAIL.
- `NEXT_PUBLIC_*` secret-shaped values: FAIL.
- CSP nonce middleware when CSP is set: WARN.
- Rate limit on auth/payment server actions: WARN.
- `productionBrowserSourceMaps` truthy in prod: WARN.
