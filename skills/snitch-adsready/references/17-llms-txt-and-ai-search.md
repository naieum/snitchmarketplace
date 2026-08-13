# 17 — llms.txt + AI search readiness

Read when prepping for AI Overviews, ChatGPT search, Perplexity, You.com, Brave Summarizer, or other LLM-driven traffic sources.

**ChatGPT is also an ad channel now** (sponsored cards in responses, self-serve OpenAI Ads
Manager since May 2026, contextual matching against the search index). That makes AI-search
readiness ad readiness: a site `OAI-SearchBot` can't crawl is invisible to both the organic
answers and the ad-matching layer. Full picture in `references/platforms/openai.md`; the
`state site <url> robots` slice reports per-agent crawler verdicts under `crawler_access`.

## llms.txt

`/llms.txt` is a public proposal for a markdown index of your site optimized for LLM crawlers. Place at the apex root with `Content-Type: text/markdown`.

```markdown
# Site Name

> One-line description of what the site is and who it serves.

## Key pages

- [Pricing](https://example.com/pricing): How the product is priced
- [Docs](https://example.com/docs): Reference documentation
- [Blog](https://example.com/blog): Latest writeups
- [Contact](https://example.com/contact): How to reach us

## Optional

- [Changelog](https://example.com/changelog): Recent changes
- [FAQ](https://example.com/faq): Common questions

## llms-full.txt

For a full-text concatenated version of all docs, see [llms-full.txt](https://example.com/llms-full.txt).
```

`llms-full.txt` (optional) contains full content of important pages concatenated as plain markdown. LLMs ingest it in a single fetch.

Adoption: not yet a Google / Anthropic / OpenAI standard, but Perplexity, Cursor, Codeium read it. Cheap to ship.

## What AI Overviews actually use

Google's AI Overviews surface from the same index that powers traditional SERP. Optimization shifts:

| Signal | Weight in AI Overviews vs SERP |
|---|---|
| Structured data (JSON-LD) | HIGHER — AI extracts entities directly |
| Direct answer in first paragraph | HIGHER — AI Overviews quote the lead |
| Lists + tables in content | HIGHER — easy to extract |
| FAQ schema with concise answers | MUCH HIGHER — direct ingestion path |
| HowTo schema | HIGHER (despite SERP deprecation) |
| Author bylines + bio | HIGHER for YMYL content (E-E-A-T) |
| Page speed / CWV | SAME |
| Backlinks | SAME or LOWER |

Practical: write content with a clear thesis in the first paragraph, ship FAQ + Article schema, use lists/tables for extractable answers.

## ChatGPT, Claude, Perplexity, Brave AI

Each has its own crawler:

| Service | User-Agent prefix | Notes |
|---|---|---|
| ChatGPT browse | `ChatGPT-User`, `OAI-SearchBot` | Honors `robots.txt` |
| Claude (Anthropic) | `ClaudeBot`, `Claude-Web`, `Claude-User` | Honors `robots.txt` |
| Perplexity | `PerplexityBot`, `Perplexity-User` | Honors `robots.txt` |
| Brave AI | `Brave/Summarizer-Bot` | Honors `robots.txt` |
| Common Crawl | `CCBot` | Used by many LLM training sets |

To allow them, ensure `/robots.txt` doesn't disallow them.

```
# robots.txt
User-agent: *
Allow: /

User-agent: GPTBot
Disallow: /private/

User-agent: ClaudeBot
Allow: /

User-agent: CCBot
Disallow: /private/
```

## AI search citation strategy

1. **Be the canonical source on a narrow query.** Generic SaaS marketing pages don't cite well.
2. **Ship structured data.** Article + FAQ + HowTo + Product schema.
3. **Don't gate cited content behind email walls.** AI crawlers can't get past forms.
4. **Use clean HTML semantics.** `<article>`, `<section>`, `<h1>`/`<h2>` hierarchy.
5. **Set `rel="canonical"` correctly.** Duplicates dilute citation.
6. **Write for question-answer extractability.** Section headings should match likely user questions.

## Local businesses: profile-side AI visibility

For a local business, AI-recommendation visibility is mostly **off-site**: assistants answering "best plumber near me" draw on the Bing index (Copilot, ChatGPT search) and high-trust directory corpora (Yelp, BBB) more than on the business's own website. Claiming free listing profiles — Bing Places, Yelp, BBB — is therefore an AI-search-readiness move on par with anything in this file. Run `recommend listings` for the goal-sorted catalog; the picking guide is in `references/recommendations/listings.md`.

## Audit signals

- `/robots.txt` accessibility and bot allowlist.
- `/llms.txt` presence (🟡 WARN if missing — not yet required).
- `/sitemap.xml` validity.
- Structured-data coverage (in `state site <url> structured-data`).
- `<meta name="robots">` accidentally `noindex`.

## See also

- `07-structured-data.md` — schema coverage.
- llms.txt spec: https://llmstxt.org/
- Google AI Overviews: https://developers.google.com/search/docs/appearance/ai-features
