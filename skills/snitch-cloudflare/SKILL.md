---
name: snitch-cloudflare
description: Cloudflare security + readiness skill. Thin tools for the agent to compose. Detects the user's project, audits zone/account/Workers/Pages/Tunnel/Access posture, applies free + plan-tier hardening, and produces honest migration / scaling guidance. Triggers on harden Cloudflare, secure my Cloudflare site, Cloudflare audit, Cloudflare best practices, Cloudflare WAF / DNSSEC / HSTS / AOP setup, migrate to Cloudflare, Cloudflare scaling readiness, under attack mode, Cloudflare incident response, should I move to Cloudflare.
---

# snitch-cloudflare

This skill's CLI, `snitch-cloudflare.sh`, lives at the skill root and exposes thin tools. Invoke it by a path relative to this skill folder — in Claude Code/SDK use `${CLAUDE_SKILL_DIR}/snitch-cloudflare.sh`; otherwise `bash snitch-cloudflare.sh <subcommand>` from the skill directory. The script resolves its own location, so `lib/`, `references/`, and `templates/` are found regardless of CWD. Read tools emit JSON; mutating tools (`fix`, `panic`) are explicit and idempotent. You classify intent, prioritize findings, and render prose. Run `bash snitch-cloudflare.sh help` for the full surface.

## Setup

- `CLOUDFLARE_API_TOKEN` — scoped, never the global API key. If missing, `doctor` prints the dashboard URL and `templates/token-permissions.checklist.md`.
- Optional: `wrangler` and the Cloudflare Developer Platform MCP. Skill works without either.
- If the MCP is loaded, export `CFSEC_MCP_PRESENT=1`.

## Portability (Claude + Codex)

This skill conforms to the open Agent Skills spec: frontmatter is only `name` +
`description`, the CLI is referenced by a path relative to the skill folder, and
all logic lives in the agent-agnostic `snitch-cloudflare.sh` + `references/`.
It loads in **Claude Code / Claude Agent SDK** (`~/.claude/skills/` or project
`.claude/skills/`) and in **OpenAI Codex** (`~/.agents/skills/` or
`.agents/skills/`; symlinks are followed, so one canonical folder serves both).
`agents/openai.yaml` is a Codex-only sidecar (Claude ignores it). Full setup,
including the symlink and the Codex network-sandbox caveat, is in
`references/37-portability.md`.

> Codex sandboxes network egress by default. This CLI calls the Cloudflare API,
> so run Codex with network access enabled (or approve the egress) or every
> live tool fails — see `references/37-portability.md`.

## Tools

Read-only (JSON on stdout, errors as JSON on stderr):

| Subcommand | Returns |
|---|---|
| `doctor` | env health (curl, jq, token, wrangler, MCP) |
| `detect` | cwd signals: `stacks[]`, `databases[]`, `object_storage[]`, `native_deps[]`, `ai_providers[]`, `vector_dbs[]`, `headless_browser`, `package_managers[]`, `current_host_provider`, `hostnames[]`, `project_kind` |
| `state zone [zone-id] [slice]` | digest by default; slices: `dns`, `rulesets`, `firewall`, `full` |
| `state account [acct-id] [slice]` | digest by default; slices: `members`, `tokens`, `audit`, `full` |
| `state tunnels` / `state access` / `state pageshield` | inventory JSON |
| `analytics zone [zone] [1h\|24h\|7d]` | totals + top countries/ASNs/paths + colo distribution |
| `events zone [zone] [1h\|24h\|7d]` | recent firewall events |
| `fit-matrix [stack]` | migration verdict + caveats |
| `stack-docs [stack]` | canonical doc URLs to `WebFetch` |
| `score [host...]` | SSL Labs / MDN HTTP Observatory / local security-header grade / hstspreload grades |

Audit lenses (cross-cutting; JSON on stdout; gated lenses emit `{locked:...}` cleanly so a free/pro report stays complete):

| Subcommand | Returns / lens |
|---|---|
| `audit auditlog [acct] [24h\|7d\|30d]` | audit-log analysis: counts + sensitive-event subset |
| `audit logpush [acct]` | Logpush job coverage + redacted destinations (Enterprise → `locked:"enterprise"`) |
| `audit dns [zone] [1h\|24h\|7d]` | DNS settings posture + DNS analytics (NXDOMAIN/SERVFAIL, query mix) |
| `audit ai-gateway [acct]` | AI Gateway governance flags (no gateway → `locked:"not-configured"`) |
| `audit secevents [zone] [1h\|24h\|7d]` | aggregated WAF/security events by action/source/rule/country/host |
| `audit casb` / `audit dex` / `audit builds` | MCP-only → delegation pointer (CASB / device posture / CI-CD) |
| `audit browser [host...]` | rendered header/CSP (browser MCP; `score` header fallback) |
| `audit observability` | Workers errors/exceptions as attack signal (observability MCP; GraphQL count fallback) |
| `audit all` | master toes-to-top envelope: runs the curl lenses + delegation pointers + compose-also list |

Mutating (idempotent):

