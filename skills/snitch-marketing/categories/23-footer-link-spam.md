## CATEGORY 23: Footer link spam

Excessive footer linking, 50+ links jammed into the footer, repeated across every page, is a classic spam signal. Google's quality systems flag it as a sitewide footer-linking pattern (rather than contextual in-content linking) and discount the link equity flowing through it. Worse, customer-facing it just looks like a wall of noise.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<footer`, `Footer`, footer-component patterns. `Read` each.
2. Count `<a href>` AND `<Link to>` elements inside the footer component.
3. For each link: note the target. Bucket by category (legal, social, products, sitemap-style).
4. Quote the footer's full link list with count.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse `<footer>` element (or the area below the main content).
2. Count links. Quote them.

### Forbidden claims

- "The footer probably has too many links." Count them.
- "Footer linking may be excessive." Quote the count and the link distribution.

### Detection

#### Source mode

Find the footer component, count its links, classify them. Look at:
- `<footer>` semantic element
- `<div class="footer">`
- Components named `Footer`, `SiteFooter`, `PageFooter`

#### Crawl mode

Parse footer area in rendered HTML.

### What to Search For

- `<footer`
- Components: `Footer`, `SiteFooter`, `MainFooter`, `<Footer>`
- Footer-styled divs with high link counts

### Actually Hurts SEO

- **>50 links in the footer** (sitemap-as-footer anti-pattern).
  Evidence required: link count + the footer HTML quoted.
- **Footer links repeating in-content navigation**.
  Evidence required: same anchors appear in header nav + sidebar + footer.
- **Footer with keyword-stuffed anchors** ("buy cheap shoes online", "best running shoes 2026", etc.).
  Evidence required: quoted anchors with the stuffing pattern.
- **Footer links to spam / paid placement** (real estate "city + service" combos linking out to partners).
  Evidence required: external link list with suspicious patterns.
- **Footer links to noindex'd / low-quality internal pages** (every blog tag page linked from footer, even ephemeral ones).
  Evidence required: link list + a sample of fetched targets showing noindex or thin content.

### NOT a Problem

- A standard footer with: brand info, 4-6 column groups (Product / Resources / Company / Legal), social icons, copyright. Even with 30-40 links, this is organized and acceptable.
- Sitemap-style footers on small sites where most of the site's content fits naturally in the footer.
- Legal links (Terms, Privacy, Cookies, Accessibility), required, not spam.

### Context Check

1. How many total indexable pages does the site have? A footer linking to 30 of 50 pages is fine; a footer linking to 30 of 5000 pages is suspicious.
2. Are the footer links categorized / grouped meaningfully? A wall of unstyled links is worse than 4 column-organized link groups.
3. Are the footer links the ONLY way to reach those pages (orphans)? Cross-reference Cat 19. Footer-only-linked pages have the link-equity issue from Cat 19 anyway.
4. Are the links contextual to the page? Footer is supposed to be sitewide; per-page contextual linking belongs in body content.
5. Is the footer rendered server-side or hydrated only? Crawler sees what's SSR'd; client-only footer links don't pass.

### Reference

Google's quality rater guidelines (general): https://developers.google.com/search/docs/essentials/spam-policies

**Severity tagging:**
- Footer with >50 links → Medium (sitewide pattern).
- Footer with keyword-stuffed anchors → High (spam signal).
- Footer linking to noindex'd / low-quality pages at scale → Medium.
- Footer with paid / partner spam links → High.

**Fix voice:** `dieter-rams` (primary) | `mike-monteiro` (backup).

Read `souls/dieter-rams.json` before writing the Fix. Less but better, every footer link should earn its place.

Worked fix example:

> The footer is not a sitemap. It's chrome. Treat it as the smallest amount of structure that helps a user who's reached the bottom of the page.
>
> Three column groups, six links each, plus legal. That's the floor and probably the ceiling. Anything more is noise.
>
> ```html
> <footer>
>   <div class="cols">
>     <div>
>       <h4>Product</h4>
>       <a href="/plugin">Plugin</a>
>       <a href="/cli">CLI</a>
>       <a href="/action">GitHub Action</a>
>     </div>
>     <div>
>       <h4>Resources</h4>
>       <a href="/docs">Docs</a>
>       <a href="/blog">Blog</a>
>       <a href="/changelog">Changelog</a>
>     </div>
>     <div>
>       <h4>Company</h4>
>       <a href="/about">About</a>
>       <a href="/contact">Contact</a>
>     </div>
>   </div>
>   <div class="legal">
>     <a href="/privacy">Privacy</a> · <a href="/terms">Terms</a> · © 2026
>   </div>
> </footer>
> ```
>
> If the site has 20 important pages, the footer doesn't need 20 links. The pages that matter are reached from the header, the in-content navigation, and the sitemap. The footer holds the leftovers, legal, contact, the rest of the bottom-of-funnel scaffolding.
