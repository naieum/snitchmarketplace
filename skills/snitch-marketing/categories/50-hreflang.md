## CATEGORY 50: Hreflang correctness

`<link rel="alternate" hreflang="...">` tells Google which URL to serve users in different languages / regions. Required when the same content exists in multiple locales. Done wrong, Google serves the wrong locale to users (English speakers see French, etc.) and ranks one variant over the others arbitrarily.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify if the site is multi-locale: routes prefixed with `/en/`, `/es/`, `/fr/`; framework i18n config; CMS locale fields.
2. `Grep` for `rel="alternate"`, `hreflang=`. Quote each link.
3. For each route: confirm hreflang declarations point at all locale variants of that route.
4. Verify each declared hreflang URL resolves AND declares a reciprocal hreflang back.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Find `<link rel="alternate" hreflang>` elements. Quote.
2. For each declared variant: fetch that URL, check it also declares hreflang back.

### Forbidden claims

- "Hreflang may be wrong." Quote the declarations.
- "Variants may not link back." Fetch and verify.

### Detection

Hreflang link elements in head + cross-locale URL structure.

### What to Search For

- `rel="alternate"`, `hreflang="..."`
- ISO language codes (`en`, `es`, `fr`, `de`, `ja`, `zh`)
- ISO language-region codes (`en-US`, `en-GB`, `es-MX`, `pt-BR`)
- `hreflang="x-default"` (fallback)

### Actually Hurts SEO

- **Multi-locale site without hreflang declarations**.
  Evidence required: locale routes + missing hreflang.
- **Hreflang declared without reciprocal link** (en page declares es variant; es page doesn't declare en variant).
  Evidence required: both pages quoted.
- **Hreflang URLs pointing at 404**.
  Evidence required: declaration + fetched response.
- **Wrong language code** (`en-UK` instead of `en-GB`; `gb` doesn't exist as a language code).
  Evidence required: quoted code.
- **Missing `x-default` for global / language-selector page**.
  Evidence required: declarations + missing x-default.

### NOT a Problem

- Single-locale site with no hreflang. Don't flag.
- Site with hreflang declared but only for the languages it has (not flagging for non-existent locales).

### Context Check

1. Is the site actually multi-locale?
2. Are the locale URLs canonical or redirected?
3. Is the framework managing hreflang automatically (Next.js i18n routing, Astro i18n)?

### Reference

Google on hreflang: https://developers.google.com/search/docs/specialty/international/localized-versions

**Severity tagging:**
- Multi-locale site without hreflang → Critical.
- Hreflang without reciprocal links → High.
- Hreflang URLs 404 → Critical.
- Wrong language codes → High.

**Fix voice:** `solutions-architect` (primary) | `jen-simmons` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Each locale variant of a page declares all the variants (including itself). Reciprocal links are mandatory; without them, Google picks one variant arbitrarily.
>
> ```html
> <!-- /en/about -->
> <link rel="alternate" hreflang="en" href="https://example.com/en/about">
> <link rel="alternate" hreflang="es" href="https://example.com/es/about">
> <link rel="alternate" hreflang="fr" href="https://example.com/fr/about">
> <link rel="alternate" hreflang="x-default" href="https://example.com/en/about">
>
> <!-- /es/about, declares the same set, all four -->
> <link rel="alternate" hreflang="en" href="https://example.com/en/about">
> <link rel="alternate" hreflang="es" href="https://example.com/es/about">
> <link rel="alternate" hreflang="fr" href="https://example.com/fr/about">
> <link rel="alternate" hreflang="x-default" href="https://example.com/en/about">
> ```
>
> Generate the hreflang block from the framework's locale routing, every variant of a route gets the same hreflang block automatically. Manual maintenance breaks reciprocity.
