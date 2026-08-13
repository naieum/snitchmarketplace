# Recommendations — Lighthouse runner

Catalog for `recommend lighthouse-runner`. Synthetic CWV + Lighthouse audits in CI / monitoring.

## Pick by need

| Need | Pick |
|---|---|
| Per-PR check, free, full control | lighthouse CLI in CI |
| History + diff, free, self-hosted | Lighthouse CI Server (lhci-server) |
| Field + lab combined, alerts, Slack | Calibre |
| Best UI / filmstrip diff | SpeedCurve |
| Best price-feature, INP-focused | DebugBear |

## Lighthouse CLI (local / CI)

- **Pricing**: Free.
- **URL**: https://github.com/GoogleChrome/lighthouse
- **Install**: `npm i -g lighthouse`
- **Pros**: Local control. Full audit JSON. Same engine PSI uses.
- **Cons**: Single-machine results vary; aggregate with multiple runs. No field data.
- **Best for**: Per-PR CI checks; local audits.

GitHub Actions sample:

```yaml
- run: npm i -g lighthouse
- run: lighthouse https://example.com --output=json --quiet --chrome-flags="--headless" > lh.json
- run: jq '.categories.performance.score' lh.json
```

## Lighthouse CI Server (self-hosted)

- **Pricing**: Free; you pay the host.
- **URL**: https://github.com/GoogleChrome/lighthouse-ci
- **Install**: Deploy lhci-server via Docker; @lhci/cli in CI uploads runs.
- **Pros**: History + diff. Self-hosted; data stays yours.
- **Cons**: You maintain the host. No field-data aggregation.
- **Best for**: Teams with budget for the host but not SaaS.

## Calibre

- **Pricing**: ~$83-416/mo (Solo to Team).
- **URL**: https://calibreapp.com/
- **Install**: Sign up; CLI: `npm i -g @calibre/cli`; `calibre snapshot create`.
- **Pros**: Field + lab combined. Slack/PR integrations. Excellent budgets/alerts.
- **Cons**: Pricier than self-hosted.
- **Best for**: Mid-market with performance as a KPI.

## SpeedCurve

- **Pricing**: ~$114-1100/mo (Lite to Pro).
- **URL**: https://www.speedcurve.com/
- **Install**: Sign up; CLI for synthetic + LUX RUM beacon for field.
- **Pros**: Best-in-class waterfall + filmstrip UI. Filmstrip diff between deploys. RUM + synthetic.
- **Cons**: Premium pricing. Setup more involved than Calibre.
- **Best for**: Enterprise/marketing where every percentile matters.

## DebugBear

- **Pricing**: ~$60-210/mo (Solo to Team).
- **URL**: https://www.debugbear.com/
- **Install**: Sign up; CLI for CI; pixel beacon for RUM.
- **Pros**: Strong INP analysis. Good price-feature ratio. Real-user CrUX integration.
- **Cons**: Less flashy UI than SpeedCurve.
- **Best for**: Small/mid teams who want SpeedCurve features at lower price.

## Honest framing

For most users, **lighthouse CLI in GitHub Actions + PageSpeed Insights API** covers 80% of the value at $0/mo. Paid tools (Calibre, SpeedCurve, DebugBear) are worth it when:

- Performance is a tracked KPI with monthly review.
- The team has someone responsible for CWV.
- The site sees high enough traffic that field data + percentile drilldowns drive decisions.

For a SaaS marketing site or small ecommerce shop, the free path is fine.

## See also

- `06-core-web-vitals.md` — CWV targets + fixes.
- `templates/github-actions/ads-ready-on-pr.yml` — drop-in CI step running `score`.
