# 06 — Core Web Vitals

Read when an audit returns 🔴/🟡 on `state crux` or `state lighthouse`. Measure user experience directly; do not claim a specific ad score, AI eligibility, or
ranking effect from these metrics alone.

## Targets (mobile-first)

| Metric | Good | Needs improvement | Poor |
|---|---|---|---|
| **LCP** Largest Contentful Paint | ≤ 2.5s | 2.5-4.0s | > 4.0s |
| **INP** Interaction to Next Paint | ≤ 200ms | 200-500ms | > 500ms |
| **CLS** Cumulative Layout Shift | ≤ 0.1 | 0.1-0.25 | > 0.25 |

Field data (CrUX) > lab data (Lighthouse). Field is what Google and the user actually experience; lab is your faster iteration loop.

## `state crux` vs `state lighthouse`

- **`state crux`**: 28-day rolling Chrome User Experience Report. Uses PageSpeed Insights API. Free; `PSI_API_KEY` raises quota.
- **`state lighthouse`**: synthetic lab run via local lighthouse CLI. Falls back to PSI category scores if not installed (`npm i -g lighthouse`).

CrUX does not publish a fixed visitor threshold. Missing field data can reflect eligibility
or insufficient samples; mark it unknown and label any Lighthouse result as lab, not field.
Methodology checked 2026-09-04: https://developer.chrome.com/docs/crux/methodology

## LCP — slow causes

| Cause | Fix |
|---|---|
| Hero image huge / unoptimized | AVIF/WebP, responsive `srcset`, `fetchpriority="high"` on LCP image |
| Hero image lazy-loaded | Remove `loading="lazy"` from above-the-fold images |
| Render-blocking JS / CSS | Inline critical CSS; defer non-critical JS |
| Slow server TTFB | CDN / edge platform; cache HTML at the edge if dynamic content allows |
| Web fonts blocking | `font-display: swap`; preload primary weight |
| Pixels loading sync | `async` on every pixel script tag |
| Cookie banner blocking layout | Render at bottom of `<body>`, not above the fold |

Pixels rarely become the LCP element but compete for main-thread CPU during load — see INP.

## INP — interaction to next paint

INP describes interaction responsiveness over a page visit, with outlier handling for long
visits. The field threshold is assessed at the 75th percentile across visits, not the 75th
percentile of interactions inside one session. Trace long tasks before blaming a pixel.

| Cause | Fix |
|---|---|
| GTM container with 30+ tags | Disable unused tags; consider sGTM (`recommend gtm-server`) |
| Pixels heavy on click handlers | Move `track` calls into `requestIdleCallback`; debounce |
| Large React renders blocking event loop | Code-split; `useDeferredValue` |
| Synchronous extension-injected globals | try/catch + early return |
| Many `MutationObserver`s from pixels | Reduce pixel count; partytown them off main thread |

Off-main-thread tag execution via Partytown is one of the biggest INP wins. Astro has `@astrojs/partytown`; Next/Nuxt have plugins.

## CLS

| Cause | Fix |
|---|---|
| Images without dimensions | Always set `width` + `height` attributes |
| Iframes (ad slots) without space | Reserve `min-height` on the slot |
| Web font swap shifts | `size-adjust` in @font-face; preload primary weight |
| CMP banner appearing late | Modal or `fixed` at bottom |
| Carousels / sliders | Reserve full slide dimensions; avoid `auto` height |
| Third-party widgets | Reserve container; render after layout settles |

## Verification

1. `state lighthouse <url>` for instant lab feedback.
2. Record the field collection window; rolling data mixes old and new experiences after a fix.
3. `state crux <url> mobile` to confirm field improved.
4. Cross-check Search Console → Core Web Vitals report.

## When CWV can't be saved without rework

Recommend architectural rework only when measured bottlenecks and constraints justify it.
SPAs are not measured as static shells; client route transitions can have attribution
limitations, so name the page/window measured. Plugin count alone proves no failure.
Compare scoped optimizations before proposing a migration; no framework guarantees good CWV.

## See also

- `05-quality-and-engagement-signals.md` — CWV maps to Quality Score.
- `references/recommendations/lighthouse-runner.md` — CI runners.
- `references/recommendations/cwv-monitoring.md` — RUM tools.
- web.dev: https://web.dev/articles/vitals
