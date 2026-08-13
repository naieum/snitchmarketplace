# Setup — ads.txt

Walkthrough for `setup ads-txt`. Only relevant if user is a publisher (monetizes by showing ads). Advertisers don't need ads.txt — surface as N/A.

## Pre-checks

1. **Confirm user is a publisher.** "Do you run ads to make money on this site, or buy ads to acquire users?" If buying, mark N/A and stop.
2. **Run `bash ads-ready.sh state site <url> ads-txt`.** Reports current `/ads.txt` presence + line count.
3. **Identify SSPs running inventory.** Common: Google AdSense / Ad Manager, Amazon Publisher Services, Meta Audience Network, reseller SSPs (Rubicon, PubMatic, OpenX, Index Exchange).

## Steps

### 1. Get publisher IDs from each SSP (manual / external-tool)

| SSP | Where to find publisher ID |
|---|---|
| Google AdSense | https://www.google.com/adsense/ → Account info → Publisher ID (`pub-XXX`) |
| Google Ad Manager | https://admanager.google.com/ → Admin → Network settings |
| Amazon Publisher Services | TAM / UAM dashboard |
| Meta Audience Network | https://business.facebook.com → Monetization Manager |
| Microsoft Audience Network | https://about.ads.microsoft.com/audience |
| Rubicon Project | Magnite Streaming dashboard |
| PubMatic | PubMatic dashboard |
| OpenX | OpenX dashboard |
| Index Exchange | IX dashboard |
| AppNexus / Xandr | Xandr Curate / Microsoft Curate |

### 2. Apply the merged ads.txt (auto)

```bash
bash ads-ready.sh fix ads-txt
```

The apply step:
- Reads `templates/ads-txt-entries.template.txt`.
- Substitutes `{{PUB_ID}}` placeholders with provided IDs (or leaves as templates).
- Detects existing `/ads.txt` and merges entries — never overwrites with fewer lines.
- Emits `=== FILE/DIFF/CONTENT ===` targeting `public/ads.txt` (or stack-specific path).

### 3. Deploy `/ads.txt` at the apex root (manual)

File MUST be at apex domain, HTTPS, content-type text/plain.

| Stack | Where |
|---|---|
| Next.js / Astro / Nuxt / Remix / Vite SPA | `public/ads.txt` |
| SvelteKit | `static/ads.txt` |
| WordPress | `wp-content/uploads/ads.txt` (or root via plugin) |
| Shopify | Settings → Domains → Manage ads.txt |
| Cloudflare Pages | repo root or `public/ads.txt` |
| Webflow | Project Settings → SEO → Ads.txt (or upload as redirect) |

Critical: `https://example.com/ads.txt`, NOT a subdomain or subdirectory. Subdomains inherit the apex.

### 4. Validate (external-tool)

| Tool | URL |
|---|---|
| adstxt.guru | https://adstxt.guru/ |
| IAB Tech Lab validator | https://iabtechlab.com/ads-txt/ |
| AdSense → Sites → Ads.txt status | inside AdSense (24h delay) |

### 5. If user has a mobile app, ALSO add `/app-ads.txt` (manual)

Same format, different file. Required for monetizing in-app inventory through AdMob, Audience Network, AppLovin. Place at `https://example.com/app-ads.txt`. iOS + Android app metadata references the developer's website for canonical path.

### 6. Re-run state site (auto)

```bash
bash ads-ready.sh state site <url> ads-txt
```

Digest should now report `present: true` + expected line count.

## Common mistakes

- Wrong path (sub-directory or sub-domain — must be apex).
- Wrong TAG-ID (40-char hex must match seller's certification ID exactly).
- Missing newline at EOF (some parsers truncate the last line).
- Mixing DIRECT and RESELLER for same seller (only one).
- Adding lines for SSPs you don't actually monetize through.
- Forgetting subdomain inheritance.

## When NOT to run this setup

- User is an advertiser (buys ads).
- No programmatic monetization.
- Hosting platform that doesn't allow root-level static file (rare).

Mark `ads-txt` as ⚪ N/A.

## See also

- `08-ads-txt.md` — full reference.
- `templates/ads-txt-entries.template.txt` — annotated starter.
- IAB spec: https://iabtechlab.com/ads-txt/
