## CATEGORY 106: llms.txt (AI-crawler-friendly site description)

`llms.txt` is the emerging AI-crawler convention proposed by Jeremy Howard in 2024 and adopted by an accelerating share of AI-aware sites in 2025-2026. It's a top-level markdown file at `/llms.txt` that describes the site, names the canonical resources, and (optionally via `/llms-full.txt`) provides full content text in a format AI crawlers can ingest cleanly. Where `robots.txt` (Cat 1) governs crawler access and `sitemap.xml` (Cat 2) governs URL inventory, `llms.txt` governs how AI assistants understand and cite the brand.

This category is the standalone audit of `llms.txt`, its presence, format, content quality, and the relationship between `llms.txt` and `llms-full.txt`. Cat 82 (AI-search citation) cross-references this category for the discoverability layer.

### Evidence-based posture

`llms.txt` is worth publishing — it's a one-file, low-cost map — but be honest about what it does. No major AI assistant has published that it uses `llms.txt` to decide citations, and prominent search engineers have stated they don't consume it for ranking. Independent 2026 industry AEO research corroborates the posture bluntly: no major LLM provider officially supports the file — OpenAI doesn't use it, Anthropic publishes one on its own site but hasn't confirmed its crawlers read it, and Google hasn't adopted it; `robots.txt` remains the file that actually governs access. Treat `llms.txt` as a courtesy map for crawlers that choose to read it, not a citation guarantee. The load-bearing AI-citation levers are crawler access (Cat 1 + `references/ai-crawler-registry.md`), extractable structure, and genuine authority (Cat 82 Layers 2-3). Calibrate findings accordingly: a missing file is Medium at most; a malformed-but-present file or one pointing at dead URLs is the more defensible finding, because it actively misleads the crawlers that do read it.

### Pre-flight: relevance check

Skip with reason `not applicable` only if the brand has explicitly opted out of AI-crawler indexing (rare; would be visible as `User-agent: GPTBot Disallow: /` etc. in `robots.txt`). Otherwise: in scope — but apply the evidence-based posture above before assigning severity. Never tag a missing `llms.txt` higher than Medium.

### Evidence required (do not skip)

**Crawl mode, required tool calls:**

1. `Fetch {origin}/llms.txt`, quote the response (200 + body, OR 404).
2. `Fetch {origin}/llms-full.txt`, quote the response (200 + body, OR 404). The full variant is optional; presence of `/llms.txt` without `/llms-full.txt` is acceptable.
3. If `/llms.txt` returns 200, validate the format per spec:
   - Starts with `# {Brand name}` H1
   - Followed by a blockquote (`>`) one-paragraph summary
   - Optional H2 sections grouping links (`## Docs`, `## Categories`, `## Blog`, etc.)
   - Each link in the form `- [Title](URL): one-line description`
4. Cross-reference linked URLs in `/llms.txt`, do they resolve (200) and represent the canonical resources for those topics?
5. Check `robots.txt` (Cat 1) for AI-crawler rules across the full fleet (see `references/ai-crawler-registry.md`), not just the well-known few. The `llms.txt` file is meaningless if the AI crawlers are blocked — and the training-bot vs live-retrieval-bot distinction in the registry determines which block actually matters here.

**Source mode, required tool calls:**

1. `Glob` `**/llms.txt`, `**/llms-full.txt`. Quote location.
2. If found, validate format same as crawl mode.
3. Check the build pipeline, is `llms.txt` regenerated from a single source of truth (the same data feeding the homepage hero, the docs index, the blog index)? Or is it a hand-maintained file likely to drift?
4. Check whether `/llms-full.txt` is regenerated on content changes (CI / build hook), drift-prone otherwise.

### Forbidden claims

- "The site is probably missing llms.txt." Run the fetch.
- "llms.txt may be outdated." Quote the file content + show the current canonical resources.
- "Format may not match spec." Quote the file + name the spec deviation.

### Detection

Looking for `/llms.txt` and optionally `/llms-full.txt` at the site root, with valid markdown structure.

### What to Search For

- `/llms.txt` 200 response
- `/llms-full.txt` 200 response (optional)
- Markdown structure: H1, blockquote summary, H2 sections, link list
- Linked URLs that resolve and represent canonical resources
- `robots.txt` AI-crawler permissions matching the `llms.txt` intent

### Actually Hurts the Marketing Surface

- **No `/llms.txt` file** (returns 404).
  Evidence required: `Fetch /llms.txt` returning 404.
- **`/llms.txt` returns wrong content type** (e.g., HTML 200 from a SPA fallback instead of markdown).
  Evidence required: response Content-Type + body.
- **`/llms.txt` file format invalid** (no H1, no summary, no link sections, just prose blob).
  Evidence required: file content + spec deviation.
- **Linked URLs in `/llms.txt` 404 or are stale** (the file points at deprecated docs / removed blog posts).
  Evidence required: each linked URL + fetch result.
- **`/llms.txt` doesn't match the brand's actual canonical resources** (file lists 3 docs sections; site has 12, selection criteria opaque or outdated).
  Evidence required: file's link inventory + visible site structure.
