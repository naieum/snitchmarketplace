# MCP / CLI / skill division of labor

Railway's primary tool surface is the `railway` CLI. No first-party Railway MCP exists today. If a community MCP is loaded (`RWSEC_MCP_PRESENT=1` exported), prefer typed access where it covers an operation.

## Use the railway CLI directly for

| Operation | Command |
|---|---|
| Confirm session | `railway whoami` |
| Quick project meta | `railway status --json` |
| Read current env (one service, one env) | `railway variables` |
| Set a single var | `railway variables --set NAME=value` |
| Tail logs | `railway logs` |
| Open DB shell | `railway connect` |
| Deploy (only at user request) | `railway up` |
| Add a domain (with user confirmation) | `railway domain` |

## Use the GraphQL endpoint (skill does this internally)

- Bulk variable reads across services.
- Service / volume / TCP proxy enumeration.
- Cross-environment views.
- Plan tier detection.

The skill wraps GraphQL via `lib/api.sh::rw_gql`. Don't call directly.

## Use this skill for

- Posture across multiple subscopes (`state workspace + project + services + env + domains`).
- Idempotent fixes (`fix env`, `fix services`, `fix databases`).
- Incident response (`panic suspend-service`, `panic revoke-token`).
- Heuristic / synthesis tools the CLI lacks (`detect`, `fit-matrix`, `stack-docs`, `score`).

## Don't use this skill for

- Deploy → `railway up` directly.
- Set a single variable → `railway variables --set`.
- Quick log tail → `railway logs`.

## With a Railway MCP loaded

Community MCPs vary; substitute actual tool names from your session.

| Operation | Where |
|---|---|
| List projects | MCP if available, else `railway status --json` per project, else this skill |
| List services | this skill (`state services`) |
| Read variables | `railway variables` for quick check; this skill (`state env`) for audit |
| Deploy | `railway up` directly |
| Add custom domain | `railway domain <name>` directly |

When in doubt: `bash snitch-railway.sh doctor` — reports CLI presence + session state + MCP detection.
