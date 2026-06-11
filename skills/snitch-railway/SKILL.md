---
name: snitch-railway
description: Railway security + readiness skill. Thin tools for the agent to compose. Detects the user's project, audits workspace/project/services/env/volumes/databases/tokens/domains/tcp-proxies/logs/cost posture, applies idempotent hardening, and produces honest migration / scaling guidance. Triggers on audit my Railway project, harden Railway, secure Railway services, Railway env audit, should I move to Railway, Railway scaling readiness, Railway incident response.
---

# snitch-railway

Orchestrator role. `~/.claude/skills/snitch-railway/snitch-railway.sh` exposes thin tools — read-only data tools emit JSON, mutating tools (`fix`, `panic`) are explicit and idempotent. You synthesize: classify intent, prioritize findings, render prose.

Run `bash ~/.claude/skills/snitch-railway/snitch-railway.sh help` for the full surface.

## Setup

- Install `railway` CLI: `brew install railway` or `npm i -g @railway/cli`. Auth: `railway login`. Skill refuses to operate when `railway whoami` fails.
- For richer queries the skill calls Railway GraphQL at `https://backboard.railway.com/graphql/v2`. Export `RAILWAY_TOKEN` (project-scoped) or `RAILWAY_API_TOKEN` (account-scoped).
- Optional: a Railway MCP. Export `RWSEC_MCP_PRESENT=1` if one is loaded.

## Tool inventory

Read-only (JSON on stdout, errors as JSON on stderr):

| Subcommand | Returns |
|---|---|
| `doctor` | env health (railway CLI, jq, token, MCP) |
| `detect` | cwd signals: stacks, databases, native deps, host provider, hostnames, plus Railway-specific (railway_configs, nixpacks_config, procfile, dockerfile, railway_env_refs) |
| `state workspace [slice]` | digest (default): teams + plan + members. Slices: `members`, `billing`, `full` |
| `state project [pid] [slice]` | digest: project + envs + services count. Slices: `environments`, `full` |
| `state services [pid] [slice]` | digest: services + builders + replicas + health-check summary. Slices: `full` |
| `state env [pid] [env] [slice]` | digest: var counts + reference summary + secret-shape flags. Slices: `vars`, `full` |
| `state volumes [pid] [slice]` | volume inventory + mount summary |
| `state databases [pid] [slice]` | DB add-on inventory + version + EOL flags |
| `state tokens [slice]` | token inventory (project + account) with age + scope |
| `state domains [pid] [slice]` | custom domains + TLS state + redirect summary |
| `state tcp-proxies [pid] [slice]` | per-service public TCP exposures + port mapping |
| `state logs [pid] [slice]` | log retention + drain config summary |
| `state cost [pid] [slice]` | usage estimate, free-tier exhaustion, sleeping vs always-on |
| `fit-matrix [stack]` | migration verdict + caveats |
| `stack-docs [stack]` | canonical doc URLs to `WebFetch` |
| `score [host...]` | SSL Labs / Mozilla Observatory / securityheaders / hstspreload grades |

Mutating (idempotent):

| Subcommand | Behavior |
|---|---|
| `fix <area> [args]` | apply hardening; safe to re-run. Areas: `env services databases domains workspace tokens logs all` |
| `panic <action> [args]` | incident response: `suspend-service <svc>`, `revoke-token <id>`, `lockdown-db <svc>`, `restore`. Confirm with user first. |

Utility: `export`, `terraform`, `verify`, `refresh-docs`, `help`.

Removed (exit 64 + deprecation notice): `check`, `migrate`, `roadmap`, `report`, `diagnose`. Compose primitives — see `references/30-recipes.md`.

## Division of labor: CLI / MCP / skill

The Railway CLI is the primary tool — typed, no token-burn parsing. With a Railway MCP loaded (`RWSEC_MCP_PRESENT=1`), prefer it where it covers an operation. Use this skill for what the CLI/MCP don't cover (heuristics, idempotent fixes, scoring, migration verdicts).

Use `railway` CLI directly for:

| Operation | Command |
|---|---|
| Whoami / login state | `railway whoami` |
| Project / service status | `railway status -j` |
| Variable read | `railway variables` |
| Logs tail | `railway logs` |
| Domain list | `railway domain` |
| Deploy | `railway up` (user-initiated only) |

Use this skill (`bash snitch-railway.sh ...`) for:

- Posture across workspace / project / services / env / volumes / databases / tokens / domains / tcp-proxies / logs / cost — digests synthesize CLI + GraphQL into one report.
- Heuristics the CLI lacks: secret-shaped value detection, EOL DB version flags, TCP exposure audit.
- Mutations: `fix <area>`, `panic <action>`.
- Offline: `detect`, `fit-matrix`, `stack-docs`, `score`.

`doctor` reports CLI/auth state. The skill refuses state/fix/panic without `railway whoami` succeeding — Railway's auth model has no global API key fallback by design.

## Usage

For any Railway-related request:

1. Classify intent (audit, migrate, scale-plan, diagnose, incident). Don't shell out to do it.
2. Call the smallest tool set. Prefer digest mode first; fetch a slice only when the digest signals you should. Run independent calls in parallel.
3. Lazy-load matching references. Read `references/30-recipes.md` for orchestration. Read `references/<NN>-<area>.md` when an area surfaces an issue. Read `references/15-stack-best-practices/<stack>.md` when a stack needs tailored guidance.
4. Synthesize the report yourself. Group by area. Mark `OK / WARN / FAIL`. Surface paid-only items as `[locked: <tier>+]` with one-line value statements from `references/10-plan-tier-matrix.md`.
5. For project file changes (`fix env`, `fix services`, etc.), the tool emits proposed contents + unified diff to stdout:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` or `Write` after user confirms. The skill never writes inside the user's project. For Railway secret values, the tool emits `railway variables --set NAME=...` invocations — never type secret values yourself.

## Recipes

Canonical orchestration recipes live in `references/30-recipes.md`. Read it when you need a specific recipe (audit, migrate, scaling, diagnose, incident). Recipes assume the digest-by-default contract above.

## Guardrails

- Refuses without `railway whoami` succeeding. Tell the user to `railway login`.
- Railway treats env vars and secrets as one surface. Skill flags any value that looks like a secret (long random string, `_key`/`_token`/`_secret` suffix) but is duplicated across services or stored as plaintext rather than `${{ }}` reference. False positives expected — surface as `WARN`, not `FAIL`.
- `fix` is idempotent — no-op when state matches target.
- `panic` records each action to `.state/panic-<ts>.json`. `panic restore` rolls back where reversible.
- Honest verdicts: static sites (Hugo, Jekyll, plain HTML) get `not-recommended` — Railway is wasted compute. Point users at Pages/Vercel/Netlify.
