# Secrets and environment variables

Railway treats env vars and secrets as one surface. There is no separate secret store. Every value typed into Variables is visible to anyone with project access (modulo role-based view restrictions on Pro+).

Implications:
- Leaked project token = read access to every secret.
- Compromised dev account with project access = read access.
- Audit log shows variable changes but does not redact values.

## Closest things to "secrets"

| Mechanism | Behavior |
|---|---|
| Cross-service references — `${{ Postgres.DATABASE_URL }}` | Resolved at deploy time. Not visible in consumer service's Variables list. Use for any secret produced by another service. |
| Shared (project-level) variables — `${{ shared.NAME }}` | One source of truth, referenced from many services. Still readable to project members. |
| Sealed variables (paid, when available) | Write-only after first set. Check dashboard for current availability. |

## Heuristics

`state env` digest flags as `secret-shaped`:

| Signal | Pattern |
|---|---|
| Name suffix | `_KEY`, `_TOKEN`, `_SECRET`, `_PASSWORD`, `_PASS`, `_DSN`, `_PRIVATE_KEY`, `_API_KEY` |
| Value prefix | `sk_`, `pk_`, `ghp_`, `xoxb-`, `AKIA`, `eyJ` (JWT) |
| Value entropy | ≥32 chars and base64ish/hex |

False positives expected. Surface as `WARN`, not `FAIL`.

Distinguishing secret from config:
- Secret → matches a heuristic above OR is consumed by a third-party API client (Stripe, GitHub, AWS, OpenAI).
- Config → URL/path/feature-flag/numeric tunable. Stays plaintext fine.

## Reserved variables

Railway reserves these — setting in user space is usually a bug:

- `PORT` — Railway sets; bind to it.
- `RAILWAY_STATIC_URL`, `RAILWAY_PRIVATE_DOMAIN`, `RAILWAY_PUBLIC_DOMAIN`
- `RAILWAY_TCP_PROXY_DOMAIN`, `RAILWAY_TCP_PROXY_PORT`
- `RAILWAY_GIT_COMMIT_SHA`, `RAILWAY_ENVIRONMENT`, `RAILWAY_SERVICE_NAME`, `RAILWAY_PROJECT_NAME`

## Recommendations

1. Move every secret-shaped value to a shared variable + reference.
2. Service-scoped secrets consumed by exactly one service (e.g., `STRIPE_WEBHOOK_SECRET`) can stay — tag for rotation in your runbook.
3. Rotate all values pasted into Variables within 30 days of staffing changes.
4. Audit `bash snitch-railway.sh state env <pid> <env> digest` quarterly.

## Docs

- https://docs.railway.com/guides/variables
- https://docs.railway.com/reference/variables
