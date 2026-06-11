## CATEGORY 6: Redirect chains

Each redirect adds latency, consumes crawl budget, and risks a chain breaking somewhere in the middle. Google follows up to 10 redirects but treats long chains as a quality signal. Two hops is acceptable; five hops is wasted bandwidth on every visit and crawl.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for redirect patterns: `redirect()`, `Response.redirect`, `res.redirect`, `308`, `307`, `301`, `302`, `Redirect`, `<meta http-equiv="refresh"`, rewrite rules in `vercel.json` / `netlify.toml` / `_redirects` / `next.config.js` / `nginx.conf` / `.htaccess`.
2. `Read` each match to determine the source URL and target URL pair.
3. Build a directed graph of redirects. Walk from each source forward, the chain length is the number of hops to reach a non-redirect destination.
4. Flag chains of 3+ hops AND any chain that loops back on itself (cycles).

**Crawl mode, required tool calls:**

1. `Fetch` the URL with redirect-following disabled. Quote the response status (3xx) and the `Location` header.
2. Recursively fetch the `Location` URL until you hit a non-3xx response or 10 hops.
3. Quote each hop in the chain: `URL → status → Location → ...`. The chain length is the finding.
4. For "redirect to noindex" findings: when the chain ends, fetch the final URL with redirect-following enabled and check meta robots / X-Robots-Tag. Quote.

### Forbidden claims

- "The site probably has redirect chains." Walk the chain and count. Quote each hop.
- "Some redirects may be 302 instead of 301." Show me the response status of each redirect.
- "Redirects to redirects might be wasting crawl budget." Quote the chain. State the hop count.

### Detection

#### Source mode

- **Next.js**: `redirects()` function in `next.config.js` returns array of `{ source, destination, permanent }`.
- **Vercel**: `vercel.json` `redirects` array.
- **Netlify**: `netlify.toml` `[[redirects]]` blocks OR `public/_redirects` file.
- **Cloudflare Workers**: `Response.redirect(url, status)` calls in handler code.
- **TanStack Start**: `redirect()` from `@tanstack/react-router` in route loaders.
- **Express**: `res.redirect(status, url)` calls.
- **WordPress**: `.htaccess` rewrite rules, `Redirection` plugin DB rules, theme `template_redirect` action.
- **Apache**: `.htaccess` `RewriteRule` and `Redirect` directives.
- **Nginx**: `rewrite` and `return 301 ...` directives in server blocks.

#### Crawl mode

`Fetch` the URL with `redirect: 'manual'` (don't auto-follow). Inspect the response status and `Location` header. If 3xx, fetch the `Location` value the same way. Recurse. Stop at non-3xx, at hop 10, or when a cycle is detected.

### What to Search For

Source patterns:
- `redirect(`
- `Response.redirect`
- `res.redirect`
- `return 301`, `return 302`, `return 307`, `return 308`
- `permanent: true` (Next.js redirect config)
- `<meta http-equiv="refresh"` (a soft / client-side redirect; see Cat 8 for that specifically)
- `RewriteRule`, `Redirect 301`, `RedirectPermanent` (Apache)
- `rewrite ^.*$ ... redirect` (Nginx)

### Actually Hurts SEO

- **Redirect chain of 3+ hops**.
  Evidence required: the full chain quoted (URL → status → Location → ...).
- **Redirect chain ending in a 404 or 410**.
  Evidence required: the chain quoted PLUS the final URL's response status.
- **Redirect cycle** (URL A → B → A or longer cycle).
  Evidence required: the cycle quoted with the repeating step highlighted.
- **302 (temporary) used for permanent redirects**.
  Evidence required: the redirect declaration AND a comment / pattern showing it's been in place for >30 days. (Or: the URL pattern suggests permanence, e.g., redirecting an old product slug to a new one.)
- **HTTPS redirect missing on the apex / www variant**.
  Evidence required: fetch http://example.com and quote the response. If not 301 to https, that's the finding.
- **www / apex split with no canonical redirect**.
  Evidence required: fetch both `www.example.com` and `example.com`, quote responses. If both serve content (no redirect between them), that's the finding.
- **Redirect from an indexable URL to a noindex URL**.
  Evidence required: chain + the final URL's robots meta.

### NOT a Problem

- Single-hop 301 (one redirect, sane). Standard pattern. Don't flag.
- 302 used during temporary maintenance with a clear "back soon" page. Intentional.
- Locale-detection redirects on the homepage (`/` → `/en` based on Accept-Language). Acceptable; some platforms recommend rendering the homepage instead, but it's not a critical issue.
- 307 / 308 used for method preservation (POST → POST through redirect). Required behavior; can't be 301.

### Context Check

1. Is the chain on a high-traffic URL? A 5-hop chain on a 404 page nobody visits is low-impact; a 5-hop chain on the homepage is bleeding milliseconds off every visit.
2. Are the intermediate hops cleanly resolvable? A chain that includes a 5xx response in the middle is broken in a way Google may handle worse than a clean 5-hop chain.
3. Did the redirects accumulate over multiple migrations? Pattern: `/old-blog/post → /blog/post → /articles/post → /content/post`. Common after multiple URL strategy changes. Fix by collapsing all the intermediate redirects to point straight at the final URL.
4. Is the redirect HTTP-level (301/302) or HTML-level (`<meta http-equiv="refresh">` or JS `window.location`)? HTTP-level is preferred; HTML-level is Cat 8.
5. Are www→apex (or vice versa) redirects in place? Without one, the site has two indexable hosts → duplicate content.

### Reference

Google's documentation on redirects: https://developers.google.com/search/docs/crawling-indexing/301-redirects

**Severity tagging:**
- Redirect cycle → Critical.
- Chain of 5+ hops → High.
- Chain of 3-4 hops → Medium.
- Chain ending in 404/5xx → Critical.
- 302 used for permanent redirect → Medium.
- Missing http→https redirect → Critical.
- www / apex split, no redirect between → Critical.

**Fix voice:** `performance-engineer` (primary) | `solutions-architect` (backup).

Read `souls/performance-engineer.json` before writing the Fix. Each redirect is a roundtrip. PerfEng's voice for "every byte and every hop costs you something measurable; collapse the chain."

Worked fix example:

> Each hop adds 50-300ms. A 4-hop chain that lands on the right URL is 200-1200ms of pure waste before any content arrives. Collapse the chain at its source.
>
> Walk the redirects backward from the final URL. For every intermediate hop, replace the source's redirect with one that points straight at the final destination.
>
> ```js
> // Before: redirect chain of 4
> // /old-blog/post → /blog/post → /articles/post → /content/post → page
>
> // After: collapsed
> '/old-blog/post': '/content/post'  // 1 hop
> '/blog/post': '/content/post'      // 1 hop
> '/articles/post': '/content/post'  // 1 hop
> ```
>
> Then add a CI check that exercises common entry URLs, fetches with `redirect: 'manual'`, and asserts the response is either 200 (no redirect needed) or a single 301 (one hop max). Catches new chains as they're introduced.
