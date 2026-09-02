## CATEGORY 76: Partner & sponsorship program attribution

Four programs the brand can run with someone else's audience — integration partnerships, affiliate / referral, creator deals, newsletter and podcast sponsorships — share one audit shape. For each: does the program exist, is there a surface a partner can find and act on, and is the traffic it sends attributable when it arrives? Whether the brand *should* run a given program, and how to recruit for it, is strategy, not audit — that lives in snitch-cmo.

### Pre-flight: program relevance

If brand maturity is `none` everywhere AND no partners, affiliates, creators, or sponsorships exist yet, **Skip** with reason `no partner or sponsorship programs yet; reassess once brand maturity is at least minimal`. Some brands legitimately don't run these (early stage, standalone single-purpose product, low LTV that can't support payouts, enterprise sales where attribution runs through the CRM). Skip the program types that don't fit and say which, rather than emitting a finding for each absent one.

### Program types

Each row is audited the same way: presence, the partner-facing surface, the attribution mechanism, and whether the terms a partner needs are actually stated.

| Program type | Presence signal | Partner-facing surface | Attribution mechanism |
|---|---|---|---|
| **Partnership / integration** | `/integrations`, `/partners`, `/marketplace`, `/ecosystem` routes; partner OAuth or webhook routes (`api/oauth/<partner>`, `api/webhooks/<partner>`); a public API or extension surface partners could build on | A per-partner page that says what the integration does and how to turn it on | The brand's listing in the partner's own directory; a co-marketing landing page whose URL is distinguishable |
| **Affiliate / referral** | `/affiliate`, `/referral`, `/refer-friend` routes; affiliate-platform scripts or subdomains; a per-account referral link in the product | A public page stating commission, cookie window, payout schedule and prohibited promotions — not "contact us" | `?ref=`, `?aff=`, `?via=`, `?invitation=` and platform-specific params, handled server-side and persisted to the signup record |
| **Creator** | `/creators`, `/ambassadors` pages; per-creator discount codes in the checkout handler; organic creator mentions of the brand | A page a creator can apply through, or the affiliate program with named codes | Per-creator code or `utm_source=<creator-handle>`; the code resolved to a creator in source, not in a spreadsheet |
| **Newsletter / podcast sponsorship** | Vanity routes named after a show or publication; per-show discount codes; sponsorship landing pages | A landing page per show that names the show | Vanity URL (`/<show-name>`) or per-show code, with the route actually existing and resolving |

### Evidence required (do not skip, only when the program type is in scope)

**Source mode, required tool calls:**

1. `Grep` for the routes in the Presence column and `Read` the ones that exist. Quote what each page states — partner list, commission terms, cookie window, payout schedule, application path.
2. `Grep` for attribution handling: `?ref=`, `?aff=`, `?via=`, `?invitation=`, `utm_source=`, per-creator or per-show discount codes in the checkout / signup handler. A link that carries a param nothing reads is not attribution — quote the handler, or record its absence at the route that should have it.
3. `Grep` for affiliate / creator platform integrations (a third-party attribution and payout service loaded on the site, its subdomain, or its SDK). Quote the integration point.
4. `Read` the README / docs for technical integrations and identify whether the product exposes an API, webhooks, or an extension surface a partner could build on.
5. `Glob` for sponsorship landing pages named after a show or publication and `Read` each. A vanity route referenced in a sponsorship but missing from the app is a dead link finding.

**Crawl mode, required tool calls:**

