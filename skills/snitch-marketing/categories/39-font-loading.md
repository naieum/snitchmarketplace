## CATEGORY 39: Font loading strategy

Web fonts are render-blocking by default. Without `font-display: swap` (or `optional`), text remains invisible (FOIT, flash of invisible text) until the font loads, contributing to LCP and CLS. Bad font loading is the most common cause of "page looks blank for 2 seconds before text appears."

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` `**/*.css`. `Grep` for `@font-face`, `font-display:`, `<link rel="preload"` (font preloading).
2. For each `@font-face`: confirm `font-display: swap` (or `optional`) is set.
3. `Grep` for `<link href="https://fonts.googleapis.com"` and similar font-CDN imports. Check whether they're preconnected and whether the rendered URL includes `&display=swap`.
4. For framework-managed fonts (Next.js `next/font`, Astro fontsource, Remix fonts): `Read` the config to confirm sane defaults.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Look for `<link>` tags loading fonts (CSS files containing @font-face, Google Fonts URLs, font preload links).
2. Fetch the font CSS, look for font-display declarations.

### Forbidden claims

- "Font loading is probably blocking." Quote the @font-face declarations.
- "Google Fonts may not be preconnected." Show the link tags.

### Detection

CSS source: `@font-face` blocks + their `font-display` property.

### What to Search For

- `@font-face`
- `font-display:` (`auto`, `block`, `swap`, `fallback`, `optional`)
- `<link rel="preload" as="font"`
- `<link rel="preconnect" href="https://fonts.googleapis.com">`
- `<link rel="stylesheet" href="https://fonts.googleapis.com/...&display=swap">`
- Framework font imports: `import { Inter } from 'next/font/google'`

### Actually Hurts SEO

- **`@font-face` without `font-display: swap` (or optional)**.
  Evidence required: the @font-face block quoted.
- **Google Fonts URL without `&display=swap`**.
  Evidence required: the link href.
- **No preconnect to fonts.gstatic.com when using Google Fonts**.
  Evidence required: link tags showing the font URL but no preconnect.
- **Critical font (used for hero / first viewport text) not preloaded**.
  Evidence required: hero text uses the font + no `<link rel="preload" as="font">` for it.
- **Multiple unused font weights / styles loaded** (loading 6 weights when the page only uses 2).
  Evidence required: declared weights + grep evidence of which are actually used in CSS.

### NOT a Problem

- `font-display: optional` on non-critical fonts (acceptable; system font fallback is used if web font is slow).
- Self-hosted font files served from same origin (no preconnect needed).
- Variable fonts (one file, all weights/styles). Best practice; not a finding.

### Context Check

1. Are fonts critical to brand recognition? If yes, prioritize them (preload, swap).
2. Are fonts being subset (only loading characters used)? Modern best practice; reduces font weight.
3. Does the framework manage font loading? Next.js `next/font/google` does font self-hosting + display-swap automatically.

### Reference

Web.dev on font best practices: https://web.dev/articles/font-best-practices

CSS font-display: https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-display

**Severity tagging:**
- Font-display missing or set to `block` on critical fonts → High.
- Google Fonts without display=swap → High.
- No preconnect to fonts CDN → Medium.
- Multiple unused font weights loaded → Medium.

**Fix voice:** `typography-master` (primary) | `performance-engineer` (backup).

Read `souls/typography-master.json` before writing the Fix. Type that arrives late is type that failed. Make the text readable from the first paint.

Worked fix example:

> Type that doesn't render is type that doesn't communicate. The hero's heading should appear in a system font fallback within 100ms of paint, then swap to the brand font when it's ready. The user reads either way.
>
> ```html
> <!-- Preconnect early -->
> <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
>
> <!-- Load font with display=swap -->
> <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap">
>
> <!-- Or self-hosted with framework -->
> // Next.js
> import { Inter } from 'next/font/google';
> const inter = Inter({ subsets: ['latin'], display: 'swap' });
> ```
>
> Subset to the characters you actually use (Latin only, if no other languages). Drop unused weights, every weight is a font file. Two weights cover most sites; three is generous.
