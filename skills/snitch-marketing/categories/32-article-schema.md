## CATEGORY 32: Article schema

`Article` (and its subtypes `BlogPosting`, `NewsArticle`, `TechArticle`) is the most common schema.org type. It powers rich results on blog posts, articles, news. Required fields done correctly: byline, publish date, hero image, organization. Get it right and your blog posts become eligible for Top Stories, Discover, and richer SERP rendering.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify article-type pages (cross-reference Cat 31 page-type detection, look for `/blog/`, `/posts/`, `/articles/` URL patterns OR `<article>` semantic elements).
2. `Grep` for `Article`, `BlogPosting`, `NewsArticle`, `TechArticle` inside JSON-LD blocks. Quote each.
3. For each Article schema: parse the JSON. Check required fields: `headline`, `image`, `datePublished`, `author`, `publisher`.
4. For "missing Article schema on a blog post" findings: confirm the page IS a blog post (URL pattern + `<article>` element) AND no schema is present.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Find JSON-LD blocks. Parse.
2. Look for Article-flavored schema. Quote the entire object.
3. Check required fields. Quote any missing.

### Forbidden claims

- "Article schema is probably missing." Confirm the page is article-type AND parse for the schema.
- "The headline may not match the title." Quote both.

### Detection

Looking for `Article`, `BlogPosting`, `NewsArticle`, `TechArticle`, `ScholarlyArticle` types in JSON-LD blocks on article-shaped pages.

### What to Search For

- `"@type": "Article"`, `"@type": "BlogPosting"`, `"@type": "NewsArticle"`, `"@type": "TechArticle"`
- Required fields: `headline`, `image`, `datePublished`, `dateModified`, `author`, `publisher`

### Actually Hurts SEO

- **Article-type page with no Article schema**.
  Evidence required: URL pattern + `<article>` element + missing schema.
- **Article schema missing required fields** (`headline`, `image`, `datePublished`).
  Evidence required: parsed schema with field absent.
- **`headline` >110 characters** (Google truncates rich-result rendering).
  Evidence required: quoted headline + char count.
- **`image` field as relative URL or 404**.
  Evidence required: image URL + fetch status.
- **`author` field as plain string instead of structured `Person` / `Organization`**.
  Evidence required: parsed `author` value.
- **`datePublished` in the future** (data error or pre-publication artifact).
  Evidence required: quoted date + current date comparison.

### NOT a Problem

- Article subtype confusion (using `BlogPosting` instead of `Article`). Both are accepted.
- `dateModified` missing (only `datePublished`). Acceptable; dateModified is recommended for freshness signals but not required.
- Author as string (works for legacy data), flag as Low and recommend upgrading.

### Context Check

1. Is the page actually an article? Don't flag missing Article schema on listing / index / category pages.
2. Is the schema rendered server-side? Client-side schema injection may not be seen by Google's initial render.
3. Does the page have multiple Article schema blocks? One is correct; multiple is confusing.
4. Is the `image` field a 1200x630 image suitable for Top Stories? Smaller images don't qualify.

### Reference

Google's Article documentation: https://developers.google.com/search/docs/appearance/structured-data/article

Schema.org Article: https://schema.org/Article

**Severity tagging:**
- Article-type page with no Article schema → High.
- Required fields missing → High.
- `headline` too long → Medium.
- `image` 404 → Critical.
- Future `datePublished` → High.

**Fix voice:** `frank-chimero` (primary) | `jen-simmons` (backup).

Read `souls/frank-chimero.json` before writing the Fix. Frank's writing/structure POV: an article has metadata that makes it findable; the schema is just that metadata, made explicit.

Worked fix example:

> Every blog post deserves an Article schema block. The required fields aren't decorative; they're the difference between Google understanding the post is a 2026 piece by Eric Waters about CVE-2026-3854 vs. a generic blob of HTML.
>
> ```tsx
> const articleSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'BlogPosting',
>   headline: post.title,
>   image: [post.heroImage],
>   datePublished: post.publishedAt,
>   dateModified: post.updatedAt,
>   author: {
>     '@type': 'Person',
>     name: post.author.name,
>     url: post.author.profileUrl,
>   },
>   publisher: {
>     '@type': 'Organization',
>     name: 'Snitch',
>     logo: { '@type': 'ImageObject', url: 'https://snitchplugin.com/logo.png' },
>   },
> };
> ```
>
> All fields are derived from the same data the page renders, no schema/page divergence is possible. JSON.stringify the whole object and inject as JSON-LD in the head. Done.