1. Fetch `/integrations`, `/partners`, `/marketplace`, `/affiliate`, `/referral`, `/creators`, `/ambassadors` where they exist. Quote the partner or program content and record the fetch date; a page promising something "available soon" is a finding only with the date evidence that shows how long it has said so.
2. Check whether the brand appears in the partner directories of products it integrates with. Quote the listing or its absence.
3. Search the brand name plus "review" / "tutorial" / "alternative" on the platforms where its audience is, and record creator mentions found. **Tooling caveat:** those platforms are JS-rendered and personalized — use a browser/Playwright or `WebSearch` tool IF one is present, else ask the user to paste what they see, else **Skip-with-reason**. Do not assert what creators have or haven't published if you couldn't look.
4. For any sponsorship the brand is running, capture the URL the ad copy points at. A sponsorship pointing at the bare homepage is the attribution finding; the show-named landing page is what makes it measurable.

### Forbidden claims

- "Partnerships are probably underdeveloped." Quote the list.
- "The affiliate program is probably absent." Quote present-or-absent at the route.
- "Attribution is probably not set up." Show the handler, or the route where it isn't.
- "Creators may not know about the brand." Search where you can; quote what's there. If you couldn't search, Skip.
- "Sponsorship attribution may be missing." Show the URL the sponsorship points at.
- Any statement about payouts, revenue, or partner-driven conversions. Those live in the analytics account, not on the surface.

### Detection

Route inventory + program-terms read + attribution-handler grep, plus an off-site check for directory listings, creator mentions, and the destination a running sponsorship points at.

### What to Search For

URL patterns:
- `/integrations`, `/partners`, `/marketplace`, `/ecosystem`
- `/affiliate`, `/referral`, `/refer-friend`
- `/creators`, `/ambassadors`
- vanity routes matching a show or publication name

Attribution patterns:
- `?ref=`, `?aff=`, `?via=`, `?invitation=`, platform-specific referral params
- `utm_source=<creator-handle>`, `utm_medium=creator`, `utm_medium=sponsorship`
- discount codes named for a creator or a show, resolved in the checkout handler

Code patterns:
- partner OAuth flows (`api/oauth/<partner>`), webhook integrations (`api/webhooks/<partner>`), embedded SDK references
- a third-party affiliate / creator attribution service's script or subdomain

### Actually Hurts the Marketing Surface

- **A program runs with no partner-facing surface.** Affiliates, creators, or partners have nothing to find and no way to apply. Evidence required: the attribution mechanism or platform integration present in source, with no corresponding public page.
- **The program page states no terms.** "Contact us" where a partner needs commission, cookie window, payout schedule, and prohibited-promotion rules to decide. Evidence required: the page content quoted.
- **Attribution parameters accepted but never read.** Links carry `?ref=` / `?via=` and nothing persists the value to the signup. Evidence required: the param in use + the handler's absence at the route that receives it.
- **Creator mentions with no attribution wiring.** The brand is being talked about and the traffic arrives anonymous. Evidence required: the mention + no code or param linking it.
- **Sponsorship traffic landing on the homepage.** No show-named page, no per-show code, so nothing distinguishes one show's traffic from another's. Evidence required: the sponsorship's destination URL.
- **A sponsorship or partner vanity URL that 404s.** Paid placement pointing at a dead route. Evidence required: the URL + the fetched response status.
- **A partner page listing one or two partners, or promising integrations "available soon".** It reads as abandoned. Evidence required: the page content + the date it was last changed (`git blame` in source mode, or the fetch date plus any date stated on the page).
- **The brand is absent from the directories of products it integrates with.** The integration exists and the partner's audience can't find it. Evidence required: the integration in source + the missing listing on the partner's marketplace.
- **Existing customers have no way to refer.** No per-account referral link or dashboard entry. Evidence required: the product surface inspected, or `/referral` absent.
- **Disclosure missing on affiliate or creator arrangements the brand controls** (its own comparison pages, its own creator-supplied embeds). Evidence required: the commercial link or embed + no disclosure near it. The FTC Endorsement Guides govern the disclosure; Cat 125 owns the wider site-reputation risk.

### NOT a Problem

