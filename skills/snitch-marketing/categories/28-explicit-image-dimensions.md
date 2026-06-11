## CATEGORY 28: Explicit width / height (CLS prevention)

When images render without explicit `width` and `height` attributes, the browser doesn't know how much space to reserve until the image loads. The result: layout shift (CLS, Cumulative Layout Shift) as images pop in and push surrounding content around. CLS is a Core Web Vital and a direct ranking factor.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<img ` and `<Image `. Quote each + check for `width=` and `height=` attributes.
2. For framework Image components: most require `width` and `height` props. Check the prop signature.
3. For raw `<img>` without dimensions: that's the finding.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse images. Quote each with its `width` and `height` attributes (or note absence).
2. Optional: run a Lighthouse / PSI audit and quote the CLS score and the image-induced shift contribution.

### Forbidden claims

- "Images probably cause CLS." Show me the missing-dimension count.
- "Some images may shift layout." Quote the offending elements.

### Detection

Source: `<img>` and framework Image components. Look for missing `width` / `height` attributes.

Crawl: parse rendered HTML, check attributes.

### What to Search For

- `<img src=` followed by no `width=` or `height=` in the same tag
- `<Image` (framework) without `width` / `height` props
- CSS `aspect-ratio` declarations (an alternative to width/height that also works for CLS prevention)

### Actually Hurts SEO

- **`<img>` without explicit width AND height**.
  Evidence required: the image element quoted, showing absence.
- **Framework Image used without width/height props** (when the framework supports them).
  Evidence required: the component invocation + prop signature showing dimensions are missing.
- **Aspect-ratio CSS missing on a component-styled image** (no width/height attrs, no CSS aspect-ratio either).
  Evidence required: the element + the CSS rules applied to it.

### NOT a Problem

- Images styled with explicit `aspect-ratio` CSS even without width/height attrs. Modern browsers reserve space correctly. Acceptable.
- Decorative SVG icons sized via CSS and treated as inline-block. Negligible CLS impact.
- Background images (CSS `background-image`). Don't cause CLS in the same way; not a concern here.

### Context Check

1. Is CLS actually a problem on the page? Run PSI / Lighthouse. If CLS is good (<0.1), this category is low priority.
2. Does the framework auto-set dimensions? Next.js Image requires width/height; Astro Image accepts them. If TypeScript is enforcing, missing dimensions can't ship.
3. Are images inside slots / placeholders? Server-rendered placeholders with explicit dimensions can prevent CLS even if the final image doesn't have attrs.

### Reference

Web.dev on CLS: https://web.dev/articles/cls

Setting image dimensions to prevent CLS: https://web.dev/articles/optimize-cls

**Severity tagging:**
- Hero / above-fold image without dimensions (high CLS contribution) → High.
- Below-fold image without dimensions → Medium.
- Inline-content image without dimensions → Medium.

**Fix voice:** `performance-engineer` (primary) | `sarah-drasner` (backup).

Read `souls/performance-engineer.json` before writing the Fix. CLS is a measurable, ranked metric; missing dimensions is the most preventable cause.

Worked fix example:

> Every image needs reserved space before it loads. Width and height attrs do that even at native pixel ratios; the browser computes the box from the ratio.
>
> ```html
> <!-- Bad: layout shifts when image loads -->
> <img src="/hero.webp" alt="…">
>
> <!-- Good: space reserved before load -->
> <img src="/hero.webp" alt="…" width="1200" height="600">
>
> <!-- Also good: aspect-ratio in CSS -->
> <img src="/hero.webp" alt="…" style="aspect-ratio: 2/1; width: 100%; height: auto;">
> ```
>
> Framework Image components usually require width/height; if yours doesn't, set them anyway. The cost is two extra attributes per image. The benefit is CLS goes from "needs improvement" to "good," which Google measures and uses.
