## CATEGORY 91: SoftwareApplication schema

SoftwareApplication schema (and subtypes `WebApplication`, `MobileApplication`, `VideoGame`) powers the SERP card for SaaS apps, browser extensions, native apps, and AI tools. It surfaces the app's name, category, price (or "free"), rating, and a direct link to the install / signup. In 2026, with SERP and AI-overview real estate fiercely contested, SoftwareApplication schema is one of the few signals that distinguishes a SaaS landing page from a generic content page.

### Pre-flight: relevance check

Skip this category with reason `not applicable` unless the site sells / offers a software product (SaaS, mobile app, browser extension, AI tool, desktop software, video game). A generic marketing site for a service business is not a candidate.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify product / app pages by URL pattern (`/`, `/product/`, `/app/`, `/extension/`, `/download/`) AND content shape (named app + features + signup or download CTA).
2. `Grep` for `"@type": "SoftwareApplication"` (or `"WebApplication"`, `"MobileApplication"`, `"VideoGame"`).
3. For each schema: parse the JSON. Check required: `name`, `applicationCategory`. Strongly recommended: `operatingSystem`, `offers` (with `price`, `priceCurrency`), `aggregateRating`, `description`, `image`/`screenshot`, `url`, `softwareVersion`, `releaseNotes`.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Find JSON-LD blocks. Parse.
2. Quote the entire `SoftwareApplication` object.
3. Check required + recommended fields. Quote any missing.

### Forbidden claims

- "SoftwareApplication schema is probably missing." Confirm the page IS a product page AND parse.
- "Rating may be inflated." Quote the `aggregateRating` value AND show the visible review evidence (or its absence).

### Detection

Looking for `"@type": "SoftwareApplication"` (or subtypes) on pages selling / offering software.

### What to Search For

- `"@type": "SoftwareApplication"`, `"WebApplication"`, `"MobileApplication"`, `"VideoGame"`
- Required: `name`, `applicationCategory` (e.g., `BusinessApplication`, `DeveloperApplication`, `SecurityApplication`, `BrowserApplication`)
- Strongly recommended: `operatingSystem` (`Web`, `Windows`, `macOS`, `Linux`, `iOS`, `Android`), `offers` (with `price`, `priceCurrency`; `0` for free), `aggregateRating` (only if backed by visible reviews), `description`, `image` or `screenshot`, `url`, `softwareVersion`, `releaseNotes`, `downloadUrl`, `installUrl`
- For free apps: `offers` with `price: "0"` (not omitted, explicit "free" beats absent)
- For paid apps: `offers` with `price`, `priceCurrency`, `priceValidUntil`

### Actually Hurts the Marketing Surface

- **SaaS / app landing page with no SoftwareApplication schema**.
  Evidence required: URL + visible app branding + missing JSON-LD.
- **`applicationCategory` missing** (Google can't classify the app for the right SERP filter).
  Evidence required: parsed schema.
- **`operatingSystem` missing on a downloadable app** (Google's app card shows OS prominently).
  Evidence required: parsed schema + visible download options on page.
- **`offers` missing entirely** (Google can't show price or "free" badge).
  Evidence required: parsed schema.
- **Faked / unattributed `aggregateRating`** (manual-action risk, same as other schema types).
  Evidence required: schema rating + missing on-page review surface.
- **`aggregateRating` from a third-party review site without attribution** (e.g., schema cites "4.8 stars" but no review surface on the page; the rating is borrowed from G2 / Capterra without crediting them).
  Evidence required: schema rating + missing source attribution.
- **`softwareVersion` stale** (last updated 18 months ago; Google reads version freshness as a quality signal).
  Evidence required: visible release notes / changelog with newer version + stale schema.
- **`screenshot` missing or 404** (the SERP app card relies on screenshots).
  Evidence required: parsed `screenshot` URL + fetch result.

### NOT a Problem

- A marketing site for a service company (consulting, agency, cafe) without SoftwareApplication schema, not a candidate.
- Free app with `offers` set to `price: "0"` instead of omitting `offers`, correct (explicit free signal).
- Multiple `screenshot` entries, encouraged.
- `releaseNotes` absent on a brand-new app, acceptable.

### Context Check

1. Is the page actually a product / app page? Generic "About" or "Contact" pages don't get SoftwareApplication.
2. Is the app currently offered? Sunset / deprecated apps shouldn't have active SoftwareApplication schema.
3. If `aggregateRating` is present, is there a visible review surface on the page that justifies it (or attribution to a third-party review platform)?
4. Does `softwareVersion` match the current released version?
5. For browser extensions / mobile apps, does `installUrl` / `downloadUrl` point at the right store?

### Reference

Google's SoftwareApp documentation: https://developers.google.com/search/docs/appearance/structured-data/software-app

Schema.org SoftwareApplication: https://schema.org/SoftwareApplication

applicationCategory values: https://schema.org/applicationCategory

**Severity tagging:**
- SaaS / app landing page with no SoftwareApplication schema → High.
- `applicationCategory` missing → Medium.
- `operatingSystem` missing on downloadable → High.
- `offers` missing → Medium.
- Faked / unattributed `aggregateRating` → Critical (manual-action risk).
- `softwareVersion` stale by >12 months → Low (advisory).
- `screenshot` missing or 404 → Medium.

**Fix voice:** `sahil-lavingia` (primary) | `tobias-van-schneider` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Your product page is doing the work of selling the app to a human. SoftwareApplication schema does the same work for the search engine, name, category, OS, price, rating, link to install. Ship it, then ship a screenshot, then ship the version number. The whole thing is mechanical; the only reason it isn't on your page yet is that nobody made it the priority.
>
> ```tsx
> const appSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'SoftwareApplication',
>   name: 'Snitch',
>   applicationCategory: 'SecurityApplication',
>   operatingSystem: 'Web, macOS, Linux, Windows',
>   offers: {
>     '@type': 'Offer',
>     price: '49.99',
>     priceCurrency: 'USD',
>   },
>   description: 'Security review for the code your AI wrote.',
>   image: 'https://snitchplugin.com/og-image.png',
>   screenshot: [
>     'https://snitchplugin.com/screenshots/scan.png',
>     'https://snitchplugin.com/screenshots/report.png',
>   ],
>   url: 'https://snitchplugin.com',
>   softwareVersion: '7.5.0',
>   releaseNotes: 'https://snitchplugin.com/changelog',
>   installUrl: 'https://snitchplugin.com/install',
> };
> ```
>
> Two non-negotiables. One: if you publish `aggregateRating`, every star needs to be backed by a real review the user can find on the page (or attributed to G2/Capterra/etc.). Faked ratings get you a manual action. Two: when you cut a new version, the `softwareVersion` field changes too. The schema is part of the release, not a one-time thing you set and forget.
