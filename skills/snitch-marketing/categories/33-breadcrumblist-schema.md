## CATEGORY 33: BreadcrumbList schema

`BreadcrumbList` JSON-LD makes the breadcrumb path eligible to replace the URL in SERP. Pairs with visible breadcrumb element (Cat 22). Schema without visible breadcrumbs is allowed but missing the user-facing benefit; visible without schema is missing the SEO benefit.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `BreadcrumbList`. Quote each match.
2. Cross-reference with Cat 22 visible-breadcrumb evidence. Schema and visible should agree.
3. For pages 3+ levels deep: confirm BreadcrumbList schema OR flag as missing.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse JSON-LD blocks. Quote any BreadcrumbList found.
2. Compare to visible breadcrumbs (Cat 22). Quote both.

### Forbidden claims

- "BreadcrumbList may be missing." Parse and confirm.
- "Schema may not match visible breadcrumbs." Quote both for comparison.

### Detection

Looking for `"@type": "BreadcrumbList"` in JSON-LD blocks.

### What to Search For

- `"@type": "BreadcrumbList"`
- `itemListElement` (BreadcrumbList field)
- `position` integers (1, 2, 3 sequential)

### Actually Hurts SEO

- **Visible breadcrumbs but no BreadcrumbList schema**.
  Evidence required: visible breadcrumb HTML + missing schema.
- **BreadcrumbList schema with `position` skipping** (1, 2, 4 with no 3).
  Evidence required: parsed schema quoted.
- **BreadcrumbList schema item URLs that don't match the visible breadcrumbs**.
  Evidence required: both quoted.
- **BreadcrumbList missing `name` or `item` fields per ListItem**.
  Evidence required: parsed schema.

### NOT a Problem

- BreadcrumbList schema without visible breadcrumbs (Google still uses it for SERP rendering).
- Single-item breadcrumb (Home only), typically not worth schema; skip without flagging.

### Context Check

1. Is the page deep enough to have meaningful breadcrumbs (3+ levels)?
2. Is the visible breadcrumb generated from the URL or from data? Schema should match the visible.
3. Does the framework auto-emit BreadcrumbList? Yoast / RankMath do for WordPress.

### Reference

Google on Breadcrumb structured data: https://developers.google.com/search/docs/appearance/structured-data/breadcrumb

**Severity tagging:**
- Deep page with no BreadcrumbList → Medium.
- Schema/visible mismatch → High.
- Position skipping → High.

**Fix voice:** `brad-frost` (primary) | `jen-simmons` (backup).

Read `souls/brad-frost.json` before writing the Fix. Atomic-design POV: BreadcrumbList is a structured-data atom, generated from the same data as the visible component.

Worked fix example:

> The visible breadcrumb component already has the data. Emit the schema from the same source.
>
> ```tsx
> // Single source of truth for breadcrumb data
> const items = [
>   { label: 'Home', href: '/' },
>   { label: 'Blog', href: '/blog' },
>   { label: post.title, href: `/blog/${post.slug}` },
> ];
>
> // Visible component receives `items`
> <Breadcrumbs items={items} />
>
> // Schema receives the same `items`, transformed
> <script type="application/ld+json" dangerouslySetInnerHTML={{
>   __html: JSON.stringify({
>     '@context': 'https://schema.org',
>     '@type': 'BreadcrumbList',
>     itemListElement: items.map((item, i) => ({
>       '@type': 'ListItem',
>       position: i + 1,
>       name: item.label,
>       item: `https://example.com${item.href}`,
>     })),
>   }),
> }} />
> ```
>
> Same data, two outputs. Drift is impossible because the source is one place.
