# Auth and tokens

Railway has two auth surfaces, both via Bearer tokens. There is no global API key — every credential is scoped.

## Tokens

| Kind | Where | Scope | Use |
|---|---|---|---|
| CLI session | `railway login` (browser flow) | account | Local dev. Stored in `~/.config/railway/` or `~/.railway/`. |
| `RAILWAY_API_TOKEN` | dashboard → account → tokens | account | Admin across all projects. Most powerful. |
| `RAILWAY_TOKEN` (project) | dashboard → project → tokens | one project, optionally one env | CI/CD deploys. |

## Skill expectations

- State queries: session (`railway login`) or `RAILWAY_API_TOKEN`. Skill prefers `RAILWAY_API_TOKEN` for GraphQL — covers all projects.
- Per-project mutations: `RAILWAY_TOKEN` works.
- Skill refuses to operate without one — Railway has no degraded-mode path.

## Rotation

GraphQL schema does not expose `last_used_at`. Rotate every 90 days by policy.

| Token type | Rotation path |
|---|---|
| Project | dashboard → project → Settings → Tokens → revoke + recreate. Update CI secret. |
| Account | dashboard → account → Tokens → revoke + recreate. Update local env. |

## Session storage

`railway login` writes a JWT to `~/.railway/session.json` (path varies). Treat like `~/.aws/credentials` — leak = full account access.

## Recommendations

- Project tokens > account tokens for any automated context (CI, scripts).
- Scope project tokens to one environment when action is env-specific (e.g., production deploy webhook should not nuke staging).
- Never commit a token. Use `railway` CLI from logged-in shell or set in CI secret store.

## Docs

- https://docs.railway.com/reference/public-api
- https://docs.railway.com/guides/cli
- https://railway.com/account/tokens
