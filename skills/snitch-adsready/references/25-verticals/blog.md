# 25 — Vertical: blog / publication / content site

A content-driven site whose primary goal is reach, engagement, and ad / affiliate revenue. Examples: news, magazine, niche blog, content agency, media company.

If the site SELLS something at the end, it's actually ecommerce or SaaS — see those guides.

## Standard event suite

| Funnel stage | Event |
|---|---|
| Article view | `page_view` + scroll-depth events (25%, 50%, 75%, 100%) |
| Share | `share` per platform |
| Newsletter signup | `subscribe` / `Lead` |
| Comment | custom `comment` |
| Outbound link click | custom `click` |
| Affiliate click | `select_promotion` |

For ad-funded blogs, "conversions" are usually subscribers and engagement events, not purchases. Optimize Meta / TikTok ads on `Subscribe`; optimize Google Discover for organic traffic.

## Schema.org

Required:
- `Organization` (root)
- `WebSite`
- `BreadcrumbList`
- `BlogPosting` (each post) OR `NewsArticle` (journalism only) OR `Article` (general)
- `Person` (author byline)
- `ImageObject` (hero images)

Required article fields:
- `headline` (under 110 chars for Google rich results)
- `image` (1×1, 4×3, 16×9 variants — `templates/structured-data/article.starter.json` ships these)
- `datePublished` / `dateModified` (ISO 8601 with timezone)
- `author.name` + `author.url`
- `publisher` linked to `@id` of root Organization
- `mainEntityOfPage`
- `articleSection`
- `inLanguage`

For Google News inclusion: register your domain in Publisher Center.

## ads.txt is REQUIRED for ad-monetized blogs

If you run AdSense or any programmatic display, `/ads.txt` is mandatory. Without it, programmatic demand drops 20-40%. See `08-ads-txt.md` and `templates/ads-txt-entries.template.txt`.

## CWV is doubly important

1. Ads stack on top of articles. Each ad slot = additional CLS + INP risk.
2. Search Google traffic is massive. Google Discover uses CWV as a ranking signal.

Tactics:
- Reserve fixed dimensions for every ad slot (`min-height`).
- Lazy-load below-the-fold ad slots.
- Don't auto-refresh ads on viewable; tanks INP.
- Hero image: AVIF/WebP, `priority`, explicit dimensions.
- Comments: lazy-load Disqus / Commento; don't render on first paint.

## AI Overviews / AI search are HUGE for blogs

LLM-driven traffic is the next decade's organic. Optimize:

1. First paragraph contains direct answer to the headline question.
2. Ship FAQ schema for question-formatted content.
3. Ship HowTo schema for tutorials.
4. Ship Article schema with author E-E-A-T signals.
5. Don't gate meaty content behind email walls — AI can't extract from a form.
6. Use `<article><section>` semantic HTML.

See `17-llms-txt-and-ai-search.md` for `/llms.txt` setup.

## Common blog-specific failures

| Symptom | Cause |
|---|---|
| AdSense earnings dropped suddenly | ads.txt missing / wrong; or low ad-viewability flagged |
| Newsletter signups not in GA4 | Embedded form (Substack, ConvertKit) iframes; tracking lives in vendor's analytics |
| Affiliate clicks not tracked | Outbound link tracking not wired; link-shortener intercepting |
| Article schema invalid | Missing `image` array, or `datePublished` not ISO format |
| CWV scores tanking on article pages | New ad-network rotation introduced heavy JS |

## Honest framing

For ad-funded content sites, the audit priority is:

1. **ads.txt** (revenue floor)
2. **Schema.org Article + FAQ** (SERP visibility)
3. **CWV** (ranking + ad viewability)
4. **Newsletter capture pixel + CAPI** (only if running paid acquisition)
5. **AI search readiness** (next-decade traffic)

Less priority: 10-platform pixel coverage. Most blogs run ads to monetize; they don't run paid ads to acquire users. Most platforms in the 10-platform suite are N/A unless the blog also runs paid email-list acquisition.
