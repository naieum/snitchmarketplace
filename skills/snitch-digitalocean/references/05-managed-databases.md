# Managed Databases

DigitalOcean offers Managed Postgres, MySQL, Redis (Valkey), MongoDB, OpenSearch, and Kafka.

## Hardening checklist

| Item | Detail |
|---|---|
| TLS-only | Postgres `sslmode=require` (or `verify-full`). MySQL `--ssl-mode=REQUIRED`. Redis `rediss://`. Mongo `tls=true`. |
| Trusted sources | Populate with Droplet IDs, tags, k8s clusters, or IPs. Empty = cluster accepts auth from anywhere. |
| VPC-attached | Set `private_network_uuid`; clients connect on the private network. |
| Backups | Automatic daily; retention by plan tier. |
| PITR | Postgres / MySQL only. Verify enabled for prod clusters. |
| Read replicas | Route reporting / analytics off primary. |
| Maintenance window | Set a low-traffic schedule. |
| Version | Stay on a supported release line. |
| Connection pooling | Built-in pools on Postgres/MySQL. Size to app concurrency, not DB CPU count. |

## Trusted-source rules

```bash
doctl databases firewalls append <id> --rule "tag:web-tier"      # autoscaling-friendly
doctl databases firewalls append <id> --rule "droplet:<id>"
doctl databases firewalls append <id> --rule "ip_addr:1.2.3.4"
doctl databases firewalls append <id> --rule "k8s:<cluster-id>"
```

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | Trusted-sources empty |
| 🟡 WARN | No VPC attachment (clients use public network) |
| 🟡 WARN | Outdated minor version |
| INFO | No read replicas for >100 GB read-heavy clusters |

## SQLite / D1

DigitalOcean does **NOT** offer a SQLite or D1 equivalent. Migrating from Cloudflare D1 → port to Managed Postgres.
