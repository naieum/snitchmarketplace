# Vertical — Blog on AWS

## Architecture

- Static SSG (Hugo, Astro, Eleventy, Jekyll, Hexo) → S3 + CloudFront.
- Comments: third-party (Disqus, Giscus) — don't roll your own.
- Search: client-side (lunr / Pagefind) for static; OpenSearch Serverless if dynamic.
- RSS / sitemap: emit at build time.

## Hardening

- WAFv2 unnecessary unless there's an admin/CMS path; if so, IP-restrict it.
- DNSSEC via Route 53; HSTS via security-headers CloudFront Function.

## When NOT AWS

Personal blog with <1k MAU: GitHub Pages / Cloudflare Pages / Netlify is cheaper and simpler. Don't overarchitect.
