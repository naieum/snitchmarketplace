## CATEGORY 31: JSON-LD presence

Schema.org structured data via `<script type="application/ld+json">` is what unlocks rich results in Google: star ratings under products, FAQ accordions in SERP, breadcrumb paths replacing the URL, recipe cards, event listings, video previews. No JSON-LD = no rich results = lower CTR vs competitors who do declare it.

This category is the **gateway**: does the page have ANY structured data at all? Per-type validation (Article, Product, FAQ, and every other type) is Cat 32, driven by the per-type table in `references/standards-table.md`; rating honesty is Cat 94.

JSON-LD is the format Google strongly recommends (over Microdata or RDFa). It can sit anywhere in `<head>` or `<body>`; the JSON object inside the script tag is what matters.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `application/ld+json` across the entire project. Capture every match.
2. For each match, `Read` the surrounding 50 lines to capture the full JSON object being injected (it may be assigned to a variable far from the `<script>` tag).
3. Parse the JSON literal as JSON. If it doesn't parse (template interpolation present, missing quotes, etc.), that IS the finding, quote the exact unparseable string.
4. For each parsed schema object: extract `@context`, `@type`, and the top-level properties. Quote each.
5. For "no JSON-LD on a rich-result-eligible page" findings: confirm via page-type detection (`references/smart-detection.md`) that the page IS eligible. Quote the page-type signal you used (URL pattern, presence of product attributes, etc.).

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Find every `<script type="application/ld+json">` element. Quote each script's content.
2. Parse each script's body as JSON. Quote parse errors verbatim.
3. For each parsed object, check `@context`, `@type`, and required properties for that type (cross-reference the type against `references/standards-table.md`).
4. For "schema describes content not on the page" findings: quote the schema's relevant property AND the missing-from-rendered-HTML evidence (e.g., FAQPage with 5 Q&A pairs in schema; only 2 visible in rendered HTML, quote both numbers).

### Forbidden claims

- "The page is probably missing schema." Either grep / fetch found a JSON-LD block or it didn't. No "probably."
- "The schema may be invalid." Parse it. Either it parses or it doesn't. Quote the exact failure if it doesn't.
- "Most pages don't have schema." Enumerate the pages you checked. "Most" needs a denominator.
- "The schema looks generic." Show me what's generic about it. Quote the field that's a placeholder or default.

### Detection

#### Source mode

Find every place the project emits a `<script type="application/ld+json">` block:

- **Next.js App Router**: typically in `app/layout.tsx` or per-page via `<script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }} />`.
- **Next.js Pages Router**: same, inside `next/head` or directly in component JSX.
- **TanStack Start**: `head: () => ({ scripts: [{ type: 'application/ld+json', children: JSON.stringify(schema) }] })`.
- **Astro**: `<script type="application/ld+json" set:html={JSON.stringify(schema)} />` in the layout or page.
- **Remix**: `meta` returns the JSON-LD block via the `tagName: 'script'` shape (Remix v2+); `links` only emits `<link>`, so JSON-LD never lives there.
- **WordPress**: Yoast SEO emits Article + Organization + WebSite schema by default; RankMath similar; manual via `wp_head` action.
- **Shopify**: `{% render 'product-json' %}` snippet in modern themes.
- **Static HTML**: literal `<script type="application/ld+json">{...}</script>` in `<head>` or end-of-`<body>`.

For each found block:
1. Parse the JSON. Verify it's syntactically valid.
2. Check `@context` is `https://schema.org` (or `http://schema.org`).
3. Check `@type` is set and is a real schema.org type.

#### Crawl mode

Fetch the URL. Find every `<script type="application/ld+json">` element. Parse the JSON content.

For each:
- Validate it parses as JSON (no trailing commas, unterminated strings, etc.).
- Check the `@context` and `@type` are present and valid.
- Note the `@type` value for Cat 32 to consume; it decides which per-type rows to validate.

### What to Search For

- `<script type="application/ld+json">` literal in source or rendered HTML
- `'application/ld+json'` as a string in metadata builders (Next.js script tag, TanStack head, etc.)
- `dangerouslySetInnerHTML` blocks that contain JSON.stringify of an object with `@context` or `@type` keys
- Yoast / RankMath / AIOSEO function calls that emit schema (`yoast_get_schema_context`, `rank_math_get_schema`)
- Shopify Liquid `{% render 'product-json' %}` or similar snippets

### Actually Hurts SEO

