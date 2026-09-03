# Voice Mapping — which soul writes the Fix for each category

Every category file lists its `**Fix voice:**` at the bottom. This file is the master table the SKILL.md references when generating fixes. Each row: category → primary voice → backup voices (use only when the primary's POV doesn't fit the specific finding).

The voice JSON files live at `souls/{slug}.json` next to SKILL.md. Read the full soul before writing the fix; you can't write in someone's voice from their slug alone.

## Mapping

| Cat | Topic | Primary voice | Backup(s) | Why this voice |
|---|---|---|---|---|
| 1 | Robots.txt | `security-engineer` | `solutions-architect` | Robots.txt is a security-shaped concern (what's exposed); SecEng voice for "lock down what shouldn't be crawled, expose what should." |
| 2 | Sitemap.xml | `solutions-architect` | `analytics-engineer` | Architecture-flavored: declare your URL inventory cleanly, point crawlers at it. |
| 3 | Canonical URL | `less-but-better-designer` | `solutions-architect` | "Less, but better" — one canonical, no competing URL signals. |
| 4 | Indexability (noindex) | `solutions-architect` | `security-engineer` | Decisions about what gets indexed are architectural. |
| 5 | Soft 404 | `honest-design-critic` | `solutions-architect` | The honest-critic voice for "a 200 OK page that says 'not found' is lying to your users — fix the lie." |
| 6 | Redirect chains | `performance-engineer` | `solutions-architect` | Each hop is latency. PerfEng cares about request count. |
| 7 | Pagination | `intrinsic-web-engineer` | `solutions-architect` | Per-page canonical correctness, semantic web. |
| 8 | Meta refresh | `solutions-architect` | `honest-design-critic` | Architectural anti-pattern; replace with a real redirect. |
| 9 | Title tag | `plain-language-designer` | `hierarchy-purist` | Plain-language commercial design: make it readable, kill the cleverness. |
| 10 | Meta description | `plain-language-designer` | `honest-design-critic` | Same — say what the page is, in one breath, no fluff. |
| 11 | Open Graph | `brand-surface-designer` | `expressive-typographer` | Social cards are brand-design surface; the brand-voice read. |
| 12 | Twitter Card | `brand-surface-designer` | `expressive-typographer` | Same. |
| 13 | Favicon set | `icon-designer` | `less-but-better-designer` | Small-scale icon craft is the whole category: what survives at 16 pixels. |
| 14 | Web manifest | `systems-designer` | `motion-engineer` | PWA-flavored; the systems-design voice. |
| 15 | Single H1 | `hierarchy-purist` | `less-but-better-designer` | Hierarchy is the whole discipline; one H1 is non-negotiable. |
| 16 | Heading hierarchy | `hierarchy-purist` | `less-but-better-designer` | Same. |
| 17 | Semantic HTML | `intrinsic-web-engineer` | `content-shape-editor` | Semantic markup is the core of the intrinsic-web POV. |
| 18 | Thin content | `content-shape-editor` | `less-but-better-designer` | Content-shape judgment on depth, with restraint as backup for "less but better-shaped." |
| 19 | Internal link graph | `intrinsic-web-engineer` | `solutions-architect` | Site architecture is intentional; the intrinsic-web POV. |
| 20 | Broken internal links | `honest-design-critic` | `solutions-architect` | "You're shipping links to nowhere. That's on you. Fix it." |
| 21 | Anchor text quality | `plain-language-designer` | `honest-design-critic` | Plain language; "Click here" is the enemy. |
| 22 | Breadcrumb markup | `systems-designer` | `intrinsic-web-engineer` | Component-thinking, atomic. |
| 23 | Footer link spam | `less-but-better-designer` | `honest-design-critic` | Less but better, with the honest-critic voice for the "this is link-juice spam, stop" version. |
| 24 | External link rel | `honest-design-critic` | `security-engineer` | Responsibility for what you link to (sponsored, ugc, nofollow). |
| 25 | Image alt presence | `emotional-design-lead` | `usability-scientist` | Designing for emotion + a11y. |
| 26 | Image alt quality | `content-shape-editor` | `emotional-design-lead` | The writing of alt text is shape-of-design territory. |
| 27 | Image format (webp/avif) | `performance-engineer` | `solutions-architect` | Pure perf decision. |
| 28 | Explicit width/height (CLS) | `performance-engineer` | `motion-engineer` | CLS is the literal Core Web Vital PerfEng owns. |
| 29 | Lazy-load directives | `motion-engineer` | `performance-engineer` | MotionEng for the animation/UX side ("lazy doesn't mean janky"); PerfEng for the byte side. |
| 30 | Video sitemap | `analytics-engineer` | `solutions-architect` | Discoverability/measurement-flavored. |
| 31 | JSON-LD presence | `intrinsic-web-engineer` | `solutions-architect` | Semantic web. |
| 32 | Schema type validation | per type, see below | `intrinsic-web-engineer` | One category, fourteen type rows, and each type has its own POV. The Fix voice column of the per-type table in `references/standards-table.md` names the voice per row; the intrinsic-web read holds a finding that spans several types. |
| 39 | Font loading strategy | `typography-master` | `performance-engineer` | Font loading is half typography, half perf. |
| 40 | Render-blocking CSS/JS | `performance-engineer` | `solutions-architect` | Pure perf. |
| 41 | Critical-path CSS | `performance-engineer` | `motion-engineer` | Same. |
| 42 | Third-party scripts | `security-engineer` | `performance-engineer` | Supply-chain risk + perf cost. |
| 43 | Image weight | `performance-engineer` | `less-but-better-designer` | "Less, but better" works for image budgets too. |
| 44 | JS bundle weight per route | `performance-engineer` | `less-but-better-designer` | Same. |
| 45 | Viewport meta | `intrinsic-web-engineer` | `usability-scientist` | Intrinsic web sizing. |
| 50 | Hreflang correctness | `solutions-architect` | `intrinsic-web-engineer` | Architectural; cross-locale linking. |
| 51 | Locale canonicals | `solutions-architect` | `intrinsic-web-engineer` | Same. |
| 52 | Lang attribute | `intrinsic-web-engineer` | `solutions-architect` | Semantic root attribute. |
| 53 | Analytics instrumentation (install, tag manager, event taxonomy, UTM) | `analytics-engineer` | `solutions-architect` | Native voice — the role exists for this; `security-engineer` when the finding is third-party tag supply-chain risk in the tag-manager pass. |
| 57 | Topical depth | `content-shape-editor` | `honest-design-critic` | Depth-of-content writing voice. |
| 58 | Keyword targeting / intent match | `plain-language-designer` | `honest-design-critic` | Plain language; what does the searcher actually want? |
| 59 | AI-content tells | `honest-design-critic` | `content-shape-editor` | "Cut the bullshit." |
| 60 | Conversion & trust (CTAs, forms, trust signals, 404 page) | `indie-commerce-founder` | `plain-language-designer` | Indie-maker conversion + plain-language CTA voice. |
| 61 | Transactional email inventory & templates | `solutions-architect` | `honest-design-critic` | Architectural visibility — make the system's email surface inventory-able; the honest-critic voice for the template copy half (every word in a transactional email is a promise), and `emotional-design-lead` when the finding is the rendering and dark-mode half. |
| 63 | Email deliverability (SPF/DKIM/DMARC) | `security-engineer` | `analytics-engineer` | DNS-level authentication / sender posture. |
| 65 | Email compliance | `security-engineer` | `solutions-architect` | Regulatory + bulk-sender header constraints as system design. |
| 66 | Paid channel presence (search + social) | `analytics-engineer` | `indie-commerce-founder` | Measurement-driven, or skip-and-build-organic when paid economics don't fit; `brand-surface-designer` when the finding is the social side's creative and message. |
| 68 | Organic social | `brand-surface-designer` | `indie-commerce-founder` | Brand surface across owned channels. |
| 69 | Backlinks (now AI-citation signal) | `honest-design-critic` | `indie-commerce-founder` | "Build a thing worth linking to; stop gaming." |
| 70 | Content strategy (distribution-first) | `content-shape-editor` | `honest-design-critic` | Substance + cadence + the discipline to ship. |
| 71 | Lifecycle / newsletter | `indie-commerce-founder` | `honest-design-critic` | Email is the product surface — treat it like one. |
| 72 | Community building | `indie-commerce-founder` | `honest-design-critic` | Founder-shows-up community-building. |
| 73 | CRO signals | `analytics-engineer` | `indie-commerce-founder` | Funnel measurement before optimization. |
| 74 | Customer feedback / social proof | `indie-commerce-founder` | `honest-design-critic` | Real customers, named, attributed. |
| 75 | Brand consistency | `brand-surface-designer` | `expressive-typographer` | Brand-as-philosophy; every surface is the brand. |
| 76 | Partner & sponsorship program attribution | `indie-commerce-founder` | `analytics-engineer` | Indie-commerce voice for the program surface (pick the right partners, state the terms, ship); AnalyticsEng when the finding is the attribution wiring — per-creator, per-show, per-affiliate identifiers that survive the click. |
| 77 | PR / launches (HN+PH+creator first) | `indie-commerce-founder` | `brand-surface-designer` | Founder-led announcement, not press pitch. |
| 79 | Local SEO / GBP (foundation, depth, retired features) | `solutions-architect` | `analytics-engineer` | NAP consistency as system discipline; AnalyticsEng for the depth pass (fill-every-field, the box is empty, fill it) and for retired-feature dependence that makes a number fiction. |
| 80 | Product-led growth | `indie-commerce-founder` | `brand-surface-designer` | The product IS the funnel; make it the funnel. |
| 81 | Market positioning | `plain-language-designer` | `brand-surface-designer` | Plain-language hero + bold differentiation. |
| 82 | AI-search citation (four layers, incl. llms.txt and per-assistant differentiation) | `intrinsic-web-engineer` | `content-shape-editor` | Intrinsic-web POV applied to AI-extraction-friendly content and to the AI-crawler convention; `analytics-engineer` when the finding is the per-assistant measurement loop. |
| 84 | Founder-led brand channel | `brand-surface-designer` | `indie-commerce-founder` | Brand-as-philosophy + people follow people. |
| 86 | Keyword research + intent mapping | `content-shape-editor` | `plain-language-designer` | Content shape for "form follows function — the page must match the intent"; plain language as backup for "use the words customers actually type, not the words you wish they typed." |
| 94 | Review / AggregateRating schema | `honest-design-critic` | `solutions-architect` | "Don't fake reviews. Don't pad ratings." The rating-honesty audit. |
| 95 | Programmatic SEO audit | `solutions-architect` | `honest-design-critic` | The architectural fix: data quality controls page existence; page existence controls index inclusion. |
| 96 | Brand-SERP defense | `brand-surface-designer` | `honest-design-critic` | Brand as portfolio; the brand-surface POV. |
| 97 | Content decay & refresh audit | `content-shape-editor` | `honest-design-critic` | The content-shape POV applied to the rolling content lifecycle. |
| 98 | Internal site search audit | `analytics-engineer` | `content-shape-editor` | Search log as content-strategy data source; AnalyticsEng for the measurement loop. |
| 99 | Conversion funnel deep-audit | `indie-commerce-founder` | `analytics-engineer` | Indie-maker funnel walking, with the "fix the leakiest step first" POV. |
| 101 | AI-agent commerce signals | `solutions-architect` | `indie-commerce-founder` | Architectural pattern: agent surface vs human surface, both deliberately designed. |
| 109 | Message match audit | `plain-language-designer` | `content-shape-editor` | Plain-language "same words, same promise" discipline; content shape as backup for the structural angle. |
| 114 | Persuasion architecture (7-section audit + ethics overlay) | `permission-marketer` | `brand-surface-designer` | The permission-marketing voice carries the narrative arc; the brand-surface read for the visual and peak-end recommendations. |
| 115 | Pricing psychology tactical (display, anchoring, frames) | `positioning-strategist` | `permission-marketer` | Positioning for what the price says about the segment; permission marketing as backup for the honest-frame angle. |
| 116 | Retention psychology (activation, peak-end, exit flow) | `brand-surface-designer` | `permission-marketer` | Peak-end design is a brand-surface concern; permission marketing as backup for the retention-without-coercion POV. |
| 117 | Site copy lint (vague adjectives, dark patterns, hidden price, weak social proof) | `honest-design-critic` | `plain-language-designer` | The honest-critic voice for "you're telling the buyer nothing, fix the bullshit." The plain-language voice as backup when the fix is "rewrite this in one breath, in English." |
| 119 | Hyper-local landing page completeness | `intrinsic-web-engineer` | `analytics-engineer` | Intrinsic-web POV applied to per-city pages: schema + semantic markup + linked structure. AnalyticsEng as backup for the data-grounded rubric (named landmarks count, photo geo-tags, schema completeness). |
| 121 | Information architecture & site structure | `systems-designer` | `solutions-architect` | The systems/IA POV (hierarchy, hub-and-spoke, navigation as a system); SolArch as backup for the crawl-budget / faceted-trap engineering framing. |
| 122 | Comparison / alternatives / "vs" page strategy | `positioning-strategist` | `permission-marketer` | Positioning for the honest comparison frame (name the segment each option wins); permission marketing as backup for the "be the one who tells the truth" angle. |
| 123 | Lead-magnet / free-tool acquisition assets | `indie-commerce-founder` | `newsletter-operator` | The indie-founder give-before-you-ask, PLG on-ramp instinct; the newsletter operator as backup for the audience/value-exchange framing. |
| 124 | Buying-committee / stakeholder coverage | `positioning-strategist` | `indie-commerce-founder` | Positioning-led coverage of each stakeholder; the segment frame primary, indie-pragmatic as backup. |
| 125 | Parasite SEO / site-reputation-abuse risk | `solutions-architect` | `honest-design-critic` | Content-system integrity (SA for the architectural fix); the honest critic as backup for "stop renting the domain's reputation". |
| 126 | Domain heritage / expired-domain risk | `security-engineer` | `solutions-architect` | Provenance / abuse-risk posture; SecEng for "what baggage does this domain carry", SA for the migration call. |
| 128 | Citation-gap audit | `honest-design-critic` | `content-shape-editor` | "Back up the claim or cut it." Honest-critic enforcement; the content-shape voice as backup for the writing-craft angle. |
| 129 | AI-image provenance metadata | `solutions-architect` | `analytics-engineer` | Metadata as a declared signal in the asset pipeline; reversible config change. |
| 130 | IndexNow / indexing-submission readiness | `solutions-architect` | `analytics-engineer` | Declare URL changes to the index; notify-on-publish as architecture. |
| 131 | SXO page-type / SERP-intent alignment | `content-shape-editor` | `positioning-strategist` | Form follows function: the page must be the right shape for the job; positioning as backup. |
| 132 | SERP-overlap topic clustering | `systems-designer` | `solutions-architect` | Hub-and-spoke as a system; the systems/IA POV, SA as backup for the dedup/cannibalization fix. |
| 133 | Machine-translation quality drift | `content-shape-editor` | `honest-design-critic` | Translation is a writing surface; the content-shape voice for craft, the honest critic as backup for "don't ship localization that's actually slop". |
| 134 | Agent operability (accessibility-tree) | `intrinsic-web-engineer` | `solutions-architect` | Semantic HTML is the substance of machine operability; the intrinsic-web read, SA as backup for the agent-surface architecture. |


### Cat 32's per-type Fix voices

Cat 32 validates every schema type whose page-type signal fires, and the voice follows the type, not
the category. The authority is the Fix voice column of the per-type table in
`references/standards-table.md`; this is the same set, restated for the reader who is here rather
than there.

| Type row | Primary voice | Backup | Why this voice |
|---|---|---|---|
| Article / BlogPosting | `content-shape-editor` | `intrinsic-web-engineer` | Articles are a writing surface; the content-shape voice. |
| BreadcrumbList | `systems-designer` | `intrinsic-web-engineer` | An atomic UI element with structured data behind it. |
| Product | `indie-commerce-founder` | `brand-surface-designer` | Indie-maker commerce voice: "this is what makes the snippet show up; do it." |
| FAQPage | `honest-design-critic` | `content-shape-editor` | "Write the questions your customer actually asks, not the ones you wish they did." |
| HowTo | `plain-language-designer` | `honest-design-critic` | Step-by-step plain language, and an honest note that no rich result is at stake. |
| Organization / WebSite | `brand-surface-designer` | `expressive-typographer` | Brand-as-entity; the brand-surface read. |
| VideoObject | `motion-engineer` | `analytics-engineer` | The motion-engineering voice carries the video surface. |
| Recipe | `recipe-author` | `intrinsic-web-engineer` | The recipe-as-contract POV: the structured data must match the visible recipe, exactly. |
| Course | `content-shape-editor` | `intrinsic-web-engineer` | A course is a writing surface — curriculum, instructor, outcomes. |
| Event | `solutions-architect` | `honest-design-critic` | Time, place and status as a contract; the honest critic for "tell the truth about the event." |
| JobPosting | `honest-design-critic` | `solutions-architect` | "A job posting is a contract with the candidate." Honesty in salary, location, role. |
| SoftwareApplication | `indie-commerce-founder` | `brand-surface-designer` | Indie SaaS commerce: ship the block, ship the screenshots, ship the version number. |
| LocalBusiness | `solutions-architect` | `honest-design-critic` | NAP as configuration, not content — one source of truth. |
| Person / Author | `content-shape-editor` | `honest-design-critic` | The byline is a writing surface; the content-shape POV. |

## Notes

- Every slug in this table is vendored in `souls/` next to SKILL.md. If a soul file is missing,
  fall back to the backup voice; if both are missing, skip the voice flourish for that finding
  (write a clean generic Fix and note in the report metadata that the voice library was
  incomplete).
- Slugs are discipline names, not people. A soul is a role profile — philosophy, principles,
  cadence samples, and a critique stance — with no biography in it. Nothing in this table or in
  `souls/` may be surfaced to the customer (`references/voiced-remediations.md`).
- Adding a NEW category? Pick the primary voice from the souls library — don't invent one. If no
  existing soul fits, the category is probably mis-scoped.

## Souls vendored in this skill bundle (23)

```
souls/analytics-engineer.json
souls/brand-surface-designer.json
souls/content-shape-editor.json
souls/emotional-design-lead.json
souls/expressive-typographer.json
souls/hierarchy-purist.json
souls/honest-design-critic.json
souls/icon-designer.json
souls/indie-commerce-founder.json
souls/intrinsic-web-engineer.json
souls/less-but-better-designer.json
souls/motion-engineer.json
souls/newsletter-operator.json
souls/performance-engineer.json
souls/permission-marketer.json
souls/plain-language-designer.json
souls/positioning-strategist.json
souls/recipe-author.json
souls/security-engineer.json
souls/solutions-architect.json
souls/systems-designer.json
souls/typography-master.json
souls/usability-scientist.json
```
