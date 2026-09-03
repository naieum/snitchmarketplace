## CATEGORY 01: Text alternatives for non-text content

Every image, icon, chart, canvas, media poster and image button carries information. A person who
cannot see it reaches that information only through the text alternative the markup provides. This
category judges non-text content against **WCAG 2.2 SC 1.1.1 Non-text Content (Level A)** and
**SC 1.4.5 Images of Text (Level AA)**: does an equivalent alternative exist, is decorative content
correctly silenced, and are words shipped as real text rather than baked into a picture.

1.1.1 appears in demand letters more than any other criterion, because it is the cheapest to test
and the most visible to fail. It is also the one most often faked: an `alt` that repeats the
filename, or says "image", satisfies a validator and tells the reader nothing. A text alternative
serves the **equivalent purpose** of the thing it replaces. That is the test, not the presence of
the attribute.

**Boundary.** This category asks whether the alternative meets the criterion. When the same missing
`alt` is judged as a **search and machine-readability signal** — what image search and an assistant
can read from the page — that is the sibling's judge; call the Skill tool with "snitch-marketing".
When the question is whether the silent image **stops one person from finishing a task** on their
decision path, call the Skill tool with "snitch-ux". Same element, three judges. Report the
criterion here and cross-file rather than restating the other half.

### Pre-flight

Always run. Every public surface has non-text content, the checks are static, and 1.1.1 is Level A.

1. **The image inventory.** Count every `<img>`, framework `<Image>`, `<svg>`, `<canvas>`,
   `<video poster>`, `<input type="image">`, `<area>` and CSS background that carries content.
   The count goes in the report; a finding set with no denominator is not evidence.
2. **Declared intent.** Read `BLUEPRINT.md` (*Audience & wedge*, *Conversion action*, *Claim
   inventory*, *Constraints*) and `marketing/positioning.md` read-only. A `Decision` line does not
   excuse a Level A failure; it caps a best-practice fix that contradicts it at Medium. Neither
   file present is a Skip with that reason.

Skip with reason `no non-text content in scope` only when the inventory is genuinely zero.

### Rule table

One row per success criterion. A finding names its row. A check with no row here is a Skip, never a
finding under a borrowed SC number.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 1.1.1 Non-text Content | A | Every non-text element either exposes a text alternative that serves its equivalent purpose, or is marked decorative and hidden from the accessibility tree | `<img>` with no `alt`; `<svg>` with no `role="img"` + `<title>` and no `aria-hidden`; `<canvas>` with no fallback content or `aria-label`; image link or image button whose only name source is an empty or absent `alt`; `<input type="image">` with no `alt`; `<area>` with no `alt`; decorative element with a non-empty `alt`; `alt` that names the file or the medium | no | Critical (informative content silent, or image link / image button unnamed) / Low (decorative element announced) |
| 1.4.5 Images of Text | AA | Words are real text, except in logotypes and where a specific presentation is essential | headline, price, CTA, testimonial or feature-list text shipped as an `<img>` / background image with the words only in `alt` or nowhere; text-bearing hero and banner assets | no | Medium |

**CAPTCHA is a 1.1.1 row, not a separate criterion.** A CAPTCHA needs a text alternative that
describes its *purpose* ("verify you are not a robot"), plus an alternative form of the test for a
different sense. Missing the purpose description is a 1.1.1 finding. A CAPTCHA that is the **only**
way through an authentication step is 3.3.8 Accessible Authentication (Minimum), AA, and belongs to
Cat 10; cross-file, do not double-report.

**Complex images.** A chart, diagram, map or infographic needs a short alternative *and* a long
description. The short alternative names the thing and its takeaway; the long description carries
the data. Adjacent visible text, a `<figcaption>`, an `aria-describedby` target or a linked data
table all satisfy it. A chart with a bare `alt="Revenue chart"` and no long description is a 1.1.1
finding, because the alternative does not serve the equivalent purpose.

### Evidence required

A finding needs an observation and a criterion. The observation is the quoted element at
`file:line` (source mode) or URL + selector (crawl mode). The criterion is the SC from the table.

**Source mode, cheapest first:**

1. `Grep` for `<img `, `<Image `, `<NextImage`, and the project's own image wrapper. Capture the
   total count. For each match, record whether `alt` is present, and whether it is empty.
2. `Grep` for `<svg` and icon-component imports. An inline `<svg>` needs `role="img"` plus a
   `<title>` (or `aria-label`), or `aria-hidden="true"` when decorative.
3. `Grep` for `<canvas`, `<video`, `poster=`, `<input type="image"`, `<area `, `usemap=`.
4. `Grep` for `background-image:` and `background:` shorthand in CSS and inline styles. Read the
   markup around each to decide whether the image carries content or decorates.
5. `Grep` for icon-font markup (`<i class="`, `<span class="icon-`) with no adjacent text node and
   no `aria-label`.
6. For every image inside an `<a>` or a `<button>`, read the whole element. If the anchor or button
   has no text node, the `alt` is the accessible name; an empty `alt` there is a nameless link.
