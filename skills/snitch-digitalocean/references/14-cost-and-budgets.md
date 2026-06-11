# Cost and budgets

DO charges per hour for most resources, prorated to the second on Droplets / DBs / DOKS. Spaces and CDN are GB-month / GB-egress-month.

## Where to look

| Where | What |
|---|---|
| `bash snitch-digitalocean.sh state cost` | MTD balance, recent charges, recent invoices |
| https://cloud.digitalocean.com/account/billing | Full breakdown by resource |
| https://cloud.digitalocean.com/account/billing/notifications | Configure spend alert thresholds |

## Budget alerts

DO supports balance threshold alerts:

- Alert when MTD spend exceeds $X (per account).
- Alert when balance is low (prepaid).

Set both. Skill warns if no billing alert exists.

## Cost-cliff watchlist

| Driver | Detail |
|---|---|
| Backups | ~20% of droplet price |
| Reserved IPs | Free if attached, **$5/mo each unattached** |
| Snapshots | $0.06/GB/mo; accumulate forever unless deleted |
| Spaces egress | ~1 TB outbound/TB stored free; over = $0.01/GB |
| Managed DB read replicas | Each costs same as primary |
| DOKS HA control plane | $40/mo extra over standard |
| DOKS load balancers | One per `LoadBalancer` Service. Aggregate via Ingress controller. |
| App Platform Pro | $12/mo + per-component costs |
| GPU droplets | $$$$. Verify intent on every spin-up. |

## Rightsizing

Droplets:

- <30% utilization for 30+d → downsize one tier.
- >80% sustained → upsize OR scale horizontally.

Managed DBs:

- Connection count near pool limit → upsize.
- Replication lag >30s → upsize replica or reduce load.

## Tagging for cost attribution

DO supports tags on Droplets, DBs, LBs, firewalls, k8s, snapshots, volumes, Spaces.

```
env:prod | env:staging | env:dev
team:backend | team:frontend | team:data
project:<name>
```

Group costs by tag in the dashboard. Untagged = unowned.

## Idle-resource hunt

```bash
doctl monitoring metrics droplet cpu --droplet-id <id> --start <ago>
doctl compute reserved-ip list --format IP,Region,DropletID
doctl compute snapshot list --resource droplet --format ID,Name,CreatedAt,SizeGigabytes
```
