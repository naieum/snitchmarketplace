# Custom Category Selection

Used by scan menu Option 8. The user picks categories by number or by name.

## Display this menu

```
Pick categories to scan. Comma-separated numbers, ranges, or names.

Examples:
  1,2,3              -> Cat 1, 2, 3
  1-8                -> all crawl & indexing
  31-38              -> all schema.org
  title,canonical    -> Cat 9, Cat 3
  schema             -> all schema.org categories (31-38)
  conversion         -> Cat 60
  perf               -> all performance categories (39-44)

[ enter selection ] >
```

## Name → category number mapping

The picker accepts either category number or a friendly alias. Map:

| Alias | Cat # | Group keywords |
|---|---|---|
| `robots` / `robots.txt` | 1 | crawl |
| `sitemap` / `sitemap.xml` | 2 | crawl |
| `canonical` | 3 | crawl, dup |
| `noindex` / `indexability` / `meta-robots` | 4 | crawl |
| `soft-404` / `404` | 5 | crawl |
| `redirects` / `redirect-chains` | 6 | crawl |
| `pagination` / `rel-prev-next` | 7 | crawl |
| `meta-refresh` | 8 | crawl |
| `title` / `title-tag` | 9 | meta |
| `meta-description` / `description` | 10 | meta |
| `og` / `open-graph` | 11 | meta, social |
| `twitter` / `twitter-card` | 12 | meta, social |
| `favicon` | 13 | meta |
| `manifest` / `web-manifest` | 14 | meta |
| `h1` / `single-h1` | 15 | structure |
| `headings` / `heading-hierarchy` | 16 | structure |
| `semantic-html` / `semantic` | 17 | structure |
| `thin-content` / `word-count` | 18 | content |
| `internal-links` / `link-graph` / `orphan` | 19 | links |
| `broken-links` / `broken-internal` | 20 | links |
| `anchor` / `anchor-text` | 21 | links |
| `breadcrumbs` / `breadcrumb-markup` | 22 | links, schema |
| `footer-spam` / `footer-links` | 23 | links |
| `external-links` / `nofollow` / `rel-attrs` | 24 | links |
| `alt` / `alt-text` / `image-alt` | 25 | images |
| `alt-quality` | 26 | images |
| `image-format` / `webp` / `avif` | 27 | images, perf |
| `image-dims` / `width-height` / `cls` | 28 | images, perf |
| `lazy-load` / `lazy-loading` | 29 | images, perf |
| `video-sitemap` / `videositemap` | 30 | media |
| `json-ld` / `jsonld` / `structured-data` | 31 | schema |
| `article-schema` / `article` | 32 | schema |
| `breadcrumb-schema` / `breadcrumblist` | 33 | schema |
| `product-schema` / `product` | 34 | schema |
| `faq-schema` / `faq` | 35 | schema |
| `howto-schema` / `howto` | 36 | schema |
| `org-schema` / `organization` / `website-schema` | 37 | schema |
| `video-schema` / `videoobject` | 38 | schema, media |
| `font-loading` / `font-display` | 39 | perf |
| `render-blocking` | 40 | perf |
| `critical-css` / `critical-path` | 41 | perf |
| `third-party-scripts` / `third-party` | 42 | perf |
| `image-weight` | 43 | perf, images |
| `bundle-weight` / `js-weight` | 44 | perf |
| `viewport` | 45 | mobile, a11y |
| `touch-targets` / `touch-target-size` | 46 | mobile, a11y |
| `text-zoom` / `readable-text` | 47 | mobile, a11y |
| `aria` / `aria-labels` | 48 | a11y |
| `contrast` / `color-contrast` | 49 | a11y |
| `hreflang` | 50 | i18n |
| `locale-canonical` / `locale-canonicals` | 51 | i18n |
| `lang-attr` / `html-lang` | 52 | i18n |
| `ga4` / `analytics` | 53 | analytics |
| `gtm` / `tag-manager` | 54 | analytics |
| `event-taxonomy` / `events` | 55 | analytics |
| `consent` / `consent-mode` / `cookie-banner` | 56 | analytics, privacy |
| `topical-depth` / `topic-depth` | 57 | content |
| `keyword-intent` / `intent` / `keyword-targeting` | 58 | content |
| `ai-content` / `ai-tells` / `slop` | 59 | content |
| `conversion` / `cta` / `trust-signals` | 60 | conversion |
| `email-inventory` / `email-list` / `transactional-list` | 61 | email |
| `email-content` / `email-copy` | 62 | email |
| `email-deliverability` / `spf` / `dkim` / `dmarc` | 63 | email, deliverability |
| `email-design` / `email-rendering` / `email-a11y` | 64 | email, a11y |
| `email-compliance` / `unsubscribe` / `can-spam` / `bulk-sender` | 65 | email, compliance |
| `paid-search` / `google-ads` / `bing-ads` / `ppc` | 66 | paid, off-site |
| `paid-social` / `meta-ads` / `linkedin-ads` / `tiktok-ads` | 67 | paid, off-site |
| `organic-social` / `social-presence` / `linkedin` / `twitter` | 68 | off-site |
| `backlinks` / `link-building` / `referring-domains` | 69 | off-site, seo |
| `content-strategy` / `editorial-cadence` / `blog-strategy` | 70 | off-site, content |
| `lifecycle-email` / `drip` / `newsletter-marketing` | 71 | off-site, email |
| `community` / `discord` / `slack-community` | 72 | off-site |
| `cro` / `conversion-rate` / `ab-test` / `funnel` | 73 | off-site |
| `reviews` / `testimonials` / `social-proof` / `nps` | 74 | off-site |
| `brand-consistency` / `cross-channel-brand` | 75 | off-site, brand |
| `partnerships` / `integrations` / `co-marketing` | 76 | off-site |
| `pr` / `launches` / `press` / `product-hunt` / `hacker-news` | 77 | off-site |
| `affiliate` / `referral-program` | 78 | off-site |
| `local-seo` / `google-business-profile` / `gbp` | 79 | off-site, local |
| `plg` / `product-led-growth` / `viral-loop` | 80 | off-site |
| `positioning` / `value-prop` / `differentiation` | 81 | off-site, brand |
| `ai-search` / `llm-citation` / `chatgpt-cite` / `perplexity` | 82 | 2026, off-site |
| `creator-partnerships` / `creator-marketing` / `mid-tier-influencer` | 83 | 2026, off-site |
| `founder-led` / `personal-brand` / `founder-channel` | 84 | 2026, off-site |
| `sponsorships` / `newsletter-sponsorship` / `podcast-sponsorship` | 85 | 2026, off-site |
| `keyword-research` / `keyword-strategy` / `intent-mapping` / `serp-clustering` / `query-research` | 86 | content, strategy |
| `recipe-schema` / `recipe` / `recipe-rich-result` | 87 | schema, food |
| `course-schema` / `course` / `online-course` | 88 | schema, education |
| `event-schema` / `event` / `event-rich-result` | 89 | schema, events |
| `jobposting-schema` / `job-posting` / `google-for-jobs` / `careers-schema` | 90 | schema, hiring |
| `softwareapplication-schema` / `app-schema` / `saas-schema` / `webapplication` | 91 | schema, saas |
| `localbusiness-schema` / `local-schema` / `nap-schema` | 92 | schema, local |
| `person-schema` / `author-schema` / `eeat-author` / `byline-schema` | 93 | schema, eeat |
| `review-schema` / `aggregate-rating` / `aggregaterating` / `rating-schema` | 94 | schema, reviews |
| `programmatic-seo` / `programmatic` / `templated-pages` / `pseo` | 95 | content, scale |
| `brand-serp-defense` / `brand-serp` / `branded-search-defense` | 96 | brand, off-site |
| `content-decay` / `content-refresh` / `content-pruning` / `content-audit` | 97 | content, lifecycle |
| `internal-site-search` / `site-search` / `search-analytics` | 98 | content, analytics |
| `conversion-funnel-deep` / `funnel-audit` / `journey-audit` / `funnel-walking` | 99 | conversion, journey |
| `cookieless-analytics` / `cookieless` / `server-side-tagging` / `capi` / `enhanced-conversions` / `consent-mode-v2` | 100 | analytics, future |
| `ai-agent-commerce` / `agent-shopping` / `agent-commerce` / `chatgpt-commerce` | 101 | commerce, future |
| `multi-llm-citation` / `per-llm-citation` / `llm-differentiation` | 102 | ai-search, future |
| `wcag22` / `wcag-conformance` / `accessibility-conformance` / `aa-conformance` | 103 | a11y, legal |
| `keyboard-navigation` / `keyboard-a11y` / `focus-management` | 104 | a11y |
| `screen-reader-semantics` / `screen-reader` / `aria-semantics` | 105 | a11y |
| `llms-txt` / `llms.txt` / `llmstxt` / `ai-crawler-file` | 106 | 2026, ai-search |
| `pixel-completeness` / `pixel-install` / `pixel-inventory` / `pixel-audit` / `capi-audit` | 107 | ads, measurement |
| `utm-hygiene` / `utm-consistency` / `utm-audit` / `parameter-hygiene` | 108 | ads, measurement |
| `message-match` / `landing-page-match` / `ad-lp-match` / `lp-message-match` | 109 | ads, conversion |
| `icp-scoring` / `icp-wedge` / `wedge-scoring` / `segment-scoring` | 110 | strategy, positioning |
| `trust-artifact` / `trust-audit` / `trust-strip` / `founder-face` | 111 | trust, conversion |
| `pricing-strategic` / `pricing-read` / `pricing-strategy` / `pricing-mix` | 112 | pricing, strategy |

