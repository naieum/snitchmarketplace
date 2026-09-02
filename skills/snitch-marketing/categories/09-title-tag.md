## CATEGORY 9: Title tag

The `<title>` is the single most-weighted on-page SEO signal Google still uses. It's also what users click in the SERP. Get it wrong (missing, duplicated across pages, longer than ~60 chars and truncated mid-keyword, generic, keyword-stuffed) and you bleed both rankings and CTR.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` every route file pattern in the detected framework (`src/routes/**/*.{ts,tsx}` for TanStack Start; `app/**/{layout,page}.{ts,tsx}` for Next.js App Router; `pages/**/*.{ts,tsx,js,jsx}` for Pages Router; `src/pages/**/*.astro` for Astro; etc.). Capture all routes.
2. `Read` each route file in full plus its parent layouts. Title cascade is real; you cannot judge a child's title without reading the parent's `template`.
3. Quote the EXACT title string for each route (the resolved value, including parent template substitution if applicable). Note the file:line.
4. For "duplicate titles across routes" findings, group routes by exact title string AFTER resolving template substitutions. Quote at least 3 routes per duplicate bucket in the report.
5. For framework-default titles (e.g., `'Create Next App'`), grep for the literal string across the route tree before claiming it appears anywhere.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Quote the entire `<title>` element verbatim from the response.
2. For "duplicate titles" findings, `Fetch` up to `crawl-max-pages` URLs from the sitemap. Bucket by exact title string. Quote each bucket's titles + URLs.
3. For "title set client-side" findings, note the SSR title from the initial response, then declare in the report that JS-set titles cannot be verified by this crawl mode (would need a JS-rendering crawler). Don't claim "title is missing" when the SSR value differs from a possible client-set value.

### Forbidden claims

- "The page is missing a title." Either the rendered HTML / source has no title element, or it has one. Quote it (or quote its absence) before claiming.
- "Most pages probably have generic titles." Enumerate or don't claim.
- "The title is too keyword-stuffed." Cite the title literally and the keyword count. Don't say "stuffed" without showing the words.
- "The title doesn't match the page content." Quote both the title AND a section of page content that contradicts it. The mismatch is the finding; without both sides, you have nothing.

### Detection

#### Source mode

Locate where titles are declared per route across the framework:

- **Next.js App Router**:
  - `metadata.title` in `layout.tsx` / `page.tsx`. Can be a string OR an object: `{ default: '...', template: '%s | Brand' }`.
  - `generateMetadata` async function returning `{ title }`.
  - Layout titles cascade: child page title fills the layout's `template` slot if defined.
- **Next.js Pages Router**: `<title>{...}</title>` inside `next/head` `<Head>` block.
- **TanStack Start**: `head: () => ({ meta: [{ title: '...' }] })` per `createFileRoute`.
- **Astro**: `<title>{title}</title>` in the layout's `<head>` slot, with `title` set from page frontmatter / props.
- **Remix**: `meta` export returning `[{ title: '...' }]`.
- **Nuxt**: `useHead({ title })` or `useSeoMeta({ title })`.
- **WordPress**: theme `header.php` `<title><?php wp_title(); ?></title>` OR plugin override (Yoast / RankMath set the title via filter).
- **Static HTML**: literal `<title>` in `<head>`.

For each indexable route:

1. A title is declared.
2. The title is unique across routes (no two indexable pages share one).
3. The title is reasonable length: ~30-60 chars renders fully in Google's SERP at desktop pixel widths; longer truncates to `...`.
4. The title isn't a generic placeholder or template default (`Untitled`, `New page`, `Page`, the framework name, the project name with no page context).

#### Crawl mode

Fetch the URL. Parse `<head> > title`. Inspect:

- Does the element exist?
- Is it non-empty?
- What's the rendered length in characters?

For "duplicate titles across pages" (the highest-impact title issue), you need to crawl multiple URLs. Pull up to `crawl-max-pages` from the sitemap, fetch each, and bucket by exact title string. Buckets with >1 entry are the duplicate-title finding.

### What to Search For

- `<title>` literal in HTML / JSX / template files
- `title:` in metadata configs across all the framework patterns above
- `wp_title()`, `the_title()`, `single_post_title()`, `bloginfo('name')` in WordPress themes
- The string `'Untitled'`, `'New page'`, `'Page'`, framework defaults (`'Create Next App'`, `'Vite + React'`, `'Astro'`, `'TanStack Start'`)

### Actually Hurts SEO

