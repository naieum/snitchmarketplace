---
name: snitch-flyio
description: Fly.io security + readiness skill. Thin tools for the agent to compose. Detects the user's project, audits org/apps/machines/volumes/postgres/redis/secrets/services/network/tokens posture, applies idempotent hardening, and produces honest migration / scaling guidance. Triggers on audit my Fly app, harden Fly.io, secure my Fly machines, Fly secrets review, should I move to Fly, Fly Postgres audit, Fly scaling readiness, Fly incident response, Fly best practices, Fly WireGuard audit.
---

# snitch-flyio

Orchestrator skill. `~/.claude/skills/snitch-flyio/snitch-flyio.sh` exposes thin tools — read-only data tools emit JSON; mutating tools (`fix`, `panic`) are explicit and idempotent. You classify intent, prioritize findings, render prose.

Run `bash ~/.claude/skills/snitch-flyio/snitch-flyio.sh help` for the full surface.

## Setup once

| Item | Action |
|---|---|
| `flyctl` (alias `fly`) | `curl -L https://fly.io/install.sh \| sh` or `brew install flyctl`. The skill refuses without it. |
| `fly auth login` | Opens a browser; writes a token to `~/.fly/config.yml`. The skill verifies via `fly auth whoami`. |
| Fly MCP server | None widely available. If present, set `FLYSEC_MCP_PRESENT=1`. |
| `FLY_API_TOKEN` | Optional. `flyctl` honors it automatically. |

## Tool inventory

Read-only (JSON on stdout, errors as JSON on stderr):

| Subcommand | Returns |
|---|---|
| `doctor` | Env health (flyctl, jq, auth status, MCP). |
| `detect` | Cwd signals: stacks, databases, object_storage, native_deps, ai_providers, vector_dbs, headless_browser, package_managers, current_host_provider, hostnames, project_kind, fly_toml_paths, dockerfile, fly_signals. |
| `state account [org] [slice]` | Digest: tier, members, 2FA coverage. Slices: `members`, `full`. |
| `state apps [org] [slice]` | Digest: app inventory, force_https, plaintext-secret-in-env counts. Slice: `full`. |
| `state machines [app] [slice]` | Digest: per-machine status, restart policy, health checks, regions. Slice: `full`. |
| `state volumes [app] [slice]` | Digest: count, region affinity, snapshot retention. Slice: `full`. |
| `state postgres [app] [slice]` | Digest: nodes, region spread, backups. Slice: `full`. |
| `state redis [slice]` | Digest: Upstash-on-Fly Redis, TLS posture. Slice: `full`. |
| `state secrets [app] [slice]` | Digest: count, names (no values), digests. Slice: `full`. |
| `state services [app] [slice]` | Digest: HTTP/TCP services, force_https, internal vs public, checks. Slice: `full`. |
| `state network [org] [slice]` | Digest: WireGuard peers, allocated IPs (v4/v6), private-net presence. Slice: `full`. |
| `state tokens [org] [slice]` | Digest: count, scopes, expiry distribution. Slice: `full`. |
| `state cost [org]` | Spend digest (machine-hours, volume GB-months, GPU minutes). |
| `state regions [app]` | Per-region presence summary. |
| `fit-matrix [stack]` | Migration verdict + caveats. |
| `stack-docs [stack]` | Canonical doc URLs to `WebFetch`. |
| `score [host...]` | SSL Labs / Mozilla Observatory / securityheaders / hstspreload grades. |

Mutating (idempotent):

| Subcommand | Behavior |
|---|---|
| `fix <area> [app]` | Apply hardening for one area; safe to re-run. Areas: `apps secrets postgres machines volumes account tokens project gha all`. |
| `panic <action> [args]` | Incident response: `suspend <app>`, `revoke-token <id>`, `scale-to-zero <app>`, `restore`. Confirm with the user. |

Utility: `export`, `terraform`, `verify`, `refresh-docs`, `help`.

## Division of labor

`flyctl` is the primary tool. The skill wraps it for structured JSON via `--json`.

Use `flyctl` directly for:

| Operation | Command |
|---|---|
| Login / token issue | `fly auth login`, `fly tokens create deploy` |
| Deploy / release | `fly deploy`, `fly releases` |
| One-off SSH / console | `fly ssh console`, `fly console` |
| Volume snapshot create / restore | `fly volumes snapshots <create\|list\|restore>` |
| Scale a service | `fly scale count`, `fly scale memory`, `fly autoscale` |
| Tail logs | `fly logs -a <app>` |
| Postgres `psql` | `fly postgres connect -a <pg-app>` |

Use this skill for:

- Audit-shaped state across all apps in an org with derived signals (2FA coverage, plaintext secret detection, region drift, snapshot-retention gaps).
- Idempotent hardening passes (`fix <area>`).
- Offline tools `flyctl` lacks: `detect`, `fit-matrix`, `stack-docs`, `score`.
- Incident-response composition: `panic suspend`, `panic revoke-token`, `panic scale-to-zero`, `panic restore` — each records original state to `.state/panic-<ts>.json` for rollback.

`doctor` prints the install command if `flyctl` is missing; nothing else runs.

## How to use the tools

1. Classify intent yourself (audit, migrate, scale-plan, diagnose, incident).
2. Call the smallest set of tools. Prefer `state apps` / `state account` digest first; fetch slices only when the digest signals it. Run independent calls in parallel (single message, multiple Bash calls).
3. Lazy-load references that match findings — never all of them. Read `references/30-recipes.md` for recipes, `references/<NN>-<area>.md` per area, `references/15-stack-best-practices/<stack>.md` per stack.
4. Synthesize the report yourself. Group by area; mark `OK / WARN / FAIL`; surface tier-only items as `[locked: <tier>+]` (sourced from `references/10-plan-tier-matrix.md`).
5. For project file changes (`fix project`, `fix gha`, `fix apps`), the tool emits proposed contents + unified diff to stdout in this format:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` / `Write` after user confirms. The skill never writes inside the user's project. For Fly secrets, the tool emits `fly secrets set NAME=...` — never type secret values yourself.

## Recipes

Canonical orchestration recipes live in `references/30-recipes.md`. Read it for any specific recipe (audit, migrate, scaling, diagnose, attack response).

## Guardrails

- The skill refuses when `fly auth whoami` fails. Redirect the user to `fly auth login`.
- The skill refuses changes to apps where `fly.toml` `[env]` contains high-entropy values (likely API keys / DB passwords). Surfaces as `FAIL` with `fly secrets set NAME=...` remediation.
- `fix` is idempotent — no-op when state matches target.
- `panic` records each action to `.state/panic-<ts>.json`; `panic restore` rolls back.
- Honest verdicts: static / JAMstack apps get `not-recommended` from `fit-matrix`. Phoenix/Elixir, Rails, Django, Node, Go, Rust, WebSocket-heavy, ML/GPU all get `strong`.
