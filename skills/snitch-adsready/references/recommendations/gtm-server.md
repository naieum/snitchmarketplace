# Recommendations — Server-side GTM hosting

Catalog the agent surfaces via `recommend gtm-server`. Companion to `16-tag-manager-server-side.md`.

## When to recommend sGTM

- Combined Google Ads + Meta spend > $10k/mo.
- Substantial mobile Safari traffic (ITP cuts client-side measurement 20-40%).
- Existing client-side GTM with 30+ tags.
- DevOps available to operate the host.

If none, sGTM is over-engineering. Stick with client-side GTM or direct gtag.

## Hosting options

### Google Cloud App Engine

- **Pricing**: ~$40-120/mo for small to mid traffic (F1 → F4 instance class).
- **URL**: https://developers.google.com/tag-platform/tag-manager/server-side/manual-setup-guide
- **Pros**: Canonical Google-recommended path. First-party domain via custom subdomain (sgtm.example.com). Same auth as GCP usage.
- **Cons**: GCP billing setup required. Cold starts on F1 — bump instance class for production.
- **Best for**: Teams already on GCP. Heavy Google Ads + GA4.
- **Install**: Run Google's deployment script in Cloud Shell.

### Cloudflare Workers

- **Pricing**: Free tier ~100k requests/day; Workers Paid $5/mo for 10M requests.
- **URL**: https://github.com/gtm-server/cloudflare-worker (community)
- **Pros**: Edge-local; lowest tracking latency. Cheap at scale. Same domain as the site.
- **Cons**: Community-maintained. Some GTM tag templates haven't been ported to Workers runtime.
- **Best for**: Cloudflare-native stacks. High-volume sites.
- **Install**: Deploy a community sgtm-on-Workers template via wrangler.

### Stape.io

- **Pricing**: Free starter; paid ~$20-300/mo by traffic + features.
- **URL**: https://stape.io/
- **Pros**: Zero-DevOps in minutes. Geographically distributed (US + EU + AU). Pre-built Power-Ups for Meta CAPI, TikTok Events.
- **Cons**: Vendor lock-in. Cost grows fast at high volumes.
- **Best for**: Small/mid teams without DevOps. Fast-validation projects.
- **Install**: Sign up; paste GTM container ID; Stape provisions endpoint and DNS.

### Vercel (custom function)

- **Pricing**: Pro tier required (~$20/mo) + function compute.
- **URL**: https://vercel.com/templates
- **Pros**: Same vendor as marketing site for many teams. Edge functions reduce latency.
- **Cons**: Not a first-class sGTM target; you maintain the bridge. Function timeouts can clip slow tag fires.
- **Best for**: Vercel-native stacks where ops simplification > raw compatibility.

### AWS App Runner

- **Pricing**: ~$25-150/mo (1 vCPU / 2GB).
- **URL**: https://aws.amazon.com/apprunner/
- **Pros**: Container-native. Auto-scaling with predictable bill.
- **Cons**: More setup than App Engine; no Google-published deployment script.
- **Best for**: AWS-native stacks.
- **Install**: Push sgtm container image to ECR; create App Runner service.

## Decision matrix

| Need | Pick |
|---|---|
| Easiest to operate, no DevOps | Stape.io |
| Lowest cost at high volume | Cloudflare Workers |
| Google-supported reference path | App Engine |
| Already on AWS | App Runner |
| Already on Vercel + small site | Vercel function |
| Edge-local for global ad spend | Cloudflare Workers |

## What sGTM doesn't fix

- Doesn't replace per-platform CAPI. Meta CAPI, TikTok Events API still need their own templates.
- Doesn't fix consent. Consent Mode v2 still applies.
- Doesn't make pixels invisible to anti-fingerprint browsers.

## See also

- `16-tag-manager-server-side.md` — sGTM mechanics.
- Google sGTM: https://developers.google.com/tag-platform/tag-manager/server-side
