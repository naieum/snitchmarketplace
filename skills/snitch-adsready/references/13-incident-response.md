# 13 — Incident response

Read when something is broken right now: tracking dropped to zero, a conversion missing, attribution shifted.

## Triage in 60 seconds

1. **Confirm the symptom.** "Conversions are 0 in Meta" — verify in Events Manager → Test Events. If THAT works, issue is reporting / latency, not pixel.
2. **Scope.** One platform, all platforms, or one campaign? One country, one device, all? `state crux <url>` for CWV; `state site <url>` for pixel signatures.
3. **Recent change?** Deploy log, GTM publish, CMP banner update, DNS change. 90% of incidents are recent-change related.

## Symptoms → likely causes

| Symptom | Most likely | Tools |
|---|---|---|
| All pixels stopped firing | CSP change blocking platform domains, OR cookie banner script broke before pixel | DevTools Console (look for `Refused to load`); `state site <url> headers` |
| One platform's pixel stopped | Platform-specific snippet removed in deploy; pixel disabled (security action); access token revoked | `state site <url> pixels` |
| Conversion count plummeted | Consent default flipped to denied without update path; CAPI access token expired | `state site <url> consent`; CAPI server logs |
| Conversion count doubled | Lost dedup — same `event_id` not flowing client → server | grep server logs for two CAPI sends per order; DevTools → Network → fbq/track |
| Attribution moved paid → direct | Click-ID parameters being stripped (URL canonicalization) | check redirect chain; ensure gclid/fbclid/ttclid preserved |
| Bot traffic spike inflating GA4 | Filtering not enabled; new bot referral source | GA4 Admin → Data Settings → Data Filters |
| Mobile platform conversions vanished | iOS ATT decline rate up; SKAdNetwork postback URL misconfigured | check ATT opt-in rate; verify postback URL in Apple Developer |
| Quality Score dropped | Recent landing-page change degraded LCP/INP/CLS, OR pixel-induced INP regression | `state lighthouse <url>` vs prior snapshot |
| Google Ads "low quality landing page" | Cookie banner > 30% of viewport (mobile) or interstitial | inspect on mobile; reduce CMP banner footprint |
| Merchant Center item disapproved for data mismatch | `Product`/`Offer` markup drifted from the feed (price, availability, lapsed `priceValidUntil`) | Rich Results Test on the product URL, then compare against the feed row |

## When to escalate to platform support

- Pixel reports `Pixel disabled` — Meta / TikTok / Snap occasionally disable for ToS or fraud signals; appeal via Business Help.
- API token revoked without your action — possible security event; escalate.
- Conversion delays > 24h on Google Ads / Meta — usually platform-side; check status pages.

## Status pages

| Platform | URL |
|---|---|
| Google | https://status.cloud.google.com/products/jK6dcZBR1jaDrREoXBnH |
| Meta | https://metastatus.com/ |
| Microsoft Advertising | https://status.cloud.microsoft/ |
| LinkedIn | https://www.linkedin-status.com/ |
| TikTok Business | (no first-party page; @TikTokBusiness on X) |
| X | (first-party status page retired — api.twitterstat.us now serves an inactive page; watch @XDevelopers on X and https://devcommunity.x.com/) |
| Pinterest | https://www.pinterestbusinessstatus.com/ |
| Reddit | https://www.redditstatus.com/ |
| Snap | https://status.snap.com/ |
| Apple Search Ads | https://developer.apple.com/system-status/ |

## After the incident

1. Re-run the audit: `state site <url>` + `state crux <url>` + `score <url>`.
2. Run `verify <url>` after a `doctor` or `fix` pass — it writes a findings snapshot so the next incident has a baseline to diff against.
3. Document root cause + fix in the team's runbook.

## Honest framing

Many "incidents" aren't incidents — they're attribution shifts caused by privacy changes (Safari ITP cohort, iOS ATT). When a user reports "Meta conversions dropped 30%," the first question is "did Apple ship a privacy update?" Don't assume a code bug.

## See also

- `04-consent-and-cmp.md` — the privacy regimes behind most attribution shifts.
- `14-cost-and-budgets.md` if symptom is "API quota exhausted."
- `30-recipes.md` — "want help fixing this?" prompt.
