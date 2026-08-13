# 08 — ads.txt + app-ads.txt

Read when auditing publisher-side monetization or troubleshooting reduced programmatic fill rate.

## Who needs ads.txt

**Publishers** (sites monetizing by showing ads): blogs, news, content portals running AdSense + display partners.

**Advertisers** (sites buying ads to acquire users) do NOT need ads.txt — common audit mistake. Mark N/A, not FAIL.

## Why it matters

Without ads.txt, programmatic DSPs flag inventory as "unauthorized" and 20-40% of demand drops out. The IAB Tech Lab spec lets buyers cryptographically verify the seller has rights to the inventory.

## Format

Plain text at `/ads.txt` (apex domain root, HTTPS, content-type text/plain).

```
<domain of seller>, <publisher account ID>, <DIRECT|RESELLER>, <TAG-ID>
```

Example:

```
google.com, pub-1234567890123456, DIRECT, f08c47fec0942fa0
rubiconproject.com, 12345, RESELLER, 0bfd66d529a55807
```

- `DIRECT` — direct contractual relationship with seller.
- `RESELLER` — third-party network authorized to sell on your behalf.
- TAG-ID is the certification authority's identifier (TAG = Trustworthy Accountability Group).

Comments start with `#`. Empty lines OK.

## ads.txt v1.1 records

```
contact=ads@example.com
managerdomain=example.com
ownerdomain=example.com
```

`managerdomain` declares which entity manages inventory; `ownerdomain` declares the legal owner. Help DSPs authenticate the chain when operating domain differs from parent.

## Per-platform publisher entries

`templates/ads-txt-entries.template.txt` covers:

| Platform | Line shape | Notes |
|---|---|---|
| Google AdSense / AdX | `google.com, pub-XXX, DIRECT, f08c47fec0942fa0` | Most common entry |
| Meta Audience Network | `facebook.com, XXX, RESELLER, c3e20eee3f780d68` | Only if Audience Network enrolled |
| Microsoft Audience Network | `microsoftadvertising.com, XXX, DIRECT` | Display via MS Ads |
| Amazon Publisher Services | `aps.amazon.com, XXX, DIRECT` | TAM / UAM users |
| Common SSPs (Rubicon, PubMatic, OpenX, AppNexus, Index Exchange) | per SSP | Each issues a pub ID |

LinkedIn, TikTok, Pinterest, Reddit, Snapchat, X, Apple Search Ads are buy-side only — no ads.txt entries needed.

## app-ads.txt (mobile in-app)

Same format, different file: `/app-ads.txt`. Required for monetizing in-app inventory through AdMob, Audience Network, Unity Ads, Vungle, AppLovin. iOS apps reference the developer's website for the canonical path.

## Validation

| Tool | What it checks |
|---|---|
| https://adstxt.guru/ | syntax, duplicates, accessibility |
| IAB Tech Lab validator | spec compliance |
| AdSense / Ad Manager → Ads.txt → Status | Google's view |

## Common mistakes

1. Wrong path. Must be apex (`example.com/ads.txt`).
2. Wrong TAG-ID. The 40-char hex must match the seller's certification ID exactly.
3. Missing newline at EOF. Some parsers truncate the last line.
4. Mixing `DIRECT` and `RESELLER` for same seller. Only one or the other.
5. Adding lines for SSPs you don't actually monetize through.
6. Forgetting subdomain inheritance. Subdomains inherit apex; subdomain-specific inventory needs its own ads.txt.

## When you DON'T need ads.txt

- Pure advertiser sites (e-commerce, SaaS marketing pages, lead-gen).
- No programmatic monetization.
- Subdomains that don't serve ads.

Mark `ads-txt` as ⚪ N/A — not 🔴 FAIL.

## See also

- `references/setup/ads-txt.md` — walkthrough.
- `templates/ads-txt-entries.template.txt` — annotated starter.
- IAB spec: https://iabtechlab.com/ads-txt/
