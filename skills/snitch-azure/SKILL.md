---
name: snitch-azure
description: Azure security + readiness skill. Thin tools for the agent to compose. Detects the user's project, audits subscription/Entra/RBAC/Defender/Sentinel/storage/keyvault/compute/database/network posture, applies free + plan-tier hardening, and produces honest migration / scaling guidance. Triggers on audit my Azure subscription, harden Azure, Azure security audit, secure my Azure resources, should I move to Azure, Azure RBAC audit, Defender for Cloud setup, Azure scaling readiness, Azure incident response.
---

# snitch-azure

You orchestrate. `~/.claude/skills/snitch-azure/snitch-azure.sh` exposes thin tools — read tools emit JSON; `fix` and `panic` are explicit and idempotent. You classify intent, prioritize findings, render prose. Run `bash ~/.claude/skills/snitch-azure/snitch-azure.sh help` for the full surface.

## Setup

- `az login` (interactive) or `az login --identity` (managed-identity context). Pin a subscription with `AZSEC_SUBSCRIPTION_ID`.
- Skill refuses when `AZURE_CLIENT_SECRET` is set alongside WI/MI markers (`AZURE_FEDERATED_TOKEN_FILE`, `MSI_ENDPOINT`, `IDENTITY_ENDPOINT`, `ACTIONS_ID_TOKEN_REQUEST_TOKEN`). Drop the secret; use OIDC / MI.
- If an Azure MCP is loaded, set `AZSEC_MCP_PRESENT=1`.

## Tools

Read-only (JSON on stdout, errors as JSON on stderr). Each `state <area>` accepts a slice (`digest` default | `<resource>` | `full`).

| Subcommand | Returns |
|---|---|
| `doctor` | env health, login, MCP, secret-leak guard |
| `detect` | cwd signals: stacks, databases, object_storage, native_deps, ai_providers, vector_dbs, headless_browser, package_managers, current_host_provider, iac_signals, hostnames, project_kind |
| `state tenant` | id, default domain, B2B |
| `state subscription [id]` | meta, locks, owners, budgets |
| `state entra` | users/groups/apps/SPs, MFA hint, CA, legacy-auth |
| `state rbac [scope]` | role assignments, custom-vs-builtin, deny |
| `state policy` | initiatives, compliance, remediation |
| `state defender` | per-workload plan, secure score, recommendations |
| `state sentinel` | workspaces, connectors, rules, incidents |
| `state storage` | HTTPS, public access, shared-key, soft-delete, encryption, network |
| `state keyvault` | soft-delete, purge, RBAC, network ACL, expiring keys/certs |
| `state vm` | public IPs, NSG mgmt-ports, encryption-at-host, JIT, agents |
| `state appservice` | HTTPS, TLS, FTPS, SCM basic, identity, slots |
| `state functions` | HTTPS, identity, runtime |
| `state aks` | version, network policy, AAD, RBAC, defender |
| `state acr` | scan, retention, network, content trust |
| `state sql` | TDE, AAD, Defender, audit, public access |
| `state cosmos` | TLS, AAD, firewall, PE, CMK |
| `state postgres` / `state mysql` | TLS, AAD, firewall, PE |
| `state appgw` / `state frontdoor` | WAF mode, policy, TLS |
| `state dns` | zones, DNSSEC note |
| `state nsg` | 0.0.0.0/0 mgmt ports, flow logs |
| `state firewall` / `state bastion` | tier, threat-intel; Bastion vs public RDP/SSH |
| `state backup` | RSV: soft-del, MUA, immutability, cross-region |
| `state cost` | budgets, spend, untagged |
| `state tags` | required-tag policy + coverage |
| `state activitylog` | diagnostic-settings (LA + Storage + Event Hub) |
| `analytics subscription [w]` | activity-log totals, top callers, top resources (`1h \| 24h \| 7d`) |
| `events subscription [w]` | recent activity-log entries |
| `fit-matrix [stack]` | migration verdict + caveats |
| `stack-docs [stack]` | canonical doc URLs to `WebFetch` |
| `score [host...]` | SSL Labs, Mozilla Observatory, securityheaders, hstspreload |

Mutating (idempotent):

| Subcommand | Behavior |
|---|---|
| `fix <area>` | hardening for one area: `storage keyvault appservice sql cosmos postgres mysql nsg defender sentinel backup dns subscription tags policy activitylog all` |
| `panic <action>` | `lockdown <rg>`, `nsg-deny-all <nsg>`, `keyvault-rotate <vault>`, `policy-emergency`, `restore`. Confirm with user first. |

Utility: `export`, `terraform`, `verify`, `refresh-docs`, `help`.

## MCP / CLI division

If `AZSEC_MCP_PRESENT=1`, prefer the Azure MCP for typed inventory (RGs, subs, KV list, Storage list, RBAC). Use this skill for security-shape state, mutations, and offline tools (`detect`, `fit-matrix`, `stack-docs`, `score`). Without MCP, this skill works fully via `az`.

## How to use

1. Classify intent (audit, migrate, scale-plan, diagnose, incident).
2. Call the smallest set of tools. Prefer digest mode first; fetch slices only when a digest signals it. Run independent calls in parallel.
3. Lazy-load references that match findings: `references/30-recipes.md` for orchestration; `references/<NN>-<area>.md` per finding; `references/15-stack-best-practices/<stack>.md` per stack.
4. Synthesize the report. Group findings by area; mark `FAIL / WARN / OK / N/A`; surface paid items as `[locked: <plan>+]` with the value statement from `references/10-plan-tier-matrix.md`.
5. For project file changes (Bicep / ARM / Terraform / GHA / `staticwebapp.config.json`), the tool emits proposed contents + unified diff:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` / `Write` after user confirms. The skill never writes inside the user's project. For Key Vault secrets, the tool emits `az keyvault secret set ... --value <user-supplied>` — never type secret values yourself.

Canonical recipes in `references/30-recipes.md`.

## Guardrails

- Refuses `AZURE_CLIENT_SECRET` when WI/MI is available.
- Refuses no-auth: `az account show` must succeed.
- `fix` is idempotent; no-op when state matches target.
- `fix nsg` will not strip a 0.0.0.0/0 mgmt-port rule without explicit confirmation.
- `panic` records each action to `.state/panic-<ts>.json`; `panic restore` rolls back.
- DNSSEC on Azure DNS is not GA — surface as `WARN` with a doc pointer.
- Honest verdicts: PHP/Rails/Django on Azure map to App Service or Container Apps (works, with caveats).
