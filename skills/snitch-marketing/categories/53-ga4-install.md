## CATEGORY 53: GA4 install

Google Analytics 4 needs to be installed correctly: snippet present, measurement ID set, sending pageviews, not double-firing, not missing on key routes. Botched install = no data = no measurement = decisions made on guesses.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `gtag(`, `G-`, `googletagmanager.com/gtag/js`, `analytics.google.com`. Quote.
2. Verify the snippet is in head OR in a global layout (so it loads on every page).
3. Check for double-install patterns: gtag.js loaded directly AND via GTM.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Look for the gtag snippet or GTM container loading.
2. Check for `G-` measurement ID format.

### Forbidden claims

- "GA4 may be installed wrong." Quote the snippet.
- "Pageviews may not be firing." Without runtime testing, you can only check the install pattern.

### Detection

GA4 snippet patterns.

### What to Search For

- `gtag('config', 'G-XXXXX')`
- `<script src="https://www.googletagmanager.com/gtag/js?id=G-XXXXX">`
- GTM container: `<script src="https://www.googletagmanager.com/gtm.js?id=GTM-XXXXX">`

### Actually Hurts SEO

(Note: this category isn't directly SEO; analytics enables informed decisions about SEO. Findings are about install correctness.)

- **GA4 snippet missing on key pages** (only on homepage, not blog or product pages).
  Evidence required: per-page check.
- **Double-firing pageviews** (gtag direct + GTM container both sending).
  Evidence required: both patterns present.
- **Old Universal Analytics (UA-XXXX) instead of GA4 (G-XXXXX)**.
  Evidence required: snippet pattern (UA is sunset since 2023).
- **GA4 without consent gating in regulated jurisdictions** (cross-reference Cat 56).
  Evidence required: snippet + missing consent check.

### NOT a Problem

- Single GA4 install via either gtag.js direct or GTM. Either is valid.
- GA4 dev environment (snippet behind env check), correct.

### Context Check

1. Is the site analytics-driven? If yes, install matters.
2. Does the team use GA4 or another tool (Plausible, Fathom, Posthog)?
3. Is consent gated properly?

### Reference

GA4 documentation: https://support.google.com/analytics/answer/9304153

**Severity tagging:**
- GA4 missing on key routes → High.
- Double-firing → High.
- UA instead of GA4 (sunset) → Critical.

**Fix voice:** `analytics-engineer` (primary) | `solutions-architect` (backup).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> One snippet, in the global layout, loaded on every page. Don't double-install via gtag + GTM. If you use GTM, let GTM handle the GA4 tag; don't also embed gtag directly.
>
> ```html
> <!-- Single GA4 install via direct gtag -->
> <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
> <script>
>   window.dataLayer = window.dataLayer || [];
>   function gtag(){dataLayer.push(arguments);}
>   gtag('js', new Date());
>   gtag('config', 'G-XXXXXXXXXX');
> </script>
> ```
>
> Or via GTM, in which case the gtag config lives in the GTM container, not in source. One or the other; never both.
