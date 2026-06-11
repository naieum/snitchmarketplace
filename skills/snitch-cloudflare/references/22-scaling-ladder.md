# 22 — Scaling Ladder

Five plateaus. At each: have, watch, budget.

## 10 users — posture before load

Have: proxied DNS on every public hostname; SSL strict; min TLS 1.2 (1.3 if no legacy clients); HSTS started (max-age=86400 → 1y over 2 weeks); Free Managed WAF on; Bot Fight Mode on; 2FA enforced; scoped API token; Workers Free / Pages Free; `_headers` (Pages) or Transform Rules deploying full security set; `.dev.vars` and `.env*` in `.gitignore`.

Budget: $0/mo.

## 100 users — round out free posture

Add: 1 free Rate Limiting Rule on `/login`, `/signup`, `/api/auth/*`; foreign-tech WAF rule per stack profile; Cloudflare Tunnel if origin has public IP; DNSSEC active + DS at registrar; CAA records; SPF / DKIM / DMARC at `p=none` with aggregator; notifications (WAF block spike, cert expiry, DDoS L3/L7).

Watch: 4xx spikes (probes), unique-IP-from-one-ASN scrapers, BFM false positives on legit scrapers.

Budget: $0/mo.

## 1,000 users — Pro becomes worth it

Pro ($25/mo): Cloudflare Managed Ruleset, OWASP CRS, Super BFM, exposed-credentials, 20 custom rules, `log` action, Page Shield script monitor, tunable L7 DDoS sensitivity.

Workers Paid ($5/mo) if past 100k Workers req/day OR need Cron Triggers / Hyperdrive / Durable Objects / Smart Placement / Vectorize.

Other: Tiered Cache (free); Cache Rules (long TTL on `/_next/static/*`, `/assets/*`, bypass on auth-cookie); R2 for user uploads; DMARC ramp; weekly `export` to private repo; monthly audit-log review.

Watch: cache hit rate < 80%, Workers CPU near 30s, R2 Class A op growth, auth abuse spikes.

Budget: ~$25–50/mo — Pro $25 + Workers Paid $5 + R2 $0–$15.

## 10,000 users

Add: Smart Tiered Cache (free with Pro+); Cache Reserve (Workers Paid add-on); Argo Smart Routing (usage-based); Page Shield script-change alerts; Workers RL binding for per-user limits; Hyperdrive in front of external Postgres/MySQL; DDoS Alerts; Logpush to webhooks (free); Workers Logs `head_sampling_rate=0.1`; staging zone behind Access; Health Checks + LB.

Watch: Workers CPU on hot endpoints; D1 read/write quota; KV 1/s/key write cap; Durable Object instance counts; Vectorize query throughput; small-origin saturation on cache misses.

Budget: ~$100–500/mo — Pro $25 + Workers Paid $5 + overage $0–$50 + R2 $10–$200 + D1 $5–$50 + Cache Reserve $5–$50 + Argo $0–$200.

## 100,000+ users — Business or Enterprise

Business ($250/mo): regex in custom rules, payload logging, 100 custom rules, Page Shield connection + cookie monitor, Custom Certificates upload, API Shield foundations.

Enterprise: Bot Management ML scoring, full API Shield (JWT, mTLS, sequence analytics), account-level WAF, SSO, Logpush to S3/Splunk/Datadog, Aegis (dedicated egress IPs), Magic Transit, status page, multi-account separation, quarterly `panic` drills.

Watch: support-response SLA only at Ent; uncached origin egress; D1 size approaching plan limit; Vectorize index size; DO cold starts; long-running Worker CPU bills; API Shield rule misses.

Budget: ~$200–2000+/mo — Business $250 (or Ent per-deal) + Workers $5–$200 + R2 $50–$500 + D1 $20–$200 + Cache Reserve+Argo $20–$500 + Logpush $50–$500 + ZT seats >50 at $7/seat + Aegis ~$1k+/mo.

## Resilience by plateau

| Plateau | Pattern |
|---|---|
| 10–100 | origin-down fallback via Pages-served static + Always Online |
| 1k–10k | WAF misfire → `panic restore`; tight RL on shared NAT → per-user-id keying via Workers RL |
| 10k–100k | hot-path Worker CPU runaway → circuit breakers; cache-on-error; static maintenance Pages fallback |
| 100k+ | active DDoS → `panic under-attack`; origin compromise → Aegis + AOP; account compromise → SSO + scoped tokens + rotation + audit |

## Cross-references

`23-cost-cliffs.md`, `29-health-failover.md`, `26-multi-zone-org.md`, `13-incident-response.md`.

## Honest framing

Don't recommend Pro at 1k users if Free serves them. The matrix is "when these features become valuable". If `$5/mo Workers + $0 R2 + $0 DDoS = $10/mo` covers the workload, say so.
