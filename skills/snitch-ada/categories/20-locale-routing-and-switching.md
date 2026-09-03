## CATEGORY 20: Locale negotiation, the language switcher and locale persistence

Shipping a translation is not the same as letting someone reach it. A site can hold four
excellent locales and still trap a German speaker in Spain on the Spanish site, hide the switcher
in the footer behind a flag, throw them back to the homepage when they use it, and lose the
choice again at checkout. Each of those is a routing decision, not a translation one, and each
ends the same way: the reader settles for a language they read less well, or leaves.

This category judges whether a person can reach their language and stay in it. The evidence is
the middleware, the route configuration and the switcher markup at `file:line`, or the served
redirect chain and the rendered switcher at URL + selector. Accept-Language is a hint, and
RFC 9110 says as much: users are rarely familiar with the details of language matching, and
sending a full preference list can run against a user's privacy expectations. A hint is a good
default and a bad prison.

**Boundary.** How search engines are told which locale variants exist is **not** judged here.
`hreflang`, `x-default` and locale canonicals belong to a sibling: call the Skill tool with
"snitch-marketing", whose Cat 50 and Cat 51 own them, and whose Cat 133 judges whether the
translated page reads well. Whether the switcher is the right control in the right place on the
decision path is a different judge: call the Skill tool with "snitch-ux". The `lang` attribute is
judged against WCAG 3.1.1 and 3.1.2 in Category 12 here, and the switcher's on-change behavior
against WCAG 3.2.2 in Category 09.

### Pre-flight

Skip with the reason `not applicable` when the surface serves one locale **and** a recorded
`Decision` in the declared-intent files states a single-language scope. Cite the line. Otherwise:

