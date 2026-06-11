## CATEGORY 37: Organization / WebSite schema

Site-wide schema describes the brand and the site itself. `Organization` (with logo, social profiles, contact) builds the brand entity in Google's Knowledge Graph, this is the load-bearing half of this category and remains fully valid. `WebSite` schema still names the site, but note that Google RETIRED the Sitelinks Searchbox in Nov 2024: the `WebSite` `SearchAction` / `potentialAction` markup is now inert and no longer renders a search box in SERP. Don't flag its absence as a missed opportunity.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `"@type": "Organization"`, `"@type": "WebSite"`. Quote.
2. Check that they're declared in a global layout (so they appear on every page), typically root layout or `_app.tsx` / `__root.tsx`.
3. For Organization: check `name`, `url`, `logo`, `sameAs` (social profiles).
4. For WebSite: check `url`, `name`. (`potentialAction.SearchAction` is inert since the Sitelinks Searchbox was retired Nov 2024, do not treat its presence or absence as a finding.)

**Crawl mode, required tool calls:**

1. `Fetch` homepage. Parse JSON-LD for Organization + WebSite. Quote.
2. Check `logo` URL resolves.
3. Check `sameAs` URLs resolve to actual brand profiles.

### Forbidden claims

- "Org schema may be missing." Parse and confirm.
- "Logo URL may be broken." Fetch and quote status.

### Detection

Looking for `"@type": "Organization"` and `"@type": "WebSite"` in JSON-LD, typically in the global head.

### What to Search For

- `"@type": "Organization"`
- `"@type": "WebSite"`
- `logo`, `sameAs`, `contactPoint`
- `url`, `name`
- (`"@type": "SearchAction"` is inert post Nov-2024 Sitelinks Searchbox retirement, noted for context only, not a finding either way)

### Actually Hurts SEO

- **No Organization schema on the site at all** (brand entity not built in Knowledge Graph).
  Evidence required: scanned all pages, no Organization JSON-LD found.
- **Organization schema missing `logo`**.
  Evidence required: parsed schema.
- **Organization `logo` URL 404 or non-square / wrong dimensions** (Google requires logo within specific dims).
  Evidence required: logo URL + image dimensions.
- **No `sameAs` array** (brand entity not linked to social profiles).
  Evidence required: parsed schema without sameAs.
- **Multiple conflicting Organization schemas** (different names, different logos across pages).
  Evidence required: bucketed schemas across pages.

### NOT a Problem

- Tiny static sites where brand entity is overkill. Skip with note.
- Personal blogs where Person schema is more apt than Organization. Acceptable.

### Context Check

1. Is the brand listed in the Knowledge Graph already? Search for the brand name + verify the side panel.
2. Does the site have a real logo asset? Schema requires it.
3. Are there real social profiles to link via `sameAs`?

### Reference

Google on Organization: https://developers.google.com/search/docs/appearance/structured-data/logo

Sitelinks Searchbox retirement (Nov 2024 — `WebSite` `SearchAction` is now inert): https://developers.google.com/search/blog/2024/10/sitelinks-searchbox

**Severity tagging:**
- No Organization schema → Medium.
- Missing logo → High (Knowledge Graph eligibility).
- Logo URL broken → Critical.
- No sameAs → Low.
- No WebSite `SearchAction` → not a finding (Sitelinks Searchbox retired Nov 2024; the markup is inert).

**Fix voice:** `tobias-van-schneider` (primary) | `paula-scher` (backup).

Read `souls/tobias-van-schneider.json` before writing the Fix. van Schneider's brand-as-entity POV: the brand is a thing in the world; the schema is how the web indexes that thing.

Worked fix example:

> Organization and WebSite schema declare the brand entity. Set them once in the root layout; they appear on every page automatically.
>
> ```tsx
> // root layout's <head>
> const orgSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'Organization',
>   name: 'Snitch',
>   url: 'https://snitchplugin.com',
>   logo: 'https://snitchplugin.com/logo-512.png',
>   sameAs: [
>     'https://github.com/snitchplugin',
>     'https://twitter.com/snitchplugin',
>     'https://www.linkedin.com/company/snitchplugin',
>   ],
> };
>
> const websiteSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'WebSite',
>   name: 'Snitch',
>   url: 'https://snitchplugin.com',
>   // No SearchAction: Google retired the Sitelinks Searchbox in Nov 2024,
>   // so SearchAction markup no longer renders anything. Don't add it.
> };
> ```
>
> Logo at 512x512 minimum, JPG or PNG. SameAs to real brand profiles only, broken / abandoned profiles weaken rather than strengthen the entity.
