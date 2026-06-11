# MCP / CLI division of labor

Three surfaces an agent can call:

| # | Surface | Auth | Used for |
|---|---|---|---|
| 1 | `vercel` CLI | `vercel login` | Command-style queries (primary) |
| 2 | Vercel REST API | `VERCEL_TOKEN` | Richer JSON than CLI exposes |
| 3 | Vercel MCP | `VRCSEC_MCP_PRESENT=1` | Typed reads/writes when available |

No first-party Vercel MCP is published as of writing; community MCPs vary in coverage.

## When to use which

| Operation | First choice | Fallback |
|---|---|---|
| Identity / login | CLI (`vercel whoami`) | — |
| Project/team list | REST `/v9/projects` `/v2/teams` | CLI `vercel projects ls` |
| Env-var add/remove | CLI (`vercel env add NAME ENV --sensitive`) | — (CLI handles sensitive write-once) |
| Env-var list with sensitivity flags | REST `/v9/projects/<id>/env?decrypt=false` | CLI `vercel env ls` |
| Deployment list | REST `/v6/deployments?projectId=...` | CLI `vercel ls` |
| Domain inspect | REST `/v6/domains/<name>/config` + `/v9/projects/<id>/domains` | CLI `vercel domains inspect` |
| Logs | CLI `vercel logs <url>` | — |
| Audit log | REST `/v1/teams/<id>/audit-logs` (Pro+) | — |
| Log drains | REST `/v1/integrations/log-drains` | — |
| Project mutation | REST `PATCH /v9/projects/<id>` | dashboard UI |

## Why the skill prefers REST

- CLI emits human-readable tables for many list commands; parsing is brittle.
- REST surfaces fields the CLI hides (env type=`sensitive`, deployment-protection details, `ssoProtection.deploymentType`).
- Pagination + filtering is consistent.
- MCP, when present, wraps a subset of REST with typed schemas — fewer tokens than parsing JSON.

## CLI-only fallback

The skill still works without `VERCEL_TOKEN`. `state account` falls back to `vercel whoami` + `vercel teams ls`. Some richer-JSON endpoints (env-var sensitivity, log drains) require the token; the skill emits `WARN` and skips that piece.

## Neither CLI nor token

Refusal. Doctor reports both as missing; skill exits with `E_AUTH`.

## Ecosystem checks

| Check | Where |
|---|---|
| `npm`/`node` installed | `command -v node` |
| `vercel` installed | `command -v vercel` |
| Logged in | `vercel whoami` returns the username |
| Token set | `[ -n "$VERCEL_TOKEN" ]` |

`doctor` runs all four and emits a table.
