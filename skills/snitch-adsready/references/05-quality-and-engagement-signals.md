# 05 — Quality + engagement signals

Read when ad platforms report low Quality Scores, Relevance Diagnostics, or Optimization Score and you need to distinguish creative problems from landing-page problems.

## Why this matters

Every major ad platform discounts your bid based on landing-page quality. A 10% LCP improvement can cut CPC 5-15%.

## Per-platform signal model

| Platform | Signal name | Components | Where you see it |
|---|---|---|---|
| Google Ads | Quality Score (1-10) | Expected CTR, Ad relevance, Landing page experience | Keywords tab |
| Google Ads | Optimization Score | Bidding, Targeting, Ads + assets, Auto-applied | Recommendations tab |
| Meta | Quality + Engagement Rate + Conversion Rate Rankings | engagement / conversion vs similar audiences | Ads Manager → Delivery |
| Microsoft | Quality Score | CTR, Ad Relevance, Landing Page UX | Keywords tab |
| LinkedIn | Quality Score (relative) | bid + relevance from member responses | Performance Forecast |
| TikTok | Ad Score | engagement + completion + retention | Ad-set reporting |
| Pinterest | Pin score | engagement (saves, clicks), CTR | Pin Analytics |
| X | Post engagement quality | engagement vs similar audiences | X Ads Manager |
| Snap | Snap DR score | swipe-up rate vs benchmark | Ads Manager → Insights |
| Apple Search Ads | Match score | metadata + query relevance | Campaigns → Insights |

## Landing-page experience checklist

The signal name varies; the checklist is the same:

1. **Match between ad copy and landing page.** "Free trial" ad → free trial above the fold.
2. **Mobile-first.** Mobile is 60-80% on most platforms. Test a real low-end Android.
3. **LCP under 2.5s.** See `06-core-web-vitals.md`.
4. **CLS under 0.1.** Layout shift cuts clicks.
5. **HTTPS.** Required everywhere — mixed content blocks pixel fires.
6. **No interstitials.** Cookie banners > 15% of viewport hurt scoring.
7. **One clear CTA.** Multiple CTAs above the fold dilute conversion intent.
8. **Trust signals.** Reviews, certifications, customer logos.
9. **Fast time-to-interactive.** Long tasks > 50ms hurt INP.

## De-ranking triggers

- LCP > 4s = severe penalty.
- Cloaked landing pages (different content for bots vs users).
- Adult / illegal content (auto-suspension).
- Misleading offers / bait-and-switch.
- Excessive ads above the fold.
- Broken pixels (no signal = poor-quality bid).
- Cookie banner blocking primary content.

## Quick wins for low quality score

1. Cut page weight under 1MB compressed.
2. Add the canonical event for the funnel stage the ad bids for (`Purchase`, `Lead`, `Sign up`).
3. Hash + send PII via CAPI — match rate +10-30%.
4. Wire Consent Mode v2.
5. Use the platform's auto-event (e.g., scroll depth) — trains faster than custom events alone.
6. Match ad copy to H1 verbatim where reasonable.

## See also

- `06-core-web-vitals.md` — LCP/INP/CLS targets and fixes.
- `03-conversion-tracking.md` — GA4 events and conversion imports.
- `references/platforms/<name>.md` — per-platform interpretation.
