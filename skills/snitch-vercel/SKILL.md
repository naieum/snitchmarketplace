---
name: snitch-vercel
description: Vercel security + readiness skill. Thin tools for the agent to compose. Detects the user's project, audits account/team/project/env/domains/deployments/protection/functions/middleware/storage/edge-config/log-drains/analytics/cost posture, applies idempotent hardening, and produces honest migration / scaling guidance. Triggers on audit my Vercel deployment, harden Vercel, Vercel security audit, secure Vercel project, Vercel deployment protection, Vercel env audit, should I move to Vercel, Vercel scaling readiness, Vercel incident response, Vercel custom domain TLS.
---

# snitch-vercel

You orchestrate. `~/.claude/skills/snitch-vercel/snitch-vercel.sh` exposes thin tools — read-only tools emit JSON; mutating tools (`fix`, `panic`) are explicit and idempotent. **You synthesize:** classify intent, prioritize findings, render prose.

Run `bash ~/.claude/skills/snitch-vercel/snitch-vercel.sh help` for the full surface.

## Setup once

- Install: `npm i -g vercel`, then `vercel login`.
- For richer JSON than the CLI exposes, set `VERCEL_TOKEN`. Create a scoped token at https://vercel.com/account/tokens — never the team-wide owner token.
- Optional Vercel MCP: if loaded, set `VRCSEC_MCP_PRESENT=1`.
- Refusal: the skill refuses when `vercel whoami` fails AND `VERCEL_TOKEN` is unset. `doctor` prints the dashboard URL.

## Tool inventory

Read-only (JSON on stdout, errors as JSON on stderr):

| Subcommand | Returns |
|---|---|
| `doctor` | env health (curl, jq, vercel CLI, token, MCP) |
| `detect` | cwd signals: `stacks[]`, `databases[]`, `object_storage[]`, `native_deps[]`, `ai_providers[]`, `vector_dbs[]`, `headless_browser`, `package_managers[]`, `current_host_provider`, `hostnames[]`, `project_kind`, `vercel_markers[]` |
| `state account [slice]` | user + team summary + 2FA + token-meta. Slices: `members`, `tokens`, `audit`, `full` |
| `state team [team-id] [slice]` | team meta + plan + member count. Slices: `members`, `full` |
| `state project [project-id] [slice]` | project meta + framework + region + linked git. Slices: `full` |
| `state env [project-id] [slice]` | env-var count per environment + sensitive vs plaintext + `NEXT_PUBLIC_*` leak suspects. Slices: `production`, `preview`, `development`, `full` |
| `state domains [project-id]` | domains + TLS state + redirects + DNS verification |
| `state deployments [project-id] [window]` | recent deployments + statuses + production-deploy gate |
| `state protection [project-id]` | password / Vercel auth / trusted IPs / OAuth / approval flow |
| `state functions [project-id]` | serverless + edge inventory: runtime, region, memory, timeout |
| `state middleware [project-id]` | introspect `middleware.ts` for bot-block / auth / geo / rate-limit |
| `state kv-postgres-blob [project-id]` | Vercel KV / Postgres / Blob bindings + region |
| `state edge-config [project-id]` | Edge Config inventory + read tokens + write API access |
| `state log-drains [team-id]` | log-drain destinations (Pro+) |
| `state analytics [project-id]` | Web Analytics + Speed Insights status |
| `state cost [team-id] [window]` | function invocations, bandwidth, image-opt volume, KV reads/writes |
| `fit-matrix [stack]` | migration verdict + caveats |
| `stack-docs [stack]` | canonical doc URLs to `WebFetch` |
| `score [host...]` | SSL Labs / Mozilla Observatory / securityheaders / hstspreload grades |

Mutating (idempotent):

| Subcommand | Behavior |
|---|---|
| `fix <area> [project-id]` | apply hardening for one area; safe to re-run. Areas: `account project env domains headers log-drains all` |
| `panic <action> [args]` | incident response: `pause-deploys`, `revoke-token <id>`, `lock-production`, `restore`. Always confirm with the user before invoking. |

