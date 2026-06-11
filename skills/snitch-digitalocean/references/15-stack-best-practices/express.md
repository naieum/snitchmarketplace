# Express on DigitalOcean

Verdict: `fit-matrix express`. Docs: `stack-docs express`.

## Landing

| Option | Detail |
|---|---|
| App Platform Node service | Easiest |
| Droplet + PM2 + nginx | Full control |
| DOKS | Microservice mesh |

## Hardening

- `helmet()` middleware (mandatory).
- `express-rate-limit` on auth + write endpoints, backed by Managed Redis.
- `cors()` with explicit origin allowlist; never `origin: '*'` in prod.
- Session store: `connect-redis`. In-memory breaks with `instance_count > 1`.
- App Platform terminates TLS at edge; upstream is HTTP. Don't redirect to `http://` from app code.
- Cookies: `secure: true`, `httpOnly: true`, `sameSite: 'lax'`.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | No `helmet()` |
| 🔴 FAIL | No rate limit on auth |
| 🔴 FAIL | In-memory sessions with `instance_count > 1` |
| 🟡 WARN | `cors({origin: '*'})` |
