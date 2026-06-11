# Droplets

## Hardening checklist

| Item | Detail |
|---|---|
| SSH key-only | `/etc/ssh/sshd_config`: `PasswordAuthentication no`, `PermitRootLogin prohibit-password`. DO API can't inspect — skill emits WARN per droplet. |
| Backups | ~20% of price; daily, 7-day retention. `enable_backups` action. |
| Monitoring agent | Free; CPU/mem/disk/bandwidth + alert eligibility. |
| IPv6 | Enable on every droplet (free). |
| Reserved IP | DNS-stable services keep public IP across rebuilds. |
| Cloud Firewall | See `02-network-vpc-firewalls.md`. |
| Named VPC | Not the default VPC. Use private interface for intra-cluster traffic. |
| Image freshness | Rebuild from a current image every 6 months — managed images don't auto-patch. |

## Commands

```bash
doctl compute droplet-action enable-backups <droplet-id>
doctl compute droplet-action enable-monitoring <droplet-id>
doctl compute droplet-action enable-ipv6 <droplet-id>
```

## Snapshots vs Backups

| Type | Cost | Retention | Use |
|---|---|---|---|
| Backups | ~20% droplet price | 7d auto | Standard recovery |
| Snapshots | $0.06/GB/mo | None (kept forever) | Restore points before risky changes |

## Skill checks

| Check | Status |
|---|---|
| No firewall coverage | 🔴 FAIL |
| No `backups` feature | 🟡 WARN (paid; flag for cost confirm) |
| No `monitoring` feature | 🟡 WARN |
| In default VPC | 🟡 WARN |
| Image age >180d | 🟡 WARN |
| No `ipv6` | INFO |
