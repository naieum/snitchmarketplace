## CATEGORY 17: Semantic HTML

Semantic elements (`<article>`, `<section>`, `<nav>`, `<aside>`, `<main>`, `<header>`, `<footer>`, `<figure>`) tell browsers, screen readers, and search crawlers what each region of the page means. Sites built entirely from `<div>`s look the same visually but carry no structural information, Google has to infer document parts from context, accessibility tools have less to work with.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` route + layout files. `Read` each.
2. `Grep` for `<article`, `<section`, `<nav`, `<aside`, `<main`, `<header`, `<footer`, `<figure`, `<figcaption`, `role="`. Quote each match.
3. `Grep` for `<div` (likely a lot of matches; sample top-of-page blocks). Identify divs that should be semantic elements.
4. For each route: count semantic elements vs total elements. Heavy `<div>` saturation with no semantic siblings is the finding.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse `<body>`. Count: `<main>`, `<article>`, `<section>`, `<nav>`, `<aside>`, `<header>`, `<footer>` instances.
2. Identify if the document has at least: one `<main>`, one `<header>`, one `<footer>`, one `<nav>` (typically).
3. Quote the `<body>`'s top-level structure.

### Forbidden claims

- "The page probably uses too many divs." Show me a count or a quoted sample.
- "Semantic markup is missing." List which elements are missing and quote what's there instead.
- "Accessibility may be impacted." Tie it to a specific element or a specific screen-reader behavior; don't speculate.

### Detection

#### Source mode

For each route's component tree:
1. Identify the page's main content region. Is it wrapped in `<main>` or `<article>`? Or is it a `<div>`?
2. Identify the navigation. `<nav>` or `<div className="nav">`?
3. Identify the page header / footer. `<header>` / `<footer>` or `<div>`?
4. Identify article-like content (blog posts, product descriptions). `<article>` or `<div>`?

#### Crawl mode

Parse rendered HTML, count semantic elements, identify gaps.

### What to Search For

- `<main`, `<article`, `<section`, `<nav`, `<aside`, `<header`, `<footer`, `<figure`, `<figcaption`
- `role="main"`, `role="article"`, `role="navigation"`, `role="contentinfo"` (ARIA roles as fallback semantics)
- `<div>` opening tags (high-volume; sample for div-saturation)

### Actually Hurts SEO

- **No `<main>` element** (the page's primary content has no semantic anchor).
  Evidence required: rendered HTML showing absence + an indication of where the main content lives (typically a `<div>` instead).
- **Article-shaped content not wrapped in `<article>`** (blog post in a `<div>`).
  Evidence required: page type + the surrounding element. If it's `<div>`, that's the finding.
- **Multiple `<main>` elements** (HTML spec violation; should be one per page).
  Evidence required: count of main elements.
- **Navigation in a `<div>` instead of `<nav>`**.
  Evidence required: the navigation block's element + its child links.
- **Header / footer in `<div>` instead of `<header>` / `<footer>`**.
  Evidence required: same.
- **`<section>` used as a `<div>` substitute for visual grouping with no semantic meaning**.
  Evidence required: the `<section>` + content that doesn't have a heading (sections need headings to be meaningful).

### NOT a Problem

- A `<div>` for a layout grid or visual container. That's what `<div>` is for.
- A `<section>` used for genuinely thematic content even without a heading IF the surrounding context makes the section clear (rare).
- ARIA roles substituted for semantic elements (e.g., `<div role="main">`). Functionally equivalent, less ideal but not broken.
- React component naming that doesn't map to semantic elements (e.g., `<HeroSection>` rendering as `<div>`). The component name is for devs; the rendered element is what matters.

### Context Check

1. Is the page primarily content (article, product, blog)? Semantic structure matters more.
2. Is the page primarily UI (dashboard, app interface)? Semantic structure matters less for SEO; matters a lot for a11y.
3. Does the framework provide semantic-by-default layouts? Some component libraries (Radix, shadcn/ui) use semantic elements internally; others wrap everything in divs.
4. Is the user using a CSS framework that emphasizes class-based styling over semantic markup (early Bootstrap, Tailwind)? The class-based approach often defaults to divs; that's a habit to fight, not a tooling limitation.
5. Are screen reader landmarks present? `<main>` alone gives a "Main" landmark; `<nav>` gives "Navigation"; `<aside>` gives "Complementary". Each landmark = jump-to ability for assistive tech users.

### Reference

MDN on HTML5 semantic elements: https://developer.mozilla.org/en-US/docs/Web/HTML/Element#content_sectioning

WAI-ARIA landmark roles: https://www.w3.org/WAI/ARIA/apg/patterns/landmarks/

**Severity tagging:**
- No `<main>` on content page → Medium.
- Article wrapped in `<div>` instead of `<article>` → Medium.
- Multiple `<main>` elements → High (HTML invalid).
- Navigation in `<div>` instead of `<nav>` → Low.
- `<section>` used as `<div>` substitute (no heading inside) → Low.

**Fix voice:** `jen-simmons` (primary) | `frank-chimero` (backup).

Read `souls/jen-simmons.json` before writing the Fix. Jen's intrinsic-web POV: HTML is the structural layer. Use the elements that mean what you mean, then style them however you want.

Worked fix example:

> The page is an article. Wrap it in `<article>`. The block at the top with the logo and nav links is a header. Wrap it in `<header>`. The list of nav links is navigation. Wrap it in `<nav>`. The bottom with copyright and links is a footer. Wrap it in `<footer>`. The main content area is the main content area. Wrap it in `<main>`.
>
> ```tsx
> // Before: div soup
> <div className="page">
>   <div className="top-bar">
>     <div className="brand-logo">…</div>
>     <div className="nav">…</div>
>   </div>
>   <div className="content">…article…</div>
>   <div className="bottom-bar">…</div>
> </div>
>
> // After: same layout, semantic elements
> <div className="page">
>   <header className="top-bar">
>     <a className="brand-logo">…</a>
>     <nav className="nav">…</nav>
>   </header>
>   <main>
>     <article className="content">…article…</article>
>   </main>
>   <footer className="bottom-bar">…</footer>
> </div>
> ```
>
> Same CSS classes, same visual output. The structure now means something. Screen readers gain landmark navigation, search engines gain document understanding, and the markup reads like the page rather than fighting it.
