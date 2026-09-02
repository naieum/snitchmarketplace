## CATEGORY 8: Meta refresh anti-pattern

`<meta http-equiv="refresh" content="N;url=X">` is a client-side redirect mechanism dating to 1998. It works but Google treats it differently from HTTP 301, slower to honor, sometimes not honored at all, occasionally treated as a soft redirect (no link equity transfer). Modern correct pattern: HTTP 301 for permanent redirects, HTTP 307/308 for method preservation, JS-side `window.location` for runtime client-state-driven redirects.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<meta http-equiv="refresh"` and `<meta http-equiv='refresh'` and `httpEquiv="refresh"` (JSX) across the project.
2. For each match: `Read` the surrounding code, quote the meta tag's `content` attribute (the delay + target URL), and identify the route the tag appears on.
3. For "meta refresh as primary redirect" findings: cross-reference with Cat 6 (redirect chains), is there an HTTP-level redirect path that should replace the meta refresh?

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Parse `<head>` for `<meta http-equiv="refresh">`. Quote the element verbatim.
2. If found, fetch the `url=` value to confirm it resolves.
3. For "0-second meta refresh" findings: quote the `content` attribute showing `content="0;url=..."` (zero-second delay = essentially an immediate redirect, but client-side and worse than HTTP 301).

### Forbidden claims

- "Meta refresh might be in use." Grep / fetch and confirm.
- "The site probably uses meta refresh for old URL paths." Show me the meta tag.
- "Some pages use both meta refresh and HTTP redirects." Quote each page's signals.

### Detection

#### Source mode

- HTML templates: literal `<meta http-equiv="refresh" content="0;url=/new-page">`.
- JSX/TSX: `<meta httpEquiv="refresh" content="0;url=/new-page" />` (note `httpEquiv` camelCase).
- WordPress themes: occasionally in `header.php` for legacy redirects.
- Single-page splash pages, "click here if not redirected" pages, ancient migration leftovers.

#### Crawl mode

`Fetch` URL. Look for `<meta http-equiv="refresh">` in `<head>`. The element's presence is the signal.

### What to Search For

Literal strings:
- `http-equiv="refresh"`
- `http-equiv='refresh'`
- `httpEquiv="refresh"` (JSX)
- `httpEquiv='refresh'`
- `meta refresh`

### Actually Hurts SEO

- **Meta refresh used as primary redirect for an indexable URL**.
  Evidence required: the URL, the meta refresh tag, the target URL. The fix is "use HTTP 301 instead", quote both.
- **Meta refresh delay >0 seconds AND url= specified**.
  Evidence required: the `content` attribute quoted, showing `content="N;url=..."` where N>0. (Delayed refresh is a UX disaster, user sees the old page for N seconds then jumps. Indistinguishable from broken JS to many users.)
- **Meta refresh pointing at an external domain**.
  Evidence required: the meta refresh AND the target URL on a different host. (Often legitimate, affiliate-link cloaking, exit gateways, but should be documented and the host confirmed legitimate. Phishing pattern uses this exact mechanism.)
- **Meta refresh in addition to an HTTP 301 on the same response**.
  Evidence required: the response status 301 + Location header AND the meta refresh tag in the body. Conflicting signals; Google chooses one but the page is incoherent.

### NOT a Problem

- A "thank you" page after form submission that meta-refreshes to the homepage after 5 seconds with visible "Thanks! Redirecting..." text. UX-acceptable; not a SEO concern (the thank-you page is usually noindex'd).
- A maintenance page that meta-refreshes to itself every 60 seconds to check if maintenance is over. Operational pattern; not a SEO concern.
- Documentation pages with `<meta http-equiv="refresh" content="600">` (auto-reload to get fresh content every 10 min), non-standard but harmless.

### Context Check

1. Is the URL indexable? Meta refresh on a noindex'd page doesn't impact rankings.
2. Is there an HTTP-level redirect path available? If the site has Vercel / Netlify / Next.js redirects() / nginx access, meta refresh is unnecessary; HTTP 301 is strictly better.
3. Is the meta refresh present because the site can't set HTTP redirects (static hosting like GitHub Pages, S3 without CloudFront, basic shared hosting)? Then meta refresh is the only option; flag as Low and note the constraint.
4. Is the delay 0 seconds? Closer to acceptable than longer delays, but still slower-honored than HTTP 301.
5. Does the meta refresh point at another redirect? Could create a hybrid HTTP/HTML chain, particularly painful for crawlers.

### Reference

Google's documentation on redirects: https://developers.google.com/search/docs/crawling-indexing/301-redirects

W3C / WHATWG note on meta refresh accessibility issues: https://www.w3.org/TR/WCAG20-TECHS/F40.html

**Severity tagging:**
- Meta refresh as primary redirect on indexable URL → High.
- Meta refresh + HTTP 301 on same response (conflicting) → Medium.
- Meta refresh with delay >0 → Medium (UX cost).
- Meta refresh on noindex'd or non-indexable page → Low / Skip.

**Fix voice:** `solutions-architect` (primary) | `honest-design-critic` (backup, when the use case is clearly legacy and needs to be torn out).

Read `souls/solutions-architect.json` before writing the Fix. SA's voice: use the right protocol layer for the job. HTTP redirects belong at HTTP. Meta refresh belongs in 1998.

Worked fix example:

> Replace the meta refresh with an HTTP 301. The mechanism for telling clients "this URL has moved" is the response status, not a body element.
>
> ```ts
> // Next.js example, next.config.js
> module.exports = {
>   async redirects() {
>     return [
>       { source: '/old-page', destination: '/new-page', permanent: true },  // 308
>     ];
>   },
> };
> ```
>
> If the redirect target depends on runtime data (logged-in user, locale detection), do it server-side in the route handler with `Response.redirect(target, 301)`, not in the page body. Meta refresh is the wrong tool because it requires the browser to fully parse and render the response before honoring the redirect, by which point the user has seen the old page.
