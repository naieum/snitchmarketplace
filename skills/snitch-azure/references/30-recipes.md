# Recipes — when the user asks X, do Y

The agent synthesizes; shell tools provide facts.

## Audit / harden a subscription

```
bash snitch-azure.sh doctor
bash snitch-azure.sh detect
bash snitch-azure.sh state subscription
bash snitch-azure.sh state entra
bash snitch-azure.sh state defender
bash snitch-azure.sh state storage
bash snitch-azure.sh state keyvault
bash snitch-azure.sh state appservice
bash snitch-azure.sh state nsg
bash snitch-azure.sh state activitylog
```

Run in parallel. Digests are ~85% smaller than full payloads. If `AZSEC_MCP_PRESENT=1`, also pull resource inventory via MCP.

Then:

1. Compare `state.subscription.*` to `references/02-entra-and-rbac.md`, `04-storage.md`, `06-compute-vm-appservice-aks-functions.md`.
2. Compare `state.entra.conditional_access_summary` against `02-entra-and-rbac.md` (CA must include block-legacy-auth + admin-MFA).
3. Compare `state.defender.pricing_summary` against `10-plan-tier-matrix.md` — flag Free workloads on prod.
4. Fetch slices only when a digest demands: `state storage accounts` if `https_only_violations > 0`; `state nsg nsgs` for offending rules.
5. Group findings; emit `FAIL / WARN / OK / N/A`. Mark plan-locked items `[locked: <tier>+]` with the value statement.
6. Ask which areas to fix. For each: `bash snitch-azure.sh fix <area>`. Then `bash snitch-azure.sh verify`.

## "Should I migrate to Azure?"

Offline.

```
bash snitch-azure.sh detect
bash snitch-azure.sh fit-matrix <stack>
bash snitch-azure.sh stack-docs <stack>
```

`WebFetch` each URL from `stack-docs`; `WebSearch` `<stack> azure security best practices <year>` and `<stack> security advisory <year>`.

| Verdict | Render |
|---|---|
| `strong` | App Service / Container Apps / Static Web Apps + DNS cutover |
| `partial` | Same plan but flag every `entry.dependencies_to_flag` and `entry.caveats` item |
| `proxy-only` | Keep origin; Front Door + WAF in front. Stop. |
| `not-recommended` | Rare on Azure; same as proxy-only |

DB honesty: MySQL → Azure DB for MySQL Flexible. Postgres → Azure DB for PostgreSQL Flexible. SQL → Azure SQL. MongoDB → Cosmos for MongoDB API OR MongoDB Atlas on Azure (compatibility caveat). Redis → Azure Cache for Redis. S3 → Blob via azcopy.

End with cost realism (`14-cost-and-budgets.md`), DNS cutover steps, rollback path.

## Scaling readiness ("10k users?")

```
bash snitch-azure.sh state subscription
bash snitch-azure.sh state appservice
bash snitch-azure.sh state sql
bash snitch-azure.sh detect
bash snitch-azure.sh analytics subscription 7d
```

Pick the user's plateau. Render the next plateau's checklist with present items marked `OK`. Small scale: App Service Basic + SQL DTU + single region. Growth scale: slots, autoscale, geo-redundant DB, Front Door, Defender Standard.

## Diagnose

| Symptom | Tools |
|---|---|
| App Service slow | `state appservice` + `analytics subscription 24h` |
| 502/503 from Front Door | `state frontdoor` + origin App Service health |
| Storage throttling | `state storage` + activity-log |
| Cert error | `state appservice` (managed cert state) |
| Deployment failed | `events subscription 1h` |
| Bill spike | `analytics subscription 7d` + `state cost` |
| Suspicious sign-ins | `events subscription 24h` filter on roleAssignments |

## "We're under attack"

```
bash snitch-azure.sh events subscription 1h
bash snitch-azure.sh panic lockdown <rg>
bash snitch-azure.sh panic nsg-deny-all <nsg>
bash snitch-azure.sh panic keyvault-rotate <vault>
bash snitch-azure.sh panic restore   # after attack ends
```

Postmortem: `references/13-incident-response.md`.

## Report format — required

Every audit / migrate / roadmap report MUST:

- Open with a one-line verdict.
- Use markdown tables (no bare `[FAIL] foo` lines).
- Close with "Next steps" — at most 3 imperative bullets.
- No prose paragraphs between sections except a single transitional sentence.

Status column uses these badges. Sort 🔴 → 🟡 → ⚪️ → 🟢.

| Badge | Meaning |
|---|---|
| 🔴 | FAIL |
| 🟡 | WARN |
| ⚪️ | N/A (locked behind plan/SKU/license) |
| 🟢 | OK |

### Findings

```markdown
| Status | Area | Finding | Remediation |
|---|---|---|---|
| 🔴 | storage | 3 accounts allow blob public access | `fix storage` |
| 🟡 | entra | no Conditional Access policies | Apply `templates/entra-conditional-access.starter.json` |
| ⚪️ | defender | Defender for VMs gated behind Standard | Upgrade ($15/VM/mo) |
| 🟢 | keyvault | all 4 vaults have soft-delete + RBAC | — |
```

### Architecture inventory

```markdown
| Component | Detail | Source |
|---|---|---|
| App Service | webapp-prod (Linux, Node 20) | rg-prod / asp-prod |
| Storage | sastorage1 (CMK, public access off) | rg-prod |
| Postgres | psql-prod (Flexible, AAD, ZoneRedundant) | rg-prod |
```

### Cost / scaling

```markdown
| Driver | Current | Watch for |
|---|---|---|
| App Service Plan | P1v3 single instance | scale-out at >70% CPU |
| SQL DB | S2 DTU | upgrade to vCore Business Critical at >50 active users |
```

### Migration verdict

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| express | strong | App Service Linux Node 20 OR Container Apps |
| laravel | strong | App Service Linux PHP 8.2 |
| nextjs | strong | Static Web Apps (Hybrid) OR App Service Linux for full SSR |
```

## Common mistakes

- Don't pre-load all of `references/`. Read only files relevant to the current finding.
- Don't suggest Cosmos for MongoDB API as a drop-in for MongoDB Atlas without flagging compatibility.
- Don't recommend Defender Standard on every workload by default — call out cost.
- Don't auto-strip 0.0.0.0/0 NSG rules without confirmation.
- Don't write inside the user's project. `fix` emits proposed contents + diff; apply via `Edit` / `Write`.
