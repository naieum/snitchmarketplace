## CATEGORY 21: Anchor text quality

The clickable text of an internal link tells users AND search engines what the linked page is about. "Click here" anchors waste a ranking signal. "Pricing details for the Pro plan" anchors give Google a strong topical hint about the linked page.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` content + route files. `Grep` for `<a href`, `<Link to=`. Quote each match including the link's text content.
2. For each internal link: extract the anchor text. Bucket by phrasing.
3. Identify "click here", "read more", "learn more", "more", "this", "here" anchors. Quote each.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse links. Quote each anchor's text + target.
2. Identify generic anchors. Same pattern.

### Forbidden claims

- "Many anchors are probably generic." Quote them.
- "Click here links may be hurting." Either you found them or you didn't.

### Detection

#### Source mode

Extract every `<a>` and `<Link>`'s rendered text content. Be aware:
- React links wrapping multiple elements: `<Link to="/x"><Icon /> Text</Link>`, the icon is invisible to screen readers without alt; the anchor text is "Text".
- Buttons styled as links: `<button onClick={() => router.push('/x')}>`, not links, but functionally equivalent. Worth flagging if their labels are generic.

#### Crawl mode

Parse rendered links + anchors.

### What to Search For

Anchor text patterns to flag:
- "click here", "Click Here", "CLICK HERE"
- "read more", "Read More"
- "learn more", "Learn More"
- "more", "More"
- "this", "here"
- ">>", "→", "..." (just punctuation as anchor)

### Actually Hurts SEO

- **"Click here" / "Read more" anchors on important internal links**.
  Evidence required: quoted anchor + target.
- **Same anchor text used for many different targets** ("Learn more" linking to 30 different pages).
  Evidence required: bucketed anchors with target URLs.
- **Generic anchors as the ONLY link to a page** (the only inbound link to /pricing is "click here").
  Evidence required: link + the target's other inbound links (none with descriptive text).
- **Image links with no alt text** (the alt IS the anchor text).
  Evidence required: `<a href><img src ... no alt></a>` pattern.

### NOT a Problem

- "Read more" buttons on a card / preview component IF the card itself contains the descriptive headline (the H2 of the card is the implicit anchor). Less ideal but acceptable.
- Brand name as anchor when linking to a brand page (`<a href="/brands/example">Example</a>`).
- "Buy now" / "Get started" CTAs on commercial pages, these are conversion-focused, not topical.

### Context Check

1. Is the anchor inside a navigation menu? Nav anchors should be short and topical (Pricing, Docs, Blog).
2. Is the anchor inside body text? Body anchors should describe the linked page.
3. Is the anchor inside a card/preview? Acceptable to be brief if the card's heading is descriptive.
4. Are anchors auto-generated from data (CMS-driven)? Audit the data, not the template.
5. Is the link an image? The image's alt text becomes the anchor, flag missing alt as Cat 25 instead.

### Reference

Google on anchor text: https://developers.google.com/search/docs/fundamentals/seo-starter-guide#write-good-link-text

**Severity tagging:**
- "Click here" / "Read more" as primary anchor for important pages → Medium.
- Same anchor for many targets → Medium.
- Image link with no alt → High (cross-listed with Cat 25).

**Fix voice:** `aaron-draplin` (primary) | `mike-monteiro` (backup).

Read `souls/aaron-draplin.json` before writing the Fix. DDC's voice on plain language: say what you mean. The anchor IS the promise.

Worked fix example:

> "Click here" tells the user nothing and tells Google less. The anchor is real estate; use it.
>
> ```html
> <!-- Bad -->
> Need pricing details? <a href="/pricing">Click here</a>.
>
> <!-- Good -->
> Need pricing? <a href="/pricing">See the Pro and Team plans</a>.
> ```
>
> The link's text now tells you AND Google what's at the other end. CTAs ("Get started", "Buy now") on conversion pages stay punchy; in-content links describe their target.
