# Environments and deployments

A Railway project can have multiple environments (`production`, `staging`, `preview`). Each has its own variables, services, deployments, and TCP proxies.

## Environment kinds

| Kind | Pattern | Notes |
|---|---|---|
| `production` | always-on, real users | never enable sleep |
| `staging` | always-on, test traffic | sleep OK if cost matters |
| `preview` (PR) | spin up per PR via GitHub integration | sleep on; disabled when PR closes |
| `ephemeral` | local dev | use `railway run`, not deploy |

## Variable scoping

| Scope | Reference | Tied to |
|---|---|---|
| Service-level | `NAME` | one service in one env |
| Project-level (shared) | `${{ shared.NAME }}` | project root |
| Cross-service | `${{ ServiceName.VARIABLE }}` | resolved at deploy |
| Reserved | `RAILWAY_*`, `PORT` | do not override |

## Deploys

Triggers: `git push` to tracked branch, `railway up`, deploy webhook, GraphQL `serviceInstanceDeploy`.

Each deploy:
1. Builds (Nixpacks or Dockerfile).
2. Runs health check.
3. Promotes if healthy; otherwise rolls back to previous deployment.

## Promoting between environments

Railway has no first-class "promote" mutation. Common patterns:
- Tag-based: production tracks `release/*`, staging tracks `main`.
- Manual: copy variables forward via `railway variables --service ... --set`. The skill's `apply_env` flow surfaces opportunities to share variables.

## Recommendations

- Production: `sleepApplication: false`, `numReplicas: 2+`.
- Preview: ephemeral; auto-delete on PR close.
- Audit shared variables periodically — they apply to every environment.

## Docs

- https://docs.railway.com/reference/environments
- https://docs.railway.com/guides/migrations
