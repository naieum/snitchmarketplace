# 35 — Workers Builds / CI-CD supply-chain security

Tool: `audit builds` (MCP-only; recipe in `32-mcp-surfaces.md#builds`). The deploy
pipeline is part of the attack surface: whoever controls CI controls production.
This complements the source-side checks in `lib/gha.sh` (GitHub Actions) and
`lib/wrangler_lint.sh` (wrangler config).

## What "good" looks like

- **Provenance:** production Workers deploy from a connected repo via Workers
  Builds (or a reviewed GitHub Actions pipeline), not ad-hoc `wrangler deploy`
  from laptops. Auditable build history exists.
- **Branch/fork trust:** builds trigger only from trusted branches; fork PRs do
  not deploy or receive production secrets.
- **No secrets in logs:** build logs never echo tokens/keys. Secrets are injected
  as encrypted build/deploy variables, never printed.
- **Green production:** the production worker's latest build succeeded; repeated
  failures aren't masking a broken/rolled-back deploy.

## Findings (tag `area=builds`)

| Signal (from build metadata/logs) | Verdict |
|---|---|
| Log line matches `sk-`, `Bearer `, `AWS_`, `*_TOKEN=`, `AKIA` | **FAIL** — secret in CI logs; rotate immediately, then move to encrypted vars |
| Build from an unexpected branch/fork | **WARN** — review who can trigger production deploys |
| Failing / repeatedly-failing build on the production worker | **WARN** — deploy integrity unclear |
| No connected repo (manual deploy only) | **INFO** — no CI provenance to audit; recommend connecting a repo |

## Remediation pointers (this pass is audit-only — no `fix builds`)

- Secret leaked in logs → rotate the credential now; relocate to Workers secrets
  (`wrangler secret put`) or encrypted build vars; scrub the value from any cached
  logs.
- Tighten branch/environment protection rules and required reviews on the repo.
- For GitHub Actions specifics (OIDC vs long-lived `CLOUDFLARE_API_TOKEN`, least-
  privilege scopes, `pull_request_target` risks), see `lib/gha.sh` and
  `01-auth-and-tokens.md`.

Cross-refs: `06-workers-pages.md` (secrets vs vars), `32-mcp-surfaces.md#builds`,
`01-auth-and-tokens.md`.
