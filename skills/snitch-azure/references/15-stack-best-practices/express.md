# Express on Azure

Verdict + caveats: `fit-matrix express`. Docs: `stack-docs express`.

## Landing

- **App Service Linux Node 20** — canonical. No `web.config` (Linux); use `package.json` `start` script.
- **Container Apps** — Docker + scale-to-zero.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off (`fix appservice`).
- Sessions: not `express-session` memory store. Use Azure Cache for Redis with `connect-redis`.
- File uploads: `multer` to disk works, but disk is ephemeral after restart — stream to Blob Storage.
- Helmet middleware (CSP, HSTS, X-Frame-Options).
- Body limits: `express.json({limit: '10kb'})`; bigger = APIM / WAF rule.
- Rate limiting: `express-rate-limit` + Redis; OR push to Front Door / App Gateway.
- CORS: allowlist origins; never `*` with credentials.

## Skill targets

| Finding | Severity |
|---|---|
| HTTPS-only / TLS / FTPS / SCM basic | `fix appservice` |
| Memory session store (`express-session` without redis/mongo backing) | WARN |
| `helmet` not in `package.json` | WARN |
