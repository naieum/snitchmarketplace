# 18 — Cost Model

Snapshot 2026-05. `refresh-docs` updates; defer to live pages.

## Workers

| Item | Free | Paid ($5/mo base) |
|---|---|---|
| Requests | 100k/day | 10M/mo, then $0.30/M |
| CPU | 10ms/req | 30s/req, $0.02/M CPU-ms beyond included |
| Subrequests/req | 50 | 1000 |
| Logs | 200k events/d, 3-day | 20M events/d, 7-day |
| Smart Placement / Cron Triggers | n/a | included |

https://developers.cloudflare.com/workers/platform/pricing/

## Pages

Free: 1 concurrent build, 500 builds/mo, unlimited static delivery + bandwidth + custom domains. Pages Functions tracks Workers Paid.

https://developers.cloudflare.com/pages/platform/limits/

## R2

| Item | Free | Paid |
|---|---|---|
| Storage | 10 GB-mo | $0.015/GB-mo |
| Class A (PUT/LIST/COPY/DELETE) | 1M/mo | $4.50/M |
| Class B (GET/HEAD) | 10M/mo | $0.36/M |
| Egress to internet | $0 | $0 |

https://developers.cloudflare.com/r2/pricing/

## KV

| Item | Free | Paid |
|---|---|---|
| Reads | 100k/d | $0.50/M |
| Writes / Deletes / Lists | 1k/d each | $5/M |
| Storage | 1 GB | $0.50/GB-mo |

https://developers.cloudflare.com/kv/platform/pricing/

## D1

| Item | Free | Paid |
|---|---|---|
| Storage | 5 GB | $0.75/GB-mo |
| Rows read | 5M/d | $0.001/1k |
| Rows written | 100k/d | $1/M |
| Databases | 10 | unlimited |

https://developers.cloudflare.com/d1/platform/pricing/

## Durable Objects (Workers Paid required)

- Requests $0.15/M.
- Duration $12.50/M GB-second active.
- Storage $0.20/GB-mo.
- Read units $0.20/M, write units $1.00/M.

https://developers.cloudflare.com/durable-objects/platform/pricing/

## Hyperdrive

Free with Workers Paid. No per-query fees. Cost driver = origin DB bill, not Cloudflare's. https://developers.cloudflare.com/hyperdrive/platform/pricing/

## Vectorize / Workers AI / AI Gateway

See `17a-ai-offerings.md`. Vectorize $0.04/M queried dim, $0.05/100M stored dim/mo. Workers AI ~$0.011 / 1k Neurons. AI Gateway free 100k logged req/mo.

## Argo Smart Routing

Usage-based, ~$0.10/GB delivered. Worth it when origin latency variance is high or origin is far from users.

## Logpush (Enterprise)

Per-record fees by log type + destination. Sample at 0.1 for high-volume zones.

## Page Shield

Pro $25/mo: script monitor. Business $250/mo: connection + cookie monitor + enforcement. No per-event fees.

## Aegis (Enterprise)

Dedicated egress IPs. Per-deal.

## Stream / Images

- Stream: $5/1k min stored, $1/1k min delivered.
- Images: $5/100k stored, $1/100k delivered, polish included.

## Plan upgrade math

| From → To | Net | Notes |
|---|---|---|
| Free → Pro | +$25/mo | CF Managed + OWASP CRS, Super BFM, 20 custom rules, `log` action, Page Shield script monitor, ACM available |
| Pro → Business | +$225/mo | Regex in custom rules, payload logging, 100 custom rules, Page Shield connection+cookie, Custom Certs |
| Business → Enterprise | varies | API Shield, Bot Management ML, account-level WAF, SSO, Logpush, Aegis, account team |
| Free → Workers Paid | +$5/mo | Required for >100k req/d, Cron Triggers, Hyperdrive, DOs, Smart Placement, Vectorize, Workers AI past free |
| Free → Zero Trust seats | $7/seat/mo past 50 | Access, Gateway, Browser Isolation pro features |

## How `cost.sh` uses this

Reads Analytics last 7d → projects monthly → applies free tiers → estimates bill. Honest framing if Cloudflare is more expensive than the user's current host. See `23-cost-cliffs.md`.

`refresh-docs` re-pulls live pricing and prints "pricing data is N days old".
