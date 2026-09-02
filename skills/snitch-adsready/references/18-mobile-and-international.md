# 18 — Mobile + international

Read when auditing mobile-first landing-page behavior, or when a campaign runs in a region
with its own ad rules.

## Mobile-first reality

Mobile traffic typically dominates:

| Source | Mobile share (typical) |
|---|---|
| Google Ads (Search) | 55-70% |
| Meta (FB + IG) | 90%+ |
| TikTok | 95%+ |
| Snapchat | 99% |
| LinkedIn | 40-60% (B2B desktop-heavier) |
| Pinterest | 80%+ |
| Reddit | 70%+ |

Test in DevTools mobile mode + a real low-end Android (Moto G or similar).

## Mobile checklist

| Item | Why |
|---|---|
| `<meta name="viewport" content="width=device-width, initial-scale=1">` | Without, mobile renders zoomed-out desktop. Auto-fail. |
| `<meta name="theme-color" content="#FFFFFF">` | Colors mobile browser chrome; light + dark schemes |
| `<meta name="apple-mobile-web-app-capable" content="yes">` | iOS PWA install behavior |
| `<link rel="manifest" href="/manifest.webmanifest">` | Android Chrome PWA install + theming |
| `<link rel="apple-touch-icon" href="/apple-touch-icon.png">` | 180×180 PNG; iOS home-screen icon |
| Tap targets ≥ 48×48 CSS px | Lighthouse Mobile-Friendly + Google Ads check |
| No horizontal scroll on viewport widths 320-414 px | Common breakage with full-bleed hero |
| Cookie banner < 30% of viewport on mobile | Google EU enforcement penalizes blocking interstitials |
| Form inputs use `type="email"` / `type="tel"` | Triggers mobile keyboard layout |

`apply_mobile` emits these as a starter set in the host file head.

## Multi-region landing pages

Locale variants, `hreflang` reciprocity, and localized page content are judged against search
and traffic, not against an ad platform: **call the Skill tool with "snitch-marketing"**. What
stays here is the per-platform and per-region ad behavior below, and the consent defaults —
those moved to `04-consent-and-cmp.md`, which owns the region table.

## Per-platform regional caveats

- **Google Ads** in EU/UK requires Consent Mode v2 — no exceptions.
- **Meta** requires CAPI registration in some EU countries due to DPA scrutiny.
- **TikTok** has its own US data-residency rules; ad data is partitioned.
- **LinkedIn** B2B rules vary by country.
- **Apple Search Ads** is iOS-only — non-Apple regions still don't have iOS ATT context, but the postback API works the same.

## Verification

- Lighthouse or PageSpeed Insights, mobile strategy (Google retired the standalone Mobile-Friendly Test in December 2023)
- Manual: load page on a low-end Android, confirm interactive in <3s

## See also

- `06-core-web-vitals.md` — CWV is mobile-first measured.
- `04-consent-and-cmp.md` — region-aware consent.
- `references/platforms/apple.md` — the iOS attribution section (ATT, SKAdNetwork, AdAttributionKit).
