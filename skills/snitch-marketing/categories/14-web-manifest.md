## CATEGORY 14: Web app manifest

`manifest.json` (or `manifest.webmanifest`) is the PWA / installable-webapp configuration. It controls how the site behaves when added to a home screen, what icon is used, what theme color shows in the browser chrome, and whether the install prompt fires. Incomplete or missing manifest = no PWA install + worse mobile experience.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` `**/manifest.{json,webmanifest}`. Quote each match.
2. `Read` the manifest. Parse as JSON. Verify required fields exist (`name`, `short_name`, `icons`, `start_url`, `display`, `theme_color`, `background_color`).
3. `Grep` for `<link rel="manifest"`. Quote each match. Verify the href resolves to one of the globbed files.
4. For each `icons[]` entry: confirm the referenced icon file exists.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Find `<link rel="manifest" href="...">`. Quote.
2. `Fetch` the manifest URL. Quote response + parse JSON.
3. For each icon in `icons[]`: fetch and quote status.

### Forbidden claims

- "The manifest is probably incomplete." Parse and check fields. Quote what's missing.
- "PWA install probably doesn't work." Either the manifest meets PWA criteria or it doesn't. Cite Lighthouse PWA audit criteria as the test.
- "Theme color may be missing." Read the manifest and quote.

### Detection

#### Source mode

Required fields for a usable manifest:

- `name`, full app name (used in install prompt + splash screen)
- `short_name`, fits on home screen icon label (~12 chars)
- `icons`, array with at least 192x192 and 512x512 PNGs
- `start_url`, URL to load when launched
- `display`, usually `standalone` (looks like an app) or `minimal-ui`
- `theme_color`, browser chrome color
- `background_color`, splash screen background

Optional but recommended:
- `description`
- `categories`
- `screenshots` (for richer install prompt on supporting browsers)
- `shortcuts` (long-press menu items on Android)

#### Crawl mode

Fetch the page, find the manifest link, fetch the manifest, parse JSON, validate fields.

### What to Search For

- `manifest.json`
- `manifest.webmanifest`
- `<link rel="manifest"`
- `name`, `short_name`, `icons`, `start_url`, `display`, `theme_color`

### Actually Hurts SEO

- **No manifest declared on a site that's mobile-first or PWA-targeted**.
  Evidence required: missing `<link rel="manifest">` + missing manifest file. (Less critical for desktop-only or read-only sites.)
- **Manifest references icons that 404**.
  Evidence required: icons[] entries + fetched icon statuses.
- **Manifest missing `start_url`** (PWA install fails on some browsers).
  Evidence required: parsed manifest with field absent.
- **Manifest missing `display`** (defaults to `browser`, which is no-op for install).
  Evidence required: parsed manifest.
- **Manifest invalid JSON**.
  Evidence required: parse error message + the offending line.
- **Manifest declared at wrong content-type** (`text/html` instead of `application/manifest+json`).
  Evidence required: response Content-Type header.
- **`scope` field present and too restrictive** (PWA shell can navigate outside scope and lose installed state).
  Evidence required: scope value + URLs the user navigates to that fall outside.

### NOT a Problem

- Manifest missing on a desktop-focused tool / docs site / blog. PWA install isn't the value prop; manifest is nice-to-have.
- `theme_color` matching the page background (intentional for unified branding).
- Single icon size (192x192) when only Android install is supported. Acceptable v1.
- `display: minimal-ui` when full standalone is too disruptive for the use case.

### Context Check

1. Is the site mobile-first / PWA-positioned? Manifest priority is High.
2. Are there installed-PWA users? Check analytics for `display-mode: standalone` events. If none, PWA install isn't being used regardless.
3. Does the framework auto-generate? Next.js App Router has `app/manifest.ts` exporting a default function. Astro has `@astrojs/pwa` integration.
4. Are icons same as the favicon set? Manifest `icons[192]` = `apple-touch-icon` size = 180x180 OR 192x192, close but not always identical. Verify dimensions match the file.
5. Is the `start_url` identical to the canonical homepage URL? If not, PWA users land somewhere other than the canonical page.

### Reference

Web App Manifest spec: https://www.w3.org/TR/appmanifest/

Lighthouse PWA audit: https://developer.chrome.com/docs/lighthouse/pwa/

**Severity tagging:**
- No manifest on PWA-positioned site → High.
- Manifest references missing icons → Critical (install broken).
- Manifest missing required fields → High.
- Invalid JSON → Critical.
- Wrong Content-Type → Medium.
- Manifest on desktop-only site missing → Low (or skip).

**Fix voice:** `systems-designer` (primary) | `motion-engineer` (backup).

Read `souls/systems-designer.json` before writing the Fix. Systems thinking applied to a small declarative artifact that unlocks a real user benefit (install). Get it right once, treat it as part of the design system.

Worked fix example:

> The manifest is a tiny file with outsized impact: with it, your site becomes installable on phones and looks like an app to the people who do install. Without it, you're invisible to that whole flow.
>
> ```json
> {
>   "name": "Snitch, Security Audit",
>   "short_name": "Snitch",
>   "description": "Security review for the code your AI wrote.",
>   "start_url": "/",
>   "display": "standalone",
>   "background_color": "#0a0a0a",
>   "theme_color": "#dc2626",
>   "icons": [
>     { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
>     { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" },
>     { "src": "/icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
>   ],
>   "categories": ["productivity", "developer", "security"]
> }
> ```
>
> Add `<link rel="manifest" href="/manifest.json">` to the `<head>`. Set `theme_color` to your primary brand color (it tints the browser chrome on mobile). Test by opening the site on Android Chrome and looking for the install banner.
