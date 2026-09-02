# Recommendations — Core Web Vitals monitoring (RUM)

Catalog for `recommend cwv-monitoring`. Real-user-monitoring tools that capture CWV from production traffic.

## Pick by need

| Need | Pick |
|---|---|
| Free, DIY, just CWV | web-vitals JS → GA4 |
| Free for Cloudflare-fronted sites | Cloudflare Web Analytics |
| Vercel-native, low setup | Vercel Speed Insights |
| Errors + performance combined | Sentry |
| Backend + RUM single pane | Datadog RUM |

## web-vitals JS (DIY)

- **Pricing**: Free.
- **URL**: https://github.com/GoogleChrome/web-vitals
- **Install**: `npm i web-vitals`; ship a small beacon to GA4 / your endpoint.
- **Pros**: Tiny library; no vendor. Pipes into GA4 as events. Edge-runtime compatible.
- **Cons**: You own the dashboard / alerting. Sample-rate decisions are yours.
- **Best for**: Everyone. Start here.

GA4 wiring:

```ts
import { onLCP, onINP, onCLS, onFCP, onTTFB } from "web-vitals";

const send = (metric) => {
  if (typeof gtag === "function") {
    gtag("event", metric.name, {
      value: Math.round(metric.value),
      metric_id: metric.id,
      metric_value: metric.value,
      metric_delta: metric.delta,
      non_interaction: true
    });
  }
};

onLCP(send); onINP(send); onCLS(send); onFCP(send); onTTFB(send);
```

## Vercel Speed Insights

- **Pricing**: $10/mo per project (Pro tier required); higher for high traffic.
- **URL**: https://vercel.com/docs/speed-insights
- **Install**: `npm i @vercel/speed-insights`; render `<SpeedInsights />` in root layout.
- **Pros**: Zero config on Vercel. First-party dashboard.
- **Cons**: Vercel-only. Aggregate dashboard; less drilldown than Calibre/SpeedCurve.
- **Best for**: Vercel-native projects.

## Cloudflare Web Analytics

- **Pricing**: Free for sites on Cloudflare.
- **URL**: https://www.cloudflare.com/web-analytics/
- **Install**: Free + cookieless beacon — paste snippet in `<head>` or use Cloudflare zone setting.
- **Pros**: Cookieless; no consent banner needed. Free.
- **Cons**: Lighter dashboard than paid tools. Not as deep on INP attribution.
- **Best for**: Cloudflare-fronted sites wanting privacy-first RUM.

## Sentry Performance

- **Pricing**: ~$26/mo (Team) up; transactions priced per-volume.
- **URL**: https://sentry.io/for/performance/
- **Install**: `npm i @sentry/browser` (tracing ships inside the browser SDK; the separate `@sentry/tracing` package was folded in and is no longer published).
- **Pros**: Errors + performance combined. Trace-level INP attribution.
- **Cons**: Cost climbs with traffic. Heavier client JS than web-vitals alone.
- **Best for**: Teams already on Sentry for errors.

## Datadog RUM

- **Pricing**: ~$1.50 per 1k sessions; min $15/mo.
- **URL**: https://www.datadoghq.com/product/real-user-monitoring/
- **Install**: `npm i @datadog/browser-rum`.
- **Pros**: Single pane with backend metrics. Strong session replay.
- **Cons**: Most expensive at scale. Privacy review needed.
- **Best for**: Enterprise on Datadog for everything else.

## Honest framing

For 90% of sites, **web-vitals JS → GA4 + occasional Lighthouse CI runs** is the right answer. Paid RUM is worth it when:

- You have a dedicated performance engineer.
- INP attribution at the trace level is on the team's roadmap.
- Backend latency + frontend latency need to live in the same dashboard.

If those don't apply, paid RUM tools usually become "we set it up and never look at the dashboard."

## See also

- `06-core-web-vitals.md` — CWV mechanics.
- `references/recommendations/lighthouse-runner.md` — synthetic monitoring (complementary).
