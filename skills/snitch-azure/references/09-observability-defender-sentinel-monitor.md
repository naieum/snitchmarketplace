# Observability: Defender, Sentinel, Monitor

## Azure Monitor (Log Analytics)

Data plane. Activity Log + diagnostic settings stream here.

| Setting | Target |
|---|---|
| Retention | 30d default; prod 90+; archive 7y for regulated |
| Daily cap | set to control cost (alert before cap) |
| Linked Storage | for archive |

## Defender for Cloud

| Tier | Capability |
|---|---|
| Free | secure score, basic recommendations |
| Standard | paid; threat detection, VA, regulatory compliance |

Workloads to enable Standard on (prod): VirtualMachines, AppServices, StorageAccounts, SqlServers, KeyVaults, Arm, Dns, ContainerRegistry, KubernetesService, OpenSourceRelationalDatabases, CosmosDbs.

`fix defender` warns on each Free workload. Cost: see `references/10-plan-tier-matrix.md`.

## Sentinel

SIEM/SOAR on a Log Analytics workspace. Paid (commitment tiers, per-GB). Recommended connectors: AzureActivity, AzureActiveDirectory, MicrosoftDefenderAdvancedThreatProtection, Office365, AzureFirewall, MicrosoftCloudAppSecurity. `apply_sentinel` emits guidance only.

## Activity Log → diagnostic settings

Stream subscription activity log to:

1. Log Analytics workspace — Sentinel + alerting.
2. Storage account — long-term retention (1y+).
3. Event Hub — external SIEM.

`fix activitylog` checks all three.

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| No diagnostic settings on subscription | FAIL | `fix activitylog` |
| Diagnostic settings only to LA | WARN | Add Storage target |
| Defender Free on prod workloads | WARN | `fix defender` |
| No Sentinel | INFO | Recommend if regulated / large org |
| Workspace retention < 90d | WARN | Bump to 90+ |
| No daily cap on workspace | WARN | Cost runaway risk |

## Docs

- Azure Monitor: https://learn.microsoft.com/en-us/azure/azure-monitor/overview
- Defender for Cloud: https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction
- Sentinel: https://learn.microsoft.com/en-us/azure/sentinel/overview
- Activity log: https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log
