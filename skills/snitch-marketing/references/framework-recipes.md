# Framework Recipes — per-stack gotchas

Each section is the load-bearing knowledge an SEO auditor needs about that stack. Load this file when the detected stack is in the table; reference the matching section before flagging metadata / head / routing findings.

---

## Next.js (App Router, 13+)

**Where metadata lives:**
- Static export: `export const metadata: Metadata = { title, description, openGraph, twitter, ... }` in any `layout.tsx` or `page.tsx`.
- Dynamic: `export async function generateMetadata({ params }): Promise<Metadata>`.
- Layout metadata is **merged** with page metadata; child overrides parent. Read the parent layout before flagging missing tags.
- Image metadata via `opengraph-image.tsx` / `twitter-image.tsx` / `icon.tsx` files in the route directory — Next.js auto-generates the `<meta>` tags for these.

**Common false positives:**
- Searching for `<title>` literal in source: there isn't one. Title comes from `metadata.title`. Use Grep on `metadata` + `generateMetadata`.
- Searching for `<link rel="canonical">`: again, not in source. Comes from `metadata.alternates.canonical`.
- `metadata.robots` → renders `<meta name="robots">`. If `robots: { index: false }`, the page is `noindex` (don't flag missing canonical etc. on noindex'd pages).

**Sitemap & robots:**
- `app/sitemap.ts` exports a default function returning the sitemap entries.
- `app/robots.ts` exports a default function returning robots config.
- Static fallbacks: `public/sitemap.xml`, `public/robots.txt`. Source-side both should be checked.

---

## Next.js (Pages Router, legacy)

**Where metadata lives:**
- `<Head>` from `next/head` inside the page component. Manual.
- `_app.tsx` provides defaults; pages override.
- `_document.tsx` only for `<html>` / `<body>` attributes.

**Common false positives:**
- Same defaults-and-override pattern. Read `_app.tsx` and any wrapping layout before flagging missing tags.

---

## TanStack Start

**Where metadata lives:**
- Each `createFileRoute(...)` may include a `head: () => ({ meta, links, scripts })` function. `meta` is an array of `<meta>` configs; `links` is an array of `<link>` configs.
- `__root.tsx` has the global `head()` providing defaults. Each child route's `head()` is **appended**, not merged — duplicate meta entries can appear if both root and child set `title`.

**Common false positives:**
- The route's `head()` may return computed values that depend on loader data. The static source doesn't show the resolved value; verify with crawl mode if uncertain.
- Splat routes (`$.tsx`) handle multiple URLs with the same `head()` — flag once, not per URL.

---

## Astro

**Where metadata lives:**
- Component frontmatter (` --- ` block) sets variables; the layout interpolates them into `<head>` slots.
- `BaseLayout.astro` typically owns the head; pages set props.
- Content collections: frontmatter `title`, `description` etc. flow into the page via the collection schema.

**Common false positives:**
- Astro's frontmatter is server-only; the `<head>` is rendered statically. What you see in source IS what's served (no client-side metadata mutation typical).
- `getStaticPaths` generates the route table; check it for which slugs actually exist before flagging missing pages.

---

## Remix

**Where metadata lives:**
- `meta` export from a route module: `export const meta: MetaFunction = () => [{ title }, { name: 'description', content }, ...]`.
- Parent route metas merge; child wins on conflict.
- `links` export for `<link>` tags (canonical, preconnect, etc.).

---

## Nuxt 3 / 4

**Where metadata lives:**
- `useHead({ title, meta, link })` composable inside a page or layout.
- `useSeoMeta({ title, description, ogTitle, ... })` composable for the SEO-flavored shorthand.
- `app.config` / `nuxt.config.ts` for global defaults.

---

## SvelteKit

**Where metadata lives:**
- `<svelte:head>` block inside `+page.svelte` / `+layout.svelte`.
- `+page.ts` / `+page.server.ts` `load` returns data; `<svelte:head>` consumes it for dynamic titles.

---

## WordPress

**Where metadata lives (theme):**
- `header.php` — `wp_head()` action runs all registered head hooks (Yoast, RankMath, AIOSEO, etc.) plus the theme's own `<title>` and meta tags.
- `functions.php` — theme may add custom `<meta>` via `wp_head` action or filters.

**Where metadata lives (plugin overrides):**
- Yoast SEO: per-post `_yoast_wpseo_*` postmeta. Page-level value overrides the theme default. Check the post edit screen / database before flagging.
- RankMath: similar `rank_math_*` postmeta.
- AIOSEO: `_aioseo_*` postmeta.

