# Edge: Front Door, App Gateway, CDN, DNS

## Application Gateway WAF

| Target | Setting |
|---|---|
| Tier | `WAF_v2` (legacy `WAF_v1` deprecated — flag if seen) |
| WAF Policy | `firewallPolicy.id` attached |
| Mode | start `Detection` 1-2 weeks → `Prevention` |
| Rules | OWASP 3.2 + Bot Manager 1.0 |
| TLS policy | `AppGwSslPolicy20220101S` or newer; min `TLSv1_2` |
| HTTP→HTTPS | redirect on listener |

## Azure Front Door

| Tier | Capabilities |
|---|---|
| Standard | global Azure-managed CDN + basic WAF |
| Premium | + private endpoint origins, managed bot rules, per-policy custom rules |

Hardening (Premium):

- WAF mode `Prevention`; managed Microsoft Default Rule Set 2.1+ + Bot Manager.
- Custom rate-limit on `/login`, `/signin`, `/api/auth/`.
- HTTPS-only; redirect 80→443.
- Origin: private endpoint.
- Custom domains with managed certs (auto-rotated).

## Azure CDN (classic)

`Microsoft.Cdn/profiles` of SKU `Standard_Verizon` / `Standard_Akamai` retiring → `WARN`. Migrate to Front Door Standard/Premium.

## Azure DNS

- Public zones: DNSSEC support is preview / limited GA → `WARN`. https://learn.microsoft.com/en-us/azure/dns/dnssec
- Private zones: internal-only; pair with VNet links.
- CAA: Azure DNS supports; recommend `issue letsencrypt.org` (or your CA).
- TTL: 3600 default; lower (300-600) before cutover.

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| App Gateway WAF v1 | WARN | Migrate to WAF_v2 |
| WAF mode = Detection on prod | WARN | Move to Prevention after observation |
| TLS policy < TLS1_2 | FAIL | Update SSL policy |
| Front Door classic (deprecating) | WARN | Migrate to Standard/Premium |
| No CAA records | WARN | Add `issue <ca>` |
| DNSSEC desired | WARN | Limited GA — verify before relying |
| DNS zone with stale records | WARN | Audit + clean up |

## Docs

- App Gateway WAF: https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview
- Front Door WAF: https://learn.microsoft.com/en-us/azure/frontdoor/web-application-firewall
- Azure DNS: https://learn.microsoft.com/en-us/azure/dns/dns-overview
- DNSSEC (preview): https://learn.microsoft.com/en-us/azure/dns/dnssec
