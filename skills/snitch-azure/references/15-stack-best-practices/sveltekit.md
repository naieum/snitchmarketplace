# SvelteKit on Azure

Verdict + caveats: `fit-matrix sveltekit`. Docs: `stack-docs sveltekit`.

## Landing

- **Static Web Apps** — `@sveltejs/adapter-static` for full-static. SWA Hybrid with `@sveltejs/adapter-node` for SSR (preview-ish).
- **App Service Linux Node 20** — canonical for SSR with `@sveltejs/adapter-node`.
- **Container Apps** — Docker.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- Form actions are POST-heavy — Front Door / App Gateway WAF custom rule rate-limits `/login`, `/signup`, etc.
- Hooks: `handle` is the place for security headers (`response.headers.set('Strict-Transport-Security', ...)`).

## Skill targets

Same App Service hardening as Next.js. Plus:

| Finding | Severity |
|---|---|
| `kit.csp` not set in `svelte.config.js` (when strict CSP desired) | WARN |
