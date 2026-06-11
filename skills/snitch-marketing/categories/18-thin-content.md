## CATEGORY 18: Thin content (word count + content depth)

"Thin content" is Google's term for pages that exist but don't say much: stub pages with placeholder copy, auto-generated category indexes with no per-page content, pages with one paragraph of text padded out by stock images. Google's quality systems flag these and demote the entire site (not just the thin pages, the surrounding good content gets dragged down).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` route + content files. `Read` each.
2. For each indexable route: extract the visible text content (remove imports, JSX boilerplate, components, navigation, footer). Count words.
3. For data-driven routes: read the data source. If the route renders `{post.body}` and `post.body` could be empty, flag the empty case AND the route's handling of it.
4. Quote the actual text content with word count for each finding.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse `<body>`. Strip nav, header, footer, sidebar (if identifiable). Extract main content text.
2. Word count the main content.
3. For "thin content" findings: quote the entire main content + the word count.

### Forbidden claims

- "Many pages probably have thin content." Sample. Quote.
- "The product pages may be too short." Quote at least 3 with word counts.
- "Auto-generated category pages are likely thin." Read the route's template, see what it actually renders.

### Detection

#### Source mode

Estimate word count for each route's main content area. Common thin-content patterns:

- A blog "post" that's actually a tweet-length aside (50-100 words).
- A product page that's just title + price + add-to-cart with no description.
- An auto-generated category page: title + product grid + nothing else.
- A "service" page with three sentences of placeholder text.
- An "about" page with one sentence: "Coming soon."

#### Crawl mode

Word-count the rendered main content area.

### What to Search For

Patterns indicating thin content:

- Routes that render only data without static content
- Empty-state fallbacks: `{post.body || 'Coming soon.'}`
- Templated pages with minimal-per-page customization (programmatic SEO at low quality)
- Pages with `<lorem ipsum>` placeholder text
- "Coming soon" / "Under construction" / "Page in progress" copy

### Actually Hurts SEO

- **Indexable page with <100 words of main content**.
  Evidence required: word count + the entire content quoted.
- **Page with placeholder text (lorem ipsum, "Coming soon", "TODO")**.
  Evidence required: quoted placeholder + the route URL.
- **Auto-generated category / tag / archive page with no per-page content**.
  Evidence required: the page's template + the rendered output showing zero descriptive content beyond the listings.
- **Programmatic SEO pages where only the variable token differs across hundreds of pages** ("Snitch CLI for {{language}}" with the same boilerplate body, only the language name varying).
  Evidence required: 2-3 page samples showing the templated similarity.
- **Duplicate content across pages** (the same paragraph repeated on every product page in a category).
  Evidence required: the duplicated paragraph + at least 3 routes that contain it.

### NOT a Problem

- A short blog post (300 words) on a topic that doesn't need more. Length isn't quality; quality is quality.
- A product page with the actual product description AND specs AND reviews, even if the dev-written copy is short, total content is rich.
- A landing page with very little body text but rich functional content (a calculator, a tool, an interactive demo). Functional value counts.
- An archive / index page with rich curation: not just a list, but ranked, categorized, with intro context per category.
- Single-page-app shells where the content loads client-side. SSR the content; don't flag the shell.

### Context Check

1. What's the page's purpose? An interactive tool doesn't need 1000 words of body text. A blog post does.
2. Is the content data-driven? Read the data source. Empty-state handling is the real concern.
3. Is this programmatic SEO? Templated pages can rank if each variant has substantive variation; cookie-cutter variants rank for nothing.
4. Are there reviews / comments / user-generated content that adds depth? Don't flag if UGC is rich (and SSR'd or indexable).
5. Is the page noindex'd? If yes, thinness doesn't matter. Flag only if indexable.

### Reference

Google's quality rater guidelines on thin content: https://developers.google.com/search/docs/essentials/spam-policies

**Severity tagging:**
- Page <100 words on indexable URL → High.
- Placeholder text shipped to prod → Critical (not just thin, embarrassing).
- Templated programmatic SEO with <30% per-page variation → High.
- Duplicate paragraphs across many pages → High.
- Index/archive page with no curation → Medium.

**Fix voice:** `frank-chimero` (primary) | `dieter-rams` (backup).

Read `souls/frank-chimero.json` before writing the Fix. Frank's "Shape of Design" voice on substance over volume, content depth isn't word count, it's whether the page does for the reader what they came for.

Worked fix example:

> Thin content isn't about being short. It's about not having said anything. A 100-word page can be enough; a 5,000-word page can be thin if all it does is repeat the same point.
>
> Look at the page through the visitor's eyes. They typed something into Google and clicked your link. Did the page answer what they were asking? If yes, you're not thin, you're efficient. If no, the fix isn't more words; it's saying the right thing.
>
> For pages that genuinely have nothing to say (auto-generated archives, placeholder service pages): either add real content (a curator's note, a context paragraph, a reason to be on this page), or `noindex` it and stop competing for slots that aren't earning their place.
>
> For programmatic SEO pages: 30% boilerplate / 70% per-page substance is the floor. If the variable tokens (language, framework, location) carry the entire variation, the pages are thin. Add per-token specifics: examples, code, gotchas unique to that variant.
