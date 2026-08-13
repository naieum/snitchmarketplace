# 14 — Cost + budgets

Read when the user asks about API quotas, monthly costs of CAPI / sGTM hosting, or where the bill lands.

## What costs money

| Item | Cost shape | Typical monthly cost (mid-traffic) |
|---|---|---|
| Pixel + CAPI | free at platform | $0 (compute on your infra) |
| GA4 Standard | free up to 10M events/mo | $0 |
| GA4 360 | enterprise, ~$150k/yr min | $12,500/mo |
| BigQuery export of GA4 | $0.02/GB scanned + $5/TB query | $5-100/mo typical |
| Server-side GTM hosting | App Engine ($40-120), Workers ($5), Stape ($20-300) | $40-150/mo |
| PageSpeed Insights API | free; rate-limited | $0 |
| Lighthouse CI Server (self-hosted) | host cost only | $5-25/mo |
| Calibre / SpeedCurve / DebugBear | $60-1,100/mo | varies |
| CMP (Cookiebot, OneTrust, etc.) | $0-500+/mo | $11-200/mo typical |
| Sentry / Datadog RUM | $20-1,000+/mo by traffic | $50-500/mo |
| Vercel Speed Insights | $10/mo per project (Pro required) | $10-50/mo |
| Cloudflare Web Analytics | free if site on CF | $0 |

## API quotas (read-only)

| API | Free tier | Notes |
|---|---|---|
| PageSpeed Insights | 25k/day with key; 400/day without | One audit ≈ 1 query/strategy |
| Search Console | 1,200/min/user; 50k/day/user | Rarely a constraint |
| GA4 Data API | 50k tokens/day/property | Concurrent: 50 |
| GA4 Measurement Protocol | unlimited; rate-limited at high QPS | Use exponential backoff |
| Google Ads API | 15k operations/day (free dev token) | Approved tokens get higher quotas |
| Meta Marketing API | varies by app review tier | App Review required for production |
| Microsoft Ads API | rate-limited per second | Check dev-token tier |
| LinkedIn Marketing API | 100 req/sec, 100k req/day per token | Partner approval for many endpoints |
| TikTok Marketing API | 500 req/min per app | More for partner apps |
| X Ads API | tier-dependent | OAuth 1.0a |
| Pinterest Ads API | ~1k req/min | |
| Reddit Ads API | 60 req/min default | |
| Snapchat Marketing API | 1k req/min | |
| Apple Search Ads | 50 req/sec peaks | JWT auth overhead |

`state platform <name>` calls fewer than 10 endpoints per invocation — quotas rarely hit during routine audits.

## Budget cliffs

1. **GA4 360.** Event volume crossing 10M/mo may push to 360 with no flexible middle tier. BigQuery export reduces urgency.
2. **Server-side GTM at scale.** App Engine F1 cold-starts hurt at ~50 req/sec sustained; bump to F4 or migrate to Workers.
3. **CMP per-page-view pricing.** Cookiebot mid-tier starts charging once you exceed N sub-pages. Some teams pay 5x what they need.
4. **RUM at scale.** Datadog RUM at $1.50 per 1k sessions × millions of sessions = real money. web-vitals JS to GA4 is free.

## Fixed vs variable cost

Spiky traffic (campaign launches): Cloudflare Workers (per-request), Stape Free, PSI free, web-vitals + GA4.

Steady traffic: App Engine, Vercel Speed Insights, Cookiebot.

## Not cost-justified for most

- Datadog RUM for sub-100k MAU (use web-vitals JS).
- OneTrust for sub-$10M-revenue (use Cookiebot or CookieYes).
- SpeedCurve Pro tier without a dedicated performance engineer.
- Calibre + SpeedCurve + DebugBear concurrently — pick one.

## See also

- `references/recommendations/cmp.md`, `gtm-server.md`, `lighthouse-runner.md`, `cwv-monitoring.md`, `listings.md` — pricing in vendor cards (`listings` options are all free to claim; only their upsells cost money).
