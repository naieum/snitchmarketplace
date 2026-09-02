## CATEGORY 51: Locale-specific canonicals

Each locale variant should self-canonical. The English page canonicals to itself; the Spanish page canonicals to itself. Pointing all locales at one canonical URL collapses them in Google's index, only one ranks, the others are treated as duplicates.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. For each locale variant: `Grep` / `Read` the canonical declaration.
2. Confirm each variant's canonical points at itself (within its locale prefix).
3. Cross-reference Cat 3 + Cat 50.

**Crawl mode, required tool calls:**

1. `Fetch` each locale variant. Quote canonical.
2. Variants pointing at the same canonical URL = finding.

### Forbidden claims

- "Locale canonicals may be cross-pointing." Quote them.

### Detection

Same as Cat 3 + locale awareness.

### What to Search For

Same canonical patterns as Cat 3, scoped per locale.

### Actually Hurts SEO

- **All locale variants canonical to the en variant** (consolidates into one Google index entry).
  Evidence required: each variant's canonical quoted.
- **Locale variant canonical to a different locale** (es page canonical to en page).
  Evidence required: same.

### NOT a Problem

- Each locale self-canonicalizing. Correct.
- Canonical missing on locales (handled by hreflang), flag separately as Cat 3.

### Context Check

1. Is hreflang correctly cross-linking the variants? Both hreflang AND self-canonical needed.
2. Is the framework auto-managing per-locale canonical?

### Reference

Same as Cat 3 + Cat 50.

**Severity tagging:**
- Locales canonical to single URL → Critical.
- Locales cross-canonicaling → High.

**Fix voice:** `solutions-architect` (primary) | `intrinsic-web-engineer` (backup).

Worked fix example:

> Each locale variant declares its own URL as the canonical. Hreflang handles the relationship between variants; canonical handles "I am the authoritative version of this content at this URL."
>
> ```ts
> // Per-route metadata in Next.js
> export async function generateMetadata({ params }) {
>   return {
>     alternates: {
>       canonical: `https://example.com/${params.locale}/about`,
>     },
>   };
> }
> ```
>
> Same pattern for every framework: the canonical href includes the locale prefix.
