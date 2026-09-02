## CATEGORY 69: Backlink profile + link-building

The value of links has shifted. Google's classic ranking weight on backlinks is reduced (algorithm matured, AI overviews answering many queries). The new primary value of inbound links is **AI-search citation**, LLMs (ChatGPT, Perplexity, Claude, Gemini) weight authoritative inbound links + Wikipedia-tier mentions when deciding which sources to cite in answers. Cross-reference Cat 82.

Backlinks still matter for commercial-intent SERP ranking (the queries that survive AI-overview displacement) and for AI-citation signal. Audit identifies: who links to the site, anchor diversity, toxic links, competitor gap.

### Pre-flight: brand maturity check

Confirm STEP 0.6 classified backlink presence as `minimal` or `established`. If `none` (branded-name search returns zero third-party mentions; domain age <90d), **Skip** with reason `no detectable inbound links; brand needs to earn first mentions before backlink audit is meaningful, see STEP 4 recommendations`. Don't run Evidence Required.

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

A free Common Crawl coverage proxy plus branded-mention search give a partial signal on every applicable run (see `references/backlink-commoncrawl.md`); the full referring-domain profile (who links in, anchor distribution, toxic links, lost links) still needs a paid index or a GSC Links export. Two per-link quality checks need no index at all: a linking site's outbound dofollow/nofollow ratio and a referring page's external-link count are both readable from the live page. The traffic-cliff penalty check needs a traffic-estimate source (paid index, or the linking site owner's own data — usually unavailable, so mark it Skip rather than guess).

### What to Search For

When data is available:
- Top 20 referring domains by third-party authority score — **triage view, not quality verdict**. Authority scores are third-party metrics, and link equity flows at the page level, not the domain level. Their legitimate uses: evidence a site has earned followed links at all, and a bulk first-pass filter when triaging many domains (removes more bad than good). Always pair the score with the domain's organic-traffic trend before drawing conclusions: high authority score + near-zero traffic = probable penalty or devaluation.
- Anchor text distribution (branded vs partial-match vs exact-match vs generic)
- Toxic link patterns (link farms, PBNs, Russian / Chinese spam domains, paid link networks). Production outreach SOPs exclude prospects by URL footprint; the same footprints classify toxic links: hosted-blog subdomains (blogspot and kin), .ru / .pw TLDs, gambling / adult domains, path footprints like `/forum/` and `/job/`.
- Lost links (links that existed previously and are gone). Related pattern: anchors that read like an old page title usually mean the link flows through a redirect from a renamed or acquired page — still passing equity, but contextually stale, and a ready-made recovery / outreach pool.
- Competitor gap (referring domains they have that this site doesn't)

**Per-link quality rubric** — vet an existing link or an outreach prospect with seven questions. Effort-allocation guidelines, not hard pass/fail gates; requiring all seven shrinks any pool too far:

1. Is the **site** topically relevant to the niche? A random personal blog linking a running-shoes page fails this.
2. Is the **page** relevant, even when the site is broad? Page relevance trumps site relevance for mega-publications: a business-news page entirely about running shoes counts, an economics op-ed linking the same target doesn't. For local businesses add **locational** relevance: links from same-city vendors and local lifestyle blogs carry weight generic ones don't.
3. Does the domain carry a third-party **authority score**? Use it only as evidence the site has earned followed links, and as a bulk filter — never gate exclusively on it; a link from a weak-but-growing site appreciates.
4. Does the **site** get consistent Google traffic? A traffic-history cliff (steady traffic, then near zero after a known core-update date) signals a penalty or devaluation. Links on such hosts may pass nothing, and a link-selling penalty can't be ruled out.
5. Does the linking **page** get search traffic? Proves the page is in Google's good books and adds referral-traffic upside.
6. Are most of the site's **external links nofollowed**? A predominantly-nofollow outbound profile means a placement there passes no equity. Checkable with no paid index: inspect the external links in-page, or use a link index's linked-domains view.
7. Does the page **link out to too many pages**? Equity splits across external links; a resource page with ~1,000 outbound links is near-worthless. Sort referring pages (or prospects) by external-link count.

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
- **Referring domains with a traffic-history cliff** (high third-party authority score but organic traffic collapsed to near zero after a core-update date = penalized or devalued host; equity from those links is suspect, and a link-selling penalty can't be ruled out).
  Evidence required: domain traffic-history curve showing the cliff, alongside the authority score for contrast.
- **Equity parked on placements that pass nothing** (guest posts / mentions on sites whose external links are predominantly nofollowed; listings on resource pages with hundreds of outbound links diluting each one to near-zero).
  Evidence required: the host's outbound dofollow/nofollow ratio, or the referring page's external-link count.

### NOT a Problem

- Low backlink count on a new / pre-launch site. Time + content earn links.
- Few branded anchors when most links are organic mentions in articles. Natural.
- Internal-network links (your own subdomains linking to each other). Don't count, don't worry.

### Context Check

1. Does the site have content worth linking to (depth, original research, useful tools)? Concretely: people link for four recurring reasons — to cite a statistic or support a claim, to reference something they don't want to explain themselves, to make themselves look credible, or because a relationship exists. If nothing on the site serves one of those reasons *for someone else*, outreach will convert near zero. Informational content (how-tos, data studies, free tools) earns links far more easily than commercial pages, where the only beneficiary of the link is the site itself.
2. Has the team done outreach? Most backlinks come from explicit ask, not magic. And was the content designed for it — linkable points (the specific stats / claims / angles people cite) built in before publication, informed by how competing pages earned their links — or was outreach bolted on after the fact?
3. Is the niche link-friendly (B2B / SaaS / OSS) or link-poor (e-commerce / local services)?
4. Are there obvious link-bait opportunities (free tools, original data, opinionated takes)? Discovery method: linkable assets often target topics with no search volume, so keyword research never surfaces them — search a broad niche term in a content index and filter for pages with many referring domains (≥100) but low organic traffic (≤~1,000/mo, subdomains excluded). That isolates assets that earned links on appeal alone; an outdated one (stale data) is an opening. Ego-bait assets (curated lists or awards portraying niche entities positively) give every named entity a credibility reason to link back.

### Reference

Ahrefs Backlinks 101: https://ahrefs.com/blog/what-are-backlinks/

Google's quality guidelines on links: https://developers.google.com/search/docs/essentials/spam-policies#link-spam

Free Common Crawl coverage + authority method (no key): `references/backlink-commoncrawl.md`

**Severity tagging:**
- Toxic link clusters → High (disavow recommended).
- Heavy exact-match anchor concentration → High (manipulation signal).
- Significant lost links → Medium (recoverable).
- Competitor gap on quality referring domains → Medium.
- Referring domains with a traffic-history cliff → Medium (equity suspect; note it, don't panic-disavow unless the host is also spammy).
- Placements on nofollow-only hosts or heavily diluted pages → Low (no equity passed; informational — redirect future outreach effort).

**Fix guidance — earning links (use this instead of a vague "do outreach"):**

- **Prospecting pipeline: seed → footprint → lookalike → segment.** A seed prospect is a page that linked to a competing page for one identifiable reason. Find seeds in the competitor's anchor-text summary, not the raw backlink list: skip post-title, naked-URL, and branded anchors (not replicable); a frequently repeated *specific* anchor marks a linkable point. Extract its footprint — the shared textual mark (a statistic, a phrase, a listicle-title shape) — then expand into lookalike prospects by searching the footprint across backlink anchors + surrounding text, title-restricted web search (`intitle:` operators work in plain Google), or phrase-match full-text search. Segment by linkable point (one email template per segment), never by metric bands; the prospect count per segment sizes the campaign *before* effort is spent.
- **Vet in levels sized to the list.** (1) Metric cut: third-party authority score + domain organic traffic — removes more bad prospects than good, but never a sole gate. (2) Relevance scan of referring-page titles; drop irrelevant and other-language pages. (3) Pitch-angle validation: confirm each prospect page still contains the footprint the email references — a crawler in list mode with a custom text-contains search covers hundreds of URLs in minutes, no paid index needed.
- **Pitch the person who can actually add the link.** Tracked outreach campaigns report roughly equal link acquisition from authors and editors (~7.5% each), about half that from generic inboxes (contact@ / support@), and far less from other titles like content marketing managers and webmasters (practitioner-reported campaign numbers, not benchmarks). Guest-post pitches go to whoever approves guest writers (editor / head of content); edits to an existing post go to the author or editor.
- **Pilot before scaling.** Run the programmatically findable contacts first: an author-finder plus email verification across the vetted list yields valid addresses for roughly 6–12% of prospects in minutes; that blitz batch's conversion rate validates or kills the campaign before anyone invests in manual contact-finding for the remainder. Tracked campaigns report segment-personalized outreach at volume acquiring links at roughly 5–12%; unsegmented blasts burn sender reputation and land links on sites nobody wants. Write the email to one real prospect as if to a friend, then extract the merge fields — under segment personalization, often only the name varies. Frame the value proposition around impact on the prospect *and their audience* (safety, accuracy, freshness of what they published), never around the asker. Never contact a personal address unless it's published on their site.
- **Warm prospects first.** Unlinked brand mentions and pages embedding the site's owned media (videos, tools, images) have already demonstrated intent — pitch the fuller resource; practitioners report these convert well above cold outreach. Check both canonical and embed URL variants of owned media, they collect separate link pools.

**Fix voice:** `honest-design-critic` (primary) | `indie-commerce-founder` (backup, when fix is "stop trying to game; build a thing worth linking to").

Read `souls/honest-design-critic.json` before writing the Fix.

Worked fix example:

> Stop buying links. Stop guest-posting on garbage networks for the link in the bio. The whole game is rigged against shortcuts now and Google catches them.
>
> Build a thing worth linking to. Original research, a free tool that solves a problem people have, an opinionated piece that names something nobody else will. Then ask the people who already cited similar work to look at yours. That's link-building. Everything else is link spam dressed in a suit.
>
> Recovery first: pull the lost-links list from Ahrefs / Semrush (you'll need the data). For each lost link, email the site owner: "I noticed you used to link to us at <URL>. Here's what's there now if you want to update / restore." Conversion rate is real; one in five often replies.
>
> When you do ask, ask a human who can actually touch the page — the author or the editor, not the contact@ inbox. And pilot the pitch before you scale it: send it to the contacts you can find programmatically first. If that batch converts, scale. If it doesn't, the angle is dead and you just saved yourself a month of pretending otherwise.
