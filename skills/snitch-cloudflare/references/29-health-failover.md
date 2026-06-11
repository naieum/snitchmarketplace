# 29 — Health Checks and Failover

## Health Checks

`POST /zones/{id}/healthchecks` body:

```json
{
  "name": "origin-healthz", "type": "HTTPS",
  "address": "origin.example.com",
  "interval": 60, "retries": 2, "timeout": 5,
  "consecutive_successes": 2, "consecutive_fails": 2,
  "http_config": { "path": "/healthz", "expected_codes": ["200"], "method": "GET" },
  "check_regions": ["WNAM", "ENAM", "WEU"],
  "notification": { "email_addresses": ["ops@example.com"] }
}
```

Path preference (skill picks what's already in source): `/healthz` → `/health` → `/api/health` → `/_health` → `/status`. If none, recommend creating `/healthz` returning 200 with `{"status":"ok","db":"ok"}`.

Endpoint must be: cheap, no auth, not Access-protected, not in nav/sitemap, return non-200 on dependency failure.

Plan: free on Pro+ standalone; LB-attached health checks bill via LB.

Source: https://developers.cloudflare.com/health-checks/

## Load Balancer

Concepts: pool (origins) ← monitor (Health Check) → LB rule (hostname → pools).

Single-origin failover with maintenance-page standby:

```
Pool A (primary): origin.example.com
Pool B (standby): maintenance.example.com (Pages-served maintenance page)
LB: api.example.com, default_pools:[A], fallback_pool:B
```

Pricing: per DNS query + per pool/HC above free quotas. `fix health` requires explicit user opt-in due to per-DNS-query cost.

Steering: random, weighted, dynamic latency, geo (continent), subnet sticky.

Source: https://developers.cloudflare.com/load-balancing/about/

## Maintenance-mode worker

Toggle via `wrangler secret put MAINTENANCE` (or env var). Returns maintenance page on the route in 5 seconds. Pages-hosted standby is simpler if static; Worker pattern is better when you need partial degradation (cached responses, queued writes).

## Worker circuit breaker (10k+)

Try origin → on fail, try `caches.default.match` → last resort R2/KV-served maintenance HTML at 503 with `retry-after: 60`. Wrap origin fetch in try/catch.

## Cache-on-error rules

```
serve_stale_when_offline: true
edge_ttl: 600
```

Origin 5xx → CF serves cached version with `cf-cache-status: STALE`. Better than hard 503.

Source: https://developers.cloudflare.com/cache/how-to/configure-cache-status-code/

## Patterns by plateau

| Plateau | Pattern |
|---|---|
| 10–100 | "Always Online" (free) caches static on outage |
| 100–1k | Health Check + cache-on-error. Maintenance worker optional |
| 1k–10k | Health Check + LB primary + Pages standby |
| 10k–100k | Multi-origin LB pools + Worker circuit breaker |
| 100k+ | Multi-region origins, geo steering, Aegis IPs, status page wired to notifications |

## Skill targets

- Health Check on origin path: WARN if missing at 1k+.
- LB with standby: WARN at 10k+.
- Cache-on-error rule: WARN if missing.
- Maintenance worker pattern: INFO at 10k+.
- `/healthz` exists: WARN if missing.
- Status page wired to notifications: WARN at 100k+.
