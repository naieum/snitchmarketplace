# Recommendations — Consent Management Platforms (CMP)

The agent emits this catalog from `templates/recommendations.json` via `recommend cmp`. This file is the human-readable companion.

## Picking a CMP

1. **Engineering capacity?** Yes (dedicated DevOps) → Klaro (free, self-hosted). No → managed.
2. **Budget?** $0/mo → CookieYes free / Klaro. $11-30/mo → Cookiebot or CookieYes paid. $200+/mo → Osano. Enterprise → OneTrust.
3. **Compliance scope?** Single-region GDPR → most CMPs work. IAB TCF v2.2 + multi-region + DSAR → OneTrust / Osano / Cookiebot.
4. **Team type?** Marketing-led → CookieYes / Termly. Eng-led → Klaro / Cookiebot.

## OneTrust

- **Pricing**: Enterprise quote-based. Floor ~$1,500/mo for full suite.
- **URL**: https://www.onetrust.com/products/cookie-consent/
- **Pros**: Industry default. IAB TCF + GPC + APAC frameworks. Cookie scanner + geo rules + audit logs. Full Consent Mode v2 + Microsoft UET + Meta integrations.
- **Cons**: Heaviest CMP (100kB+ if not pruned). Cost overshoot for SMB. Onboarding requires admin training.
- **Recommended for**: Enterprise (>$1B revenue, >100M monthly visitors). Regulated industries. Multi-region compliance.

## Cookiebot (by Usercentrics)

- **Pricing**: Free up to 100 sub-pages. Premium ~$11-100/mo by domain size.
- **URL**: https://www.cookiebot.com/
- **Pros**: Self-serve, no sales call. Auto-scans cookies. IAB TCF v2.2 + Consent Mode v2 + Google certified.
- **Cons**: Auto-blocking can break edge cases (canvas trackers, async iframes). Branding requires Premium.
- **Recommended for**: Mid-market and SMB. EU-heavy traffic. Teams wanting one vendor for consent + cookie scan.
- **Install**: Sign up; paste Cookiebot CMP script as the FIRST `<script>` in `<head>`; keep auto-blocking enabled.

## CookieYes

- **Pricing**: Free up to 25,000 page views/mo. Paid ~$9-39/mo.
- **URL**: https://www.cookieyes.com/
- **Pros**: Generous free tier. Simple WordPress plugin. GDPR + CCPA + Consent Mode v2.
- **Cons**: Less advanced rule editor than OneTrust / Cookiebot. TCF support requires higher tier.
- **Recommended for**: Small business. WordPress sites. Free starter that scales.
- **Install**: Sign up; install via WordPress plugin or paste script tag into `<head>`.

## Klaro!

- **Pricing**: Free, MIT-licensed. Self-hosted.
- **URL**: https://klaro.org/
- **Pros**: Open-source — no vendor lock-in. Pure JS. Privacy-friendly defaults; respects DNT.
- **Cons**: No managed cookie scanner — you maintain the service list. No built-in TCF or geo-rules. No support beyond GitHub.
- **Recommended for**: Privacy-first projects. Engineers comfortable maintaining their own CMP. Open-source / self-hosted stacks.
- **Install**: `npm install klaro`; or self-host the standalone klaro.js + klaro.css. Configure services in JS.

## Termly

- **Pricing**: Free for cookie consent banner. Solo ~$15/mo. Teams ~$25/mo.
- **URL**: https://termly.io/
- **Pros**: Combines policy generator with CMP. Approachable UI for non-technical owners. GDPR + CCPA + LGPD.
- **Cons**: Less granular than OneTrust. Branded banner on free tier.
- **Recommended for**: Small business owners needing legal + consent in one tool. Marketing-led teams.
- **Install**: Sign up; embed Termly CMP script in `<head>`; generates Privacy Policy + Terms in same flow.

## Osano

- **Pricing**: Free up to 5k visitors/mo. Paid ~$199/mo for Business.
- **URL**: https://www.osano.com/products/cookie-consent
- **Pros**: Strong audit-log + DSAR workflow. Multi-jurisdiction templates. Solid data-discovery side.
- **Cons**: Mid-market price floor jumps quickly. Heavier than Cookiebot.
- **Recommended for**: Mid-market with formal privacy program. B2B SaaS with US-state law scope (CO, CT, VA).
- **Install**: Sign up; embed Osano script in `<head>`; configure consent categories in dashboard.

## Honest framing

Most users do NOT need OneTrust. Most do NOT even need a paid CMP — Cookiebot's free tier or CookieYes free covers basics for sites under 25k pageviews/mo. The skill mentions OneTrust because users have heard of it; Cookiebot or CookieYes are usually the right choice.

Already using a CMP? Don't recommend a switch unless current CMP fails compliance or cost is materially higher.

## See also

- `04-consent-and-cmp.md` — Consent Mode v2 mechanics.
- `references/setup/consent-mode.md` — install walkthrough.