7. Read the alt strings against the content they replace. Filenames, extensions and bare medium
   words are failures on their face.
8. For charts and diagrams, read the surrounding block for a long description before reporting.

**Crawl mode:**

1. `Fetch` each page in the representative set. Quote every non-text element with its attributes.
2. Re-run steps 2 to 8 against the rendered HTML, recording URL + selector per element. For
   framework images, the rendered `<img>` is the evidence, not the component call.

**Cascade caveat (every CSS-derived check):** a `Grep` or `Fetch` returns declarations, not the
resolved cascade. A background image declared in one rule may be overridden in another, and a
`content: ""` pseudo-element may not render at all. Say so in the finding when the cascade is
ambiguous, and verify the rendered element before asserting a failure.

**Enumeration discipline.** Either walk every image, or sample at least 20 (or 20% of the total,
whichever is larger) and mark the outcome `Skip — sampled K of N for time; full enumeration
pending`. Spot-checking three images without declaring it is not an audit.

### Forbidden claims

- "Alt text may be missing." Count the inventory and quote the elements that lack it.
- "Images are probably inaccessible." Name each one, or Skip with the reason.
- "This alt is poor." Quote the alt string and say what the image actually conveys.
- "The site fails WCAG." Never write **compliant**, **conformant** or **non-compliant** as a
  verdict. Conformance is a determination that follows a complete audit. Write "fails SC 1.1.1 at
  these elements" and let the reader draw the line.
- "The screen reader announces nothing here", inferred from source when the check needed a render
  and a reader. Skip with the reason instead.
- Any 1.4.5 claim about an image whose words were never transcribed. That row is a Skip.

### Detection

Static read of markup, component source and CSS across the representative page set, in source mode
or against fetched HTML in crawl mode. Every row here resolves from markup. Automated-runner output
(a rule id plus the offending node) is a second observation, never a replacement for the element.

### What to Search For

