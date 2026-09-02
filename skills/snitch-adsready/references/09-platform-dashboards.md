# 09 — Platform dashboards

Mapping table: skill subcommand ↔ where to verify in each platform's UI.

## Verification flow

After every `fix`, verify in the platform's own UI. Pixels can show as installed in code but fail in the platform if a domain is mismatched, the pixel ID is wrong, or consent state blocks them.

| Skill action | Platform UI to verify |
|---|---|
| `fix pixel-install google` | Google Tag Assistant (https://tagassistant.google.com) |
| `fix pixel-install google` (Ads conversion) | Google Ads → Tools → Conversions → Status |
| `fix pixel-install meta` | Meta Events Manager → Pixel → Test Events tab; then Diagnostics |
| `fix pixel-install microsoft` | Microsoft Advertising → Conversion Tracking → UET tags → Verify |
| `fix pixel-install linkedin` | LinkedIn Campaign Manager → Account Assets → Insight Tag → Tag Status |
| `fix pixel-install tiktok` | TikTok Ads Manager → Tools → Events → Web Events → Test Event |
| `fix pixel-install x` | X Ads Manager → Tools → Events → Pixel → Recently received |
| `fix pixel-install pinterest` | Pinterest Ads → Conversions → Tag health |
| `fix pixel-install reddit` | Reddit Ads → Events Manager → Pixel → Pixel Health |
| `fix pixel-install snapchat` | Snap Ads Manager → Events Manager → Pixel → Diagnostics |
| `fix pixel-install apple` | App Store Connect → Apps → App Analytics → SKAdNetwork |
| `fix consent-mode` | Google Tag Assistant → Consent column shows the four signals |
| `fix capi-stub <platform>` | Platform Events Manager → Test Events tab |
| `fix ads-txt` | Google AdSense → Sites → ads.txt status; adstxt.guru |
| `fix structured-data` | Merchant Center → Diagnostics; Rich Results Test |
| `fix security-headers` | securityheaders.com (target A); Mozilla Observatory (target 90+) |
| `fix mobile-meta` | PageSpeed Insights, mobile strategy (Google retired the standalone Mobile-Friendly Test in December 2023) |
| `fix verification-meta` | Search Console → Settings → Ownership; Bing Webmaster → Site verification |

## Account-level dashboards

| Platform | URL |
|---|---|
| Google Ads | https://ads.google.com |
| GA4 | https://analytics.google.com |
| Search Console | https://search.google.com/search-console |
| Tag Manager | https://tagmanager.google.com |
| Meta Business | https://business.facebook.com |
| Meta Events Manager | https://business.facebook.com/events_manager2 |
| Microsoft Advertising | https://ads.microsoft.com |
| Bing Webmaster | https://www.bing.com/webmasters |
| LinkedIn Campaign Manager | https://www.linkedin.com/campaignmanager |
| TikTok Ads Manager | https://ads.tiktok.com |
| X Ads | https://ads.x.com |
| Pinterest Ads | https://ads.pinterest.com |
| Reddit Ads | https://ads.reddit.com |
| Snap Ads Manager | https://ads.snapchat.com |
| Apple Search Ads | https://searchads.apple.com |
| App Store Connect | https://appstoreconnect.apple.com |

## CMP dashboards

| CMP | URL |
|---|---|
| OneTrust | https://app.onetrust.com |
| Cookiebot | https://manage.cookiebot.com |
| CookieYes | https://app.cookieyes.com |
| Klaro | self-hosted |
| Termly | https://app.termly.io |
| Osano | https://my.osano.com |

## CWV / RUM dashboards

| Tool | URL |
|---|---|
| PageSpeed Insights | https://pagespeed.web.dev |
| Calibre | https://calibreapp.com |
| SpeedCurve | https://app.speedcurve.com |
| DebugBear | https://www.debugbear.com |
| Vercel Speed Insights | https://vercel.com/<team>/<project>/speed-insights |
| Cloudflare Web Analytics | https://dash.cloudflare.com |

## See also

- `11-google-apis-cheatsheet.md` — curl examples.
- `references/platforms/<name>.md` — per-platform deep links.