- No program because the product doesn't fit (standalone single-purpose tool, enterprise sales cycle, margin that can't support payouts). Intentional; Skip with the reason.
- Few partners listed because the program is new. Acceptable, not a finding.
- An invite-only or closed affiliate / creator program with no public page, where the brand says curation is the point. Note it; audit the attribution instead.
- A sponsorship that ran and ended, or a single test in flight. Test-and-cut is a valid strategy and one test can't be measured yet.
- Working with large-audience creators for awareness rather than conversion, when the brand says so. Strategy, not a defect.

### Context Check

1. Which of the four program types are actually in scope for this brand, and which does its stage or economics rule out?
2. Does the product have natural integration points (API, webhooks, OAuth) that make a partnership program possible at all?
3. Is there a per-partner, per-creator, or per-show identifier in the attribution, or does everything collapse into one channel?
4. Does the team have the operational capacity the program implies (partner support, affiliate payouts, creator communication)?
5. Is the audience somewhere creators and shows actually reach it, and can you observe that with the tools available?
6. If the brand asks *whether* to run one of these programs, which shows to sponsor, how to recruit creators, or what to pay them: that is strategy, not audit. Call the Skill tool with "snitch-cmo" — its channel playbooks own creator outreach, sponsorship selection, and partner co-marketing.

### Reference

FTC Endorsement Guides (disclosure duties on affiliate, creator, and sponsored placements): https://www.ftc.gov/business-guidance/resources/ftcs-endorsement-guides

Attribution-parameter hygiene itself — casing drift, double-encoding, redirect stripping, internal-nav pollution — belongs to the analytics instrumentation category that owns UTM and query-parameter consistency (Cat 53). This category checks that a partner-facing param exists and is read; that category checks that the parameter convention holds site-wide. Report the mechanism here, the hygiene there, and don't emit both for the same URL.

`references/local-services-playbook.md` covers community-platform presence for local brands, which overlaps the partnership surface for service businesses.

**Severity tagging:**
- Program running with no partner-facing surface → High.
- Attribution parameters accepted but never read → High.
- Sponsorship or partner vanity URL that 404s → High.
- Creator mentions with no attribution wiring → High.
- Sponsorship traffic landing on the homepage with no per-show identifier → High.
- Program page with no stated terms → Medium.
- Stale partner page ("available soon", one or two logos) → Medium.
- Brand absent from partner directories where the integration exists → Medium.
- Existing customers with no referral path → Medium.
- Missing disclosure on a commercial arrangement the brand controls → Medium.

**Fix voice:** `indie-commerce-founder` (primary) | `analytics-engineer` (backup, when the finding is the attribution wiring).

Read `souls/indie-commerce-founder.json` before writing the Fix.

Worked fix example:

> Every one of these programs is the same three pieces: a surface a partner can find, terms they can act on, and an identifier that survives the click. Ship the identifier first — without it, the rest is unmeasurable.
>
> One handler reads every partner param on entry (`ref`, `aff`, `via`, `invitation`, `utm_source`), persists it to the session and then onto the signup record, and lasts the length of the cookie window the terms promise. One resolver maps a code — a creator's, a show's, an affiliate's — to the partner it belongs to, in code rather than in a spreadsheet. Now "which show sent this customer" is a query.
>
> Then the surfaces. `/affiliate` states commission, cookie window, payout schedule, and what promotion methods are prohibited; a partner deciding whether to apply needs all four, and "contact us" costs you the ones who won't write. `/integrations/<partner>` says what the integration does and how to switch it on, and the brand is submitted to that partner's own directory the same week — their audience searching "<partner> + <category>" is the whole point of the integration.
>
> Sponsorships get a page per show at a route named for the show, and the ad copy points there rather than at the homepage. The headline names the show. The code in the read matches the route. When the quarter ends you can sort shows by signups per dollar instead of guessing.
>
> For the questions this audit can't answer — which shows to buy, which creators to approach, what a fair rate looks like, whether a partner program is worth the operational cost at all — call the Skill tool with "snitch-cmo".
