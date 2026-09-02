## CATEGORY 44: JS bundle weight per route

Total JavaScript shipped to load a route. Heavy JS = slow time-to-interactive = worse Core Web Vitals = ranking signal. Modern bundlers do route-level code splitting; verify it's working AND measure per-route weight.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Read` framework build output (Next.js: `.next/build-manifest.json`, Astro: `dist/_astro/`, etc.).
2. For each route: sum the JS files needed to load.
3. `Read` `package.json` for likely-heavy dependencies (moment.js, lodash, full chart libraries, large UI kits).

**Enumeration discipline (per Rule 7):** Bundle weight requires actual build output. Two acceptable outcomes:

- **Full** (preferred): build output exists. Quote per-route bundle sizes from the manifest. Audit metadata: `routes_measured: N`.
- **Skip** with reason if build output is missing: `no build output available; run "npm run build" then re-run this category`. Do not auto-run the build (heavy side effect). Do not approximate from `package.json` alone, that gives "this dep COULD be heavy" not "this route IS heavy."

Inferring bundle weight from `package.json` without the build manifest is a Rule 1 violation.

**Crawl mode, required tool calls:**

1. `Fetch` URL. List all `<script>` elements with src + their response Content-Length.
2. Total JS bytes per page.

### Forbidden claims

- "Bundle is probably too large." Quote bytes.
- "Some dependencies are likely heavy." List + sizes.

### Detection

Build output + crawl-mode response sizes.

### What to Search For

Heavy dependencies often shipped client-side:
- `moment` (use date-fns or native Intl)
- `lodash` (cherry-pick or use native)
- `chart.js`, `d3` (heavy; lazy-load)
- `react-icons` (cherry-pick imports)
- Full UI kits (`@mui/material`, `antd`), verify tree-shaking

### Actually Hurts SEO

- **Initial JS bundle >300KB gzipped**.
  Evidence required: bundle size + composition (top 5 contributors).
- **Single route loading entire app's JS** (no code splitting).
  Evidence required: per-route bundles all the same large size.
- **moment.js or full-lodash in client bundle**.
  Evidence required: package.json + bundle analysis.

### NOT a Problem

- Server-side-rendered routes with minimal client JS (correct pattern).
- React hydration for critical UI (necessary; not bloat).

### Context Check

1. Is the framework code-splitting? Modern frameworks default to route-level splitting; verify.
2. Are heavy components dynamically imported (lazy-loaded on demand)?
3. Is the user using a static-site generator that ships less JS by default? Astro / Eleventy ship near-zero JS.

### Reference

Web.dev on JS bundle optimization: https://web.dev/articles/reduce-javascript-payloads-with-tree-shaking

**Severity tagging:**
- Initial bundle >300KB gz → High.
- No code splitting → High.
- moment.js / full-lodash in client bundle → Medium.

**Fix voice:** `performance-engineer` (primary) | `less-but-better-designer` (backup).

Read `souls/performance-engineer.json` before writing the Fix.

Worked fix example:

> Every byte of JS is a byte the browser parses, compiles, and executes before the page becomes interactive. Strip dependencies you don't need. Code-split routes so each one ships only what it requires.
>
> ```ts
> // Bad: ships moment to every route, ~300KB
> import moment from 'moment';
>
> // Good: native or smaller alternative
> const formatted = new Intl.DateTimeFormat('en-US').format(date);
> // Or
> import { format } from 'date-fns';  // ~18KB, tree-shakeable
>
> // Heavy components: lazy-load
> const Chart = lazy(() => import('./Chart'));  // not in main bundle
> ```
>
> Run a bundle analyzer (`@next/bundle-analyzer`, `vite-bundle-visualizer`) to see what's actually shipped per route. The top contributors are usually surprising. Cut what's not earning its weight.