- **No `<title>` element on an indexable page.** Google generates one from page content (often picks a heading, often picks the wrong one). You lose CTR control entirely.
- **`<title>` set to a framework default (`'Create Next App'`).** Tells Google the page is a stock starter; ranks abysmally for anything intentional.
- **`<title>` set to the same string across many pages** ("Home, My Brand" on every route, "Blog" on every blog post). Google de-duplicates and keeps one, the rest get suppressed in search.
- **Title >70 chars on a commercial page.** Truncates with `...` in SERP, hides keywords / brand at the tail. Title is intact in the page's HTML but the SERP-rendered version is what users click.
- **Title <10 chars** ("Home", "About"). No keyword surface for the algorithm to rank against; CTR garbage.
- **Title keyword-stuffed** ("Buy cheap shoes online cheap shoe sale shoes for sale buy shoes"). Google's spam filters demote this. Don't write for the algorithm; write for the user clicking.
- **Title that's just the brand name on a non-homepage** ("My Brand" on a blog post). The user has no idea what page they'd land on. Brand belongs at the END (or omitted entirely on long pages).
- **Brand at the front on every page** ("My Brand, How to Cook Eggs"). Wastes the most-weighted SERP pixels on something the user already knows. Move brand to the end ("How to Cook Eggs | My Brand").
- **Title that doesn't match what the page is about.** The title says "Pricing, Acme" but the H1 and content are about features. Google's algorithm reads both; mismatch is a relevance signal that tanks the page.

### NOT a Problem

- Long-form blog posts with titles 60-70 chars where the keyword is at the front. The tail truncates in SERP but the keyword is intact at the visible part. Acceptable.
- Brand-as-suffix on every page (e.g., `'How to Cook Eggs | My Brand'`). Standard pattern. Don't flag.
- Pagination titles like `'Recipes (Page 2), My Brand'`, distinct enough to not be a duplicate.
- Routes that are deliberately noindex'd (admin, debug, internal docs) with no title, they're not in the SERP, doesn't matter.
- Single-page-app shell that sets the title client-side via `document.title`. Modern Google renders JS; verify in crawl mode by fetching with a renderer-equivalent fetch (curl alone won't show the JS-set title; we accept this limitation and note in the report when we couldn't verify).

### Context Check

1. Is the route actually indexable? Don't flag missing/bad title on a noindex'd / robots-disallowed page.
2. Does the framework auto-set the title at runtime? Next.js's `metadata.title` cascade is real but depends on parent layouts. Read the parent layout's metadata before flagging "missing title" on a child page that inherits.
3. Does a SEO plugin (Yoast / RankMath) override the theme? In WordPress, the plugin wins. Check the plugin's settings, not just the theme template.
4. Is the title computed from CMS data? `metadata.title = post.title || 'Default'`, flag the fallback if it's likely to fire (post with no title field set). Don't flag if the codebase enforces title required.
5. Is this a 404 / error page? `'Page Not Found'` is correct, not a finding.
6. Is duplication intentional? E.g., a multi-language site where each locale has its own `/en/about`, `/es/about`, the titles are translations, but each is unique within its locale. Bucket by locale before checking duplication.

### Reference

Google's documentation on title tags: https://developers.google.com/search/docs/appearance/title-link

Google's note on title rewrites (Google sometimes overrides your title in SERP): https://developers.google.com/search/blog/2021/08/title-rewrites

**Severity tagging:**
- No `<title>` on indexable page → Critical.
- Framework default title shipped to prod → Critical.
- Same title on >5 indexable pages → Critical.
- Same title on 2-5 indexable pages → High.
- Title <10 chars or >80 chars on commercial page → High.
- Title that doesn't reflect page content → High.
- Brand-first ordering on non-homepage → Medium.
- Suboptimal length 60-70 chars with keyword at front → Low.

**Fix voice:** `plain-language-designer` (primary) | `honest-design-critic` (backup, for "you shipped a default title to prod, what are you doing" energy).

Read `souls/plain-language-designer.json` before writing the Fix. Plain-language commercial design says what the thing is, in the words of a person who actually buys things. SERP titles are the closest the web gets to a billboard you have 60 characters to write.

Worked fix example:

> The title's job is to tell the person searching "this is the page you wanted." That's it. "How to Cook Eggs | Tasty Recipes" wins because it answers the search verbatim. "Tasty Recipes - Premium Culinary Solutions for Modern Home Chefs" loses because nobody searched for that. Put the keyword at the front, the brand at the end, kill the brand on long-form posts entirely if it's stealing pixels from the headline. ~50-60 chars. Read it out loud, if you'd cringe saying it to a stranger, rewrite it.