- `<img `, `<Image `, `<NextImage`, the project's image wrapper, and every `alt` value they carry
- Inline `<svg>` without `role="img"` + `<title>`, and without `aria-hidden="true"`
- `<canvas>` with no fallback child content and no `aria-label`; `<video poster>` carrying text
- `usemap` / `<area>` sets, and `<input type="image">` with no `alt` (the alt is the button's name)
- CSS `background-image` behind meaning: badges, proof-strip logos, screenshots, step diagrams
- Icon fonts and glyph spans with no adjacent visible text and no `aria-label`
- Images inside links and buttons where no text node exists
- Alt strings that repeat the filename, the extension, or the medium
- Decorative dividers, spacers and patterns carrying a non-empty `alt`
- Charts, maps and infographics with no long description nearby; CAPTCHA purpose descriptions
- Headlines, prices, CTAs and testimonials rendered as image assets (1.4.5)

### Actually Fails

- **Informative image with no `alt` attribute, or with `alt=""`.** Evidence: the element at
  `file:line` or selector, plus the surrounding content proving it is content-bearing.
  1.1.1, Critical.
- **Image link, image button or `<input type="image">` whose only name source is an empty or absent
  `alt`.** Evidence: the whole `<a>` or `<button>` showing no text node. 1.1.1, Critical.
- **Inline `<svg>` carrying content with no `<title>`, `aria-label` or `aria-labelledby`, and no
  `aria-hidden`.** Evidence: the svg markup. 1.1.1, Critical.
- **`<area>` with no `alt`, or `<canvas>` rendering content with no fallback child and no accessible
  name.** Evidence: the element and what it presents. 1.1.1, Critical.
- **Icon font or glyph span acting as the only label on a control.** Evidence: the span and the
  absent `aria-label`. 1.1.1, Critical.
- **CSS background image carrying content with no adjacent text equivalent.** Evidence: the CSS
  rule, the markup it applies to, and the cascade caveat. 1.1.1, High.
- **Alt that names the file or the medium** — `alt="IMG_2043.jpg"`, `alt="image"`, `alt="photo"`.
  Evidence: the alt string and what the image shows. 1.1.1, High.
- **Chart, diagram or infographic with a naming alt and no long description.** Evidence: the alt,
  and the absence of adjacent text, `<figcaption>`, `aria-describedby` target or data table.
  1.1.1, High.
- **CAPTCHA with no text alternative describing its purpose.** Evidence: the widget markup.
  1.1.1, High. (Auth with no alternative path is 3.3.8, Cat 10.)
- **Decorative divider, spacer or pattern with a non-empty `alt`.** Evidence: the element.
  1.1.1, Low.
- **Headline, price, CTA or testimonial shipped as an image of text.** Evidence: the `<img>`, its
  `alt`, and the words in the asset. 1.4.5, Medium.

### NOT a Failure

- Decorative images with `alt=""`, and decorative SVGs with `aria-hidden="true"`. Correct usage.
- An icon inside a control that already has a visible text label, when the icon carries
  `aria-hidden="true"` and the label is the name.
- A `<svg>` with `role="img"` and a `<title>` as the first child. Verbose, and correct.
- `<figure>` where the `alt` is short and the `<figcaption>` carries the detail. Two channels.
- A descriptive alt that begins "Photo of" or "Link to". Redundant phrasing worth a Low
  `alt phrasing (advisory)` note; the alternative still serves the equivalent purpose, so it is not
  a 1.1.1 failure.
- A CSS background used as pure decoration: gradients, noise, patterns, section dividers.
- A logotype or wordmark rendered as an image. 1.4.5 exempts logotypes explicitly.
- Long alt text. The criterion sets an equivalence test, not a length limit.
- A `<video>` with no `poster`. Optional; the media criteria are Cat 02's rows.

### Context Check

1. Is the image content-bearing or decorative? Content needs an equivalent; decoration needs
   silencing. There is no third state.
2. Does the image sit inside a link or a button with no text? Then the alt is the accessible name.
   Cross-file the name half with Cat 11 (4.1.2) rather than reporting the element twice.
3. Is the image CMS-driven or user-generated, or does a framework component make `alt` a required
   prop? Then the template cannot ship a missing alt and the defect is in the authoring flow. Say
   so, and cite the field that permits an empty alt.
4. Is the picture carrying words? Then 1.4.5 applies alongside 1.1.1, and the fix is real text, not
   a longer alt.
5. Is the image a chart? Then the long description is part of the criterion, not a nicety.
6. Was the alt inventory enumerated or sampled? Declare which.

### Severity

- **Critical** — informative non-text content with no alternative; image link, image button or
  `<input type="image">` with no accessible name; icon-only control named only by a glyph;
  informative `<svg>` or `<canvas>` silent. Level A failures that leave a control or a message
  unreachable, and the rows most cited in demand letters.
- **High** — content-bearing CSS background with no text equivalent; alt that names the file or the
  medium; complex image with no long description; CAPTCHA with no purpose description.
- **Medium** — images of text under 1.4.5.
- **Low** — decorative element announced (non-empty alt on a divider or spacer); alt-phrasing notes.

### Fix guidance

Three fixes, in the order the criteria fail hardest.

**1. Name the thing, or hide it. There is no third option.**

```html
<!-- Fails 1.1.1: informative image, no alternative -->
<img src="/img/uptime-2024.png">

<!-- Passes: the alternative carries the takeaway, not the filename -->
<img src="/img/uptime-2024.png" alt="Uptime by quarter: 99.1%, 99.6%, 99.9%, 99.9%">

<!-- Decorative: silenced, not described -->
<img src="/img/divider.svg" alt="" aria-hidden="true">
```

**2. Give image links and image buttons a name.** When the anchor has no text node, the `alt` is
the entire accessible name, and an empty one produces a link the reader announces as "link".

```html
<!-- Fails 1.1.1: nameless link -->
<a href="/pricing"><img src="/img/pricing-card.png" alt=""></a>

<!-- Passes: the alt names the destination, not the picture -->
<a href="/pricing"><img src="/img/pricing-card.png" alt="See pricing"></a>

<!-- Inline SVG icon inside a control: the control is named, the icon is silent -->
<button type="submit" aria-label="Search">
  <svg aria-hidden="true" focusable="false"><use href="#icon-search"/></svg>
</button>
```

**3. Charts get two alternatives, and words get to be words.**

```html
<!-- 1.1.1: short alternative names it, long description carries the data -->
<figure>
  <img src="/img/revenue.svg" alt="Revenue by quarter, rising each quarter"
       aria-describedby="revenue-table">
  <figcaption id="revenue-table">Q1 $1.2M, Q2 $1.5M, Q3 $1.9M, Q4 $2.4M.</figcaption>
</figure>

<!-- 1.4.5: the headline was an image; now it is text that zooms, reflows and translates -->
<h1 class="hero-title">Ship the audit, not the anxiety</h1>
```

An image of text cannot be zoomed cleanly, restyled by a reader's own spacing, selected, searched
or translated. Web fonts and CSS produce the same look and keep all of it. The one exception in the
criterion is the logotype, and a logotype is not a headline. Nothing in this category touches a
color value or a brand token. Report first; apply nothing without explicit confirmation.

### Reference

WCAG 2.2, SC 1.1.1 Non-text Content, Level A: https://www.w3.org/TR/WCAG22/#non-text-content ·
SC 1.4.5 Images of Text, Level AA: https://www.w3.org/TR/WCAG22/#images-of-text

Understanding 1.1.1: https://www.w3.org/WAI/WCAG22/Understanding/non-text-content.html ·
Understanding 1.4.5: https://www.w3.org/WAI/WCAG22/Understanding/images-of-text.html

W3C images tutorial (the decorative-versus-informative decision tree, complex images, image maps,
functional images): https://www.w3.org/WAI/tutorials/images/ · W3C ARIA Authoring Practices:
https://www.w3.org/WAI/ARIA/apg/ · MDN, the `alt` attribute:
https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/img

axe-core rule descriptions (image-alt, input-image-alt, area-alt, svg-img-alt):
https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md
