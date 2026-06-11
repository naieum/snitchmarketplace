# Phase: discovery (pre-audit discovery + component inventory)

> Single source of truth for the discovery phase. Consumed by the CLI recon
> pass and streamed via `snitch marketing step --phase=discovery`. Mirrors
> SKILL.md STEP 0.5 + STEP 0.8 and `references/discovery-flow.md` +
> `references/component-cat-map.md`.

## Pre-audit discovery (the "## Site context" output)

Build a one-page understanding of the site, with evidence (quote the URL, title,
pricing section you used). Severity calibration depends on it — a missing meta
description is High on a content blog, Skip on a noindex'd admin tool.

- **Purpose** (one sentence): what the site does for whoever lands on it.
- **Business model**: free / freemium / subscription SaaS / e-commerce / lead-gen /
  content+ads / agency services / OSS / portfolio. Pick one (or "hybrid" + components).
- **Primary conversion**: the single action the site most wants (signup, purchase,
  contact, install, share, donation).
- **Audience**: be specific ("indie React devs shipping AI side projects," not just
  "developers").
- **Critical surfaces**: the 3-7 highest-weight routes (home, pricing, top product
  pages, signup, checkout, top posts) — strictest audit.
- **Non-critical surfaces**: intentionally low-priority routes (admin, dashboard,
  legal, status, internal docs) — reduced or skipped audit.

Derive in source mode from `package.json` description, `README.md`, the homepage
`metadata`/`head()` block, and a glob of the routes dir. In crawl mode, fetch the
homepage `<title>` + `<meta description>` + H1 + first paragraph, and `/pricing` if
present. If a field can't be determined, write `unknown` and say why — don't invent it.

## Component inventory (the "## Components detected" output)

Enumerate observable components — surfaces/signals verifiable in source or crawl, not
business archetypes. A site with both `/blog` and `/products` is BOTH a content and a
commerce surface; don't pick one. Record the evidence (file path, route, or selector)
per component. This is the ground truth the recommended scan is built from in STEP 1.5
via `component-cat-map.md`.

- **Surface components**: homepage, `/pricing`, `/blog|/posts|/articles`, `/docs`,
  `/faq`, `/about`, `/customers|/case-studies`, `/products|/shop`, `/cart|/checkout`,
  `/courses`, `/services`, `/integrations` (programmatic if 5+), `/compare`, `/for/{x}`,
  `/use-cases`, `/careers`, `/locations` (or footer address), `/newsletter` + embedded
  signup.
- **Content-shape**: author bylines (Person), multi-author (publisher), single author
  (personal brand), recipe/event/book content, video/podcast embeds.
- **Entity-shape**: name-domain (personal brand), first-person-singular hero (solo
  operator), corporate "we" (organization), team page (multi-person org).
- **Infrastructure**: GA4/GTM, ad pixels (Meta/LinkedIn/TikTok/X/Reddit/Pinterest),
  email infra (Resend/Postmark/SendGrid), Stripe, auth lib, i18n routing, `llms.txt`,
  sitemap.xml, robots.txt.
- **Off-site** (carried from brand-maturity): organic social per-platform, paid
  presence per-platform, community channel, PR/press, Google Business Profile, affiliate.

Universal-foundation cats run regardless of detected components; component-specific cats
are added per detected component.
