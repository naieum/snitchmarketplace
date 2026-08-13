# 10 — Capability matrix

Per platform: which features are free vs paid vs require API access. Use to set expectations before recommending a fix.

## Matrix

| Feature | Google | Meta | Microsoft | LinkedIn | TikTok | X | Pinterest | Reddit | Snapchat | Apple |
|---|---|---|---|---|---|---|---|---|---|---|
| Pixel install (client) | free | free | free | free | free | free | free | free | free | n/a (iOS only) |
| CAPI / server-side | free | free | offline upload (free) | free | free | free | free | free | free | n/a (SKAdNetwork) |
| Consent Mode v2 native | yes | partial (via Google API) | partial | partial | yes (newer) | partial | partial | newer | newer | OS handles (ATT) |
| Tag Manager | free (GTM) | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a |
| Server-side tag manager | free + hosting | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a |
| Marketing API access | free w/ dev token | requires app review | free w/ dev token | requires partner approval | free | requires Ads API access | free | free | free | requires invitation |
| Audience uploads | free | free | free | free | free | free | free | free | free | n/a |
| Customer match (PII) | yes (Enhanced) | yes (Custom Audience) | yes | yes (Matched) | yes | yes (Tailored) | n/a | yes | n/a | n/a |
| Lookalike / similar | yes | yes | yes | yes | yes | yes | yes (Actalike) | yes | yes (Lookalike) | n/a |
| Video ads | yes (YouTube) | yes (FB+IG) | n/a | yes | yes | yes | yes | yes | yes | n/a |
| Lead form ads | yes | yes (FB Lead Ads) | yes | yes (Lead Gen) | yes | yes | yes (some) | yes | yes | n/a |
| Catalog / product feed | Merchant Center | Catalog | Microsoft MC | n/a | Catalog | n/a | Catalog | n/a | Catalog | App Store |
| iOS ATT integration | yes | yes (ATT-aware) | yes | yes | yes | yes | yes | yes | yes | OS-native |
| SKAdNetwork postbacks | n/a (web) | yes | yes | yes | yes | yes | yes | yes | yes | OS-native |
| AdAttributionKit (17.4+) | yes | yes | yes | yes | yes | yes | yes | yes | yes | OS-native |

Legend: free = no cost; yes = supported; partial = configurable but not granular; n/a = not applicable.

## What's NOT supported anywhere

- **First-party MCP for any of the 10 platforms.** None ships an MCP today. Skill uses curl.
- **Live editing of a campaign via this skill.** This skill audits + reports + sets up tracking. Use platform UI or native CLI for campaign mutations.
- **Cross-platform attribution that beats each platform's own.** Each platform uses its own click-to-conversion model. Closest: GA4 + BigQuery export joined to your order DB.

## When to surface ⚪ N/A

- Platform legitimately doesn't support the feature.
- User's vertical doesn't need it (B2B SaaS doesn't need product schema; iOS-only app doesn't need ads.txt).
- API access requires partner approval the user can't easily get (LinkedIn, Apple, X).

⚪ N/A is real. Don't manufacture work.

## See also

- `references/platforms/<name>.md` — feature deep-dives.
- `12-migration.md` — legacy → current paths.
