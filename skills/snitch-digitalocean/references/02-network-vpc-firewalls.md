# Networking, VPC, Cloud Firewalls

## VPCs

- Every account has a default VPC per region (auto-created). Resources without `vpc_uuid` join it.
- Use a named VPC per environment (prod / staging / dev) with non-default IP ranges. Never rely on the default.
- VPCs are regional. **Cross-region VPC peering is not supported** for managed resources.

## Cloud Firewalls

Allowlist-based stateful firewalls.

- Inbound rules: protocol + port + sources (addresses, droplet IDs, tags, k8s clusters, LBs).
- Outbound rules: protocol + port + destinations.
- Apply by droplet ID or **tag** (preferred — new droplets matching the tag inherit rules).

### Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | Mgmt port world-open: 22, 3389, 5432, 3306, 27017, 6379 with `0.0.0.0/0`. Restrict to office CIDR or `bastion` tag. |
| 🔴 FAIL | Wide-open ranges `1-65535` on `0.0.0.0/0`. |
| 🟡 WARN | Droplet without firewall membership. |
| 🟡 WARN | Outbound unrestricted on databases (DBs shouldn't initiate outbound). |

### Tag pattern

```
tag: web                          # web tier
tag: db-access                    # apps that need DB
tag: bastion                      # SSH bastion(s)

firewall: web-tier                # 80/443 from world; 22 only from bastion
  tags: [web]
firewall: bastion                 # 22 from office only
  tags: [bastion]
```

## Floating / Reserved IPs

DigitalOcean's Floating IPs are now **Reserved IPs**. Audit unused — they cost money when unattached.

## Private networking

- Droplets in a VPC have a private interface (`eth1`). Use the private IP for intra-VPC traffic.
- Managed databases support `private_network_uuid`; clients in the same VPC reach the DB on the private endpoint.
