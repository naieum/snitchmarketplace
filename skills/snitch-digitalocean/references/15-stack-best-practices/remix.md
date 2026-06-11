# Remix on DigitalOcean

Verdict: `fit-matrix remix`. Docs: `stack-docs remix`.

## Landing

App Platform with Express adapter (`remix-serve` or `@remix-run/express`) / Docker on Droplet / DOKS.

## Hardening

- Loaders / actions are server-side: every loader must auth-check before returning data.
- `getSession()` with database / Redis-backed store, not in-memory.
- Session cookies: `httpOnly: true`, `secure: true`.
- Rate-limit POST actions via Redis-backed middleware.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | Memory-only session store with >1 instance |
| 🔴 FAIL | Missing CSRF token on form actions |
| 🟡 WARN | No `helmet`-equivalent on Express adapter |
