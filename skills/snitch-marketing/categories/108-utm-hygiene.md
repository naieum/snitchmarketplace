## CATEGORY 108: UTM hygiene + parameter consistency

UTM parameters are the canonical way marketing channels self-identify in analytics. They look simple, `?utm_source=newsletter&utm_medium=email&utm_campaign=q2-launch`, but the convention breaks in dozens of small ways: parameter casing drift, double-encoding, redirect strippping, internal-nav pollution, missing required params. Each break corrupts attribution; corrupted attribution drives the wrong marketing decisions.

This category audits the brand's UTM convention end-to-end: how UTMs are generated, how they're preserved across redirects, how they're stripped from internal navigation, how they're parsed into analytics events.

### Pre-flight: relevance check

Run on every site that has analytics installed AND any non-organic traffic source (paid, email, partnerships, social posts). Skip with reason `not applicable` only on sites that explicitly avoid attribution tracking (rare).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for UTM-handling code: `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`, `URLSearchParams.*utm`, `searchParams\\.get\\('utm`. Quote each location.
2. `Grep` for UTM-stripping logic on internal navigation: links / Link components / router pushes that explicitly remove or strip UTMs. Note whether they exist or are absent.
3. `Grep` for redirect handlers: middleware, server-side redirects (`next.config.js` redirects, `_redirects`, Cloudflare Workers redirects, route-level `redirect` returns). Check whether each preserves query strings (and therefore UTMs).
4. `Grep` for hardcoded UTM-bearing URLs in source (often in email-template strings, social-post seeders, footer links). Inspect for casing inconsistency, missing params, double-encoding.
5. Read email-template files (`packages/*/emails/*.tsx`, `*.mjml`, `templates/*.html`). Quote the UTM-bearing links inside; check casing + parameter completeness.

**Crawl mode, required tool calls:**

1. Visit the site with a UTM-tagged URL: `?utm_source=test&utm_medium=audit&utm_campaign=snitch-marketing-test`.
2. Click through 3-5 internal links. Quote whether the destination URL preserves, modifies, or strips the UTMs.
3. Check whether server-side redirects (force-https, www-canonicalization, locale-redirects) preserve UTMs across the redirect.
4. Check whether the analytics in network tab capture UTMs as expected, `gtag` event payload should include the source/medium/campaign in some shape.

### Forbidden claims

- "UTMs may be inconsistent." Quote the inconsistency: e.g., `utm_source=Email` in one template, `utm_source=email` in another.
- "Internal navigation may be propagating UTMs." Walk it; quote the URL on second click.
- "Redirects may strip UTMs." Test the redirect; quote before/after URL.

### Detection

UTM-handling code in source + UTM-bearing URLs in email templates + UTM behavior in runtime navigation + redirect query-string preservation.

### What to Search For

- UTM parameter parsing: `URLSearchParams.get('utm_source')`, `searchParams.utm_*`
- UTM-bearing URL construction: template strings with `utm_source=`
- Internal-link components: do they preserve URL params or strip them?
- Server-side / Cloudflare / Vercel redirects: query-string preservation flags
- Email template files with embedded UTM URLs
- Documentation / convention files: `UTM_CONVENTION.md`, `marketing-glossary.md`, etc.

### Actually Hurts the Marketing Surface

- **UTM casing inconsistent across sources** (`utm_source=Email` vs `utm_source=email` vs `utm_source=EMAIL`, analytics treats these as 3 different sources).
  Evidence required: 2+ instances quoted with mismatched casing.
- **Required UTMs missing in some campaigns** (some campaigns have `utm_source` only, others have full set; attribution gap).
  Evidence required: example campaign URLs with incomplete UTMs.
- **Server-side redirect strips query string** (the redirect chain drops UTMs; landing page sees clean URL with no source attribution).
  Evidence required: redirect rule + before/after URL test.
