# 24 — Decision Trees

Pick the right Cloudflare primitive when abstractions overlap.

## Custom Rule vs Configuration vs Transform vs Redirect vs Cache vs Origin vs Worker

| Want to | Use |
|---|---|
| Block / challenge / log / skip a request | Custom Rule (WAF) |
| Override a zone setting per request (cache, security level, BFM) | Configuration Rule |
| Rewrite URL path / query / host | Transform Rule (URL Rewrite) |
| Modify request/response headers | Transform Rule (Header Modification) |
| 301/302/307/308 | Redirect Rule (replaces Page Rules) |
| Per-request cache TTL / eligibility / key | Cache Rule |
| Per-request origin selection | Origin Rule |
| Custom multi-step logic | Worker |

Page Rules are legacy — migrate to modern equivalents.

Source: https://developers.cloudflare.com/rules/page-rules/

## WAF Rate Limit Rule vs Workers Rate Limit binding

| Need | Use |
|---|---|
| Edge per-IP throttle, no code | WAF Rate Limit Rule |
| Per-user / per-tenant / per-resource | Workers Rate Limit binding |
| Atomic counter | Durable Object |
| LLM token cost throttle | Workers binding with `cost: estimatedTokens` |

Common: WAF RL at edge for brute-force defense (cheap, doesn't hit Worker), Workers binding for fine-grained per-user quotas.

Sources: https://developers.cloudflare.com/waf/rate-limiting-rules/ , https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/

## Pages vs Workers vs Pages Functions

| Need | Use |
|---|---|
| Pure static | Pages (static) |
| Static + a few endpoints | Pages with Functions |
| Heavy SSR | Pages + framework adapter, OR Workers |
| Pure API | Workers |
| Git-based deploys + preview branches | Pages |

Pages Functions are Workers under the hood. Big sites often run Pages frontend + separate Workers backend.

Sources: https://developers.cloudflare.com/pages/functions/ , https://developers.cloudflare.com/workers/

## D1 vs Hyperdrive vs DO storage vs KV

| Need | Use |
|---|---|
| New Cloudflare-native SQL | D1 (SQLite — not MySQL/Postgres) |
| Existing Postgres / MySQL | Hyperdrive — do NOT migrate to D1 |
| Atomic counters / lock state | Durable Object |
| Eventually-consistent (sessions, flags) | KV (1/s write per key, ~60s replication) |
| Per-room / per-user state + WS | Durable Object |
| Time-series / append-only logs | Workers Analytics Engine or external |
| Vectors (RAG) | Vectorize |
| Object storage | R2 |

D1 wrong: existing Postgres/MySQL app, multi-region writes, heavy concurrent writes. D1 right: greenfield + SQLite-friendly, read-heavy CRUD.

Source: https://developers.cloudflare.com/d1/

## Hyperdrive vs direct DB

Prefer Hyperdrive for any Postgres/MySQL access from Workers. Free with Workers Paid; you pay only the origin DB. Direct TCP only for nano-prototypes.

Source: https://developers.cloudflare.com/hyperdrive/

## Origin protection: Tunnel vs IP allowlist vs AOP

| Need | Use |
|---|---|
| Origin you control | Cloudflare Tunnel (best — no public origin IP) |
| Public IP, can't run cloudflared | IP allowlist (Cloudflare CIDRs only) |
| End-to-end mTLS | Authenticated Origin Pulls + Tunnel/allowlist |
| Per-hostname certs | AOP per-hostname (Enterprise) |

Best stack: Tunnel + AOP.

Source: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

## Bot Fight Mode vs Super BFM vs Bot Management

| Plan | Tool |
|---|---|
| Free | Bot Fight Mode (single toggle) |
| Pro+ | Super BFM (per-category + JS Detections) |
| Enterprise | Bot Management (`cf.bot_management.score` 1–99 + analytics) |

SBFM default: Definitely Automated → block, Likely Automated → managed_challenge, Verified Bots → allow, JS Detections → on, Static Resource Protection → off.

Source: https://developers.cloudflare.com/bots/

## CF Cache vs Cache Rules vs Workers Cache API

| Need | Use |
|---|---|
| Static at edge | CF Cache (default) + Cache Rules |
| Dynamic by URL+headers | Cache Rules with custom key |
| Programmatic responses | Workers Cache API |
| Cold long-tail content | Cache Reserve (Pro+ Workers Paid) |

Source: https://developers.cloudflare.com/workers/runtime-apis/cache/

## Access vs Service Tokens vs Custom Rule

| Need | Use |
|---|---|
| Human users + IdP | Access app + IdP policy |
| Machine-to-machine | Access Service Token |
| IP-only allowlist (no auth) | Custom Rule |
| mTLS-required | Access app + mTLS policy |

Access > Custom Rule for human auth.

Source: https://developers.cloudflare.com/cloudflare-one/applications/

## Zaraz vs raw scripts vs Workers proxy

Zaraz = server-side tag manager. Use for privacy-friendly tags + consent gating + perf wins. Workers proxy when you need custom logic against third-party endpoints.

Source: https://developers.cloudflare.com/zaraz/

## CF Web Analytics vs GA4 vs Plausible

CFWA covers traffic, top pages, RUM. Doesn't cover events, funnels, user IDs.

Source: https://developers.cloudflare.com/web-analytics/
