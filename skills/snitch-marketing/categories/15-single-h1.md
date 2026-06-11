## CATEGORY 15: Single H1 per page

Every indexable page should have exactly one `<h1>`. The H1 is the page's primary topic signal, the in-page equivalent of the title tag. Multiple H1s split the signal; zero H1s leave Google guessing from less-weighted elements (the title tag, OG title, page content). Most modern semantic-HTML guidelines tolerate multiple H1s ("each `<section>` can have one"); Google's actual ranking signal still favors the single-H1 structure on content pages.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` every route file in the detected framework. For each route, you'll trace the component tree.
2. `Grep` for `<h1` (with attributes) and `# ` at column 0 of MDX files across the project. This produces the candidate set of H1 sources.
3. For each route: `Read` the route file. Trace its imported layout(s) and any wrapper components. `Read` each one. Count rendered H1s.
4. For library-component H1s (`<DocsTitle>`, `<PageHeading>`, custom abstractions): `Read` the component definition before assuming it renders H1. The component name doesn't tell you the rendered tag, only the source does.
5. Quote each H1's file:line + the literal text of the heading.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Parse `<body>`. Count `<h1>` elements in the response.
2. Quote each H1 element including its text content and any inline styles (a hidden H1 is a different finding).
3. For "H1 hidden via CSS" findings: locate the H1's class names in the response, fetch the relevant CSS, quote the rule that hides it. Don't claim hidden without proving it.

### Forbidden claims

- "The page has multiple H1s." Show me each one, with file:line or rendered HTML quoted. Two is multiple; show the two.
- "The H1 is keyword-stuffed." Quote the H1 text literally and identify the repeating tokens. Don't paraphrase.
- "The H1 probably contains the entire article." If you didn't read the H1's content, you don't know what's in it.
- "The framework probably auto-generates an H1." Read the framework's docs (in source) or the rendered HTML. Don't assume.

### Detection

#### Source mode

Walk the page's component tree and count rendered H1s. The challenge is that H1s come from layouts, page components, MDX frontmatter, CMS content, AND occasionally library components. You have to follow the import graph.

- **Direct JSX**: `<h1>...</h1>` literal in any TSX / JSX / Astro / Vue / Svelte component used by the route.
- **Markdown / MDX**: `# Heading` at the top level of any `.md` / `.mdx` file rendered by the route. MDX `# Heading` becomes `<h1>` by default unless the MDX provider remaps `h1` to a different element.
- **Headless component libraries**: `<Heading level={1}>`, `<Title>`, `<PageTitle>`, scan for project-specific abstractions. Common: shadcn/ui's `<h1>` in cards, fumadocs's `DocsTitle` (which renders `<h1>` in the docs page).
- **WordPress themes**: `<?php the_title(); ?>` inside `<h1>` is the most common pattern. Some themes wrap it in `<h2>` (wrong for content pages), some duplicate it via `single_post_title()` and `the_title()` separately (also wrong).
- **CMS-driven pages**: the H1 may come from a content field (`page.title`, `post.heading`). The component is correct; the data may produce duplicates if the CMS allows multiple "primary heading" fields per page.

#### Crawl mode

Fetch the URL. Parse `<body>`. Count `h1` elements. Get their text content for the report.

### What to Search For

- `<h1>` literal in any source file rendered by the route
- `# ` at column 0 of any `.md` / `.mdx` (Markdown H1 syntax)
- `### Heading 1` style in some custom MDX setups (rare, but worth noting)
- Heading components: `<Heading level={1}>`, `<H1>`, `<PageHeading>`, `<DocsTitle>`, etc.
- WordPress `<?php the_title(); ?>` patterns where the surrounding tag is `<h1>`

### Actually Hurts SEO

- **Two or more H1s rendered on the same indexable page.** A single H1 is the cleanest topical + a11y signal; Google tolerates multiple H1s (per John Mueller, below). The downside is clarity, not a known penalty: multiple H1s muddy the page's primary-topic declaration and the document's heading map. Common cause: a layout component renders an H1 (site name, brand) AND the page content also renders an H1 (article title).
- **Zero H1 on an indexable page.** The page has no primary topic declaration in the body. Google falls back to title, OG, content cues. Ranking is fragile.
- **H1 hidden via CSS AND stuffed / off-topic** (`display: none`, `visibility: hidden`, or `font-size: 0` on an H1 whose text is keyword-stuffed or unrelated to the visible page). That combination looks like a cloaking/stuffing attempt and may trigger a penalty. Note: a visually-hidden H1 using the standard accessible off-screen technique (`.sr-only` / `clip` / `width:1px;height:1px`) with honest, on-topic text is NOT this finding, see NOT a Problem.
- **H1 used as a layout element** (e.g., the brand name in the page header, repeated on every page). Wastes the H1 on something that's not the page's topic.
- **H1 contains the entire content** (the article body wrapped in `<h1>` instead of `<p>`). Yes, this happens on AI-built sites. Usually a misuse of a heading-styled component.
- **H1 mismatch with title tag / page content.** H1 says one thing, title says another, content covers a third topic. Google reads all three; mismatch demotes relevance.
- **H1 keyword-stuffed.** Same penalty pattern as a stuffed title.

