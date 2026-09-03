## CATEGORY 25: Image alt presence

Every `<img>` element needs an `alt` attribute. Either a meaningful description (for content images) or an explicit empty string `alt=""` (for decorative images). Missing alt entirely is the most common a11y bug AND a real SEO miss, Google uses alt for image search ranking.

**Boundary.** This category judges `alt` as a **search and machine-readability signal** — what image search and an assistant can read. The conformance judge for the same attribute is SC 1.1.1, which belongs to the accessibility skill; when a missing `alt` also fails that criterion, call the Skill tool with "snitch-ada" and file it there under the criterion rather than reporting the same image twice.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<img ` (note trailing space) AND `<Image ` (Next.js / framework Image components) across the project. Quote each match. **Capture the total count.**
2. For each match: confirm whether `alt` is present. Missing alt is the finding.
3. For framework Image components, `Read` the component prop signature, `alt` may be required by TypeScript (good) or optional (every missing alt is a finding).

**Enumeration discipline (per Rule 7):** This category requires walking every image. Three acceptable outcomes:

- **Full enumeration** (preferred): walk all N images found by step 1. Report findings + count of clean images. Audit metadata: `images_enumerated: N`.
- **Sampled** (when N is large): pick at least 20 images OR 20% of total (whichever is larger). Report findings + sampled-clean count. Audit metadata: `images_sampled: K of N`. Outcome must be marked **Skip** with reason `sampled K of N for time; full enumeration pending`.
- **Skip** with reason if no images / no source.

Spot-checking 2-3 images and not declaring it is a Rule 7 violation. Either enumerate, sample with explicit count, or skip with reason.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Find all `<img>` elements. Quote each with attributes.
2. Identify those with no `alt` attribute (different from `alt=""`).

### Forbidden claims

- "Many images may lack alt." Count and sample.
- "Alt text is probably missing from product images." Show me which.

### Detection

#### Source mode

For each `<img>` or framework `<Image>` element: check for `alt=` attribute.

#### Crawl mode

Parse rendered HTML, find images, check alt presence.

### What to Search For

- `<img ` (trailing space; opens img tag)
- `<Image ` (Next.js, Astro)
- `<NextImage`
- Any custom image component (look for the project's wrapper)

### Actually Hurts SEO

- **Image with no `alt` attribute at all**.
  Evidence required: the `<img>` element + file:line.
- **Image with `alt=""` on a content image** (decorative-image setting on something that's actually informative).
  Evidence required: image src + surrounding context showing it's content-bearing.
- **Image inside a link with no alt (`<a><img></a>`)**.
  Evidence required: the link wrapping the image. The alt becomes the anchor text; missing alt = empty link text.

### NOT a Problem

- `alt=""` on truly decorative images (background patterns, icons that have a visible label next to them, ARIA-hidden icons). Correct usage.
- `<svg aria-hidden="true">` with no alt, SVG ≠ img; aria-hidden is the right attr.
- CSS background images, they're not `<img>`, no alt needed, but they're invisible to image search; if the image is content, use `<img>` instead.

### Context Check

1. Is the image content-bearing (photo, diagram, screenshot of UI, illustration with information) or purely decorative (background pattern, divider line)? Content needs alt; decorative gets alt="".
2. Does the project use a framework Image component with required alt? Check the prop type. If alt is required, TypeScript will catch missing alt at compile time.
3. Are images inside MDX content? Check the MDX provider for default alt handling.
4. Are images CMS-driven? Audit the CMS data, empty alt fields in the DB produce missing alts in output.

### Reference

WCAG on alt text: https://www.w3.org/WAI/tutorials/images/

Google's image SEO docs: https://developers.google.com/search/docs/appearance/google-images

**Severity tagging:**
- Content image with no alt → High.
- Content image with empty alt (when description was needed) → High.
- Image inside link with no alt (empty link text) → High.
- Decorative image with empty alt → Not a problem.

**Fix voice:** `emotional-design-lead` (primary) | `usability-scientist` (backup).

Read `souls/emotional-design-lead.json` before writing the Fix. Designing for how people feel includes the people whose experience is not visual: alt text is how you reach someone who cannot see the image but is still your audience.

Worked fix example:

> Every content image needs an alt that says what's in it for the people who can't see it. Decorative images get `alt=""` so screen readers skip them. There's no third option.
>
> ```tsx
> // Content image: meaningful description
> <img src="/snitch-dashboard.png" alt="Snitch dashboard showing 12 critical findings across 3 repositories" />
>
> // Decorative image: empty alt (screen reader skips it)
> <img src="/divider-pattern.png" alt="" />
>
> // Icon with adjacent text: empty alt (text already describes it)
> <button>
>   <img src="/save-icon.svg" alt="" />
>   Save
> </button>
> ```
>
> The framework Image component's `alt` prop should be required (TypeScript) so missing alts can't ship. If it's not, configure it. The compiler is your alt-checker.