- **Internal navigation propagates UTMs** (user clicks an inbound paid ad with UTMs, navigates internally; every internal page now has the same UTMs in its URL; if user shares the link from a deep page, the share inherits the original ad's UTMs).
  Evidence required: walk-through showing UTMs propagating across internal nav.
- **UTMs not stripped from canonical URLs** (Cat 3 cross-ref, canonical includes UTMs; rankings split across UTM-tagged duplicates).
  Evidence required: rendered canonical URL with UTM still present.
- **UTMs double-encoded** (`utm_campaign=spring%2520launch` instead of `utm_campaign=spring%20launch`, analytics parser fails or shows ugly value).
  Evidence required: URL with double-encoded character.
- **Email-template UTMs hardcoded inconsistently across templates** (welcome email uses `utm_medium=email`; abandoned-cart uses `utm_medium=Email`; report template uses `utm_medium=mail`).
  Evidence required: 2+ templates with mismatched values.
- **No documented UTM convention** (the team has no naming standard; new campaigns invent their own values; ID drift compounds).
  Evidence required: missing convention doc + observable drift.
- **`utm_term` / `utm_content` overloaded for non-paid context** (email templates filling `utm_term` with arbitrary copy variation IDs; correct for keyword tracking, semantically wrong for content tracking).
  Evidence required: misused parameter quoted.

### NOT a Problem

- UTMs intentionally stripped from canonical URLs by the canonical-builder (correct per Cat 3).
- A redirect that intentionally drops UTMs because the redirect target is an internal-only path (rare; flag for verification).
- Different `utm_campaign` values across distinct campaigns, that's the parameter's purpose.
- UTMs absent on direct-traffic / organic links, direct traffic doesn't need self-identification.

### Context Check

1. Does the team have a documented UTM convention (`UTM_CONVENTION.md` or equivalent)? Without one, drift is inevitable.
2. Is there a UTM-builder utility (a shared function that constructs tagged URLs) vs hand-construction in each campaign?
3. Are server-side redirects preserving query strings? Default behavior varies per platform.
4. Does internal navigation strip UTMs after the initial entry?
5. Is the canonical (Cat 3) UTM-clean?
6. Does the analytics parser normalize casing on ingest? (Belt-and-suspenders defense.)

### Reference

`references/ads-detection-matrix.md`, UTM applies to every ad platform's campaign tracking

Cat 3 (Canonical URL), canonicals must be UTM-clean

Cat 53 (GA4 install), analytics layer that ingests UTMs

UTM parameter convention (Google Analytics docs): https://support.google.com/analytics/answer/10917952

**Severity tagging:**

- UTM casing inconsistent across sources → High (attribution corruption).
- Server-side redirect strips UTMs → Critical (entire campaign loses source attribution).
- Internal navigation propagates UTMs → High (pollutes attribution + risks shared-link confusion).
- Required UTMs missing on some campaigns → High.
- Canonical includes UTMs → High (Cat 3 cross-ref).
- Email-template UTMs inconsistent across templates → Medium.
- UTMs double-encoded → Medium.
- No documented UTM convention → Medium (process gap).

**Fix voice:** `analytics-engineer` (primary) | `solutions-architect` (backup).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> Attribution data is downstream of UTM hygiene. If UTMs drift, the dashboards lie, and the team makes campaign decisions on lying dashboards. Three controls keep this honest.
>
> **1. Convention first.** Document the canonical values for `utm_source`, `utm_medium`, `utm_campaign` in a single `UTM_CONVENTION.md`. Lowercase only; underscores or hyphens chosen and held; a fixed vocabulary for `medium` (`email`, `social`, `paid_search`, `paid_social`, `affiliate`, `referral`, `partnership`).
>
> **2. Builder utility, not hand-construction.** A shared function constructs every tagged URL. Hand-rolled UTMs in templates and links drift; centralized construction enforces the convention at compile time.
>
> ```ts
> // src/lib/utm.ts
> type UtmMedium = 'email' | 'social' | 'paid_search' | 'paid_social' | 'affiliate' | 'referral' | 'partnership';
>
> export function tagged(url: string, params: {
>   source: string;
>   medium: UtmMedium;
>   campaign: string;
>   content?: string;
>   term?: string;
> }) {
>   const u = new URL(url);
>   u.searchParams.set('utm_source', params.source.toLowerCase());
>   u.searchParams.set('utm_medium', params.medium);
>   u.searchParams.set('utm_campaign', params.campaign.toLowerCase());
>   if (params.content) u.searchParams.set('utm_content', params.content.toLowerCase());
>   if (params.term) u.searchParams.set('utm_term', params.term.toLowerCase());
>   return u.toString();
> }
> ```
>
> Every email template, social-post link, ad-creative URL flows through `tagged()`.
>
> **3. Strip on internal navigation; preserve on redirects.** When a user lands with UTMs and navigates internally, the next page's URL drops the UTMs (so a deep-page share doesn't inherit the original campaign's attribution). When a server-side redirect fires, query strings (and therefore UTMs) pass through to the destination.
>
> ```ts
> // first-page entry: capture UTMs into analytics, then strip from URL
> const params = new URL(window.location.href).searchParams;
> if (params.has('utm_source')) {
>   gtag('event', 'campaign_landing', Object.fromEntries(params));
>   const cleanUrl = new URL(window.location.href);
>   ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term']
>     .forEach(k => cleanUrl.searchParams.delete(k));
>   window.history.replaceState({}, '', cleanUrl.pathname + cleanUrl.search);
> }
> ```
>
> The combination, convention, builder, runtime-strip, produces UTMs that are reliable across email, paid, partnerships, social, and that don't pollute internal navigation. Attribution dashboards stay honest.