- More than one locale served: run in full.
- One locale served with no recorded Decision either way: run at **readiness severity**, capped at
  **Low**, reporting only the rows that describe absent machinery ("no locale is resolved per
  request", "no persistence mechanism exists"), worded as "this is what the second locale will
  need". Do not invent a missing switcher for a site that has one language.
- Neither declared-intent file present is a **Skip** with that reason.

Establish the locale list from the discovery i18n inventory before any row runs. A finding about a
locale nobody serves is not a finding.

### Rule table

| Pattern | What must hold | Static signal | Severity |
|---|---|---|---|
| Locale forced by IP or geolocation with no override | Geography may suggest a locale; it never decides one. The reader can choose another and the choice sticks | Middleware branching on a country header or a geo lookup and issuing a redirect, with no cookie or query-parameter escape | High |
| `Accept-Language` negotiation with no persistent user choice | The header sets the first-visit default; an explicit choice is stored in a cookie, a profile field or the URL and outranks the header afterwards | Header parsing that runs on every request with no stored-preference check ahead of it | High |
| No language switcher on a multi-locale surface | Every page offers a way into the other locales | No switcher component in the header, nav or any shared layout | High |
| Switcher present only in the footer | The control is reachable without scrolling past the content a reader cannot read | The switcher rendered only inside the footer partial | Medium |
| Switcher options labelled with flags only | Options carry text; a flag is a country, not a language, and an image alone has no accessible name | `<img>` or an emoji flag as the only content of an option | High |
| Options written in the source language rather than their own | Each option is its own endonym in its own script: `Deutsch`, `العربية`, `日本語`, not `German`, `Arabic`, `Japanese` | A locale-name map holding source-language names, or option labels drawn from one catalog | High |
| Switcher links missing `lang` and `hreflang` | Each `<a>` carries `hreflang` for the target locale and `lang` so the label is announced in its own language | Anchor markup in the switcher with neither attribute; see Category 12 for the `lang` criterion | Medium |
| Switcher navigates to the homepage instead of the equivalent page | Switching preserves the current page, and its parameters, in the target locale; the homepage is the documented fallback only when no equivalent exists | The switcher href built from a locale root rather than from the current route | High |
| Switcher implemented as `<select onchange>` navigation | Changing a selection does not navigate; a submit or a link does. See Category 09, WCAG 3.2.2 | `onchange` or a change handler on a `<select>` that assigns `location` | High |
| Locale lost on login, checkout, or a link from an email | The resolved locale survives every redirect boundary: auth callbacks, payment returns, and campaign links | A redirect target built without the locale segment; an email template linking to an unprefixed path | High |
| Untranslated route falls back to the source locale silently | A missing translation renders with a visible note in the reader's language, or the route is not offered in that locale | A catalog fallback chain with no user-facing signal; see the sibling's Cat 133 for the content half | Medium |
| Error and not-found pages outside the locale system | 404, 500 and maintenance pages resolve a locale like every other route | An error template with hardcoded source-language copy and no locale lookup | Medium |
| `<html lang>` not derived from the resolved locale | `lang` and `dir` are emitted from the same resolved locale the router used | A literal `lang="en"` in the root layout on a multi-locale surface; Category 12 owns the criterion, this row owns the routing derivation | High |
| Locale-negotiated response cached with no `Vary` on the negotiating header | A response whose content depends on `Accept-Language` declares `Vary: Accept-Language`, so a shared cache does not serve one reader's language to another | A cache header set on a negotiated route with no `Vary` naming the header | Medium |
| Language and region conflated in one control | Language and region are two axes; a reader may want German copy with Swiss pricing | A single switcher whose options mix languages and currencies or countries | Low (advisory) |

### Evidence required

**Source mode, cheapest first:**

1. Read the routing and middleware layer. Quote the code that resolves a locale per request and
   record its precedence order: stored preference, URL segment, header, geography, default. That
   order **is** the finding for the first two rows.
2. `Grep` for redirect construction on locale: `redirect(`, `Location`, `cf-ipcountry`,
   `x-vercel-ip-country`, `geoip`, `country`. Read each hit and record whether an override exists.
3. `Grep` for `Accept-Language`, `acceptLanguage`, `negotiator`, `preferredLocale`, and for the
   persistence side: `NEXT_LOCALE`, `locale` cookie names, a `locale` column on the user model.
4. Locate the switcher component, read it in full, and quote how each option is labelled, whether
   labels are endonyms, whether `lang` and `hreflang` sit on the anchors, whether the href is
   built from the current route or a locale root, and whether it is a `<select>` that navigates.
5. `Grep` the redirect boundaries (auth callback URLs, payment return URLs, email templates) and
   record whether the locale segment survives each.
6. Read the root layout and quote the `<html>` tag, recording whether `lang` and `dir` come from
   the resolved locale, and read the error and not-found templates for a locale lookup.

**Crawl mode, cheapest first:**

1. Fetch the root URL and follow every redirect, quoting the chain with status codes and
   `Location` headers. Say which signal you can prove drove it and Skip the rest.
2. Fetch again with a different `Accept-Language` and quote both chains side by side.
3. Fetch a deep page in one locale, find the switcher in the markup, and quote its options with
   their selector: the label text, the `href`, and any `lang` / `hreflang`. Compare each `href`
   against the current path to answer the homepage-reset row.
4. Quote `Vary` and `Cache-Control` on any route whose content changed with the header in step 2.
5. Whether the choice survives a login or a checkout is not observable from a fetch. Record
   `Skip — locale persistence across authenticated flows requires a runner or a human; not run`.

**Caveat:** a redirect chain proves that a redirect happened, not why. Name the signal you could
prove drove it and mark the confidence accordingly, rather than asserting a geo lookup you did
not see.

### Forbidden claims

- "The site probably geolocks users." Quote the middleware branch, or the redirect chain plus the
  signal you proved drove it, or Skip with the reason.
- "The language switcher is hard to find." That judges the decision path and belongs to the
  sibling named in the Boundary. Here, report where in the markup it renders.
- "hreflang is missing." Not this category's judge. Never report hreflang, `x-default` or locale
  canonicals here; note them for the sibling and move on.
- "The locale is lost at checkout." Unless you walked it, Skip with the runner reason. A missing
  locale segment in a redirect target is the static finding; the walked loss is a different claim.
- Never "compliant", "conformant" or "non-compliant" as a verdict.
- "Users in France will get French." Quote the signals that resolve the locale and their order.
  Predicting a reader's experience from a country is not evidence.
- Any WCAG success criterion number. The `lang` criteria are Category 12's and the on-change
  behavior is Category 09's; this category names routing patterns.

### Detection

Static read of the locale resolution order in middleware and routing, a full read of the switcher
component, a grep sweep of redirect boundaries, and a header read on negotiated routes. Crawl mode
follows the redirect chain under varied `Accept-Language`. Anything behind authentication Skips.

### What to Search For

- `Accept-Language`, `acceptLanguage`, `negotiator`, `preferredLocale`, `detectLocale`
- `cf-ipcountry`, `x-vercel-ip-country`, `geoip`, `country`, `region` in middleware; `redirect(`,
  `Location:`, `permanentRedirect`, `router.replace` next to a locale value
- Cookie and storage names: `NEXT_LOCALE`, `locale`, `lang`, `i18n_lang`, `preferred_locale`
- Switcher markup: `LanguageSwitcher`, `LocaleSwitcher`, `<select` with an `onchange` that assigns
  `location`, a flag `<img>` or a flag emoji as an option's only content
- Locale name maps holding source-language names: `{ de: 'German', ar: 'Arabic' }`
- `hreflang=` and `lang=` on switcher anchors (their presence is the pass evidence)
- `Vary` and `Cache-Control` on negotiated routes; auth and payment callback URLs and email
  templates linking to unprefixed paths; error templates (`404`, `not-found`, `500`) with
  hardcoded copy

### Actually Fails

- **A geography redirect with no override.** An expat, a traveller and anyone on a VPN are routed
  to a language they may not read, with no way out. Evidence: the middleware branch at
  `file:line`, or the redirect chain plus the signal that drove it, and the grep for a cookie or
  query override returning nothing.
- **No stored preference anywhere.** The reader picks a language and the next request negotiates
  from the header again and undoes it. Evidence: the resolution order quoted, with no
  stored-preference check ahead of the header parse.
- **A switcher labelled only with flags.** A flag names a country, so Austrian and Swiss readers
  are asked to pick Germany, and the control has no text to announce. Evidence: the option markup
  quoted with its selector.
- **Options written in the source language.** A reader who cannot read the current page also
  cannot read a list of language names written in it. Evidence: the label map or the rendered
  options, beside the endonym each should carry.
- **Switching resets to the homepage.** The reader loses the page they were on and has to find it
  again in a language they were already struggling with. Evidence: the href construction at
  `file:line`, or two quoted hrefs from a deep page showing locale roots.
- **The locale dropped at a redirect boundary.** Sign in, pay, or follow an emailed link, and the
  site is back in its source language. Evidence: the redirect target or email URL quoted with no
  locale segment.

### NOT a Failure

- Geography used to **suggest** a locale: a dismissible banner, a preselected option, a one-time
  prompt. Suggestion with an override is the pass shape.
- `Accept-Language` as the first-visit default, where an explicit choice is stored and outranks it
  afterwards. Trace the order once and record the pass.
- A single-locale site with a recorded single-language `Decision`. That is the Skip case.
- A switcher in the footer **and** in the header or account menu; footer-only is the finding. A
  flag beside a text label, or a flag on a region control that genuinely means a country.
- Source-language names shown **beside** endonyms (`Deutsch (German)`), which helps a reader who
  landed in the wrong locale.
- A homepage href where no equivalent page exists in the target locale, when the fallback is
  documented and the reader is told.
- Locale in the URL path with no cookie. The URL is a legitimate, shareable persistence mechanism.
- A route deliberately offered in one locale only, such as a country-specific legal page.

### Context Check

1. Which locales are served, and does the router resolve one per request at all? If it does not,
   that gap is the finding to lead with and the rest are symptoms.
2. What is the resolution order, precisely? Stored preference before URL before header before
   geography before default is the shape most of these rows are testing.
3. Is the geography signal a redirect or a suggestion? Only a forced redirect with no override
   reaches High.
4. Does persistence survive the boundaries this product actually has? A site with no login and no
   email has fewer boundaries to lose the locale at. And is the switcher's label list generated
   from locale data or hand-maintained? A hand-maintained map is where endonyms go missing.
5. Is a route missing in a locale because it was never translated, or because it does not apply
   there? The second is a product decision, not a gap. And is there a recorded `Decision` fixing
   the routing? If so the finding caps at Medium with the Fix "revisit or accept the trade-off".

### Severity

One tier per failure shape. `Critical` is not used in this category; it is reserved for Level A
accessibility failures that block a task.

- **High** — a forced geography redirect with no override, no persistence for an explicit choice,
  no switcher at all, flag-only or source-language option labels, a switcher that resets to the
  homepage, a `<select>` that navigates on change, a locale dropped at a redirect boundary,
  `<html lang>` not derived from the resolved locale.
- **Medium** — footer-only placement, missing `lang` / `hreflang` on switcher anchors, silent
  fallback for untranslated routes, error pages outside the locale system, a negotiated response
  cached with no `Vary`. Also the cap for a finding contradicting a recorded `Decision`.
- **Low** — language and region conflated in one control, and every finding on a single-locale
  site with no declared intent.

### Fix guidance

Resolve the locale once, in one place, in a stated order, and let the reader outrank every signal.

```js
// Before: geography decides, and the reader cannot argue with it.
export function middleware(req) {
  const country = req.headers.get('cf-ipcountry');
  return Response.redirect(new URL(`/${COUNTRY_TO_LOCALE[country] ?? 'en'}/`, req.url));
}

// After: one order of precedence, the reader's own choice first, geography only as a hint.
const SUPPORTED = ['en', 'de', 'ar', 'ja'];
export function middleware(req) {
  if (SUPPORTED.some(l => req.nextUrl.pathname.startsWith(`/${l}/`))) return;
  const stored     = req.cookies.get('locale')?.value;     // an explicit past choice
  const negotiated = matchAcceptLanguage(req.headers.get('accept-language'), SUPPORTED);
  const locale     = pick(stored, negotiated, 'en');       // geography never appears here
  const url        = req.nextUrl.clone();
  url.pathname     = `/${locale}${req.nextUrl.pathname}`;  // the path is preserved
  return Response.redirect(url);
}
```

```html
<!-- Before: a country stands in for a language, and nothing has a name. -->
<select onchange="location = this.value">
  <option value="/de/">🇩🇪</option><option value="/ar/">🇸🇦</option>
</select>

<!-- After: endonyms, real links, the current path preserved, the language announced. -->
<nav aria-label="Language">
  <a href="/de{{ currentPath }}" lang="de" hreflang="de">Deutsch</a>
  <a href="/ar{{ currentPath }}" lang="ar" hreflang="ar">العربية</a>
</nav>
```

Four rules make it hold. **One resolver**, called from one place, with the precedence written
where the next developer will read it. **The reader outranks the signals**: an explicit choice is
stored and checked before any header or geography, and geography at most raises a dismissible
suggestion. **The path is preserved** across a switch, and the homepage is a documented, announced
fallback only where no equivalent page exists. **Every boundary carries the locale**: auth
callbacks, payment returns and email links build their URLs from the same resolver, and any
negotiated response declares `Vary: Accept-Language` so a shared cache cannot hand one reader's
language to another.

Generate the option labels from locale display data rather than a hand-maintained map, so a new
locale arrives with its own endonym. Do not remove an existing geography suggestion as part of
this fix; convert it into a dismissible one and let the user confirm the change.

### Reference

- RFC 9110 section 12.5.4, Accept-Language, including the note that users are rarely familiar with
  the details of language matching and that sending complete linguistic preferences on every
  request can run against a user's privacy expectations; and section 12.5.5, `Vary`, the header
  that tells a shared cache which request fields selected the representation:
  https://www.rfc-editor.org/rfc/rfc9110.html
- BCP 47, the language-tag standard the switcher's `hreflang` and `lang` values come from
  (RFC 5646 for the tags, RFC 4647 for matching): https://www.rfc-editor.org/info/bcp47
- The `lang` global attribute and `hreflang` on links:
  https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/lang

Facts verified 2026-09-03 against rfc-editor.org and developer.mozilla.org.
