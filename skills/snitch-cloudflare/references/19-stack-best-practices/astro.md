# Astro on Cloudflare

Verdict + caveats: `fit-matrix astro`. Framework docs: `stack-docs astro`.

## Cloudflare integration

- `output: 'static'` (default) → Pages, no Functions.
- `output: 'server'` / `'hybrid'` → `@astrojs/cloudflare` adapter, mode `directory` (one function per route, faster cold start) or `advanced` (single function, smaller).
- Bindings: `Astro.locals.runtime.env` (typed via `App.Locals extends Runtime<Env>` in `src/env.d.ts`).

https://developers.cloudflare.com/pages/framework-guides/deploy-an-astro-site/

## Cloudflare-specific

- Static deploy: ship `_headers` in `public/` with the security set. Pages serves it as-is.
- Astro DB is libSQL, not D1 — not interchangeable.
- `astro:assets` remote allowlist must be explicit; otherwise the build proxy can fetch arbitrary URLs.

## CSP

Astro emits scoped inline `<style>` and inline hydration `<script>`. Baseline overlay (`csp-stack-overlays.json` `astro`) covers styles via `'unsafe-inline'` on `style-src`. View Transitions adds inline scripts → strict CSP needs a nonce setup. https://docs.astro.build/en/guides/security/

## Secrets

- `import.meta.env.PUBLIC_*` ships to client. FAIL on `PUBLIC_.*(KEY|SECRET|TOKEN)`.
- Runtime env via `Astro.locals.runtime.env`. Set with `wrangler pages secret put NAME --project-name=...`.

## Skill targets

- `output` set explicitly: WARN if missing.
- `@astrojs/cloudflare` adapter when `output != static`: FAIL otherwise.
- `_headers` with security set on static deploy: FAIL if missing.
- `import.meta.env.PUBLIC_*` secret-shaped: FAIL.
- `astro:assets` remote allowlist closed: WARN if open.
- Origin reachable only from CF (server adapter case): FAIL otherwise.
