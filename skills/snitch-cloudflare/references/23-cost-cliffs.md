# 23 — Cost Cliffs

Bills that surprise. Pricing 2026-05; cite live pages.

## Workers requests

Free 100k req/day; over = rejected. Paid ($5/mo base) 10M/mo; over = $0.30/M.

| Volume | Billed | Monthly |
|---|---|---|
| 5M req/d × 30 = 150M/mo | 140M | ~$42 |
| 10M req/d × 30 = 290M | 280M | ~$87 |
| 100M req/d × 30 = 2.99B | 2.98B | ~$897 |

https://developers.cloudflare.com/workers/platform/pricing/

## R2 Class A operations

`PUT/LIST/COPY/DELETE` = $4.50/M (1M/mo free). Class B (`GET/HEAD`) = $0.36/M (10M/mo free).

Surprises:
- Worker LISTing bucket per request: 10M req/mo = 10M LISTs = $40.50.
- Cron sync uploading 1M small objects/day = 30M PUTs/mo = $135.
- Multipart upload of huge files: each part = Class A op.

Mitigation: cache LIST in KV; batch uploads; index metadata instead of LISTing.

https://developers.cloudflare.com/r2/pricing/

## D1

Free 5M rows read/d, 100k written/d, 5 GB storage. Paid: $0.001/1k reads, $1/M writes, $0.75/GB-mo.

Surprises:
- Chat fan-out 1k subs × 1k msgs/d = 30M writes/mo = $30.
- Per-pageview analytics insert × 1M PV/d = 30M writes/mo = $30.
- N+1 (50 rows/req × 100k req/d = 5M reads/d).

Mitigation: aggregate writes; DO for atomic high-frequency, batch-flush to D1; cache reads in KV with short TTL.

https://developers.cloudflare.com/d1/platform/pricing/

## Durable Objects

$0.15/M req + $12.50/M GB-second active duration + $0.20/GB-mo storage.

Surprise: 1k always-on WS, 128 MB instance: 1000 × 24 × 30 × 3600 × 0.125 GB = 9.7M GB-s = ~$121/mo just for duration.

Mitigation: WebSocket Hibernation API (only pay duration when code runs). Aggregate to per-room DOs. Use alarms for short wakes.

https://developers.cloudflare.com/durable-objects/platform/pricing/ , https://developers.cloudflare.com/durable-objects/api/websockets/

## Vectorize

$0.04/M queried dim, $0.05/100M stored dim/mo. Free 30M queried dim/mo, 5M stored dim.

- 1M vectors @ 1536-dim stored = 1.536B → $0.77/mo.
- 1k queries/d @ topK=10 × 1536-dim = 461M queried/mo → $17.

Surprise: 1536-dim (OpenAI) vs 384-dim (BGE-small) = 4x cost.

https://developers.cloudflare.com/vectorize/platform/pricing/

## Workers AI

~$0.011/1k Neurons. Free 10k Neurons/d rolling.

Surprises: re-embedding uncached content; loop bug calling LLM per render; LlamaGuard pre-screen adds ~150 Neurons/req.

Mitigation: AI Gateway caching; RL on LLM endpoints; cheaper models where adequate.

https://developers.cloudflare.com/workers-ai/platform/pricing/

## AI Gateway

Free 100k logged req/mo. Paid per-request beyond.

Surprise: full-payload logging at 1M req/mo = log-count past free + storage.

Mitigation: metadata-only mode for production; full only for debugging; sample at 0.1.

https://developers.cloudflare.com/ai-gateway/reference/pricing/

## Argo Smart Routing

~$0.10/GB delivered. No free tier. 10 TB/mo = $1k/mo.

Argo helps cache misses, not hits. Push hit rate up first.

https://www.cloudflare.com/application-services/products/argo-smart-routing/

## Logpush (Enterprise)

Per-record fees — varies by log type + destination.

Surprise: full HTTP log at 1B req/mo unsampled = thousands.

Mitigation: sample 0.1 for general, full for security events; push only what you'll query.

https://developers.cloudflare.com/logs/logpush/

## Aegis (Enterprise)

Dedicated egress IPs, per-deal. Tunnel achieves much of the same without per-deal pricing.

## `cost.sh` watchdog

Reads Analytics last 7d, projects monthly, applies free tier. If user's current host is materially cheaper for their shape, say so.

## Billing alerts

Account → Billing → "Notify me when monthly cost exceeds $X." Threshold = 2× current run rate.

Source: https://dash.cloudflare.com/?to=/:account/billing