| Subcommand | Behavior |
|---|---|
| `fix <area> [zone-id]` | hardening for one area. Areas: `ssl hsts dnssec dns-email waf rules bots rate-limit headers aop tunnel access account tokens project security-txt cookies takeovers health gha wrangler-lint email page-shield all` |
| `panic <action> [args]` | `under-attack`, `block ip\|asn\|country <v>`, `challenge-all`, `restore`. Confirm with the user first. |

Utility: `export`, `terraform`, `verify`, `refresh-docs`, `help`.

Removed (exit 64 with deprecation): `check`, `migrate`, `roadmap`, `report`, `diagnose`, `stacks`. Compose primitives — see `references/30-recipes.md`.

## Cloudflare MCP division of labor

The skill is curl-first; Cloudflare MCP servers are accelerants. Legend:
**ALT** = a full curl lens exists (MCP saves tokens, optional); **PREFERRED** = a
weaker curl fallback exists; **REQUIRED** = no curl path (lens emits a delegation
pointer; needs the MCP). Set `CFSEC_MCP_PRESENT=1` for the Developer Platform
server and `CFSEC_MCP_<NAME>=1` for the audit-lens servers you've installed.

| Server (tool prefix `mcp__…`) | Use for | Skill lens | Role |
|---|---|---|---|
| `claude_ai_Cloudflare_Developer_Platform__` | D1/KV/R2/Hyperdrive, Workers list/get/code, `search_cloudflare_documentation`, Pages→Workers | storage, workers | ALT |
| `cloudflare-auditlogs__` (`auditlogs_by_account_id`) | typed audit-log pull | `audit auditlog` | ALT |
| `cloudflare-logpush__` (`logpush_jobs_by_account_id`) | Logpush jobs | `audit logpush` | ALT |
| `cloudflare-dns-analytics__` (`dns_report`, `show_*_dns_settings`) | DNS analytics + settings | `audit dns` | ALT |
| `cloudflare-graphql__` (`graphql_query`, schema explorer) | deeper security analytics | `audit secevents` | ALT |
| `cloudflare-ai-gateway__` (`list_gateways`, `list_logs`, `get_log_*`) | AI Gateway config + logs | `audit ai-gateway` | ALT |
| `cloudflare-observability__` (`query_worker_observability`, `observability_*`) | Worker error/exception detail | `audit observability` | PREFERRED |
| `cloudflare-browser__` (`get_url_html_content/markdown/screenshot`) | rendered DOM/CSP/3rd-party origins | `audit browser` | PREFERRED |
| `cloudflare-casb__` (`integrations_list`, `assets_*`, `asset_categories_*`) | SaaS posture | `audit casb` | **REQUIRED** |
| `cloudflare-dex__` (`dex_fleet_status_*`, `dex_list_tests`, `dex_*`) | device posture / network health | `audit dex` | **REQUIRED** |
| `cloudflare-builds__` (`workers_builds_*`, `workers_list`) | CI/CD build provenance + log secrets | `audit builds` | **REQUIRED** |

For ALT/PREFERRED lenses the curl path works standalone; prefer the MCP when its
flag is set (typed, fewer tokens). REQUIRED lenses without their MCP return
`locked:"mcp-absent"` + an install hint and render as ⚪️ N/A. Recipes + finding
taxonomies for the MCP-driven lenses: `references/32-mcp-surfaces.md`.

Use this skill for: SSL/TLS/HSTS/DNSSEC/WAF/custom rules/rate limits/Transform Rules/AOP/Bot Fight/firewall access rules/Page Shield/Tunnel/Access/members/tokens/notifications/audit log/firewall analytics/firewall events; mutations (`fix`, `panic`); offline tools (`detect`, `fit-matrix`, `stack-docs`, `score`).

If the MCP is not loaded, the skill works for everything via curl. `doctor` recommends `claude mcp add cloudflare-dev-platform`.

## How to use

1. Classify intent (audit, migrate, scale-plan, diagnose, incident).
2. Call the smallest set of tools. Prefer `state zone` / `state account` digest first; fetch a slice only when the digest signals it. Run independent calls in parallel.
3. Lazy-load references that match findings: `30-recipes.md` for orchestration, `<NN>-<area>.md` per finding, `19-stack-best-practices/<stack>.md` per stack.
4. Synthesize the report. Group by area; mark `OK / WARN / FAIL`; surface paid-only items as `[locked: <tier>+]` with one-line value statements from `10-plan-tier-matrix.md`.
5. For project file changes (`fix project`, `fix gha`, `fix wrangler-lint`, `fix security-txt`), the tool emits proposed contents + unified diff:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` / `Write` after user confirms. Skill never writes inside the user's project. For Workers secrets, the tool emits `wrangler secret put NAME` invocations — never type secret values yourself.

## Recipes

`references/30-recipes.md` — read for any specific recipe (audit, migrate, scaling, diagnose, attack response).

## Guardrails

- Refuses legacy global API key (`CLOUDFLARE_API_KEY` + `CLOUDFLARE_EMAIL`); redirect to scoped tokens.
- `fix` is idempotent — no-op when state matches target.
- `panic` records each action to `.state/panic-<ts>.json`; `panic restore` rolls back.
- D1 is SQLite — never propose as a MySQL or Postgres replacement.
- Honest verdicts: PHP/Rails/Django often get `proxy-only` or `not-recommended`. Surface that first.
