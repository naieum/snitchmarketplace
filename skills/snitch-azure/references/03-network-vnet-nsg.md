# Networking on Azure

## VNet

- Default subnet quota 1024 per VNet.
- Cross-region peering needs Premium SKU on Bastion / Firewall.
- Reserved IPs per subnet: 5 (network, gateway, DNS x2, broadcast).

## NSG

L3/L4 filtering at subnet OR NIC.

- Priority 100-4096 (lower = higher precedence).
- Default rules at 65000+ (allow VNet-to-VNet, allow LB probe, deny all inbound).
- Source/dest = IP / CIDR / `VirtualNetwork` / `AzureLoadBalancer` / `Internet` / Service Tags.
- Subnet ≤ 1 NSG; NIC ≤ 1 NSG. Both may apply.

## ASG

Tag VMs/NICs by role (`web-tier`, `db-tier`); reference ASGs in NSG rules instead of IPs.

## Azure Firewall

| Tier | Capabilities |
|---|---|
| Basic | dev/test |
| Standard | FQDN filtering, threat intel |
| Premium | TLS inspection, IDPS, URL filtering, web categories |

Forced-tunneling + UDR: gold standard for hub-and-spoke.

## Bastion

Managed RDP/SSH gateway; removes public IPs on VMs.

| Tier | Capabilities |
|---|---|
| Basic | RDP/SSH only |
| Standard | + shareable links, native client, host scaling |

## Endpoints

| Type | Behavior |
|---|---|
| Service Endpoints | VNet → public Azure service via backbone. Service still has public IP. |
| Private Endpoints | Private IP from your VNet to the service (Storage, KV, SQL, Cosmos). No public IP. Preferred for prod. |

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| 0.0.0.0/0 → port 22 / 3389 | FAIL | Replace with Bastion or jump-box allowlist |
| Flow logs disabled | WARN | Enable + retain in LA workspace |
| NSG default-allow on private subnet | WARN | Tighten outbound + add private endpoints |
| Storage account public network access | FAIL | Disable + private endpoint |
| Azure Firewall threat-intel = Off | WARN | Set to Alert (or Block in Premium) |

## Docs

- VNet: https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm
- NSG: https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
- Firewall: https://learn.microsoft.com/en-us/azure/firewall/overview
- Bastion: https://learn.microsoft.com/en-us/azure/bastion/bastion-overview
- Private Endpoints: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview
