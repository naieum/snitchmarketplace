# 14 — Cost + budgets

Read when the user asks about API quotas, monthly costs of CAPI / sGTM hosting, or where the bill lands.

## What costs money

Pixels and every platform's Conversions API are free at the platform; what you pay for is the
compute and the third-party tools around them.

Per-vendor pricing lives in one place — `references/recommendations/*.md`, which
`templates/recommendations.json` feeds and `recommend <area>` emits as JSON. Read it there
rather than from a second table here, so the numbers rot in one file instead of three:

- CMP vendors — `recommend cmp`
- Server-side GTM hosting — `recommend gtm-server`
- CAPI helper libraries — `recommend capi-helpers`
- CI Lighthouse runners — `recommend lighthouse-runner`
- RUM / CWV monitoring — `recommend cwv-monitoring`

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
3. **CMP tier thresholds.** Most CMP free and entry tiers are metered on sub-pages or monthly page views; crossing the threshold moves you a tier, and teams routinely sit on a tier above what their traffic needs. Which vendor charges at which threshold is in `recommend cmp`.
4. **RUM at scale.** Datadog RUM at $1.50 per 1k sessions × millions of sessions = real money. web-vitals JS to GA4 is free.

## Fixed vs variable cost

Spiky traffic (campaign launches): Cloudflare Workers (per-request), Stape Free, PSI free, web-vitals + GA4.

Steady traffic: App Engine, Vercel Speed Insights, a flat-rate managed CMP (`recommend cmp`).

## Not cost-justified for most

- Datadog RUM for sub-100k MAU (use web-vitals JS).
- An enterprise-tier CMP below enterprise scale — the compliance scope it prices for (multi-region frameworks, DSAR workflows, audit logs) is not what a single-region site uses. `recommend cmp` picks the tier by scope.
- SpeedCurve Pro tier without a dedicated performance engineer.
- Calibre + SpeedCurve + DebugBear concurrently — pick one.

## See also

- `references/recommendations/cmp.md`, `gtm-server.md`, `lighthouse-runner.md`, `cwv-monitoring.md` — pricing in vendor cards.