Utility: `export`, `terraform`, `verify`, `refresh-docs`, `help`.

Removed (print a deprecation notice + exit 64): `check`, `migrate`, `roadmap`, `report`, `diagnose`, `stacks`. Compose primitives instead — see `references/30-recipes.md`.

## Division of labor: CLI primary, MCP optional

The `vercel` CLI is primary — auth + most reads. The skill calls the CLI for command-style queries and falls back to REST (`https://api.vercel.com/`) for richer JSON (env-var sensitivity, domain TLS state, deployment-protection policy, log-drain destinations).

If a Vercel MCP server is loaded (`VRCSEC_MCP_PRESENT=1`), prefer it for typed reads/writes. Use this skill for everything the MCP doesn't cover and for all mutations the user wants explicit.

Reach for the CLI when you need:

| Operation | CLI / SDK call |
|---|---|
| Login + identity | `vercel whoami`, `vercel login` |
| Project list | `vercel projects ls` |
| Env vars | `vercel env ls`, `vercel env add`, `vercel env rm` (sensitive type via API) |
| Domains | `vercel domains ls`, `vercel domains inspect <domain>` |
| Deployments | `vercel ls`, `vercel inspect <url>`, `vercel rollback` |
| Functions | inspect `vercel.json` `functions` block + per-deployment build output |
| Logs | `vercel logs <url>` |
| Pull config | `vercel pull` (writes `.vercel/project.json` + env snapshot) |

Reach for this skill (`bash snitch-vercel.sh ...`) when you need:

- Posture state and mutations the CLI doesn't expose: deployment-protection policy, env-var sensitivity classification, `NEXT_PUBLIC_*` secret-shape detection, custom-domain TLS verification details, log-drain destinations, project + team plan-tier signals.
- Mutations: `fix <area>`, `panic <action>`.
- Offline tools: `detect`, `fit-matrix`, `stack-docs`, `score`.

## How to use the tools

For any Vercel-related request:

1. **Classify the intent** (audit, migrate, scale-plan, diagnose, incident). Don't shell out for that.
2. **Call the smallest set of tools** that answers the question. Prefer `state <subscope>` digest mode first; fetch a slice only when the digest signals you should. Run independent calls in parallel (single message, multiple Bash calls).
3. **Lazy-load references that match findings**, not all of them. Read `references/30-recipes.md` for orchestration recipes when needed. Read `references/<NN>-<area>.md` when an area surfaces an issue. Read `references/15-stack-best-practices/<stack>.md` when a stack needs tailored guidance.
4. **Synthesize the report yourself.** Group findings by area; mark `OK / WARN / FAIL`; surface paid-only items as `[locked: <tier>+]` with one-line value statements (sourced from `references/10-plan-tier-matrix.md`).
5. **For project file changes** (`fix project`, `fix headers`, `fix env`), the tool emits proposed contents + unified diff to stdout in this format:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` or `Write` after the user confirms. The skill never writes inside the user's project. For env-var values, the tool emits `vercel env add NAME` invocations — never type secret values yourself.

## Recipes

Canonical orchestration recipes live in `references/30-recipes.md`. Read it when you need a specific recipe (audit, migrate, scaling, diagnose, attack response). The recipes assume the digest-by-default contract above.

## Guardrails

- The skill refuses when `vercel whoami` fails AND `VERCEL_TOKEN` is unset. Redirect to `vercel login` or `https://vercel.com/account/tokens`.
- The skill flags any project loading `NEXT_PUBLIC_*` env vars containing high-entropy secret-looking strings. `NEXT_PUBLIC_*` ships to the browser — never put credentials there.
- The skill flags plaintext env vars with secret-shaped values that should be marked Vercel "Sensitive" or referenced via `@secret`.
- `fix` is idempotent — no-op when state matches target.
- `panic` records each action to `.state/panic-<ts>.json`; `panic restore` rolls back.
- Honest verdicts: WordPress / PHP / Rails / Django get `not-recommended` from `fit-matrix` — Vercel doesn't run them. Surface that first.
- Never propose Vercel KV as a Redis replacement for atomic-counter workloads — KV is eventually consistent.
