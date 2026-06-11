# Cost and budgets

Vercel has multiple meters; an unexpected bill usually comes from one:

| Meter | Hobby included | Pro included | Overage |
|---|---|---|---|
| Bandwidth | 100GB / mo | 1TB / mo | ~$40 / 100GB |
| Function execution (GB-Hours) | small | larger | ~$0.18 / GB-hour |
| Function invocations | 100k / mo | 1M / mo | per 1M |
| Edge middleware invocations | 1M / mo | 1M / mo | per 1M |
| Image Optimization source images | 1k / mo | 5k / mo | per 1k |
| KV requests | included quota | included quota | per 100k |
| Postgres compute hours | included | included | per hour |
| Blob storage + bandwidth | included | included | per GB / GB |
| Build minutes | 6,000 / mo | 24,000 / mo | per minute |

Numbers shift; confirm at https://vercel.com/pricing and `state cost`.

## Where bills break

### 1) Bandwidth

`next/image` un-optimized at high traffic, large videos served direct, public assets without aggressive cache headers.

| Mitigation | Detail |
|---|---|
| Tight `Cache-Control` | On `/api/*` and `_next/static/*` |
| Streaming for video | Mux, Cloudflare Stream |
| Large assets to R2 / S3 + CDN | Lower egress cost |

### 2) Function execution

Long `maxDuration` × high concurrency = real money. 5s avg × 100 RPS = 500 s/s = 30,000 s/min = 500 min per minute = $$.

| Mitigation | Detail |
|---|---|
| ISR / SSG / static | Move read-heavy paths off functions |
| Cache DB reads | Vercel KV in front of Postgres |
| Edge middleware | Reject auth/rate-limit before function fires |
| Per-route `maxDuration` | Fail fast; don't blanket-set 60s |

### 3) Edge middleware invocations

`matcher: ["/(.*)"]` runs on every asset. Vercel CDN serving 100k assets/min = 100k middleware invocations/min.

| Mitigation | Detail |
|---|---|
| Tight matcher | Skip `_next/static`, `_next/image`, fonts, images |
| Cache rate-limit decisions | KV with short TTL |

### 4) Image Optimization

`next/image` resizes once per source URL × variant; counts SOURCE images. Galleries with thousands of unique URLs blow quota.

| Mitigation | Detail |
|---|---|
| Image CDN with free tier | Cloudflare Images, ImageKit |
| Restrict `images.remotePatterns` | Untrusted sources can't pad your quota |
| Cap `next/image` `sizes` | Fewer breakpoints |

### 5) KV / Postgres / Blob

KV is per-request. Naive rate-limit middleware: 4 KV calls × 1000 req/s = 4000/s = quota burn.

| Mitigation | Detail |
|---|---|
| Sliding window with single GET+SET | Upstash Ratelimit does this |
| In-memory LRU in front of KV | When reasonable |
| Postgres pooled URL | Not per-request connect |

## Budgets and alerts

Vercel doesn't expose hard cost caps. Workarounds:

| Workaround | Detail |
|---|---|
| Pro spend alerts | Settings → Billing → Spend management (Pro+) |
| Pull `/v1/teams/<id>/usage` daily | Push to a SIEM dashboard; alert on weekly delta >N% |
| `state cost` + `export` | Ad-hoc snapshots, persist via `export` |

## Estimating before migration

For "should I move from $X to Vercel?":

1. Get current bandwidth + request volume from your existing host.
2. Project Vercel function cost: avg execution × invocations × $0.18 / GB-hour.
3. Add Image Optimization volume (count distinct source URLs).
4. Add KV / Postgres / Blob if storage moves too.
5. Compare to current bill.

For high-bandwidth + low-compute (static sites with big assets), Cloudflare or Bunny.net often beats Vercel. For low-bandwidth + high-compute (heavy ISR/SSR), Vercel is usually within range or better than DIY.

## References

- https://vercel.com/pricing
- https://vercel.com/docs/limits
- https://vercel.com/guides/managing-vercel-team-billing
