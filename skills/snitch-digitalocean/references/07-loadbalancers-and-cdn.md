# Load Balancers and CDN

## Load Balancers

L4/L7 with TLS termination, sticky sessions, droplet-level health checks.

| Item | Detail |
|---|---|
| HTTPS rule | Every public LB has `entry_protocol: https`. HTTP-only is a downgrade vector. |
| Redirect HTTP → HTTPS | `redirect_http_to_https: true`. |
| Modern TLS | Select modern policy (TLS 1.2+, ECDSA preferred). Verify on legacy LBs. |
| Health check | HTTP path or TCP with sane thresholds. |
| Sticky sessions | Only when needed (WebSockets, server-side sessions). Off for stateless. |
| Backends in same VPC | Cross-VPC backends route over public network. |
| Cert | Let's Encrypt managed (free, auto-renew). Wildcards: upload your own. |
| PROXY protocol | Enable when upstream consumes original-client-IP headers. |

### Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | LB with HTTP-only forwarding (no HTTPS) |
| 🟡 WARN | LB without `redirect_http_to_https` |
| 🟡 WARN | LB without health check |
| INFO | Sticky sessions on stateless backends (cost / scaling tradeoff) |

## Spaces CDN

- CDN sits in front of a Spaces bucket. Use custom subdomain + Let's Encrypt cert.
- TTL: 3600s default; bump for static assets, lower for HTML.
- Purge per-path. Use deploy-time hashed filenames for safety.

For DDoS / WAF / DNSSEC, put **Cloudflare DNS in front** (orange-cloud). DigitalOcean has no L7 WAF and no DNSSEC on managed DNS.
