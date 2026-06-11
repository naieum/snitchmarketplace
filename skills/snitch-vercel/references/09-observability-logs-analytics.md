# Observability: logs, analytics, monitoring

## Logs

- `vercel logs <deployment-url>` streams build + runtime logs.
- Retention varies by plan; logs older than the window aren't queryable.
- Log drains (Pro+) forward to a SIEM.

## Log drains (Pro+)

```bash
curl -X POST https://api.vercel.com/v1/integrations/log-drains \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "name": "siem-prod",
    "url": "https://siem.example.com/vercel",
    "deliveryFormat": "json",
    "sources": ["build", "static", "lambda", "edge", "external"],
    "environment": "production"
  }'
```

Pick a destination with retention you trust (Datadog, Better Stack, Axiom, AWS S3). Log drains support HMAC signing — set `secret` and verify on the destination.

## Vercel Web Analytics

Privacy-focused page-view + event analytics. Free tier with quota; Pro+ raises limits.

```tsx
import { Analytics } from "@vercel/analytics/react";
<Analytics />
```

Add `https://va.vercel-scripts.com` to `script-src` and `https://vitals.vercel-insights.com` to `connect-src` in CSP.

## Vercel Speed Insights

Web Vitals (CLS, LCP, FID/INP) at p75/p95.

```tsx
import { SpeedInsights } from "@vercel/speed-insights/react";
<SpeedInsights />
```

## Sentry / Datadog / OpenTelemetry

Use the framework-native integration:

| Vendor | Integration |
|---|---|
| Sentry | `@sentry/nextjs` for Next.js — auto-captures runtime + build errors |
| Datadog | `dd-trace` in serverless function |
| OpenTelemetry | `@vercel/otel` (opinionated) or roll your own |

Add `connect-src https://*.ingest.sentry.io` (or vendor equivalent) to CSP.

## Audit log (Enterprise)

`/v1/teams/<id>/audit-logs` records: deploy, env-var change, member add/remove, token create/revoke. Pro+ teams get partial visibility; Enterprise gets full retention.

`state account audit` slice surfaces recent events; combine with date filtering for postmortems.

## Alerting

Vercel has no native alerting; pipe logs/metrics to a SIEM (Datadog Monitor, PagerDuty via Datadog/Better Stack, Sentry alerts).

Common production alerts:

| Alert | Source | Trigger |
|---|---|---|
| Build failure | log drain or Slack integration | Vercel deploy `state == ERROR` |
| Function error rate >5% | log drain SIEM | per-function 5xx percentage |
| Cold-start spike | Speed Insights | Server-Timing budget exceeded |
| Bandwidth spike | Vercel usage API | week-over-week delta >50% |
| DB connection storm | Vercel Postgres metrics | connection count near pool limit |

## References

- https://vercel.com/docs/observability
- https://vercel.com/docs/observability/log-drains
- https://vercel.com/docs/analytics
- https://vercel.com/docs/speed-insights
- https://vercel.com/docs/observability/audit-log
