---
name: snitch-digitalocean
description: DigitalOcean security + readiness skill. Thin tools for the agent to compose. Detects the user's project, audits account/Droplet/Database/Spaces/App-Platform/DOKS/LB/Firewall/Registry/Functions/VPC/DNS/Monitoring posture, applies idempotent hardening, and produces honest migration / scaling guidance. Triggers on audit my DigitalOcean account, harden DigitalOcean, DO security audit, secure my Droplets, secure DigitalOcean Spaces, should I move to DigitalOcean, DOKS audit, DO scaling readiness, DigitalOcean best practices, DigitalOcean firewall, DigitalOcean managed databases hardening, DigitalOcean App Platform audit.
---

# snitch-digitalocean

Orchestrate `~/.claude/skills/snitch-digitalocean/snitch-digitalocean.sh`. Read tools emit JSON; `fix` and `panic` are explicit and idempotent. You classify intent, prioritize findings, render prose.

Run `bash ~/.claude/skills/snitch-digitalocean/snitch-digitalocean.sh help` for the surface.

## Setup

- `doctl auth init` writes a context to `~/.config/doctl/config.yaml`. The skill reads the active context or `DIGITALOCEAN_ACCESS_TOKEN`.
- The skill refuses legacy un-scoped tokens and tokens older than one year. Without auth, `doctor` prints the dashboard URL and `templates/token-permissions.checklist.md`.
- Optional: a DigitalOcean MCP. Set `DOSEC_MCP_PRESENT=1` if loaded.

## Read tools

JSON on stdout; errors as JSON on stderr with non-zero exit.

| Subcommand | Returns |
|---|---|
| `doctor` | env health: curl, jq, doctl, token, MCP |
| `detect` | cwd signals: stacks, databases, object_storage, native_deps, ai_providers, vector_dbs, headless_browser, package_managers, current_host_provider, hostnames, do_markers, project_kind |
| `state account` | digest: email, status, team, billing, 2FA. Slices: `team`, `tokens`, `audit`, `full` |
| `state droplets` | digest: count, regions, sizes, backup/monitoring/password-auth coverage. Slices: `list`, `full` |
| `state databases` | digest: count, engines, TLS, trusted-source coverage, retention. Slices: `list`, `full` |
| `state spaces` | digest: bucket count, regions, public-bucket count, CORS, CDN endpoints. Slices: `list`, `full` |
| `state apps` | digest: count, build env, secrets-vs-vars, health checks, regions. Slices: `list`, `full` |
| `state loadbalancers` | digest: count, HTTPS coverage, redirects, sticky sessions, health checks. Slices: `list`, `full` |
| `state firewalls` | digest: count, attachments, wide-open ports, mgmt exposure. Slices: `list`, `full` |
| `state registry` | digest: repo count, vuln scan, GC, image counts. Slices: `list`, `full` |
| `state kubernetes` | digest: clusters, version, autoscaler, RBAC, scanning, surge upgrade. Slices: `list`, `full` |
| `state functions` | digest: namespace + function count, runtimes, public access. Slices: `list`, `full` |
| `state vpcs` | digest: count, peering, default-VPC count, public-IP droplets. Slices: `list`, `full` |
| `state dns` | digest: domain count, record counts, TTLs. DigitalOcean managed DNS does NOT support DNSSEC. |
| `state monitoring` | digest: alert policy count, channels, retention. Slices: `list`, `full` |
| `state cost` | digest: MTD spend, projected month, top resources, untagged spend. Slices: `list`, `full` |
| `fit-matrix [stack]` | migration verdict + caveats per stack |
| `stack-docs [stack]` | canonical doc URLs for `WebFetch` |
| `score [host...]` | external validators (SSL Labs, Mozilla Observatory, securityheaders, hstspreload) |

## Mutating tools

| Subcommand | Behavior |
|---|---|
| `fix <area> [args]` | idempotent hardening. Areas: `droplets databases spaces firewalls apps kubernetes account dns all` |
| `panic <action> [args]` | `rotate-token`, `firewall-block <ip>`, `spaces-lockdown <bucket>`, `restore`. Confirm with user first. |

Utility: `export`, `terraform`, `verify`, `refresh-docs`, `help`.

## Tool layering

`doctl` is primary. The skill wraps `doctl` for typed reads, falls back to REST (`https://api.digitalocean.com/v2/`) where JSON shaping is cleaner. Prefer a DO MCP for typed inventory reads when present.

## Workflow

1. Classify intent (audit / migrate / scale / diagnose / incident).
2. Run the smallest tool set. Digests first; fetch a slice only when the digest signals it. Run independent calls in parallel.
3. Lazy-load references. `references/30-recipes.md` for recipes; `references/<NN>-<area>.md` per finding; `references/15-stack-best-practices/<stack>.md` per stack.
4. Synthesize the report. Group by area; mark status; surface team-only items with one-line value statements.
5. Project file changes (`fix apps`, `fix kubernetes`) emit proposed contents + diff to stdout:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` or `Write` after user confirmation. The skill never writes inside the user's project.

## Guardrails

- Refuses legacy un-scoped tokens, tokens older than one year, and runs without auth.
- `fix` is idempotent.
- `panic` records actions to `.state/panic-<ts>.json`; `panic restore` rolls back where reversible (token rotation cannot).
- DO managed DNS does NOT support DNSSEC. WARN; recommend Cloudflare DNS or a registrar that signs the zone.
- Honest verdicts: Rails / Django monoliths map to Droplet+Managed-DB or App Platform, not DOKS. Surface that first.
