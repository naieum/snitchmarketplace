## CATEGORY 54: GTM hygiene

Google Tag Manager containers accumulate cruft: stale tags from old vendors, paused tags that still load, duplicate trigger fires, debug snippets shipped to prod. Each tag is JS execution and a third-party request.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `googletagmanager.com/gtm.js`, `<script>` containing GTM container ID. Quote.
2. Note: GTM container contents are managed in the GTM UI, not in source. Source-mode audit is limited to: is GTM installed, where, with what container ID.

**Crawl mode, required tool calls:**

1. `Fetch` URL. List GTM container loads. Quote container ID.
2. Note: actual GTM tag inventory requires GTM UI access, out of scope for this skill. Document in the report that full audit needs GTM access.

### Forbidden claims

- "GTM probably has stale tags." Without access to the GTM UI, this can't be claimed from source.
- "Tags may be misconfigured." Same.

### Detection

GTM container snippet in source / rendered HTML.

### What to Search For

- `googletagmanager.com/gtm.js?id=GTM-`
- `<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-`

### Actually Hurts SEO

(Indirect: GTM weight + execution time impacts perf, which impacts SEO. This category is mostly informational.)

- **Multiple GTM containers loaded on same page** (test container + prod container).
  Evidence required: count of GTM container script tags.
- **GTM container ID hardcoded with no env separation** (test container in prod).
  Evidence required: container ID + env-detection logic showing none.
- **GTM noscript iframe missing** (visitors with JS disabled don't fire any tags, partial loss for paranoid analytics).
  Evidence required: GTM script present + noscript fallback absent.

### NOT a Problem

- Single GTM install with proper noscript fallback. Standard.
- GTM env-conditional load (different container per env).

### Context Check

1. Is GTM the team's tag management approach? If yes, audit matters.
2. Does the team have access to the GTM UI? They should.
3. Is GTM gated by consent?

### Reference

GTM developer docs: https://developers.google.com/tag-platform/tag-manager

**Severity tagging:**
- Multiple GTM containers on one page → High.
- Test container in prod → Critical.
- GTM noscript fallback missing → Low.

**Fix voice:** `analytics-engineer` (primary) | `security-engineer` (backup).

Worked fix example:

> Container hygiene is a quarterly task: list every tag in GTM, prove each one is still earning its keep, kill what isn't. Tags accumulate; cleanup keeps the page light.
>
> Source-side: one container, env-conditional, with noscript fallback.
>
> ```html
> <!-- GTM in head -->
> <script>
>   const gtmId = process.env.NODE_ENV === 'production' ? 'GTM-XXXXXXX' : 'GTM-YYYYYYY';
>   // ... gtm snippet using gtmId ...
> </script>
>
> <!-- noscript fallback in body -->
> <noscript>
>   <iframe src="https://www.googletagmanager.com/ns.html?id=GTM-XXXXXXX" height="0" width="0" style="display:none"></iframe>
> </noscript>
> ```
>
> The actual tag audit happens in the GTM UI: list tags, list triggers, find paused / unused / duplicate, archive them. Aim for the smallest set of tags that captures the data the team actually uses.
