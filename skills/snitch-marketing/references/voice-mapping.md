# Voice Mapping — which soul writes the Fix for each category

Every category file lists its `**Fix voice:**` at the bottom. This file is the master table the SKILL.md references when generating fixes. Each row: category → primary voice → backup voices (use only when the primary's POV doesn't fit the specific finding).

The voice JSON files live at `souls/{slug}.json` next to SKILL.md. Read the full soul before writing the fix; you can't write in someone's voice from their slug alone.

## Mapping

| Cat | Topic | Primary voice | Backup(s) | Why this voice |
|---|---|---|---|---|
| 1 | Robots.txt | `security-engineer` | `solutions-architect` | Robots.txt is a security-shaped concern (what's exposed); SecEng voice for "lock down what shouldn't be crawled, expose what should." |
| 2 | Sitemap.xml | `solutions-architect` | `analytics-engineer` | Architecture-flavored: declare your URL inventory cleanly, point crawlers at it. |
| 3 | Canonical URL | `dieter-rams` | `solutions-architect` | "Less, but better" — one canonical, no competing URL signals. |
| 4 | Indexability (noindex) | `solutions-architect` | `security-engineer` | Decisions about what gets indexed are architectural. |
| 5 | Soft 404 | `mike-monteiro` | `solutions-architect` | Mike's voice for "a 200 OK page that says 'not found' is lying to your users — fix the lie." |
| 6 | Redirect chains | `performance-engineer` | `solutions-architect` | Each hop is latency. PerfEng cares about request count. |
| 7 | Pagination | `jen-simmons` | `solutions-architect` | Per-page canonical correctness, semantic web. |
| 8 | Meta refresh | `solutions-architect` | `mike-monteiro` | Architectural anti-pattern; replace with a real redirect. |
| 9 | Title tag | `aaron-draplin` | `paul-rand-via-massimo-vignelli` (use `massimo-vignelli` if Draplin doesn't fit) | DDC's "make it readable, kill the cleverness" voice for SERP titles. |
| 10 | Meta description | `aaron-draplin` | `mike-monteiro` | Same — say what the page is, in one breath, no fluff. |
| 11 | Open Graph | `tobias-van-schneider` | `paula-scher` | Social cards are brand-design surface; van Schneider's brand-voice. |
| 12 | Twitter Card | `tobias-van-schneider` | `paula-scher` | Same. |
| 13 | Favicon set | `susan-kare` | `dieter-rams` | Susan Kare invented the visual grammar of icons; she's THE voice for favicon decisions. |
| 14 | Web manifest | `brad-frost` | `sarah-drasner` | PWA-flavored, Brad's atomic-design / pragmatic-web voice. |
| 15 | Single H1 | `massimo-vignelli` | `josef-muller-brockmann` (not vendored — fall back to `dieter-rams`) | Hierarchy is sacred to Vignelli; one H1 is non-negotiable. |
| 16 | Heading hierarchy | `massimo-vignelli` | `dieter-rams` | Same. |
| 17 | Semantic HTML | `jen-simmons` | `frank-chimero` | Jen literally wrote the intrinsic-web playbook; semantic markup is her POV. |
| 18 | Thin content | `frank-chimero` | `dieter-rams` | Frank's "shape of design" voice on content depth, plus Rams as backup for "less but better-shaped." |
| 19 | Internal link graph | `jen-simmons` | `solutions-architect` | Site architecture is intentional; Jen's POV. |
| 20 | Broken internal links | `mike-monteiro` | `solutions-architect` | "You're shipping links to nowhere. That's on you. Fix it." Pure Monteiro. |
| 21 | Anchor text quality | `aaron-draplin` | `mike-monteiro` | Plain language; "Click here" is the enemy. |
| 22 | Breadcrumb markup | `brad-frost` | `jen-simmons` | Component-thinking, atomic. |
| 23 | Footer link spam | `dieter-rams` | `mike-monteiro` | Less but better, and Mike for the "this is link-juice spam, stop" version. |
| 24 | External link rel | `mike-monteiro` | `security-engineer` | Responsibility for what you link to (sponsored, ugc, nofollow). |
| 25 | Image alt presence | `aarron-walter` | `don-norman` | Designing for emotion + a11y. |
| 26 | Image alt quality | `frank-chimero` | `aarron-walter` | The writing of alt text is shape-of-design territory. |
| 27 | Image format (webp/avif) | `performance-engineer` | `solutions-architect` | Pure perf decision. |
| 28 | Explicit width/height (CLS) | `performance-engineer` | `sarah-drasner` | CLS is the literal Core Web Vital PerfEng owns. |
| 29 | Lazy-load directives | `sarah-drasner` | `performance-engineer` | Sarah for the animation/UX side ("lazy doesn't mean janky"); PerfEng for the byte side. |
| 30 | Video sitemap | `analytics-engineer` | `solutions-architect` | Discoverability/measurement-flavored. |
| 31 | JSON-LD presence | `jen-simmons` | `solutions-architect` | Semantic web. |
| 32 | Article schema | `frank-chimero` | `jen-simmons` | Articles are a writing surface; Frank's voice. |
| 33 | BreadcrumbList schema | `brad-frost` | `jen-simmons` | Atomic UI element with structured data. |
| 34 | Product schema | `sahil-lavingia` | `tobias-van-schneider` | Indie-maker commerce voice; Sahil for "this is what makes the snippet show up; do it." |
| 35 | FAQ schema | `mike-monteiro` | `frank-chimero` | "Write the questions your customer actually asks, not the ones you wish they did." Pure Monteiro. |
| 36 | HowTo schema | `aaron-draplin` | `mike-monteiro` | Step-by-step plain-language; DDC voice. |
| 37 | Organization / WebSite schema | `tobias-van-schneider` | `paula-scher` | Brand-as-entity; van Schneider's territory. |
| 38 | VideoObject schema | `sarah-drasner` | `analytics-engineer` | Sarah's motion / video chops. |
| 39 | Font loading strategy | `erik-spiekermann` | `performance-engineer` | Spiekermann is THE typography voice; font loading is half typography, half perf. |
| 40 | Render-blocking CSS/JS | `performance-engineer` | `solutions-architect` | Pure perf. |
| 41 | Critical-path CSS | `performance-engineer` | `sarah-drasner` | Same. |
| 42 | Third-party scripts | `security-engineer` | `performance-engineer` | Supply-chain risk + perf cost. |
| 43 | Image weight | `performance-engineer` | `dieter-rams` | "Less, but better" works for image budgets too. |
| 44 | JS bundle weight per route | `performance-engineer` | `dieter-rams` | Same. |
| 45 | Viewport meta | `jen-simmons` | `don-norman` | Intrinsic web sizing. |
| 46 | Touch target size | `don-norman` | `aarron-walter` | Norman wrote the book on a11y interaction targets. |
| 47 | Readable text without zoom | `erik-spiekermann` | `don-norman` | Typography + usability. |
| 48 | ARIA labels | `aarron-walter` | `don-norman` | Designing for emotion includes a11y semantics. |
| 49 | Color contrast | `dieter-rams` | `don-norman` | Rams's "color is functional" plus Norman's a11y POV. |
| 50 | Hreflang correctness | `solutions-architect` | `jen-simmons` | Architectural; cross-locale linking. |
| 51 | Locale canonicals | `solutions-architect` | `jen-simmons` | Same. |
| 52 | Lang attribute | `jen-simmons` | `solutions-architect` | Semantic root attribute. |
| 53 | GA4 install | `analytics-engineer` | `solutions-architect` | Native voice — the role exists for this. |
| 54 | GTM hygiene | `analytics-engineer` | `security-engineer` | Tag mess + supply-chain via 3rd party tags. |
| 55 | Event taxonomy | `analytics-engineer` | `solutions-architect` | "Define decision-driving metrics before implementation." Native voice. |
| 56 | Consent-mode setup | `security-engineer` | `analytics-engineer` | Privacy/consent is security-shaped. |
| 57 | Topical depth | `frank-chimero` | `mike-monteiro` | Depth-of-content writing voice. |
| 58 | Keyword targeting / intent match | `aaron-draplin` | `mike-monteiro` | Plain language; what does the searcher actually want? |
| 59 | AI-content tells | `mike-monteiro` | `frank-chimero` | "Cut the bullshit." Pure Monteiro. |
| 60 | Conversion & trust (CTAs, forms, trust signals, 404 page) | `sahil-lavingia` | `aaron-draplin` | Indie-maker conversion + plain-language CTA voice. |
| 61 | Transactional email inventory | `solutions-architect` | `analytics-engineer` | Architectural visibility — make the system's email surface inventory-able. |
| 62 | Email content quality | `mike-monteiro` | `frank-chimero` | Cut bullshit copy; every word in a transactional email is a promise. |
| 63 | Email deliverability (SPF/DKIM/DMARC) | `security-engineer` | `analytics-engineer` | DNS-level authentication / sender posture. |
| 64 | Email design + accessibility | `aarron-walter` | `brad-frost` | Designing for emotion across hostile email clients + a11y. |
| 65 | Email compliance | `security-engineer` | `solutions-architect` | Regulatory + bulk-sender header constraints as system design. |
| 66 | Paid search | `analytics-engineer` | `sahil-lavingia` | Measurement-driven; or skip-and-build-organic when paid economics don't fit. |
| 67 | Paid social | `analytics-engineer` | `tobias-van-schneider` | Pixel hygiene + brand-creative across platforms. |
| 68 | Organic social | `tobias-van-schneider` | `sahil-lavingia` | Brand surface across owned channels. |
| 69 | Backlinks (now AI-citation signal) | `mike-monteiro` | `sahil-lavingia` | "Build a thing worth linking to; stop gaming." |
| 70 | Content strategy (distribution-first) | `frank-chimero` | `mike-monteiro` | Substance + cadence + the discipline to ship. |
| 71 | Lifecycle / newsletter | `sahil-lavingia` | `mike-monteiro` | Email is the product surface — treat it like one. |
| 72 | Community building | `sahil-lavingia` | `mike-monteiro` | Founder-shows-up community-building. |
| 73 | CRO signals | `analytics-engineer` | `sahil-lavingia` | Funnel measurement before optimization. |
| 74 | Customer feedback / social proof | `sahil-lavingia` | `mike-monteiro` | Real customers, named, attributed. |
| 75 | Brand consistency | `tobias-van-schneider` | `paula-scher` | Brand-as-philosophy; every surface is the brand. |
| 76 | Partnerships / integrations | `sahil-lavingia` | `solutions-architect` | Pick the right 3 partners; build the integration; ship. |
| 77 | PR / launches (HN+PH+creator first) | `sahil-lavingia` | `tobias-van-schneider` | Founder-led announcement, not press pitch. |
| 78 | Affiliate / referral | `sahil-lavingia` | `analytics-engineer` | Indie commerce conversion + attribution. |
| 79 | Local SEO / GBP | `solutions-architect` | `mike-monteiro` | NAP consistency as system discipline. |
| 80 | Product-led growth | `sahil-lavingia` | `tobias-van-schneider` | The product IS the funnel; make it the funnel. |
| 81 | Market positioning | `aaron-draplin` | `tobias-van-schneider` | Plain-language hero + bold differentiation. |
| 82 | AI-search citation | `jen-simmons` | `frank-chimero` | Intrinsic-web POV applied to AI-extraction-friendly content. |
| 83 | Creator partnerships | `sahil-lavingia` | `tobias-van-schneider` | Mid-tier creators + indie-commerce attribution. |
| 84 | Founder-led brand channel | `tobias-van-schneider` | `sahil-lavingia` | Brand-as-philosophy + people follow people. |
| 85 | Newsletter / podcast sponsorships | `sahil-lavingia` | `analytics-engineer` | Niche-vertical earned-media + per-show attribution. |
| 86 | Keyword research + intent mapping | `frank-chimero` | `aaron-draplin` | Frank for "form follows function — the page must match the intent"; Draplin as backup for "use the words customers actually type, not the words you wish they typed." |
| 87 | Recipe schema | `julia-child` | `jen-simmons` | Julia for the recipe-as-contract POV ("the structured data must match the visible recipe, exactly"). |
| 88 | Course schema | `frank-chimero` | `jen-simmons` | A course is a writing surface (curriculum, instructor, outcomes); Frank's voice. |
| 89 | Event schema | `solutions-architect` | `mike-monteiro` | Time + place + status as a contract; SA for accuracy + reversibility, Mike as backup for "tell the truth about the event." |
| 90 | JobPosting schema | `mike-monteiro` | `solutions-architect` | "A job posting is a contract with the candidate." Pure Monteiro for honesty in salary, location, role. |
| 91 | SoftwareApplication schema | `sahil-lavingia` | `tobias-van-schneider` | Indie SaaS commerce; Sahil for "ship the SoftwareApplication block, ship the screenshots, ship the version number." |
| 92 | LocalBusiness schema | `solutions-architect` | `mike-monteiro` | NAP as configuration not content — single source of truth. SA voice for the architectural fix. |
| 93 | Person / Author schema | `frank-chimero` | `mike-monteiro` | The byline is a writing surface; Frank's POV. |
| 94 | Review / AggregateRating schema | `mike-monteiro` | `solutions-architect` | "Don't fake reviews. Don't pad ratings." Pure Monteiro for the rating-honesty audit. |
| 95 | Programmatic SEO audit | `solutions-architect` | `mike-monteiro` | The architectural fix: data quality controls page existence; page existence controls index inclusion. |
| 96 | Brand-SERP defense | `tobias-van-schneider` | `mike-monteiro` | Brand as portfolio; van Schneider for the brand-surface POV. |
| 97 | Content decay & refresh audit | `frank-chimero` | `mike-monteiro` | Frank's "shape of design" applied to the rolling content lifecycle. |
| 98 | Internal site search audit | `analytics-engineer` | `frank-chimero` | Search log as content-strategy data source; AnalyticsEng for the measurement loop. |
| 99 | Conversion funnel deep-audit | `sahil-lavingia` | `analytics-engineer` | Indie-maker funnel walking; Sahil for the "fix the leakiest step first" POV. |
| 100 | Cookieless analytics readiness | `analytics-engineer` | `security-engineer` | Native voice — the role exists for measurement infra. |
| 101 | AI-agent commerce signals | `solutions-architect` | `sahil-lavingia` | Architectural pattern: agent surface vs human surface, both deliberately designed. |
| 102 | Multi-LLM citation differentiation | `jen-simmons` | `analytics-engineer` | Jen for the intrinsic-web angle; AnalyticsEng for per-LLM measurement loop. |
| 103 | WCAG 2.2 AA conformance | `aarron-walter` | `don-norman` | "Accessibility is design." Walter's design-for-emotion includes a11y as part of the discipline. |
| 104 | Keyboard navigation + focus management | `don-norman` | `aarron-walter` | Norman wrote the book on a11y interaction — keyboard model is foundational. |
| 105 | Screen reader semantics | `aarron-walter` | `don-norman` | Designing for emotion includes designing for assistive-tech users; Walter primary, Norman backup. |
| 106 | llms.txt | `jen-simmons` | `frank-chimero` | Intrinsic-web POV applied to the AI-crawler convention; matches Cat 82 voice for consistency. |
| 107 | Pixel install completeness | `analytics-engineer` | `security-engineer` | Native voice for measurement infra; SecEng for the pre-consent firing angle. |
| 108 | UTM hygiene + parameter consistency | `analytics-engineer` | `solutions-architect` | Convention + builder + runtime-strip discipline; AnalyticsEng primary, SA backup for the architectural fix. |
| 109 | Message match audit | `aaron-draplin` | `frank-chimero` | Plain-language "same words, same promise" discipline; Draplin primary, Chimero backup for the structural angle. |
| 110 | ICP wedge scoring | `april-dunford` | `seth-godin` | Dunford for the rigorous segment-scoring frame; Godin as backup for the smallest-viable-audience POV. |
| 111 | Trust artifact audit | `sahil-lavingia` | `mike-monteiro` | Indie-maker trust posture (founder face, real testimonials, honest privacy); Mike as backup for the "tell the truth" enforcement. |
| 112 | Pricing strategic read | `sahil-lavingia` | `april-dunford` | Indie pricing intuition; Dunford as backup for the positioning-driven pricing analysis. |
| 117 | Site copy lint (vague adjectives, dark patterns, hidden price, weak social proof) | `mike-monteiro` | `aaron-draplin` | Mike's voice for "you're telling the buyer nothing, fix the bullshit." Aaron's plain-language voice as backup when the fix is "rewrite this in one breath, in English." |
| 118 | Google Business Profile depth audit (fill-every-field discipline) | `analytics-engineer` | `solutions-architect` | Operational fill-every-field discipline; the box is empty, fill it. AnalyticsEng for the measurement-grounded version; SolArch as backup for the "treat each field as a declared signal" framing. |
| 119 | Hyper-local landing page completeness | `jen-simmons` | `analytics-engineer` | Intrinsic-web POV applied to per-city pages: schema + semantic markup + linked structure. AnalyticsEng as backup for the data-grounded rubric (named landmarks count, photo geo-tags, schema completeness). |
| 120 | Meta ads account structure health | `analytics-engineer` | `sahil-lavingia` | Account-structure discipline + learning-phase respect; the algorithm needs signal, not helicoptering. SahilL as backup for the indie-pragmatic "ship the simplest structure that lets the algorithm learn" framing. |
| 121 | Information architecture & site structure | `brad-frost` | `solutions-architect` | Brad's systems/IA POV (hierarchy, hub-and-spoke, navigation as a system); SolArch as backup for the crawl-budget / faceted-trap engineering framing. |
| 122 | Comparison / alternatives / "vs" page strategy | `april-dunford` | `seth-godin` | Dunford for the honest positioning-led comparison frame (name the segment each option wins); Godin as backup for the "be the one who tells the truth" angle. |
| 123 | Lead-magnet / free-tool acquisition assets | `sahil-lavingia` | `josh-spector` | Sahil's give-before-you-ask, PLG on-ramp instinct; Josh as backup for the audience/value-exchange framing. |
| 124 | Buying-committee / stakeholder coverage | `april-dunford` | `sahil-lavingia` | Positioning-led coverage of each stakeholder; Dunford's segment frame, Sahil as the indie-pragmatic backup. |
| 125 | Parasite SEO / site-reputation-abuse risk | `solutions-architect` | `mike-monteiro` | Content-system integrity (SA for the architectural fix); Mike as backup for "stop renting the domain's reputation". |
| 126 | Domain heritage / expired-domain risk | `security-engineer` | `solutions-architect` | Provenance / abuse-risk posture; SecEng for "what baggage does this domain carry", SA for the migration call. |
| 127 | GBP feature-deprecation audit | `analytics-engineer` | `solutions-architect` | Operational fill/replace discipline; stop depending on retired features. |
| 128 | Citation-gap audit | `mike-monteiro` | `frank-chimero` | "Back up the claim or cut it." Mike's enforcement; Frank as backup for the writing-craft angle. |
| 129 | AI-image provenance metadata | `solutions-architect` | `analytics-engineer` | Metadata as a declared signal in the asset pipeline; reversible config change. |
| 130 | IndexNow / indexing-submission readiness | `solutions-architect` | `analytics-engineer` | Declare URL changes to the index; notify-on-publish as architecture. |
| 131 | SXO page-type / SERP-intent alignment | `frank-chimero` | `april-dunford` | Form follows function: the page must be the right shape for the job; Dunford as backup for the positioning angle. |
| 132 | SERP-overlap topic clustering | `brad-frost` | `solutions-architect` | Hub-and-spoke as a system; Brad's IA POV, SA as backup for the dedup/cannibalization fix. |
| 133 | Machine-translation quality drift | `frank-chimero` | `mike-monteiro` | Translation is a writing surface; Frank for craft, Mike as backup for "don't ship localization that's actually slop". |
| 134 | Agent operability (accessibility-tree) | `jen-simmons` | `solutions-architect` | Semantic HTML is the substance of machine operability; Jen's intrinsic-web POV, SA as backup for the agent-surface architecture. |

## Notes

- Some souls referenced in this table are not vendored in the snitch-marketing `souls/` folder yet because they don't ship with the v1 bundle. If a primary voice's soul file is missing, fall back to the backup. If both are missing, skip the voice flourish for that finding (write a clean generic Fix and note in the report metadata that the voice library was incomplete).
- Souls like `josef-muller-brockmann` were considered but not vendored to keep the bundle compact. Add them later if customers ask for that voice.
- Adding a NEW category? Pick the primary voice from the souls library — don't invent one. If no existing soul fits, the category is probably mis-scoped.

## Souls vendored in this skill bundle (23)

```
souls/aaron-draplin.json
souls/aarron-walter.json
souls/analytics-engineer.json
souls/april-dunford.json
souls/brad-frost.json
souls/dieter-rams.json
souls/don-norman.json
souls/erik-spiekermann.json
souls/frank-chimero.json
souls/jen-simmons.json
souls/josh-spector.json
souls/julia-child.json
souls/massimo-vignelli.json
souls/mike-monteiro.json
souls/paula-scher.json
souls/performance-engineer.json
souls/sahil-lavingia.json
souls/sarah-drasner.json
souls/security-engineer.json
souls/seth-godin.json
souls/solutions-architect.json
souls/susan-kare.json
souls/tobias-van-schneider.json
```

### New souls (added in this round)

- `april-dunford.json` — B2B positioning expert; usable as backup for Cat 81 (positioning) when sahil-lavingia's indie voice doesn't fit
- `josh-spector.json` — newsletter-and-podcast-sponsorship specialist; usable as primary for Cat 85 if/when re-balanced from sahil-lavingia
- `julia-child.json` — recipe authority; primary for Cat 87 (Recipe schema)
- `seth-godin.json` — permission-marketing originator; usable as backup for Cat 70 (content strategy) and Cat 81 (positioning), and as primary if frank-chimero's voice doesn't fit a specific recommendation