- **`/llms-full.txt` drift** (the file exists but contains content from 6 months ago; the site has shipped 8 new posts since).
  Evidence required: `llms-full.txt` content date markers + current site content date markers.
- **`robots.txt` blocks AI crawlers despite publishing `/llms.txt`** (mixed signal, crawlers can't reach the file or the site).
  Evidence required: `robots.txt` `Disallow` rule + `/llms.txt` presence.
- **Brand voice / positioning in `/llms.txt` summary doesn't match the homepage** (the file's one-paragraph summary contradicts what the site says about itself).
  Evidence required: quote both summaries.
- **`/llms.txt` is hand-maintained** with a single source of truth elsewhere (homepage hero copy, docs index), drift is inevitable.
  Evidence required: file is static text; no build pipeline regenerates it.

### NOT a Problem

- `/llms.txt` exists with a clean format, accurate links, fresh content, correct.
- `/llms-full.txt` absent when `/llms.txt` is present, `/llms-full.txt` is optional polish.
- `/llms.txt` redirected to `/llms` (no `.txt`) on a site with friendly URLs, acceptable if the redirect is 301 and the destination is a `text/markdown` response.
- A small marketing brand's `/llms.txt` has only 3-5 links, appropriate to the brand's actual surface size.

### Context Check

1. Has the team published `llms.txt` AND continues to update it on content changes? Stale `llms.txt` is worse than absent.
2. Is `llms.txt` generated from the same source of truth as the homepage hero / docs index? If hand-maintained, it will drift.
3. Does the `llms.txt` summary match the brand's actual positioning (Cat 81)?
4. Are AI crawlers actually allowed in `robots.txt`? `llms.txt` is meaningless without crawler access.
5. If `/llms-full.txt` is published, is it kept fresh on content changes? Stale full-text variant is worse than absent.

### Reference

llms.txt convention spec: https://llmstxt.org

Jeremy Howard's introduction post: https://llmstxt.org/

Live `/llms.txt` examples worth modeling on: Anthropic, Cloudflare, Vercel, Stripe Press

Cat 82 (AI-search citation), the broader framework `llms.txt` lives within (Layer 1: Discoverability)

Cat 1 (robots.txt), must permit AI crawlers for `llms.txt` to function

**Severity tagging:**

- No `/llms.txt` on a site that wants AI citation → Medium (advisory; structured-content matters more than the file alone).
- `/llms.txt` returns wrong content type → High (the file exists but isn't readable as intended).
- `/llms.txt` format invalid → High (crawlers may skip a malformed file).
- Linked URLs 404 or stale → High (sends crawlers to dead resources; trust signal degraded).
- `/llms-full.txt` drift → Medium.
- `robots.txt` blocks AI crawlers despite published `/llms.txt` → Critical (contradiction; crawlers can't reach anything).
- Brand voice mismatch between `/llms.txt` and homepage → Medium.
- Hand-maintained `/llms.txt` with no build pipeline → Low (advisory; flag drift risk).

**Fix voice:** `jen-simmons` (primary) | `frank-chimero` (backup).

Read `souls/jen-simmons.json` before writing the Fix.

Worked fix example:

> `llms.txt` is the equivalent of a `robots.txt` for the AI era, a hint at the root of the site that tells AI crawlers what your brand is, what your canonical resources are, and where the substance lives. Like all hints on the web, the value comes from honesty and freshness; a stale or fabricated `/llms.txt` is worse than no file at all.
>
> Build it from a single source of truth.
>
> ```ts
> // src/lib/llms-txt.ts, generated at build time
> import { brand } from "./brand";
> import { docs } from "./docs-index";
> import { posts } from "./posts-index";
>
> export function generateLLMsTxt() {
>   return [
>     `# ${brand.name}`,
>     ``,
>     `> ${brand.oneLineSummary}`,
>     ``,
>     `## Docs`,
>     ...docs.canonical.map(d => `- [${d.title}](${d.url}): ${d.summary}`),
>     ``,
>     `## Recent posts`,
>     ...posts.recent.slice(0, 10).map(p => `- [${p.title}](${p.url}): ${p.summary}`),
>     ``,
>     `## Get in touch`,
>     `- [Contact](${brand.contactUrl})`,
>   ].join("\n");
> }
> ```
>
> Serve it as `text/markdown; charset=utf-8` from `/llms.txt`. Regenerate on every content deploy, same lifecycle as your sitemap. The file is short on purpose; the AI crawler that wants depth follows the links. The file's job is to be a reliable map, not a brochure.
>
> If you publish `/llms-full.txt` too: it's the same map, but each link's destination content is inlined as markdown. Larger payload, but eliminates the crawler's need to follow each link individually. Useful for brands with stable, slow-moving canonical content (docs sites, well-curated blogs); risky for fast-moving sites where the file will drift.
>
> Then check `robots.txt` (Cat 1) and confirm AI crawlers are allowed. The `llms.txt` file is a contract; the contract requires both parties, the crawler must be permitted to read it, and the file must accurately reflect the site.
