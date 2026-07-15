## CATEGORY 69: Backlink profile + link-building

In 2026 the value of links has shifted. Google's classic ranking weight on backlinks is reduced (algorithm matured, AI overviews answering many queries). The new primary value of inbound links is **AI-search citation**, LLMs (ChatGPT, Perplexity, Claude, Gemini) weight authoritative inbound links + Wikipedia-tier mentions when deciding which sources to cite in answers. Cross-reference Cat 82.

Backlinks still matter for commercial-intent SERP ranking (the queries that survive AI-overview displacement) and for AI-citation signal. Audit identifies: who links to the site, anchor diversity, toxic links, competitor gap.

### Pre-flight: brand maturity check

Confirm STEP 0.6 classified backlink presence as `minimal` or `established`. If `none` (branded-name search returns zero third-party mentions; domain age <90d), **Skip** with reason `no detectable inbound links; brand needs to earn first mentions before backlink audit is meaningful, see STEP 5 recommendations`. Don't run Evidence Required.

### Evidence required (do not skip, only when maturity is `minimal`+)

**Crawl mode, required tool calls:**

1. Without paid SEO tools (Ahrefs / Semrush / Moz API), the full referring-domain profile is incomplete. Acceptable partial sources:
   - **Common Crawl coverage proxy (free, no key):** `python3 {skill_dir}/scripts/commoncrawl_backlinks.py <domain> --competitor <competitor-domain>` returns a crawl-coverage size/authority proxy (NOT a referring-domain list). Read `references/backlink-commoncrawl.md` for how to report it honestly and the heavier web-graph authority path.
   - `Bash curl -s "https://www.google.com/search?q=%22<brand-name>%22"`, free signal of which domains mention the brand (the modern replacement for the dead `link:` operator)
   - A Google Search Console **Links** export, if the user has GSC for the property: free, and the only first-party view of links Google attributes to the site
   - Check Wayback Machine (https://web.archive.org/) for an inbound-link archive (slow, partial)
2. If Ahrefs / Semrush / Moz API is available (BYO-key, only when the user provides it), pull top 20 referring domains.
3. Outcome: if the Common Crawl coverage proxy or a GSC Links export returns data, report it (the coverage proxy labeled as a coverage proxy per `references/backlink-commoncrawl.md`) alongside any branded-mention signal. Mark the **referring-domain / anchor-text / toxic-link** portion as **Skip** with reason `requires Ahrefs/Semrush/Moz API access or a GSC Links export` unless the user provides that data. Never claim profile shape from a coverage proxy alone.

**Source mode, required tool calls:**

1. Largely irrelevant, backlinks are external by definition. Source-mode scope is limited to: outbound link reciprocity audit (do you link back to sites that link to you), partnership-page completeness.

### Forbidden claims

- "The site probably has a thin backlink profile." Without data, you can't claim profile shape. Mark Skip.
- "Competitor X has more backlinks." Without comparable data on both, don't claim.

### Detection

A free Common Crawl coverage proxy plus branded-mention search give a partial signal on every applicable run (see `references/backlink-commoncrawl.md`); the full referring-domain profile (who links in, anchor distribution, toxic links, lost links) still needs a paid index or a GSC Links export.

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

Free Common Crawl coverage + authority method (no key): `references/backlink-commoncrawl.md`

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
