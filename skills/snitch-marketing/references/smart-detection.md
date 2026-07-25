# Stack & Site Detection (Quick Audit + scan flow)

Run this at the start of every audit. Determines:

1. Mode (source / crawl / both)
2. Stack (framework, CMS, hosting)
3. Page-type detection (so per-type categories like Product schema only run where they apply)

## Mode detection

| Signal in working directory | Mode |
|---|---|
| `package.json` + `next.config.{js,mjs,ts}` | Source — Next.js |
| `package.json` + `astro.config.{js,mjs,ts}` | Source — Astro |
| `package.json` + `tanstack-start.config.{js,ts}` OR `app.config.ts` with TanStack imports | Source — TanStack Start |
| `package.json` + `remix.config.{js,mjs}` OR `vite.config` importing `@remix-run` | Source — Remix |
| `package.json` + `nuxt.config.{js,ts}` | Source — Nuxt |
| `package.json` + `svelte.config.{js,ts}` | Source — SvelteKit |
| `gatsby-config.{js,ts}` | Source — Gatsby |
| `.eleventy.{js,ts}` OR `eleventy.config.{js,ts}` | Source — Eleventy |
| `_config.yml` + `Gemfile` with jekyll | Source — Jekyll |
| `wp-config.php` OR `wp-content/themes/` | Source — WordPress |
| `config.toml` / `config.yaml` + `themes/` (Hugo layout) | Source — Hugo |
| `themes/*.hbs` + `config.production.json` (Handlebars themes) | Source — Ghost |
| `index.html` at repo root + no JS framework config | Source — static HTML |
| User pasted a URL, no working dir | Crawl |
| Both above | Both — prefer source for source-fixable, crawl to verify |
| None of the above + no URL | Ask the user "Where's the site?" |

## Stack detection (refines mode)

### Next.js variants

- **App Router (Next 13+)**: `app/` directory present. Metadata via `metadata` exports / `generateMetadata`. `<head>` is framework-managed; do not flag missing tags from page source — check the resolved metadata.
- **Pages Router (legacy)**: `pages/` directory. `<Head>` from `next/head`. Manual.
- **MDX content**: `*.mdx` files in `app/` or `pages/`. Metadata typically in frontmatter.

### TanStack Start

- Routes in `src/routes/`. Each `createFileRoute(...)` may have a `head: () => ({ meta, links })` returning the page's metadata.
- The root `__root.tsx` provides defaults that child routes override.

### Astro

- `src/pages/`. Metadata in component frontmatter or layout.
- Layouts in `src/layouts/`.

### WordPress

- Yoast SEO: meta tags emitted by `wpseo_*` filters; the page-level value overrides theme defaults. Check the page's edit screen settings before flagging.
- RankMath: similar override behavior.
- Without a SEO plugin: theme `header.php` + `wp_head()` action handles tags.

### Webflow / Wix / Squarespace

- Source mode unavailable (no repo). Force crawl mode. See **Closed / hosted platforms** below for the full list and the hosted-platform skip reason.

### Shopify

- Theme files (`*.liquid`) in `templates/`, `sections/`, `snippets/`, `layout/theme.liquid`.
- Storefront SEO: `<title>{{ page_title }}</title>`, `<meta name="description" content="{{ page_description }}">`.

### Ghost

- Source mode: Handlebars themes — `themes/*.hbs` + `config.production.json`.
- Crawl mode: `<meta name="generator" content="Ghost ...">`.
- Ghost(Pro) hosted is crawl-only (no source access). Self-hosted Ghost may expose the theme repo.

### Closed / hosted platforms (force crawl mode, SPA-aware)

- Source mode unavailable (no repo). Force crawl mode for: Webflow, Wix, Squarespace, Framer, Carrd, Bubble, Ghost(Pro).
- Framer and Bubble render SPA-like (client-hydrated DOM); treat as JS-rendered.
- Detect via `<meta name="generator">` (e.g. `Wix.com`, `Squarespace`, `Framer`, `Carrd`, `Bubble`) or platform-specific asset hosts.
- These platforms have **no source the user can point at**. Do NOT recommend source/Plugin mode for DOM-dependent skips. Use the hosted-platform skip reason below.

**Hosted-platform skip reason** (closed/hosted builders — Wix / Squarespace / Webflow / Framer / Carrd / Bubble / Ghost(Pro)): when a non-JS crawl can't see post-hydration DOM, mark DOM-dependent cats **Skip** with reason "crawl mode without JS rendering can't see post-hydration DOM; source mode is unavailable on this hosted platform — re-run with a JS-rendering crawler (Playwright / headless Chrome) for the post-hydration DOM." Do NOT tell the user to switch to source/Plugin mode — they have no source.

(For self-hosted SPAs — Next.js / React / etc. where the user owns the repo — keep recommending source/Plugin mode, which reads JSX/TSX directly and is unaffected by hydration.)

## Page-type detection

Apply per-type schema categories only where they fit:

| Page type | Detection signals | Schema categories that fire |
|---|---|---|
| Homepage | `/` route | Organization / WebSite (37) |
| Article / blog post | `/blog/`, `/posts/`, `/articles/` paths; `<article>` + author/date metadata | Article (32), BreadcrumbList (33) |
| Product detail | `/product/`, `/products/`, `/p/` paths; `add to cart` text; `Product` schema present | Product (34), BreadcrumbList (33) |
| FAQ page | `/faq` URL OR `<details>` / accordion patterns with question-shaped headings | FAQ (35) |
| How-to / tutorial | `/how-to/`, `/tutorial/`, `/guide/` paths; numbered step headings | HowTo (36) |
| Video page | `<video>` tag OR YouTube/Vimeo embeds | VideoObject (38) |
| Index / listing | Multiple article/product cards + pagination controls | BreadcrumbList (33) only |

If a page doesn't match any of the above, only run the always-applicable categories (1-30, 39-56, 57-60).

## E-commerce signal

Trigger Product schema (34) and Conversion (60) priority bumps when ANY of:

- Routes contain `/cart`, `/checkout`, `/orders`, `/products`, `/shop`
- Stripe / Shopify / Snipcart / Square integrations in dependencies
- Microdata or JSON-LD declares `Offer` or `AggregateOffer`

## Crawl-mode fetch sequence

When mode is crawl-only (or both with no source-mode evidence found for a category):

1. Fetch the URL with timeout from `snitch-marketing.config.md` (default 5000ms), max 3MB body.
2. Follow up to 3 redirects (and report the chain if >1 hop — feeds Cat 6).
3. Parse the HTML once into a DOM-ish tree usable across all categories.
4. Cache the fetch in memory for the rest of the audit.
5. Optionally fetch `/robots.txt` and `/sitemap.xml` (or the URL declared in robots.txt) once at audit start; cache results.
6. For every crawl-bound category — title (9), meta description (10), internal-link-graph (19), broken links (20) — fetch up to `crawl-max-pages` URLs from the sitemap (default 50). Stop early if the cap is hit.
   **Record both numbers — URLs discovered in the sitemap and URLs actually fetched — and carry them into the report's Coverage section.** Every one of these categories produces negative claims ("no duplicate titles", "no orphan pages", "no broken links"), and a negative claim from a capped crawl is invalid, not merely weaker: the duplicate may be on the first URL you did not fetch. Where the cap bound the crawl, phrase every negative result as "none found in the N URLs fetched" and mark that category `partial`.
