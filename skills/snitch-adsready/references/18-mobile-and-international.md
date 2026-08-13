# 18 — Mobile + international

Read when auditing mobile-first behavior or expanding to new locales.

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

## hreflang

Tells search engines + AI crawlers which version serves which language/region:

```html
<link rel="alternate" hreflang="en-us" href="https://example.com/" />
<link rel="alternate" hreflang="en-gb" href="https://example.com/uk/" />
<link rel="alternate" hreflang="de-de" href="https://example.com/de/" />
<link rel="alternate" hreflang="x-default" href="https://example.com/" />
```

Validation: hreflang.xml validator, Search Console → International Targeting.

Common mistake: hreflang reciprocity — every locale must list every other locale. If German doesn't list English, both lose ranking.

## Localized landing pages

Don't translate the same page into 8 languages and call it done. Localize:

- Currency in price displays.
- Phone number format + country-specific phone-extension widget.
- Date format (mm/dd/yyyy US; dd/mm/yyyy elsewhere).
- Image references (don't ship a UK-only photo to a US landing page).
- Examples / case studies (US healthcare ≠ UK NHS).

## Per-region consent rules

| Region | Consent default behavior |
|---|---|
| EU + UK + EEA | denied (must opt in) — Consent Mode v2 enforced |
| Switzerland (FADP) | denied (recently aligned with GDPR) |
| Brazil (LGPD) | similar to GDPR |
| California (CCPA / CPRA) | granted by default; honor opt-out + GPC signal |
| Other US states (CO, CT, VA, etc.) | similar to California |
| Canada (PIPEDA / Quebec L25) | denied for Quebec; granted elsewhere |
| Australia, NZ, Asia (most) | granted, with opt-out support |

Most CMPs auto-detect region by IP and apply the right default. Verify your CMP does this.

## Per-platform regional caveats

- **Google Ads** in EU/UK requires Consent Mode v2 — no exceptions.
- **Meta** requires CAPI registration in some EU countries due to DPA scrutiny.
- **TikTok** has its own US data-residency rules; ad data is partitioned.
- **LinkedIn** B2B rules vary by country.
- **Apple Search Ads** is iOS-only — non-Apple regions still don't have iOS ATT context, but the postback API works the same.

## Verification

- Lighthouse Mobile-Friendly Test
- Search Console → International Targeting
- Bing Webmaster → Geo-Targeting
- Manual: load page on a low-end Android, confirm interactive in <3s

## See also

- `06-core-web-vitals.md` — CWV is mobile-first measured.
- `04-consent-and-cmp.md` — region-aware consent.
- `19-ios-skadnetwork-and-att.md` — iOS-specific.
