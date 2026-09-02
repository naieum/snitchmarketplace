## CATEGORY 53: Analytics instrumentation

Everything the audit later says about traffic, campaigns and conversion is downstream of one question: is the measurement wired correctly? This category audits the whole instrumentation layer in one pass, because the four halves fail together and are all read from the same source: the **analytics install** (GA4 snippet present, one measurement ID, no double-firing, on every route), **tag-manager hygiene** (one container, env-separated, with its noscript fallback), the **event taxonomy** (stable event names, consistent property keys, no PII), and **UTM hygiene** (one convention, preserved across redirects, stripped from internal navigation). Botched install = no data = decisions made on guesses; good install with a drifting taxonomy or drifting UTMs = confident decisions made on lying dashboards.

Scope boundary: this category audits *whether the measurement is correct*. It never asserts a traffic, conversion or revenue number — those need the analytics account, which the audit does not have.

### Pre-flight: relevance check

Run everywhere analytics is installed. The UTM pass additionally requires any non-organic traffic source (paid, email, partnerships, social posts); skip that pass with reason `not applicable` on sites that explicitly avoid attribution tracking (rare). If no analytics of any kind is detected, this is one finding — "no measurement installed" — and the remaining passes Skip with that reason rather than each reporting an absence.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. **Install.** `Grep` for `gtag(`, `G-`, `googletagmanager.com/gtag/js`, `analytics.google.com`, and for the privacy-first alternatives (Plausible, Fathom, PostHog, Matomo). Quote. Verify the snippet is in head OR in a global layout, so it loads on every page. Check for double-install patterns: gtag.js loaded directly AND via a tag manager.
2. **Tag manager.** `Grep` for `googletagmanager.com/gtm.js` and the container ID. Quote. Note the limit: container contents are managed in the tag-manager UI, not in source, so the source-mode audit covers is-it-installed, where, with what container ID, with what env separation, and whether the `<noscript>` fallback exists.
3. **Event taxonomy.** `Grep` for `gtag('event'`, `analytics.track(`, `mixpanel.track(`, `posthog.capture(`, `segment.track(`. Quote each call. Bucket by event name and identify variations (snake_case vs camelCase, abbreviations, typos). Check property-key consistency across events, and check property *values* for PII.
4. **UTM handling.** `Grep` for `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`, `URLSearchParams.*utm`. Quote each location. Then three follow-ups: (a) is there UTM-stripping logic on internal navigation; (b) do server-side redirects (`next.config.js` redirects, `_redirects`, Workers redirects, route-level `redirect` returns) preserve query strings; (c) are there hardcoded UTM-bearing URLs in source (email-template strings, social-post seeders, footer links) with casing drift, missing params or double-encoding? Read the email templates (`packages/*/emails/*.tsx`, `*.mjml`, `templates/*.html`) and quote their UTM-bearing links.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Look for the gtag snippet or tag-manager container loading; quote the `G-` measurement ID and the `GTM-` container ID, and count how many of each load on one page.
2. Events fire at runtime and are largely invisible to a fetch; the taxonomy pass is source-mode-primary. Say so rather than guessing.
3. Visit the site with a UTM-tagged URL (`?utm_source=test&utm_medium=audit&utm_campaign=instrumentation-test`). Click through 3-5 internal links and quote whether the destination preserves, modifies or strips the UTMs.
4. Check whether server-side redirects (force-https, www-canonicalization, locale redirects) preserve the query string across the hop. Quote before/after.

### Forbidden claims

- "GA4 may be installed wrong." Quote the snippet.
- "Pageviews may not be firing." Without runtime testing you can only check the install pattern; say which you did.
- "The tag manager probably has stale tags." Container contents need UI access. Without it, this cannot be claimed from source — report it as the access gap it is.
- "Events may be inconsistent." Quote the variants, from the files they live in.
- "UTMs may be inconsistent." Quote the inconsistency: `utm_source=Email` in one template, `utm_source=email` in another.
- "Redirects may strip UTMs." Test the redirect; quote the before and after URL.
- Any traffic, conversion-rate or revenue figure. That needs the analytics account (`measurement` type rule).

### Detection

Analytics and tag-manager snippets in source or rendered HTML; analytics calls in source; UTM-handling code, UTM-bearing URLs in templates, and UTM behavior across runtime navigation and redirects.

### What to Search For

**Install + tag manager:**
- `gtag('config', 'G-XXXXX')`
- `<script src="https://www.googletagmanager.com/gtag/js?id=G-XXXXX">`
- `googletagmanager.com/gtm.js?id=GTM-`
- `<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-`
- Env-conditional container/measurement IDs (or a hardcoded one, which means the test container can ship to prod)