## Group keywords

These expand to a list of categories:

| Keyword | Expands to |
|---|---|
| `crawl` | 1, 2, 3, 4, 5, 6, 7, 8 |
| `meta` | 9, 10, 11, 12, 13, 14 |
| `structure` | 15, 16, 17, 18 |
| `links` | 19, 20, 21, 22, 23, 24 |
| `images` | 25, 26, 27, 28, 29, 30 |
| `schema` | 31, 32, 33, 34, 35, 36, 37, 38, 87, 88, 89, 90, 91, 92, 93, 94 |
| `perf` | 39, 40, 41, 42, 43, 44 |
| `mobile` | 45, 46, 47 |
| `a11y` | 45, 46, 47, 48, 49 |
| `i18n` | 50, 51, 52 |
| `analytics` | 53, 54, 55, 56 |
| `content` | 18, 57, 58, 59, 86, 97 |
| `strategy` | 70, 81, 86, 95, 96, 110, 112 |
| `trust` | 60, 74, 84, 96, 111 |
| `pricing` | 60, 91, 112 |
| `positioning` | 81, 110 |
| `food` | 87 |
| `education` | 88 |
| `events` | 89 |
| `hiring` | 90 |
| `saas` | 91 |
| `eeat` | 93 |
| `reviews` | 74, 94 |
| `scale` | 95 |
| `lifecycle` | 71, 97 |
| `journey` | 73, 99 |
| `future` | 100, 101, 102 |
| `legal` | 103 |
| `commerce` | 34, 91, 94, 101 |
| `ai-search` | 82, 102 |
| `social` | 11, 12 |
| `conversion` | 60 |
| `dup` | 3, 6, 7, 51 |
| `email` | 61, 62, 63, 64, 65 |
| `deliverability` | 63, 65 |
| `compliance` | 56, 65 |
| `paid` | 66, 67 |
| `off-site` | 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85 |
| `2026` | 82, 83, 84, 85, 106 |
| `ads` | 66, 67, 78, 83, 85, 107, 108, 109 |
| `measurement` | 53, 54, 55, 56, 100, 107, 108 |
| `brand` | 75, 81, 84 |
| `local` | 79 |

## Parsing rules

- Comma separates items.
- Hyphen between numbers means a range, inclusive.
- A bare name (no number) is looked up in the alias table.
- A bare keyword from the group table expands to its categories.
- Mixed input is allowed: `1, schema, 60` → `[1, 31, 32, 33, 34, 35, 36, 37, 38, 60]`.
- Duplicate numbers across input are deduplicated.
- Numbers outside 1-112 are rejected with "Cat N is not a valid category. Run with no arguments to see the menu."
- Unknown names are rejected with "I don't recognize 'foo'. Use a number, or one of: {first 10 alias keywords}."
