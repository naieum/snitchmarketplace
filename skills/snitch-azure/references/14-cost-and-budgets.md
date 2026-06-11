# Cost on Azure

## Budgets

`az consumption budget list`. Every prod sub: budget with notifications at 50%, 75%, 100%.

```sh
az consumption budget create \
  --resource-group <rg> --budget-name monthly-cap \
  --amount 1000 --time-grain Monthly \
  --start-date 2026-01-01 --end-date 2027-01-01 --category Cost \
  --notifications '{"Actual_GreaterThan_50_Percent":{"enabled":true,"operator":"GreaterThan","threshold":50,"contactEmails":["finops@example.com"],"thresholdType":"Actual"}}'
```

## Cost alerts

- Anomaly detection — surfaces unexpected spikes.
- Reservation utilization — under-utilized RIs bleed money.
- Untagged resources — by `owner` / `environment` / `cost-center` for chargeback.

## Cost cliffs

| Driver | Watch for | Mitigate |
|---|---|---|
| Log Analytics ingestion | $5K/mo on chatty cluster | Daily cap + filter at source |
| Defender Standard plans | $15/VM + per-vCore-hr | Per-workload, not all-at-once |
| Front Door Premium base | $330/mo before traffic | Premium only for private origins; Standard otherwise |
| Sentinel ingestion | $2-5/GB | Pre-filter; pay-as-you-go vs commitment |
| Storage egress (cross-region) | 5x same-region | Pin storage to compute region |
| AKS load balancer rules | $0.025/rule/hr at scale | Use AGIC |
| Public IPs (Standard) | $0.005/hr each | Bastion / Firewall, drop direct public IPs |
| Always-on VMs in dev | 24x7 billing | DevTest Labs auto-shutdown / Azure Automation |

## Tagging

Required tags via Azure Policy: `owner`, `environment`, `cost-center`, `app`. `state tags` flags untagged resources.

## Reservations

| Term | Discount |
|---|---|
| 1-year RI | ~30% off PAYG |
| 3-year RI | ~50-65% off PAYG |
| Compute Savings Plan | flexible; smaller discount than RI |

Don't reserve dev/test or unstable workloads.

## Docs

- Cost best practices: https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices
- Anomaly detection: https://learn.microsoft.com/en-us/azure/cost-management-billing/understand/analyze-unexpected-charges