**Event taxonomy:**
- `gtag('event', '...', {...})`, `analytics.track('...')`, `mixpanel.track('...')`, `segment.track('...')`, `posthog.capture('...')`
- A tracking plan in the repo (typed enum, const map, or a documented reference) vs ad-hoc string literals at each call site

**UTM:**
- UTM parsing: `URLSearchParams.get('utm_source')`, `searchParams.utm_*`
- UTM-bearing URL construction: template strings containing `utm_source=`
- Internal-link components: do they preserve URL params or strip them?
- Server-side / edge / platform redirects: query-string preservation flags
- Email templates with embedded UTM URLs
- A convention file: `UTM_CONVENTION.md`, a marketing glossary, or equivalent

### Actually Hurts the Marketing Surface

(This category isn't a ranking signal; correct instrumentation is what makes every other marketing decision evidence-based. Findings are about instrumentation correctness.)

**Install:**
- **Analytics missing on key routes** (present on the homepage, absent on blog or product pages).
  Evidence required: per-page check.
- **Double-firing pageviews** (gtag direct + tag-manager container both sending).
  Evidence required: both patterns present, quoted.
- **A sunset analytics property still installed** (a `UA-` measurement ID rather than a `G-` one).
  Evidence required: the snippet pattern quoted.
- **Analytics without consent gating in regulated jurisdictions**.
  Evidence required: the snippet + the missing consent check.

**Tag manager:**
- **Multiple containers loaded on one page** (test container + prod container).
  Evidence required: count of container script tags, IDs quoted.
- **Container ID hardcoded with no env separation** (the test container ships to prod).
  Evidence required: the ID + the absence of env-detection logic.
- **Container installed with no `<noscript>` fallback** (visitors with JS disabled fire nothing).
  Evidence required: script present, noscript absent.

**Event taxonomy:**
- **One event under several name variants** (`signup` + `sign_up` + `signUp`).
  Evidence required: the variants quoted from the files they live in.
- **Property keys inconsistent across events** (`user_id` + `userId` + `uid`).
  Evidence required: the key variants.
- **Events fired with no documented taxonomy** (no tracking plan in the repo).
  Evidence required: the events found + the missing plan.
- **PII in event properties** (email, phone, name as a property value).
  Evidence required: the property and the value pattern.

**UTM:**
- **UTM casing inconsistent across sources** (`utm_source=Email` vs `email` vs `EMAIL` — analytics treats these as three sources).
  Evidence required: 2+ instances quoted with mismatched casing.
- **Required UTMs missing on some campaigns** (some carry `utm_source` only; the attribution gap is silent).
  Evidence required: example campaign URLs with incomplete UTMs.
- **Server-side redirect strips the query string** (the landing page sees a clean URL and no source).
  Evidence required: the redirect rule + a before/after URL test.
- **Internal navigation propagates UTMs** (a deep-page share then inherits the original ad's attribution).
  Evidence required: the walk-through showing UTMs surviving across internal nav.
- **UTMs not stripped from canonical URLs** (Cat 3 cross-ref; rankings split across UTM-tagged duplicates).
  Evidence required: the rendered canonical with the UTM still in it.
- **UTMs double-encoded** (`utm_campaign=spring%2520launch`).
  Evidence required: the URL with the double-encoded character.
- **Email-template UTMs inconsistent across templates** (`utm_medium=email` here, `Email` there, `mail` elsewhere).
  Evidence required: 2+ templates with mismatched values.
- **No documented UTM convention** (every new campaign invents its own values).
  Evidence required: the missing convention doc + the observable drift.
- **`utm_term` / `utm_content` overloaded** (templates filling `utm_term` with copy-variation IDs — right parameter for keywords, wrong one for content).
  Evidence required: the misused parameter quoted.

**Ad platforms:**
- **A pixel is installed but its wiring is unknown from here.** This category reports that a pixel exists and where; whether the conversion tracking behind it is complete and correct (init order, event dedup, server-side pairing, Consent Mode signals) is a different audit — call the Skill tool with "snitch-adsready" for it rather than guessing at the wiring from source.
  Evidence required: the pixel snippet quoted with its file:line, and the handoff named.

### NOT a Problem

- A single analytics install via either the direct snippet or the tag manager. Either is valid; both together is the finding.
- A dev-environment install behind an env check.
- A single container with a proper noscript fallback, or an env-conditional container per environment.
- A consistent naming convention applied throughout, or a documented tracking plan.
- UTMs intentionally stripped from canonical URLs by the canonical builder (correct per Cat 3).
- A redirect that deliberately drops UTMs because the target is an internal-only path (rare; flag for verification).
- Different `utm_campaign` values across distinct campaigns — that is the parameter's purpose.
- UTMs absent on direct or organic links; direct traffic doesn't need to self-identify.

### Context Check

1. Is the site analytics-driven at all, and which tool does the team actually use?
2. Does the team have access to the tag-manager UI? They should; without it, container hygiene is unauditable and that is itself worth reporting.
3. Is analytics consent-gated for the jurisdictions the brand sells into?
4. Does a tracking plan exist, and is the naming convention enforced in code (typed helper, const map) rather than by discipline?
5. Are tracking calls wrapped in a helper — one source of truth for the taxonomy — or scattered as literals?
6. Is there a UTM convention document and a builder utility, or is every campaign URL hand-assembled?
7. Do server-side redirects preserve query strings? Default behavior varies per platform.
8. Does internal navigation strip UTMs after the entry hit, and is the canonical (Cat 3) UTM-clean?

### Reference

GA4 documentation: https://support.google.com/analytics/answer/9304153

Tag Manager developer docs: https://developers.google.com/tag-platform/tag-manager

UTM parameter convention (Google Analytics docs): https://support.google.com/analytics/answer/10917952

`references/ads-detection-matrix.md`, the per-platform what's-checkable spine; UTM handling applies to every ad platform

`references/strategic-recommendations.md`, where the north-star metric this instrumentation makes possible is named, thresholded and turned into a decision rule

Cat 3 (Canonical URL), canonicals must be UTM-clean

Cat 99 (Conversion funnel deep-audit), which consumes this category's events step by step

**Severity tagging:**
- Analytics missing on key routes → High.
- Double-firing pageviews → High.
- A sunset analytics property still installed → Critical.
- Test container in prod → Critical.
- Multiple containers on one page → High.
- Container noscript fallback missing → Low.
- One event under several name variants → High.
- PII in event properties → Critical (privacy).
- No tracking plan → Medium.
- Server-side redirect strips UTMs → Critical (the campaign loses source attribution entirely).
- UTM casing inconsistent across sources → High (attribution corruption).
- Internal navigation propagates UTMs → High.
- Required UTMs missing on some campaigns → High.
- Canonical includes UTMs → High (Cat 3 cross-ref).
- Email-template UTMs inconsistent → Medium.
- UTMs double-encoded → Medium.
- No documented UTM convention → Medium (process gap).

**Fix voice:** `analytics-engineer` (primary) | `solutions-architect` (backup).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> One measurement layer, one taxonomy, one UTM convention. Each of the three is cheap to set up once and expensive to reconstruct after a year of drift.
>
> **1. One install, in the global layout.** Don't double-install via the direct snippet plus the tag manager. If you use the tag manager, let it own the analytics tag; don't also embed the snippet in source.
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
> If it's the tag manager instead: one container, env-conditional, with the noscript fallback in the body. The tag inventory itself is a quarterly job inside the tag-manager UI — list tags, list triggers, kill what no longer earns its keep.
>
> **2. Taxonomy as code.** Define event names as a typed enum or const, and wrap every call in a helper that validates the name and property keys against the schema.
>
> ```ts
> // Tracking plan as code
> type EventName =
>   | 'signup_started'
>   | 'signup_completed'
>   | 'activation_reached'
>   | 'subscription_created';
>
> type EventProps = {
>   signup_started: { entry_channel: string };
>   activation_reached: { hours_since_signup: number };
>   // ...
> };
>
> function trackEvent<T extends EventName>(name: T, props: EventProps[T]) {
>   gtag('event', name, props);
> }
> ```
>
> Now an unknown event or a wrong property can't be fired. The tracking plan lives next to the code instead of in a stale doc, and no property carries an email address.
>
> **3. UTMs: convention, builder, runtime strip.** Document the canonical values for `utm_source`, `utm_medium` and `utm_campaign` in one file — lowercase only, a fixed vocabulary for `medium` (`email`, `social`, `paid_search`, `paid_social`, `affiliate`, `referral`, `partnership`). Then construct every tagged URL through one function, so the convention is enforced at compile time rather than remembered.
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
> Capture the UTMs on the entry hit, then strip them from the URL so a deep-page share doesn't inherit the campaign; keep query strings alive through server-side redirects so the campaign survives the hop.
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
> Install, taxonomy, convention. Once all three hold, the dashboards are worth arguing over — and the one number the team should argue about is the north-star metric in `references/strategic-recommendations.md`, which this instrumentation is what makes measurable.
