# SvelteKit on Cloudflare

Verdict + caveats: `fit-matrix sveltekit`. Framework docs: `stack-docs sveltekit`.

## Cloudflare integration

- `@sveltejs/adapter-cloudflare` for Pages and Workers. FAIL if a different adapter on CF.
- Bindings: `event.platform.env` typed in `src/app.d.ts` (`App.Platform.env`).

https://developers.cloudflare.com/pages/framework-guides/deploy-a-svelte-kit-site/

## Cloudflare-specific

- Form actions are POST-heavy — confirm `rate-limit-rules.starter.json` covers `/`, `/login`, etc.
- `kit.csrf.checkOrigin` must remain `true` (default). Disabling removes SvelteKit's same-origin POST guard.
- Server-only data must not be returned from `+page.ts` (universal) — use `+page.server.ts`.

## CSP — first-class

SvelteKit handles CSP itself; configure in `svelte.config.js` rather than `_headers` / Transform Rules. `csp.mode: "auto"` injects nonces or hashes per build, removing `'unsafe-inline'` on script-src.

```js
csp: { mode: "auto", directives: { "default-src": ["self"], "script-src": ["self", "strict-dynamic"], "frame-ancestors": ["none"] } }
```

Stack overlay (`csp-stack-overlays.json` `sveltekit`) marks the hydration `'unsafe-inline'` fallback. https://kit.svelte.dev/docs/configuration#csp

## Secrets

- `PUBLIC_*` env vars ship to the client. FAIL on secret-shaped `PUBLIC_*`.
- Runtime env via `platform.env.<NAME>`. Set with `wrangler pages secret put NAME --project-name=...`.

## Skill targets

- `@sveltejs/adapter-cloudflare` configured: FAIL if other adapter on CF.
- `csp.mode: "auto"` set: WARN if missing.
- `kit.csrf.checkOrigin` not disabled: FAIL if disabled.
- `App.Platform` typed in `app.d.ts`: WARN if missing.
- `PUBLIC_*` secret-shaped: FAIL.
