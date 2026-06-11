## CATEGORY 4: Indexability (noindex / nofollow / nosnippet)

`<meta name="robots">` and the `X-Robots-Tag` HTTP header tell crawlers per-page what to do: index it or not, follow links or not, show snippets or not. The single most common production catastrophe in SEO is shipping a `noindex` from staging to prod and not noticing for weeks.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `noindex`, `nofollow`, `nosnippet`, `noarchive`, `noimageindex` across the project. Quote each match with file:line.
2. `Grep` for `name="robots"` and `name='robots'` and `metadata.robots` (Next.js shape). Quote each.
3. For each match: `Read` the surrounding 30 lines to determine if the directive is conditional (env-based, route-based, header-based) or unconditional.
4. For "noindex shipped to production" findings: confirm the directive is NOT gated on a staging/dev env var. Quote the surrounding conditional logic OR confirm none exists.
5. Cross-reference against the route table (Glob route files) to identify which URLs the directive applies to.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Quote the `<meta name="robots">` element from the response head (or quote its absence).
2. Quote the `X-Robots-Tag` response header (or quote that it's not present).
3. For "noindex on a commercial route" findings: verify the URL is a route the user expects to rank by checking the sitemap (does the sitemap list it? then they want it indexed). Cross-reference with Cat 2 evidence.

### Forbidden claims

- "The page is probably noindex'd." Quote the meta tag or the X-Robots-Tag header. Either it says noindex or it doesn't.
- "Many pages may have stale noindex from staging." Enumerate. Quote each affected URL.
- "The meta robots is probably wrong." Show me the directive AND show me what you think it should be.
- "Google might be ignoring this page." Either fetch the URL and find the noindex signal, or check Google Search Console (out of scope for source/crawl audit). Don't speculate.

### Detection

#### Source mode

- **Next.js App Router**: `metadata.robots: { index: false, follow: false }` in layout/page exports OR `generateMetadata` returns. The boolean form maps to `noindex, nofollow`.
- **Next.js Pages Router**: `<meta name="robots" content="noindex" />` inside `<Head>` from `next/head`.
- **TanStack Start**: `head: () => ({ meta: [{ name: 'robots', content: 'noindex' }] })`.
- **Astro**: `<meta name="robots" content={isStaging ? 'noindex' : 'index'} />` is a common pattern; check for env-conditional logic.
- **Remix**: `meta` export returning `[{ name: 'robots', content: '...' }]`.
- **WordPress**: theme `header.php` OR Yoast / RankMath per-post overrides (postmeta `_yoast_wpseo_meta-robots-noindex` or `rank_math_robots`).
- **Cloudflare Workers / Express middleware**: `response.headers.set('X-Robots-Tag', 'noindex')` in middleware. Easy to set globally and forget.

#### Crawl mode

`Fetch` the URL. Inspect:
- `<meta name="robots" content="...">` in `<head>`
- `<meta name="googlebot" content="...">` (Google-specific overrides)
- `X-Robots-Tag` response header (case-insensitive header name)

A noindex anywhere on the page (head OR header OR Googlebot-specific meta) takes effect. The most-restrictive directive wins.

### What to Search For

Literal strings:

- `noindex`
- `nofollow`
- `nosnippet`
- `noarchive`
- `noimageindex`
- `name="robots"`
- `name='robots'`
- `name="googlebot"`
- `X-Robots-Tag`
- `metadata.robots:`
- `robots: {` (Next.js metadata shape)

### Actually Hurts SEO

- **`noindex` on a route the site needs to rank.**
  Evidence required: the meta tag / header value AND confirmation the route is in the sitemap (cross-reference Cat 2) OR linked from primary navigation.
- **Site-wide `noindex` shipped from staging.**
  Evidence required: the directive AND no env-conditional logic gating it. Quote the full surrounding context.
- **`noindex` on a parent layout that cascades to child pages unintentionally.**
  Evidence required: parent layout's `metadata.robots` declaration AND the child route's lack of override AND the rendered cascade behavior.
- **`X-Robots-Tag: noindex` set in middleware globally.**
  Evidence required: the middleware code that sets the header AND a Fetch of any production URL showing the header in the response.
- **`nofollow` on internal links to important content.**
  Evidence required: the meta tag (`<meta name="robots" content="nofollow">`), this stops Google from following ANY internal link from the page, not just nofollow'd individual links. Different from per-link `rel=nofollow` (Cat 24).
- **`noindex` AND `canonical` pointing at a different page**, conflicting signals that Google may handle unpredictably.
  Evidence required: both directives quoted from the same page.

### NOT a Problem

- `noindex` on admin / dashboard / login routes. Intentional and correct.
- `noindex` on search-result pages / faceted filters. Intentional; prevents index bloat.
- `noindex` on staging / preview environments (verified by hostname or env var). Required, not a finding.
- `noindex` on thank-you / confirmation pages after form submission. Intentional.
- `nosnippet` on premium / paywalled content. Intentional (publisher wants users to click through to read).

### Context Check

1. Is the route in the sitemap? If yes, the user wants it indexed; noindex is a finding. If no, noindex is probably intentional.
2. Is the directive env-conditional? Read the surrounding code. `if (process.env.STAGING) noindex` is correct; bare `noindex` in a layout is not.
3. Does the route serve sensitive / unfinished content? Many CMSes mark unpublished posts as noindex by default. That's correct.
4. Is there a global middleware setting `X-Robots-Tag`? That overrides per-page meta tags. Most-restrictive wins.
5. Is the canonical pointing somewhere else AND the page is noindex'd? The canonical signal is wasted; pick one strategy.
6. WordPress: is "Discourage search engines" checked in Settings → Reading? That sets noindex globally and is the #1 cause of "the site disappeared from Google."

### Reference

Google's documentation on robots meta and X-Robots-Tag: https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag

**Severity tagging:**
- Site-wide noindex on production → Critical.
- Noindex on a primary commercial route (sitemap-listed) → Critical.
- Noindex on a layout cascading to child routes unintentionally → Critical.
- X-Robots-Tag: noindex in global middleware → Critical.
- Nofollow on the meta robots blocking internal linkflow → High.
- Noindex + canonical conflict → Medium.
- Other noindex misconfigurations → Medium / Low based on impact.

**Fix voice:** `solutions-architect` (primary) | `security-engineer` (backup, when the fix is about architectural separation of staging vs prod).

Read `souls/solutions-architect.json` before writing the Fix. SA's voice for "the system's behavior must derive from the system's environment, not from a developer's last edit."

Worked fix example:

> The cause is almost always one of two patterns: (a) a hardcoded `noindex` left from staging, or (b) a global middleware setting `X-Robots-Tag` without env-gating. Both fix the same way, make indexability a function of environment, not a literal.
>
> ```ts
> // Bad: hardcoded
> metadata = { robots: { index: false } };
>
> // Good: env-gated
> const isProduction = process.env.VERCEL_ENV === 'production';
> metadata = { robots: { index: isProduction, follow: isProduction } };
> ```
>
> Then add a smoke test to CI that fetches the production homepage post-deploy and asserts the response does NOT contain `noindex`. This is a one-line test that prevents the most catastrophic SEO regression.
