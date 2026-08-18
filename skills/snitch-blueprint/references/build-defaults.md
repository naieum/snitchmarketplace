# Build Defaults — cross-cutting day-one wiring

What every web-facing surface gets at write time, regardless of archetype. Each item here
is the prescription behind a sibling audit's finding, applied while the file is being
created — when it costs one decision — instead of retrofitted after a report. Items marked
**[free]** cost nothing beyond doing it in the right place the first time.

## Metadata goes where the framework wants it [free]

The single most common retrofit in SEO audits is metadata bolted on where the framework
doesn't read it. Put it in the blessed location from the first page:

- **Next.js App Router:** `export const metadata` / `generateMetadata` in `layout.tsx` /
  `page.tsx`; canonical via `metadata.alternates.canonical`; OG/Twitter images via
  `opengraph-image.tsx` route files; `app/sitemap.ts` and `app/robots.ts` from day one.
- **Next.js Pages Router:** `<Head>` from `next/head` per page; `public/sitemap.xml`,
  `public/robots.txt`.
- **Astro / SvelteKit / Nuxt / Remix:** the layout-level head component or route `meta`
  export, one shared helper so titles/descriptions are per-page parameters, not copy-paste.
- **Plain HTML / static:** one shared head partial or template block.
- **Hosted platforms (Wix, Shopify, Squarespace):** the platform's per-page SEO fields —
  never hand-edited theme `<head>` hacks that the next theme update deletes.

Every page ships with: unique title (format decided once: `{Page} — {Brand}` or archetype
variant), meta description, canonical, OG title/description/image. One OG image template at
launch beats twelve bespoke ones never made.

## The conversion action is instrumented before the first visitor

- One analytics property (GA4 or a privacy-light alternative per the user's constraint
  set), installed site-wide, with the conversion action as a named event from day one.
  Retro-instrumenting after launch destroys the baseline forever — day one is the only
  chance to measure the whole history.
- The event name is recorded in BLUEPRINT.md → Conversion action. Phone-number conversion
  on local-service sites: the number is an `href="tel:"` link and the click is the event.
- **Consent before tags in consent jurisdictions.** If the audience includes EU/UK (or the
  user is unsure), tags load behind a consent state from the start — Consent Mode v2
  defaults denied until granted. Bolting consent onto a live tag stack is the single most
  error-prone retrofit ads-ready sees; wiring it first is a template choice.
- What NOT to install yet: heatmaps, session replay, A/B frameworks, tag managers, a
  second analytics tool. Each is a later decision with a trigger, recorded in DEFERRED.
  Day-one tag stacks accrete; blueprint builds start minimal.

## schema.org: one type, chosen once [free]

Pick the entity type at blueprint time and emit JSON-LD from a single shared component:

- Local service → the most specific `LocalBusiness` subtype schema.org defines for the
  interviewed category (bare `LocalBusiness` only when no subtype fits), with NAP,
  `areaServed`, `openingHours`, `telephone`.
  NAP (name/address/phone) is written ONCE in config and rendered everywhere — NAP drift
  across footer/contact/schema is a classic audit finding that never needs to exist.
- SaaS / tool → `SoftwareApplication` or `Organization` + product pages.
- E-commerce → `Product` with `offers` (price, availability) per product page.
- Content → `Article`/`BlogPosting` with a real `author` entity.
- Only claim in schema what the claim inventory holds — no `aggregateRating` without real
  ratings (that's a manual-action risk, not a growth hack).

## Accessibility and CWV defaults [free at write time]

- Semantic landmarks (`header/nav/main/footer`), one `h1` per page, heading order.
- Every image: `alt`, explicit `width`/`height` (kills layout shift), lazy-load below the
  fold, modern format via the framework's image component when one exists.
- Fonts: system stack or ≤2 hosted faces with `font-display: swap`; preconnect once.
- Real `<a>`/`<button>` elements; visible focus; color contrast ≥ 4.5:1 in the palette
  *before* it's applied everywhere.
- Interactive targets ≥ 44px on mobile; the layout works at 360px width from the first
  component, not as a "mobile pass" later.
- JS discipline: no client-side rendering for content pages when the framework offers
  static/SSR; third-party scripts enter through the DEFERRED list, not by paste.

## Hygiene that is only cheap now [free]

- `robots.txt` + sitemap generated, staging/preview environments `noindex` from creation
  (the "staging site indexed for eight months" finding is a template default).
- 404 page with navigation back; trailing-slash and www/apex redirects decided once.
- HTTPS-only, security headers via the host's config (fuller pass belongs to
  snitch-security / the platform-secure skills — don't duplicate it here).
- No secrets or tracking IDs hardcoded into committed templates; IDs live in env/config.
- Favicon + app icons + web manifest generated at launch, not as a launch-week scramble.

## What this file is not

Not a substitute for the audits. It front-loads their most common, cheapest findings; the
full category depth (field CWV, GEO scoring, pixel matrices, store policy) still belongs to
the siblings, run against the built thing. The handoff list in SKILL.md names them.