### NOT a Problem

- A page with one H1 in the article + an H1 in a sidebar widget that's clearly secondary chrome (e.g., a "Related posts" heading set to H1 by a misguided theme). Flag as Medium, not Critical, Google deals with this category of mistake daily and the impact is small.
- HTML5's "outline algorithm" allows multiple H1s, one per `<section>`. Modern browsers don't implement this. Google tolerates but doesn't reward it. If the site is deliberately using HTML5 outline, flag as Low (or skip with note "site uses HTML5 outline algorithm; Google has limited support") rather than High.
- Programmatic SEO pages where the H1 is templated (e.g., "Snitch CLI for {{language}}"), that's correct; the dynamic value is the topic.
- A page intentionally noindex'd. Doesn't matter what its H1 looks like.
- A visually-hidden H1 using the standard accessible off-screen technique (`.sr-only` / `.visually-hidden`, `clip: rect(...)`, `width:1px;height:1px;overflow:hidden`, or `clip-path`) with honest, on-topic text. This is the recommended accessible pattern (it gives screen-reader and SEO crawlers a page-topic H1 when the visual design uses a logo or image instead) and aligns with Cats 103-105. Don't flag it as spam. Penalty severity is reserved for `display:none` / `visibility:hidden` / `font-size:0` H1s whose text is ALSO stuffed or off-topic.

### Context Check

1. Is this an indexable page? Don't flag H1 issues on noindex'd, robots-disallowed, or canonicalized-away routes.
2. Does the layout already render an H1? Read the parent layout / template before flagging missing H1 on a child page that inherits one.
3. Is the H1 visible? Hidden H1s look like spam. Verify with rendered styles in crawl mode.
4. Is the page content-focused (article, product, landing page) or chrome-heavy (homepage, archive index)? Standards vary: a homepage often has its main message as the H1; an archive page often has "Blog" as H1 with article titles as H2s. Both are correct in context.
5. What does the title tag say? If title and H1 disagree wildly, flag the mismatch as a separate issue (Cat 9 territory).
6. Is the H1 generated from CMS data that could be empty? Check the data's source for the empty/null case; the rendered output may be `<h1></h1>` (an empty H1, worse than no H1).

### Reference

Google's John Mueller has been on record for years that multiple H1s aren't a critical issue, but a single H1 is the cleanest signal:
- https://www.youtube.com/watch?v=zyqJJXWk0gk

WebAIM's a11y guidance on heading structure (single H1 is also the a11y best practice): https://webaim.org/techniques/semanticstructure/

**Severity tagging:**
- Zero H1s on an indexable content page → High.
- Two H1s on an indexable content page (e.g., layout + page both render one) → Medium.
- Three or more H1s on a single page → High.
- H1 hidden via `display:none` / `visibility:hidden` / `font-size:0` AND stuffed or off-topic → High (penalty risk).
- H1 visually hidden via the standard accessible off-screen technique (`.sr-only` / `clip` / `width:1px`) with honest on-topic text → not a finding (correct a11y pattern; see NOT a Problem).
- H1 mismatch with title tag (different topics) → High.
- HTML5-outline use of multiple H1s with no other issues → Low (or skip).

**Fix voice:** `massimo-vignelli` (primary) | `dieter-rams` (backup).

Read `souls/massimo-vignelli.json` before writing the Fix. Vignelli's lifelong fight was for hierarchy, one primary, then secondaries, in disciplined order. The H1 is the typographic primary of the page; everything else subordinates to it. His NYC subway map and Knoll catalogs are nothing but applied hierarchy.

Worked fix example:

> One H1, set at the top of the article, stating the page's subject in the same words the title declares. Demote the layout's brand-name H1 to a `<p>` styled like an H1 if visual prominence is what you wanted, the typography stays, the structural signal moves to where it belongs. Rendered hierarchy and document hierarchy are not the same thing; the page can look any way you want, but the structure must obey the rule: one H1, then H2s under it, then H3s under those, no skipped levels.
>
> ```tsx
> // Layout: was <h1>Snitch</h1>, now styled p
> <p className="text-2xl font-bold tracking-tight">Snitch</p>
>
> // Page: the actual H1
> <h1>Security review for the code your AI wrote</h1>
> ```
