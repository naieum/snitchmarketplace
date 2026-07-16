# Stack hardening: Node.js / Express

Loaded when stack detection (`references/smart-detection.md`) identifies an Express/Node backend
(`express` in `package.json`, `app.get/post`, `req`/`res` handlers). Use it to know *where the
sinks are* in this stack and *what the framework already protects* — so findings are precise and
framework auto-protections aren't flagged as bugs.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| String-built SQL into `db.query(...)` / `knex.raw` / `sequelize.query` | SQL injection | 01 |
| `child_process.exec`/`execSync` with interpolated input (shell) | command injection | 10 |
| `res.send`/`res.write` of unescaped user input in an HTML response | reflected XSS | 02 |
| `res.redirect(req.query.url)` | open redirect / SSRF | 05 |
| `fs`/`path.join(__dir, req.params.x)` without containment | path traversal | 29 |
| `eval` / `new Function` / `vm` on input | code execution | 10 |
| `JSON.parse`→deep-merge, `Object.assign` of req body, `lodash.merge` | prototype pollution | 62 |
| `yaml.load` (unsafe), `node-serialize`/`unserialize` | insecure deserialization | 65 |
| `new RegExp(userInput)` / catastrophic patterns | ReDoS | 61 |
| outbound `fetch`/`axios`/`http.get` to a constructed URL | SSRF / cloud-metadata | 05 / 64 |

## Framework auto-protections (do NOT flag these)

- Parameterized queries via `pg`/`mysql2` placeholders (`$1`,`?`), `knex` bindings, Prisma,
  Sequelize models → **not** SQLi. Only string-built queries are findings (01).
- Express does **not** auto-escape output (no default templating) — so `res.send(userHtml)` *is* a
  real XSS sink (02). Don't assume escaping that isn't there.
- `helmet` sets security headers (32); `express-rate-limit` covers rate limiting (07); `cors`
  middleware with an allowlist covers CORS (08); `csurf`/double-submit covers CSRF (47). If present
  and correctly configured, mark the related cat Pass-with-evidence.

## Hardening checklist (per finding, recommend the minimal fix)

- Parameterize every query; never build SQL by concatenation (01).
- Validate/normalize input at the boundary with `zod`/`joi` schemas (30); validation ≠ authZ.
- AuthZ middleware on every state-changing route — server trusts nothing from the client (28, 04).
- No shell string-building; use `execFile` with an arg array, never `exec` with interpolation (10).
- `helmet` for headers + a real CSP (32); CORS allowlist, never reflect `*` with credentials (08).
- Rate-limit auth + expensive routes (07); secure/HttpOnly/SameSite cookies; secrets from env (03).
- CSRF protection for cookie-authenticated state changes (47).

## Forbidden claims

- Flagging a parameterized/ORM query as SQLi (check the binding first — 01).
- Asserting XSS without quoting the unescaped sink + confirming the response is HTML (02).
- Calling headers/CORS/rate-limit "missing" when `helmet`/`cors`/`express-rate-limit` is configured
  — quote the config or its absence (Rule 1).

---

*Per-stack reference informed by codex-security's curated best-practices model; reimplemented
evidence-first/defensive, cross-referenced to snitch's category numbers. Internal reference.*
