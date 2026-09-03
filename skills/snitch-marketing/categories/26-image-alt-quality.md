## CATEGORY 26: Image alt quality

Alt is present but generic, keyword-stuffed, or just the filename. Bad alt is sometimes worse than no alt, screen reader users hear gibberish, Google's image-search algorithm gets a confusing signal.

**Boundary.** As in Cat 25, the judge here is the **search and machine-readability** value of the text, not conformance. SC 1.1.1 owns the criterion and belongs to the accessibility skill; call the Skill tool with "snitch-ada" to file it there rather than double-counting here.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<img ` AND `<Image `. Quote each + its alt value.
2. Identify alt patterns: filenames as alt, single-word generics ("image", "photo", "icon"), keyword stuffing.
3. Sample at least 5 alt values per finding pattern.

**Crawl mode, required tool calls:**

1. `Fetch` URL, extract image alt values, identify quality issues.

### Forbidden claims

- "Alt text quality is probably poor." Quote the bad ones.
- "Many alts use keyword stuffing." Show samples with the keyword pattern visible.

### Detection

Patterns indicating low-quality alt:

- Filename as alt: `alt="img_3923.jpg"`, `alt="photo_1.png"`, `alt="DSC00123.jpeg"`
- Generic placeholders: `alt="image"`, `alt="photo"`, `alt="picture"`, `alt="icon"`
- Single character: `alt="i"`, `alt="x"` (dev placeholder)
- Keyword-stuffed: `alt="cheap running shoes nike adidas best running shoes 2026"`
- Title-as-alt mismatch: alt set to `aria-label` instead of describing the image

### What to Search For

- `alt="` values ending in an image extension (`.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`, `.svg`)
- `alt="` values matching camera/export filename shapes: `IMG_`, `DSC`, `Screenshot`, `Untitled`, `unnamed`, `download`, a bare digit run
- Placeholder words as the whole value: `image`, `photo`, `picture`, `icon`, `logo`, `graphic`, `banner`, `img`, `alt`, `TODO`, `test`
- Single-character and whitespace-only values (an intentionally empty `alt=""` on a decorative image is correct and is NOT this pattern)
- Alt values over ~125 characters, or containing the target keyword three or more times
- Alt values identical across three or more different images on the same page
- `alt={` expressions bound to a filename, slug, or id field rather than a description field (JSX / template props)
- CMS field mappings where alt defaults to the asset's title or filename (`image.filename`, `asset.name`, `media.title`)

### Actually Hurts SEO

- **Filename-as-alt**.
  Evidence required: the alt value (showing it's clearly a filename).
- **Generic placeholder alts** ("image", "photo").
  Evidence required: bucketed list of images with generic alts.
- **Keyword-stuffed alts**.
  Evidence required: alt + repeating-keyword identification.
- **Alt longer than ~125 characters**.
  Evidence required: alt + character count.
- **Alt that just repeats the surrounding caption**.
  Evidence required: alt + the visible caption (matching means alt is redundant).

### NOT a Problem

- Long alt for a complex chart / infographic that needs describing in detail. Long is fine if every word earns it.
- Alt = product name on a product image where the product name is the only meaningful description. Acceptable.
- Alt in a different language than page content (multilingual image with localized alt).

### Context Check

1. Is the image content-rich (chart, infographic, comparison) or simple (a face, a product photo)? Long alt is appropriate for content-rich; short alt for simple.
2. Is there a caption / surrounding text already describing the image? Then alt can be brief or empty (decorative-by-context).
3. Is the alt CMS-driven? Audit the CMS field for the bad patterns; the fix is in the CMS, not the template.
4. Does the framework auto-generate alt from filename if missing? Some do (Astro `image` integration); the auto-generated alt is filename-as-alt, which is the bad pattern.

### Reference

WAI on writing alt text: https://www.w3.org/WAI/tutorials/images/decision-tree/

Google's image SEO docs: https://developers.google.com/search/docs/appearance/google-images

**Severity tagging:**
- Filename-as-alt → Medium.
- Generic placeholder alt → Medium.
- Keyword-stuffed alt → High (spam signal).
- Alt >125 chars → Low.

**Fix voice:** `content-shape-editor` (primary) | `emotional-design-lead` (backup).

Read `souls/content-shape-editor.json` before writing the Fix. The writing-first view of design: alt is a sentence about the image. Make it a good sentence.

Worked fix example:

> Alt text is a description of the image written for someone who can't see it. Not a filename, not a marketing slogan, not a list of search terms. A sentence.
>
> ```html
> <!-- Filename leaking into alt -->
> <img src="/dashboard-screenshot-v3-final.png" alt="dashboard-screenshot-v3-final.png" />
>
> <!-- Just the right amount of detail -->
> <img src="/dashboard-screenshot-v3-final.png" alt="The Snitch dashboard with three open audits and a badge showing 12 critical findings." />
> ```
>
> ~50-125 chars usually fits. Read the alt out loud: if it sounds like a description, it's a description. If it sounds like SEO copy, rewrite it.
