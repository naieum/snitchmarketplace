## CATEGORY 69: Backlink profile + link-building

In 2026 the value of links has shifted. Google's classic ranking weight on backlinks is reduced (algorithm matured, AI overviews answering many queries). The new primary value of inbound links is **AI-search citation**, LLMs (ChatGPT, Perplexity, Claude, Gemini) weight authoritative inbound links + Wikipedia-tier mentions when deciding which sources to cite in answers. Cross-reference Cat 82.

Backlinks still matter for commercial-intent SERP ranking (the queries that survive AI-overview displacement) and for AI-citation signal. Audit identifies: who links to the site, anchor diversity, toxic links, competitor gap.

### Pre-flight: brand maturity check

Confirm STEP 0.6 classified backlink presence as `minimal` or `established`. If `none` (branded-name search returns zero third-party mentions; domain age <90d), **Skip** with reason `no detectable inbound links; brand needs to earn first mentions before backlink audit is meaningful, see STEP 5 recommendations`. Don't run Evidence Required.

### Evidence required (do not skip, only when maturity is `minimal`+)

**Crawl mode, required tool calls:**

1. Without paid SEO tools (Ahrefs / Semrush / Moz API), backlink data is incomplete. Acceptable partial sources:
   - `Bash curl -s "https://www.google.com/search?q=link:<domain>"`, limited but free signal of indexed mentions
   - Search for `"<brand-name>"` in quotes; identify which domains mention the brand
   - Check Wayback Machine (https://web.archive.org/) for inbound-link archive (slow, partial)
2. If Ahrefs / Semrush API is available (BYO-key per Plugin Pro tier, out of scope for v1 unless user provides), pull top 20 referring domains.
3. Mark category outcome as **Skip** with reason `backlink data requires Ahrefs/Semrush/Moz API access; partial signals only available without it` UNLESS the user explicitly provides API access.

**Source mode, required tool calls:**

1. Largely irrelevant, backlinks are external by definition. Source-mode scope is limited to: outbound link reciprocity audit (do you link back to sites that link to you), partnership-page completeness.

### Forbidden claims

- "The site probably has a thin backlink profile." Without data, you can't claim profile shape. Mark Skip.
- "Competitor X has more backlinks." Without comparable data on both, don't claim.

### Detection

External tool dependent; without API access, this category is mostly Skip + recommendation to get the data.

### What to Search For

When data is available:
- Top 20 referring domains by domain authority
- Anchor text distribution (branded vs partial-match vs exact-match vs generic)
- Toxic link patterns (link farms, PBNs, Russian / Chinese spam domains, paid link networks)
- Lost links (links that existed previously and are gone)
- Competitor gap (referring domains they have that this site doesn't)

### Actually Hurts the Marketing Surface

When data is available:

- **Heavy concentration of exact-match anchor text** ("buy AI security tool" pointing here from 50 different sites = looks like paid link manipulation).
  Evidence required: anchor distribution table.
- **Toxic links from spam domains** (foreign-language spam, .ru/.cn link-farm domains, gambling/adult sites).
  Evidence required: domain list + spam classification.
- **Lost authoritative links** (a TechCrunch article linked previously, link removed in redesign, recoverable via outreach).
  Evidence required: comparison of historical vs current link.
- **Competitor referring-domain gap** (they're linked from 200 sites, you're linked from 30).
  Evidence required: comparable count.

### NOT a Problem

- Low backlink count on a new / pre-launch site. Time + content earn links.
- Few branded anchors when most links are organic mentions in articles. Natural.
- Internal-network links (your own subdomains linking to each other). Don't count, don't worry.

### Context Check

1. Does the site have content worth linking to (depth, original research, useful tools)?
2. Has the team done outreach? Most backlinks come from explicit ask, not magic.
3. Is the niche link-friendly (B2B / SaaS / OSS) or link-poor (e-commerce / local services)?
4. Are there obvious link-bait opportunities (free tools, original data, opinionated takes)?

### Reference

Ahrefs Backlinks 101: https://ahrefs.com/blog/what-are-backlinks/

Google's quality guidelines on links: https://developers.google.com/search/docs/essentials/spam-policies#link-spam

**Severity tagging:**
- Toxic link clusters → High (disavow recommended).
- Heavy exact-match anchor concentration → High (manipulation signal).
- Significant lost links → Medium (recoverable).
- Competitor gap on quality referring domains → Medium.

**Fix voice:** `mike-monteiro` (primary) | `sahil-lavingia` (backup, when fix is "stop trying to game; build a thing worth linking to").

Read `souls/mike-monteiro.json` before writing the Fix.

Worked fix example:

> Stop buying links. Stop guest-posting on garbage networks for the link in the bio. The whole game is rigged against shortcuts now and Google catches them.
>
> Build a thing worth linking to. Original research, a free tool that solves a problem people have, an opinionated piece that names something nobody else will. Then ask the people who already cited similar work to look at yours. That's link-building. Everything else is link spam dressed in a suit.
>
> Recovery first: pull the lost-links list from Ahrefs / Semrush (you'll need the data). For each lost link, email the site owner: "I noticed you used to link to us at <URL>. Here's what's there now if you want to update / restore." Conversion rate is real; one in five often replies.
