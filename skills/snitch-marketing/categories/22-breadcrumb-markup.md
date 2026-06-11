## CATEGORY 22: Breadcrumb markup

Breadcrumbs (Home > Blog > Article Title) provide site-structure context to users and search engines. With proper schema markup (`BreadcrumbList`, see also Cat 33), Google replaces the URL in SERP with the breadcrumb path, cleaner, more clickable. Without breadcrumbs, deep pages feel disconnected and visitors bail.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for breadcrumb-related patterns: `breadcrumb`, `Breadcrumb`, `aria-label="breadcrumb"`, `<nav aria-label`, `<ol class="breadcrumb">`, schema-flavored `BreadcrumbList`. Quote each match.
2. `Read` the surrounding component to understand if breadcrumbs render on which routes.
3. For deep / nested routes (3+ levels deep), confirm breadcrumbs render on those pages.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Look for breadcrumb element (typically `<nav aria-label="breadcrumb">` or `<ol>` with breadcrumb classes).
2. For schema: parse JSON-LD blocks for `BreadcrumbList`.
3. Quote both visible breadcrumbs AND the schema (they should match).

### Forbidden claims

- "Breadcrumbs are probably missing." Show me what's there or what isn't.
- "The breadcrumb schema may be wrong." Parse and validate against schema.org BreadcrumbList type.

### Detection

#### Source mode

Look for breadcrumb components, breadcrumb data structures, or BreadcrumbList JSON-LD blocks.

#### Crawl mode

Visible breadcrumb element + parsed schema. Both should be present for full credit.

### What to Search For

- `breadcrumb`, `Breadcrumb`
- `aria-label="breadcrumb"`
- `<nav aria-label`
- `BreadcrumbList`
- `itemListElement` (BreadcrumbList field)

### Actually Hurts SEO

- **No breadcrumbs on a 3+ level deep page**.
  Evidence required: route depth + missing breadcrumb element.
- **Visible breadcrumbs without BreadcrumbList schema**.
  Evidence required: breadcrumb HTML quoted + JSON-LD blocks scanned with no BreadcrumbList found.
- **Breadcrumb schema with content not matching visible breadcrumbs**.
  Evidence required: both quoted, mismatch identified.
- **Breadcrumbs missing the home / root link**.
  Evidence required: breadcrumb sequence quoted, starting from somewhere mid-tree.
- **BreadcrumbList schema with `position` indices skipping** (1, 2, 4, no 3).
  Evidence required: parsed schema quoted.

### NOT a Problem

- Homepages without breadcrumbs (root level; no parent).
- Single-level pages directly under root (Home > About). Breadcrumb optional; the "About" page is one click away.
- Breadcrumbs visible in nav bar instead of below header (placement is design choice).

### Context Check

1. Is the route 3+ levels deep? Breadcrumbs are higher priority for deeper routes.
2. Does the framework auto-generate breadcrumbs from the URL structure? Many do (Next.js: not natively; you build it. Astro: not natively. WordPress: Yoast / RankMath plugins emit them).
3. Is there structured data alongside the visible breadcrumb? Both visible AND schema is the goal.
4. Are breadcrumbs accurate to URL or to user navigation? Should reflect the URL structure, not the visit path.

### Reference

Google's breadcrumb documentation: https://developers.google.com/search/docs/appearance/structured-data/breadcrumb

Schema.org BreadcrumbList: https://schema.org/BreadcrumbList

**Severity tagging:**
- No breadcrumbs on deep pages → Medium.
- Breadcrumbs missing schema → Medium.
- Schema/visible mismatch → High (Google penalizes inconsistency).
- Schema with skipped positions → High.

**Fix voice:** `brad-frost` (primary) | `jen-simmons` (backup).

Read `souls/brad-frost.json` before writing the Fix. Atomic-design POV: the breadcrumb is a tiny, reusable, structured component that knows its own context.

Worked fix example:

> Breadcrumbs are a small component with two responsibilities: render the visible path AND emit the schema. Build it once.
>
> ```tsx
> function Breadcrumbs({ items }: { items: { label: string; href: string }[] }) {
>   return (
>     <>
>       <nav aria-label="breadcrumb">
>         <ol>
>           {items.map((item, i) => (
>             <li key={item.href}>
>               {i < items.length - 1 ? (
>                 <a href={item.href}>{item.label}</a>
>               ) : (
>                 <span aria-current="page">{item.label}</span>
>               )}
>             </li>
>           ))}
>         </ol>
>       </nav>
>       <script type="application/ld+json" dangerouslySetInnerHTML={{
>         __html: JSON.stringify({
>           '@context': 'https://schema.org',
>           '@type': 'BreadcrumbList',
>           itemListElement: items.map((item, i) => ({
>             '@type': 'ListItem',
>             position: i + 1,
>             name: item.label,
>             item: `https://example.com${item.href}`,
>           })),
>         }),
>       }} />
>     </>
>   );
> }
> ```
>
> Pass the breadcrumb data from the route's loader so the path matches the URL structure exactly. Same component, every nested page, schema and visible always in sync.
