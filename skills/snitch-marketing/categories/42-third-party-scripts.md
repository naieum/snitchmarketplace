## CATEGORY 42: Third-party script audit

Every third-party script (analytics, ads, A/B testing, chat widgets, social embeds, error tracking) is a perf hit AND a supply-chain risk. The hosting third party can change the script at any time; if they're compromised, you ship malware. The script also blocks the main thread, eats bandwidth, and tracks users.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<script src="https://`, `<script src='https://` to find external scripts. Quote each + the source domain.
2. Count distinct third-party domains.
3. For each: identify purpose (analytics, ads, etc.) and whether the script is async/defer.

**Crawl mode, required tool calls:**

1. `Fetch` URL. List all `<script src>` elements pointing at external domains. Quote.
2. Optionally check the third-party script's response Content-Length to estimate weight.

### Forbidden claims

- "Many third-party scripts may be loaded." Count and quote.
- "Some scripts may be unnecessary." Identify which by purpose.

### Detection

External script source URLs in HTML.

### What to Search For

- `<script src="https://` patterns
- Common third-party domains: `googletagmanager.com`, `google-analytics.com`, `facebook.net`, `hotjar.com`, `mixpanel.com`, `segment.com`, `intercom.io`, `drift.com`, `chatwoot.com`

### Actually Hurts SEO

- **>10 third-party scripts on the page**.
  Evidence required: count + list.
- **Synchronous third-party script in head (blocks paint)**.
  Evidence required: script tag without async/defer.
- **Multiple analytics tools** (GA4 + Mixpanel + Amplitude on same page, pick one).
  Evidence required: list with overlap.
- **Chat widget loading on every page** (heavy script for a feature few visitors use).
  Evidence required: script + page-volume data showing overall traffic vs chat usage.

### NOT a Problem

- Single analytics provider, async-loaded.
- Error tracking (Sentry, Rollbar), small footprint, important for production.
- Native lazy-loaded video embeds (YouTube `<iframe loading="lazy">`).

### Context Check

1. Is each third-party script earning its weight? Audit ROI per script.
2. Is the chat widget activated on user interaction (deferred until click)?
3. Are the scripts gated by consent (GDPR / CCPA)? Should be.
4. Does the page have a Performance Observer or RUM tracking how much these scripts cost?

### Reference

Web.dev on third-party scripts: https://web.dev/articles/optimizing-content-efficiency-loading-third-party-javascript

**Severity tagging:**
- >10 third-party scripts → High.
- Sync third-party in head → High.
- Multiple overlapping analytics → Medium.

**Fix voice:** `security-engineer` (primary) | `performance-engineer` (backup).

Read `souls/security-engineer.json` before writing the Fix. SecEng's voice on third-party scripts: every URL you allow in is a trust boundary you've extended.

Worked fix example:

> Every third-party script on your page can change tomorrow. The vendor gets compromised, the script changes, you ship the change to your users with no warning. Audit them like dependencies.
>
> ```js
> // Step 1: inventory
> const scripts = [
>   { src: 'https://www.googletagmanager.com/gtm.js?id=GTM-XXXXX', purpose: 'analytics + tag mgmt', weight: '50KB' },
>   { src: 'https://widget.intercom.io/widget/abc', purpose: 'chat', weight: '180KB' },
>   { src: 'https://www.googletagmanager.com/gtag/js?id=G-XXXX', purpose: 'GA4 (duplicate of GTM)', weight: '30KB' },
> ];
>
> // Step 2: cut what doesn't earn weight
> // - Drop the standalone GA4 (GTM already loads it)
> // - Lazy-load Intercom on first interaction (saves 180KB on initial load)
>
> // Step 3: subresource integrity for what's left
> <script src="…" integrity="sha384-…" crossorigin="anonymous" async></script>
> ```
>
> Add `Subresource Integrity` (SRI) hashes where the third party publishes them. Lock the script content; any change tomorrow breaks the load (better than silently shipping the change).