- **No JSON-LD on a page eligible for a rich result.** A blog post with no `Article` schema, a product page with no `Product` schema, a FAQ page with no `FAQPage` schema. Eligible-but-not-claimed CTR sits on the table.
- **Invalid JSON inside the script tag.** Trailing commas, unescaped quotes, unterminated strings, Google's parser silently drops the whole block. The page has no schema at all even though source looks like it does.
- **`@context` missing or wrong.** Without `@context: "https://schema.org"`, the JSON object is just JSON, not structured data. Google doesn't recognize it.
- **`@type` missing or invalid.** A type that doesn't exist on schema.org (typo: `BlogPos` instead of `BlogPosting`) is the same as no type. Google ignores.
- **Multiple JSON-LD blocks claiming overlapping types** with conflicting properties. E.g., one block says `Article` with author "Alice"; another block says `Article` with author "Bob". Google picks one or rejects both.
- **JSON-LD inside `dangerouslySetInnerHTML` with template literal interpolation that doesn't escape**. Common AI-built bug: `<script type="application/ld+json">{`{"name": "${product.name}"}`}</script>`, if `product.name` contains a quote, the JSON is broken AND it's an XSS vector. Always `JSON.stringify` the whole object, never template-interpolate user data.
- **JSON-LD declared in `<body>` but the value depends on client-side state.** SSR-only schema is fine. SPA mounting that injects schema after client hydration may not be seen by Google's initial render in some cases, verify rendering.
- **Schema describes content that doesn't actually appear on the page.** E.g., FAQPage schema with 5 Q&A pairs, but only 2 of them appear in the visible page content. Google flags this as "inconsistent" and may demote.

### NOT a Problem

- A page that's intentionally not eligible for any rich result (a privacy policy, a 404, a "thank you" confirmation). No schema needed.
- Multiple non-conflicting JSON-LD blocks (e.g., one `Organization` for the brand, one `WebSite` for site search, one `Article` for the post). Standard pattern.
- Schema declared on a noindex'd page. Pointless but not harmful; flag as Low or skip.
- `@context` written as `http://schema.org` (no `s`), both work, modern preference is `https://`. Flag as Low.

### Context Check

1. Is the page eligible for any rich result? Use page-type detection (`references/smart-detection.md`) to determine which schema types apply, then check whether the relevant ones are present. Don't flag missing FAQ schema on a homepage.
2. Does a SEO plugin auto-emit schema? Yoast / RankMath / AIOSEO all do. Check plugin settings before flagging "no schema", the source may not have it but the rendered HTML does. Verify in crawl mode.
3. Does the framework auto-emit (e.g., Shopify themes for `Product`)? Same logic.
4. Is the JSON.stringify-around-template pattern present? Flag the template-interpolation pattern as a bug regardless of current observed output, it's a latent failure waiting for a quote in the data.
5. Is the schema being injected client-side via JS? Document the limitation in the finding; we can detect it in source but only verify rendering with a JS-rendering crawler.
6. Are there multiple blocks? Confirm they don't conflict on the same `@type`.

### Reference

Google's structured data documentation: https://developers.google.com/search/docs/appearance/structured-data

The schema.org type hierarchy: https://schema.org/docs/full.html

Google's Rich Results Test (manual validation): https://search.google.com/test/rich-results

Before recommending any `@type` "to win a rich result," check `references/schema-deprecations.md` — some types (HowTo, narrowed FAQ, SpecialAnnouncement) no longer render a rich result even though the markup is still valid structured data.

**Severity tagging:**
- Page eligible for rich result, no JSON-LD at all → High.
- Invalid JSON in JSON-LD block (silent drop) → High.
- Schema with template-interpolation XSS / break risk → High (security + SEO combined).
- `@type` missing or typo'd → High.
- Schema describes content not on the page → Medium.
- Conflicting blocks for same `@type` → Medium.
- `@context` is `http://` instead of `https://` → Low.

**Fix voice:** `intrinsic-web-engineer` (primary) | `solutions-architect` (backup, for cases that require multi-block coordination).

Read `souls/intrinsic-web-engineer.json` before writing the Fix. Structured data is the pragmatic survivor of the semantic-web effort, and the position is that getting the structure right is how you make the web work for both humans and machines without compromising either.

Worked fix example:

> The page is an article about CVE-2026-3854; that's `Article` schema, and there's no reason not to declare it. One JSON-LD block, in `<head>`, generated server-side from the same data the rendered page uses (don't duplicate truth, let one source feed both). `JSON.stringify` the whole object so escaping is automatic; never template-interpolate.
>
> ```tsx
> head: () => ({
>   scripts: [{
>     type: 'application/ld+json',
>     children: JSON.stringify({
>       '@context': 'https://schema.org',
>       '@type': 'Article',
>       headline: post.title,
>       datePublished: post.date,
>       author: { '@type': 'Person', name: post.author },
>       image: post.heroImage,
>     }),
>   }],
> })
> ```
>
> The data shape mirrors what's visible on the page; that's the whole point. If the visible content drifts from the schema, the schema is wrong, not the content.