**Common false positives:**
- A theme has a hardcoded title in `header.php` AND Yoast is installed → Yoast filter wins. The hardcoded title is dead code, not a finding.
- WordPress emits `<meta name="robots" content="max-image-preview:large">` by default. Don't flag as "wrong robots directive" — it's the default.

---

## Shopify

**Where metadata lives:**
- `layout/theme.liquid` — `<title>` typically via `{{ page_title }}` Liquid object; `<meta name="description" content="{{ page_description }}">`.
- `templates/product.liquid`, `templates/collection.liquid`, etc. — page-type-specific overrides.
- Shopify SEO settings (admin) override theme values for the homepage and selected pages.

**Common false positives:**
- `{{ canonical_url }}` outputs the canonical Shopify URL. Themes that hardcode a different canonical are wrong unless the merchant intends it.
- Product schema is auto-emitted by most modern themes via `{% render 'product-json' %}` or similar; check the snippet before flagging missing Product schema.

**Agentic commerce / AI channels (cross-ref Cat 101):**
- Product metafields and metaobjects syndicate through Shopify Catalog to AI shopping surfaces (ChatGPT shopping, Copilot, Shop app) just like standard fields. Spec-shaped facts that live only in `description` prose or hardcoded theme Liquid don't syndicate — audit whether attributes (material, dimensions, compatibility, certifications) exist as metafields, and whether defined metafields are actually connected to products.
- Shopify exposes UCP (Universal Commerce Protocol) agentic checkout self-serve since Spring '26; check `/.well-known/ucp` and whether the merchant's AI sales channels are enabled. A UCP-capable store with the channels off is a Cat 101 High finding.
- Collection pages are Shopify's natural head-term landing pages. A smart collection (rule-based, e.g. product title contains the head term) with descriptive on-page copy + CollectionPage/ItemList schema outranks a bare product grid — see the Cat 18 worked fix. The collection description field renders above the grid in most themes; theme edits are needed only to move it below.

---

## Webflow / Wix / Squarespace

**Source mode unavailable.** Force crawl mode for these.

**Common false positives:**
- These platforms emit a lot of platform-specific metadata. A `<meta name="generator" content="Webflow">` tag is not a finding.
- Wix uses `_partials/Wix.com-stable-version` and similar paths in `robots.txt`; don't flag as misconfiguration.

**Squarespace:**
- Detect via `<meta name="generator" content="Squarespace">` (and `static1.squarespace.com` asset hosts). The generator tag is not a finding.
- Don't flag Squarespace's system `?format=` URLs (e.g. `?format=json`, `?format=json-pretty`, `?format=ical`, `?format=rss`) as duplicate-content problems — they're built-in alternate representations, not crawlable duplicates.
- Don't flag tag/category archive URLs (`/blog/tag/...`, `/blog/category/...`) as duplicate content; Squarespace canonicalizes these.
- Built-in sitemap lives at `/sitemap.xml` (auto-generated, not editable); don't flag a "missing" sitemap before checking that path.

---

## Ghost

**Where metadata lives:**
- Source mode (self-hosted): Handlebars themes — `themes/<theme>/*.hbs` (`default.hbs`, `post.hbs`, etc.) + `config.production.json`. `{{ghost_head}}` / `{{ghost_foot}}` helpers emit the platform's head/footer output.
- Ghost(Pro) hosted is **crawl-only** — no source access. Audit the rendered DOM, not files.

**Common false positives:**
- Ghost auto-emits canonical tags and Article / Organization JSON-LD. "Missing canonical" / "missing Article schema" / "missing Organization schema" findings are likely false positives — verify the rendered DOM before flagging.
- Code injection: site- and post-level head/footer code-injection can override or add tags. A tag absent from the theme may still be injected; check the rendered output.
- `<meta name="generator" content="Ghost ...">` is not a finding.

---

## Static HTML / Hugo / Jekyll / Eleventy

**Where metadata lives:**
- Layout templates (`layouts/_default/baseof.html` for Hugo, `_layouts/default.html` for Jekyll, etc.).
- Page frontmatter sets variables; layout interpolates.

**Common false positives:**
- Hugo uses `{{ .Title }}`, `{{ .Description }}` — verify the front matter is set per page before flagging.
- Jekyll's `{{ page.title }}` falls back to `{{ site.title }}` in many themes — check both.

---

## When you don't recognize the stack

If detection fails to match anything in this file:

1. Don't fall back to "generic" advice that doesn't apply.
2. State explicitly in the report: "Stack not auto-detected. Findings limited to crawl-mode checks."
3. Run only crawl-mode categories. Source-mode categories are skipped with reason "no recognized framework".
