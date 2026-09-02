## CATEGORY 13: Favicon set

Favicons are the smallest brand surface on the web. They render in browser tabs, bookmarks, history, mobile home screens, OS dock, and search results. A missing favicon shows a default browser icon; a wrong-sized favicon renders blurry; an incomplete favicon set means iOS doesn't get a touch icon and Android doesn't get a maskable icon.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` `**/favicon.{ico,png,svg}`, `**/apple-touch-icon*`, `**/icon-*.{png,svg}`, `**/android-chrome-*.png`, `**/manifest*.{json,webmanifest}`. Quote each match.
2. `Grep` for `<link rel="icon"`, `<link rel="apple-touch-icon"`, `<link rel="manifest"`, `<link rel="mask-icon"`. Quote each.
3. For each declared icon link: confirm the referenced file exists in the project. `Glob` the path. If missing, that's the finding.

**Crawl mode, required tool calls:**

1. `Fetch` `{origin}/favicon.ico`. Quote response status + content-type.
2. `Fetch` URL, parse `<head>` for icon-related links. Quote each.
3. For each icon link: fetch the URL and quote status. Missing/404 icons are the finding.

### Forbidden claims

- "The site probably has favicon issues." Glob/fetch and confirm.
- "Apple touch icon may be missing." Either it's declared and exists, or it's not.
- "The icon set is probably incomplete." Enumerate what's declared and what's missing.

### Detection

#### Source mode

Required full set for modern compatibility:

- `favicon.ico` (legacy IE/Edge fallback at root)
- `favicon-32x32.png` and `favicon-16x16.png` (browser tabs)
- `apple-touch-icon.png` (iOS home screen, 180x180 recommended)
- `icon-192.png` and `icon-512.png` (Android via manifest)
- `manifest.json` or `manifest.webmanifest` (PWA + Android home screen)
- Optional: `safari-pinned-tab.svg` (Safari pinned tab, with `<link rel="mask-icon">`)

Frameworks that auto-handle:
- **Next.js App Router**: `app/icon.{ico,png,jpg,jpeg,gif,svg}`, `app/apple-icon.{png,jpg,jpeg,svg}`, `app/icon-{N}.png` for sizes, Next.js auto-emits `<link>` tags.
- **Astro**: place files in `public/` and reference via `<link>` in layout.
- **WordPress**: `add_theme_support('site-icon')` + Customizer setting.

#### Crawl mode

`Fetch` `{origin}/favicon.ico` directly. Then fetch the URL and inspect `<head>` for icon-related `<link>` elements.

### What to Search For

- `<link rel="icon"`
- `<link rel="apple-touch-icon"`
- `<link rel="manifest"`
- `<link rel="mask-icon"`
- `<link rel="shortcut icon"` (legacy synonym)
- File patterns: `favicon.*`, `apple-touch-icon.*`, `icon-*.png`, `manifest.{json,webmanifest}`

### Actually Hurts SEO

- **No favicon at all** (`/favicon.ico` returns 404 AND no `<link rel="icon">` in head).
  Evidence required: 404 quoted + absence of head links. The site shows a default browser icon in tabs / bookmarks / Google's SERP.
- **No `apple-touch-icon`** (iOS users adding to home screen get a generic icon).
  Evidence required: missing file + missing `<link rel="apple-touch-icon">`.
- **`apple-touch-icon` smaller than 180x180** (renders blurry on iOS retina).
  Evidence required: image dimensions.
- **No `manifest.json` AND no Android icons** (PWA install + Android home screen broken).
  Evidence required: missing manifest + missing icon-192/icon-512 references.
- **Manifest references icons that don't exist**.
  Evidence required: manifest's `icons` array + fetched icon URLs returning 404.
- **Favicon `<link>` tags pointing at relative paths that don't resolve** (common after framework restructure).
  Evidence required: link href + fetch response.

### NOT a Problem

- `favicon.ico` only (no PNG variants) on a small static site. Browsers fall back gracefully; not a finding.
- Single SVG favicon (modern best practice, one file, scales infinitely). Acceptable.
- Missing `safari-pinned-tab.svg`. Niche; Safari handles default fallback.
- No browserconfig.xml (Windows tile icons; obsolete since Win10).

### Context Check

1. Is the site indexable AND user-facing? Internal admin tools don't need a complete favicon set.
2. Is the site a PWA? PWA needs the full manifest + icon-192 + icon-512 + maskable icon.
3. Is the brand mark recognizable at 16x16? Detailed logos blur at favicon scale; this is a design constraint, not a finding (but worth flagging if the favicon is mush at small size).
4. Is the favicon SVG-only? Older browsers / Slack link previews need a PNG fallback.
5. Does the favicon URL include a cache-busting param? Browsers cache favicons aggressively; param-busting can cause re-fetch if you've recently changed the favicon.

### Reference

Web App Manifest: https://www.w3.org/TR/appmanifest/

Apple touch icon documentation: https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html

**Severity tagging:**
- No favicon at all → Medium (visible everywhere but not a ranking issue).
- No `apple-touch-icon` → Medium.
- No manifest + no Android icons → Medium.
- Manifest references missing icon files → Critical (PWA broken).
- Favicon link pointing at 404 → High.

**Fix voice:** `icon-designer` (primary) | `less-but-better-designer` (backup).

Read `souls/icon-designer.json` before writing the Fix. Icon craft is small-scale legibility: an icon at small scale is its essence; remove every detail that does not survive at 16 pixels.

Worked fix example:

> The favicon at 16x16 has 256 pixels to work with. That's it. Anything that doesn't survive that constraint isn't an icon, it's a logo someone shrunk.
>
> Start with the strongest single mark from your brand. A letterform, a single shape, one color against the tab background. Test it at 16x16 before you commit; if you can't recognize it, simplify until you can.
>
> ```html
> <!-- The full modern set -->
> <link rel="icon" type="image/svg+xml" href="/favicon.svg">
> <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
> <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
> <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
> <link rel="manifest" href="/manifest.json">
> ```
>
> Generate the full set from one source SVG using a favicon generator (realfavicongenerator.net or similar). Then verify each declared file actually exists at the path, broken icon links are worse than no icons.
