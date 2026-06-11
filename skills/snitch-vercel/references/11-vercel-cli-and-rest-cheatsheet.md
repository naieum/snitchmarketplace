# Vercel CLI + REST cheatsheet

## CLI quick reference

```bash
# Identity
vercel whoami
vercel login
vercel logout
vercel teams ls
vercel teams switch <slug>

# Project linking (creates .vercel/project.json)
vercel link

# Env vars
vercel env ls
vercel env add NAME production [--sensitive]
vercel env rm NAME production
vercel env pull .env.local

# Deployments
vercel                       # deploy current branch as preview
vercel --prod                # deploy to production
vercel ls                    # list recent deployments
vercel inspect <url>         # detail incl. build logs
vercel rollback <url>        # mark <url> as production
vercel logs <url>            # stream logs
vercel remove <project>      # delete the project

# Domains
vercel domains ls
vercel domains add <domain> <project>
vercel domains inspect <domain>
vercel domains rm <domain>

# Pulling project config
vercel pull                  # writes .vercel/project.json + .vercel/.env.* to cwd

# Telemetry off
vercel telemetry disable
```

## REST endpoints used by this skill

Base: `https://api.vercel.com`. Auth: `Authorization: Bearer $VERCEL_TOKEN`. Most endpoints accept `?teamId=<id>`.

| Path | Used for |
|---|---|
| `GET /v2/user` | user identity + plan |
| `GET /v2/teams` | list teams |
| `GET /v2/teams/<id>` | team meta + plan |
| `GET /v2/teams/<id>/members` | team membership + 2FA |
| `GET /v5/user/tokens` | list user tokens (metadata) |
| `DELETE /v3/user/tokens/<id>` | revoke token |
| `GET /v9/projects` | list projects |
| `GET /v9/projects/<id>` | project meta + protection state |
| `PATCH /v9/projects/<id>` | mutate project (protection, region, ...) |
| `GET /v9/projects/<id>/env?decrypt=false` | env vars (metadata) |
| `POST /v10/projects/<id>/env` | add env var |
| `DELETE /v9/projects/<id>/env/<envId>` | remove env var |
| `GET /v9/projects/<id>/domains` | project domains |
| `GET /v6/domains/<name>/config` | domain DNS verification + TLS state |
| `GET /v6/deployments?projectId=<id>` | recent deployments |
| `GET /v13/deployments/<uid>` | full deployment incl. functions block |
| `GET /v1/storage/stores` | KV / Postgres / Blob inventory |
| `GET /v1/edge-config` | Edge Configs |
| `GET /v1/edge-config/<id>/tokens` | per-config read tokens |
| `GET /v1/integrations/log-drains` | log drains |
| `POST /v1/integrations/log-drains` | create log drain |
| `GET /v1/teams/<id>/audit-logs?limit=20` | audit log (Pro+) |
| `GET /v1/teams/<id>/usage?from=<ms>&to=<ms>` | billing usage |

## Pagination

Most list endpoints use `?limit=N` + cursor (`?since=<ms>`). The skill defaults to small limits (20-100) for digest mode.

## Rate limits

Vercel's REST is roughly 1000 req/min per token. The skill caches reads in `.state/api-calls.log` (auditing only — keeps PII out).

## CLI internal endpoints

The CLI sometimes hits internal endpoints. Stick to the documented `/v*` paths unless you're prepared for breakage.

## References

- https://vercel.com/docs/rest-api
- https://vercel.com/docs/cli
