# Phase: init (mode detection + critical unknowns)

> Single source of truth for the audit's first phase. Consumed by the CLI
> recon pass (`snitch marketing audit`) and streamed to host agents via
> `snitch marketing step --phase=init`. Mirrors SKILL.md STEP 0 + STEP 0.4
> and `references/smart-detection.md` + `references/discovery-flow.md`.

## Detect the audit mode

Decide which evidence the audit has available before anything else:

- **Source mode** — a working directory with framework files (`package.json`,
  `next.config.*`, `astro.config.*`, `tanstack-start.config.*`, `wp-config.php`,
  `gatsby-config.*`, `eleventy.*`, `_config.yml`, etc.). Read/Grep into JSX, MDX,
  HTML, route configs, head builders.
- **Crawl mode** — the user gave a URL, or the working directory has no framework
  files but web-fetch is available. Fetch the rendered HTML to inspect what bots see.
- **Both** — source AND a deployed URL. Prefer source for source-fixable findings
  (missing alt prop, canonical in route head); use crawl only to verify what is
  actually served (HTTPS, response headers, hreflang).

If neither is available, ask: "Where's the site? Point me at a directory or paste a URL."

## Crawl-mode coverage limit (critical)

When the site uses a hydration-heavy framework (Next.js App Router, React/Vue/Nuxt
SPA, Remix `clientLoader`-only, client-routed SvelteKit), a plain Fetch returns only
the SSR shell. Many `<img>`, `<h1>`, canonical, JSON-LD, and meta values are injected
after hydration and are invisible to a non-JS crawl. In that case, mark DOM-dependent
cats (canonical, H1, image alt/dimensions, client-set JSON-LD, ARIA) as **Skip** with
reason "crawl mode without JS rendering can't see post-hydration DOM; re-run in source
mode or with a JS-rendering crawler." Never report a missing element as a finding when
the cause might be post-hydration only (Rule 1: no findings without evidence).

## Critical unknowns & validity preconditions

Name three things that would change the recommendation if learned, with the cheapest
way to learn each. At least one must be a **validity precondition** — something that
would invalidate the audit's approach if assumed wrong (not merely tune it). Common
classes: rendering mode, indexable population (GSC inclusion), brand maturity vs audit
shape, domain reputation, content language, audit-vs-test calendar (launch/seasonal
spike), buyer-approval authority, distribution-channel feasibility, compliance posture,
eligible-population denominator.

Treat a validity precondition as Critical-tier even before scanning. If it can't be
verified, don't promote any recommendation that depends on it — downgrade to "test the
precondition first." This block ships at the very top of the report, before any prose
or findings.
