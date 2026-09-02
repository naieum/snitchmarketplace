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

Article, BlogPosting, NewsArticle, Organization, WebSite, BreadcrumbList, author E-E-A-T
signals, and rich-result eligibility are evidenced against search, not against an ad platform:
**call the Skill tool with "snitch-marketing"**. The only schema this skill emits is
`Product`/`Offer` as a shopping-feed input (`07-structured-data.md`), which a content site
usually has no use for — Skip it with that reason.

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

## AI crawler access

For a content site the ads-side question is narrow: can the ChatGPT retrieval agent fetch the
articles, and is that a deliberate choice? `17-ai-crawler-access.md` covers it. Content
structure, citation strategy, and llms.txt are a search surface — **call the Skill tool with
"snitch-marketing"**.

## Common blog-specific failures

| Symptom | Cause |
|---|---|
| AdSense earnings dropped suddenly | ads.txt missing / wrong; or low ad-viewability flagged |
| Newsletter signups not in GA4 | Embedded form (Substack, ConvertKit) iframes; tracking lives in vendor's analytics |
| Affiliate clicks not tracked | Outbound link tracking not wired; link-shortener intercepting |
| CWV scores tanking on article pages | New ad-network rotation introduced heavy JS |

## Honest framing

For ad-funded content sites, the audit priority is:

1. **ads.txt** (revenue floor)
2. **Search and schema coverage** (snitch-marketing owns it)
3. **CWV** (ranking + ad viewability)
4. **Newsletter capture pixel + CAPI** (only if running paid acquisition)
5. **AI crawler access** (the ChatGPT retrieval and ad-matching surface)

Less priority: 10-platform pixel coverage. Most blogs run ads to monetize; they don't run paid ads to acquire users. Most platforms in the 10-platform suite are N/A unless the blog also runs paid email-list acquisition.
