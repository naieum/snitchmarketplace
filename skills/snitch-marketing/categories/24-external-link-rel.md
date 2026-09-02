## CATEGORY 24: External link rel attributes (nofollow / sponsored / ugc)

When you link to an external site, the `rel` attribute tells Google how to treat the link: editorial endorsement (default), paid placement (`sponsored`), user-generated content (`ugc`), or no endorsement (`nofollow`). Getting this wrong is a Google policy violation that can demote the entire site.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for external link patterns: `<a href="http://`, `<a href="https://`, `target="_blank"`, `rel="noopener"`, `rel="nofollow"`, `rel="sponsored"`, `rel="ugc"`. Quote each match.
2. For each external link: identify if it's editorial (in body content), affiliate / sponsored (in a "partners" section, dedicated affiliate page), user-generated (comments, forum posts), or navigational (footer "powered by" link).
3. Confirm the rel attribute matches the link's nature.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Find external `<a>` elements. Quote each with its rel attribute.
2. Check `target="_blank"` links for `rel="noopener"` (security).

### Forbidden claims

- "Some links may be missing rel attributes." Quote them.
- "Affiliate links probably aren't marked sponsored." Show which links go to affiliate networks.

### Detection

#### Source mode

Extract external links + their rel attributes. Heuristics for classification:

- Links to known affiliate networks (Amazon Associates, ShareASale, ClickBank, Impact) → should be `rel="sponsored"`.
- Links inside comment / forum / review components → should be `rel="ugc"`.
- Links inside disclaimer-flavored copy ("This post may contain affiliate links") → should be `sponsored`.
- Links to social media profiles in footer → typically `rel="me"` (linking the brand to itself); not problematic.
- Links to vendors / partners on a "Partners" page → may be `sponsored` (paid) or editorial (genuine).

#### Crawl mode

Parse external links + rel attributes.

### What to Search For

- `target="_blank"` (for opener-attack security)
- `rel="nofollow"`, `rel='nofollow'`
- `rel="sponsored"`, `rel='sponsored'`
- `rel="ugc"`, `rel='ugc'`
- `rel="noopener"`, `rel="noreferrer"`
- Affiliate-network domain patterns: `amzn.to`, `amazon.com/dp`, `shareasale.com`, `impact.com`

### Actually Hurts SEO

- **Affiliate / paid link without `rel="sponsored"`**.
  Evidence required: link target (affiliate network domain) + missing rel attribute.
- **User-generated content links without `rel="ugc"`** (forum posts, blog comments, reviews).
  Evidence required: link inside a UGC component + missing rel.
- **Massive external linking from sidebar / footer to commercial partners** (sitewide partner spam).
  Evidence required: link count + targets pattern.
- **`target="_blank"` without `rel="noopener"`** (security: tabnabbing).
  Evidence required: link with `target="_blank"` + no `noopener`. (Modern browsers default to noopener for `_blank`, so this is less critical now, but worth flagging.)

### NOT a Problem

- Editorial external links (you wrote about a tool and linked to it because it's relevant) without rel, that's the default and correct.
- `rel="noopener noreferrer"` on `_blank` links, security best practice; not a SEO concern.
- `rel="external"` (semantic, not a Google directive), harmless.
- `rel="me"` on links to your own social profiles, establishes authorship; correct.

### Context Check

1. Are the external links editorial (you chose to link) or commercial (someone paid you / you earn affiliate)? The distinction determines rel.
2. Is there a global disclosure ("This post contains affiliate links") covering the page? Disclosure helps for FTC compliance but doesn't replace `rel="sponsored"` for Google.
3. Are the links inside a comment system? UGC; rel="ugc" required (or noindex the comment region entirely).
4. Are external links opening in new tab? Add `rel="noopener"` for security regardless of SEO.

### Reference

Google on rel attributes: https://developers.google.com/search/docs/crawling-indexing/qualify-outbound-links

**Severity tagging:**
- Affiliate links without sponsored rel → Critical (Google policy violation).
- UGC links without ugc rel → High.
- Sitewide partner spam → High.
- `_blank` without `noopener` → Medium (security; less critical with modern browsers).

**Fix voice:** `honest-design-critic` (primary) | `security-engineer` (backup).

Read `souls/honest-design-critic.json` before writing the Fix. Accountability: be honest about what links are, who paid for what, what your site endorses.

Worked fix example:

> If somebody paid you for the link, mark it `sponsored`. If a user wrote it, mark it `ugc`. If you don't endorse the target but you're including the link for context, mark it `nofollow`. Otherwise, leave it alone, that's an editorial endorsement, which is what links should be.
>
> ```tsx
> // Affiliate link: paid relationship
> <a href="https://amzn.to/xyz" rel="sponsored noopener" target="_blank">
>   The book on Amazon
> </a>
>
> // User comment link: UGC
> <a href={comment.url} rel="ugc noopener" target="_blank">
>   {comment.urlText}
> </a>
>
> // Editorial link: no rel needed
> <a href="https://example.com" target="_blank" rel="noopener">
>   Example
> </a>
> ```
>
> The rel attribute isn't decoration. It's how the search engine knows what to do with the link, and it's how you stay honest about your business.
