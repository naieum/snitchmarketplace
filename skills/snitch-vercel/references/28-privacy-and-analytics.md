# Privacy and analytics

## Vercel Analytics + Speed Insights

Cookie-less, no PII. Sample page views and Web Vitals; no persistent client identifier.

| Property | Posture |
|---|---|
| Cookies | None set; DNT moot |
| Aggregation | No per-user session timeline |
| Hosting | EU + US Vercel regions; data residency configurable on Enterprise |

Your privacy policy still has to disclose them if you collect "telemetry about page performance" — even anonymous.

## Cookie banner — needed?

EU/UK-facing requires consent banner before loading:

| Tool | Banner needed? |
|---|---|
| Vercel Web Analytics | Arguably no (no tracking cookies) — consult counsel |
| Google Analytics | Yes |
| Posthog (with cookies) | Yes |
| Sentry session replay | Yes |
| Stripe Elements | No (essential for checkout, not tracking) |

## CSP for analytics scripts

See `templates/csp-stack-overlays.json` for `vercel-analytics`, `vercel-speed-insights`, `google-analytics`, `posthog`, `sentry` overlays.

## EU data residency

| Resource | EU pinning |
|---|---|
| Functions | `fra1`, `arn1`, `cdg1`, `dub1` |
| Vercel Postgres | User-selected region |
| Vercel Blob | Regional; pick EU for EU PII |
| Edge Config | Replicated globally — don't store EU PII there |

## Audit data flow on PR

Every dependency potentially touches user data. `state env` digest spots newly-added third-party API keys; `state functions` shows new endpoints. Use as input to a privacy review.

## References

- https://vercel.com/legal/privacy-policy
- https://gdpr.eu
- https://vercel.com/docs/analytics
