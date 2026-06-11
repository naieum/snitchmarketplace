# Monitoring and alerts

## Monitoring agent

Free; ships in current marketplace images. Install:

```bash
curl -sSL https://repos.insights.digitalocean.com/install.sh -o /tmp/install.sh
sudo bash /tmp/install.sh
```

Or set `monitoring: true` at create time / via `enable_monitoring` action.

## Alert policies

| Metric | Threshold | Why |
|---|---|---|
| `v1/insights/droplet/cpu` | >80% / 5min | Saturation |
| `v1/insights/droplet/memory_utilization_percent` | >80% / 5min | OOM risk |
| `v1/insights/droplet/disk_utilization_percent` | >85% | Disk fill = #1 outage cause |
| `v1/insights/droplet/load_15` | >4 * vCPUs | IO wait or stuck |
| `v1/insights/droplet/public_outbound_bandwidth` | >1 GB / 5min | Exfil or runaway loop |
| `v1/insights/lbaas/avg_cpu_utilization_percent` | >80% | LB saturation |
| Billing balance | >$X | Spend cap |

## Channels

| Channel | Detail |
|---|---|
| Email | Always available; verify delivery to IT inbox |
| Slack webhook | Per-policy; rotate URL annually |
| PagerDuty | Paid plans only |

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | No alert policies on any prod Droplet |
| 🔴 FAIL | Slack webhook in a public repo (rotate immediately) |
| 🟡 WARN | Alerts emailing one person |
| 🟡 WARN | No billing/balance alert |

## Logs

DigitalOcean has no built-in centralized logging. Ship to:

- Papertrail / Loggly / Datadog / New Relic (commercial)
- Self-hosted Loki + Grafana on a Droplet
- App Platform Logs API (retention is plan-dependent)
