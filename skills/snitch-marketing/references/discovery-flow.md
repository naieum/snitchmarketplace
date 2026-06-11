# Discovery Flow: STEP 0.4 → 0.8

The pre-audit discovery sequence that produces the ground truth every category's severity calibration depends on. Run these steps in order before scanning.

## STEP 0.4: Critical Unknowns & Validity Preconditions (Required, runs first)

The first artifact every audit produces is a **Critical unknowns** block before any prose, any findings, or any recommendation. It names three things that would change the recommendation if learned, plus the cheapest way to learn each. At least one of the three is a **validity precondition** — something that would invalidate the entire approach if assumed wrong, not merely tune it.

The distinction is load-bearing:

- An **assumption** (STEP 0.5.1 below) tunes the recommendation. "Team size is solo" makes the recommendation favor founder-led posting; "team size is 20" makes it favor ops-heavy plays. Either way, the recommendation is structurally valid.
- A **validity precondition** invalidates the entire recommendation if wrong. If the site's primary deploy is a JS-rendered SPA and the audit ran in crawl-mode without a JS renderer, half the cats produced false negatives — the recommendation derived from those negatives is structurally wrong, not merely mistuned.

Treat validity preconditions as Critical-tier findings even before the scan starts. If a precondition can't be verified, do not promote a recommendation that depends on it; downgrade to "test the precondition first" and pause the rest of the chain.

### Validity precondition classes to check

Pick the ones that apply; surface each one explicitly in the unknowns block.

| Class | Precondition | What it invalidates if wrong |
|---|---|---|
| **Rendering mode** | The site's primary deploy renders content the audit can see (SSR/SSG/MPA, or crawl mode has a JS renderer) | Half the on-page cats fire false negatives; any "missing X" finding is unsafe |
| **Indexable population** | Search Console / GSC inclusion of the surfaces being audited | A site can be technically perfect and still excluded from index; SEO recommendations are moot |
| **Brand maturity vs audit shape** | Site has been live long enough for off-site presence to exist | Cats 66-81 produce 16 redundant "no presence" findings; off-site recommendations become "build, don't optimize" |
| **Domain reputation** | Domain isn't penalized, sanctioned, or freshly registered | Optimization recommendations on a sandboxed or penalized domain don't move rankings |
| **Indexable language** | The site's content language matches the audit's analytical language | Misreading translated content for the original loses meaning; review benchmarks may apply to the wrong locale |
| **Audit-vs-test calendar** | The audit isn't running during a structural traffic event (Black Friday, conference week, post-launch spike) | Traffic numbers and Core Web Vitals fluctuate in ways the audit can't attribute |
| **Buyer-approval authority** | The role making the buying decision matches the audience the audit infers | "Audience is developers" + the buyer is the CFO produces wrong messaging recommendations |
| **Distribution-channel feasibility** | The proposed channels are actually open to the brand | Chrome Web Store payment policy, OSS-repo monetization backlash, ad-platform category bans, app-store policy — recommendations that depend on closed channels are dead on arrival |
| **Compliance posture** | Regulated-domain claims the brand can actually make (HIPAA, SOC 2, PCI, GDPR / EAA) | A wedge recommendation that depends on enterprise customers fails immediately if the team has no SOC 2 |
| **Eligible-population denominator** | Conversion or interview data covers the cohort the audit is reasoning about | Mixing returning customers, bots, sales-assisted visits, and free-tier waitlist into one "users" number destroys the inferences built on it |

### Required output (shipped at the top of every report)

```markdown
## Critical unknowns

Before acting on this audit, three things would change the recommendation if learned. At least one is a validity precondition — something that would invalidate the audit's approach if assumed wrong.

| # | What we don't know | Cheapest way to learn | Type |
|---|---|---|---|
| 1 | {specific unknown} | {action: read this file / ask the user / fetch this URL / run this command} | validity_precondition |
| 2 | {specific unknown} | {action} | assumption_tuner |
| 3 | {specific unknown} | {action} | assumption_tuner |

If we learn the precondition is false, this audit's findings about [scope] are unsafe; re-run after the precondition is corrected.
```

The block opens the report. Prose, severity counts, and findings follow it — not before it. If you catch yourself writing "Diagnosis," "Site context," or any prose section before the unknowns table, stop and reorder.

### How to derive the three unknowns

1. **Read the brief.** The user's message often names the precondition directly ("we just relaunched on Next.js App Router" → rendering mode is a precondition; "we shipped last week" → audit-vs-test calendar is a precondition).
2. **Read STEP 0 (mode detection).** If crawl mode is the only option and the stack signals SPA, rendering mode is the #1 precondition. Surface it.
3. **Read STEP 0.5 (Discovery) draft.** If the business model can't be determined from observable signals, "what's the primary conversion event" is a precondition — recommendations diverge on whether the brand is content-driven, sales-led, or self-serve commerce.
4. **Read STEP 0.7 (Niche & Competitor Research) draft.** If the niche category has compliance gates (children, health, finance, employment, housing, credit, political), compliance posture is a precondition.
5. **Read STEP 0.6 (Brand Maturity Check) draft.** If maturity scored `none` across most surfaces but the user is asking for off-site recommendations, "is the brand new" is a validity precondition — pre-public-launch brands need a different recommendation chain than established ones.

### Why this matters

What is unknown is more decision-relevant than what is known. A report that opens with "you have 12 Critical findings" but failed to flag that the audit couldn't see post-hydration DOM produces 12 confidently wrong recommendations. The unknowns table puts the precondition risk on the customer's screen first, where they can act on it before reading 30K tokens of inferences built on top of it.

## STEP 0.5: Pre-Audit Discovery (Required)

Before picking categories, build a one-page understanding of the site. Every category's severity calibration depends on this — a missing meta description on a content blog is High; on a noindex'd internal admin tool it's Skip. You can't judge SEO findings without knowing what the site is for.

Capture the following, with evidence (quote the URL, the title, the pricing page section, etc. you used):

- **Purpose** (one sentence): what does this site do for whoever lands on it?
- **Business model**: free / freemium / subscription SaaS / e-commerce / lead-gen / content + ads / agency services / OSS project / personal portfolio. Pick one (or "hybrid" with the components).
- **Primary conversion**: signup, purchase, contact form, install (CLI / extension / app), share / bookmark, donation. The single action the site most wants visitors to take.
- **Audience**: developers, marketers, designers, SMBs, enterprise IT, consumers, students, etc. Be specific — "developers" is too broad if the site clearly targets "indie React devs shipping AI-built side projects."
- **Critical surfaces**: the 3-7 routes that carry the most weight (homepage, pricing, top product pages, signup flow, checkout, top blog posts). These get the strictest audit.
- **Non-critical surfaces**: routes that are intentionally low-priority (admin, dashboard, legal, status page, internal docs). These get reduced or skipped audit.

How to derive this:

- **Source mode**: read `package.json` `description`, `README.md` if present, and the homepage route's `metadata`/`head()` block. Glob the routes directory to enumerate critical surfaces.
- **Crawl mode**: fetch the homepage, parse `<title>`, `<meta name="description">`, the visible H1 + first paragraph. Fetch `/pricing` if it exists. Look for "Sign up" / "Buy" / "Contact" CTAs to infer the primary conversion.

Write this captured context to the report under a `## Site context` section — every finding's severity tier draws on these facts. If you can't determine one of the fields confidently, write `unknown` and explain why; don't make it up.

**Why this matters:** a "missing canonical" finding on a homepage is High for an e-commerce site (every utm-tagged duplicate competes with the original), Critical for a content site (entire articles re-rank as duplicates), and Medium for a free-OSS docs site (lower commercial stakes). Same finding, three severities, depending on context. The discovery step is what makes that calibration honest.

## STEP 0.5.1: Assumptions Capture (Required)

Several recommendation dimensions cannot be observed from the site alone: team size, time commitment, budget, founder type, business goal. The audit must NOT silently assume these; it must explicitly capture and flag them as assumptions, with risk-if-wrong context. A marketing recommendation grounded in wrong assumptions is worse than no recommendation, because the team executes confidently in the wrong direction.

Capture the following, marking each as `observed` (verified from source / public data) or `assumed` (the audit's working hypothesis, to be confirmed by the customer before acting):

| Assumption | Risk if wrong |
|---|---|
| **Team size**: solo founder / small team (2-5) / mid-team (6-20) / larger | Affects how aggressively the audit recommends founder-led content vs ops-heavy plays. Solo founders cannot maintain a 10-channel distribution plan. |
| **Time commitment**: founder full-time on this / nights and weekends / 25% time | Affects realistic content cadence, customer-discovery throughput, channel-launch timing. |
| **Paid budget**: $0 / under $500/mo / $500-5000/mo / >$5000/mo | Drives toward content/community/outbound vs Google/Meta/LinkedIn ads. Don't recommend paid channels to a $0-budget brand. |
| **Founder type**: technical founder / marketing-savvy founder / non-technical / first-time | Affects voice (founder-led writing is the highest-leverage move for marketing-savvy founders; less so for technical-only founders who'd rather code). |
| **Business goal**: profitable indie SaaS (low five figures MRR) / venture-track / lifestyle / passion project | Different goals call for different pricing strategy, segment selection, and channel mix. Don't recommend venture-style scaling to an indie-profitable target. |
| **Compliance posture**: none / SOC 2 / HIPAA / EAA / other | Gates enterprise / regulated customer recommendations. A team without SOC 2 cannot pursue enterprise customers regardless of TAM. |

How to derive these:

1. **Read the source / about / team page first.** Some assumptions are observable (founder name, "Built by [team]" language, careers page presence). Mark these as `observed`.
2. **Default the rest to the most common case for the brand's stage and shape**, mark them as `assumed`. For an indie SaaS detected via STEP 0.5, default to: solo or 2-person team, founder full-time, $0 paid budget, technical founder, profitable indie goal, no compliance posture. For an established commercial brand, default to: 6-20 person team, mixed roles, modest paid budget, mixed compliance.
3. **Surface the assumptions explicitly** in the report under a `## Assumptions — confirm before acting` section. Display the table above with each row marked `observed` or `assumed` and the `risk if wrong` column populated.
4. **Action for the customer**: before executing any STEP 4.5 strategic recommendation, the team confirms or corrects each assumption. A recommendation grounded in a wrong assumption gets re-scoped before execution.

The report's recommendations must be CONDITIONAL on the assumptions: "If team size is solo and budget is $0 (assumed), the wedge recommendation is X. If budget is actually >$500/mo, the wedge recommendation shifts to Y." Never silently assume; always show the conditional.

## STEP 0.6: Brand Maturity Check (Required before any off-site / channel categories)

A new brand with no online presence yet does not benefit from a paid-search audit, a paid-social audit, a backlink audit, or a community audit. Running those wastes tokens AND produces a report full of "no presence detected, recommend establishing one" lines that don't help the customer.

Before running any category in the **66-81 range** (off-site / channel / strategy), do this check:

For each surface below, classify presence as `none`, `minimal`, or `established`:

- **Domain age**: `Bash whois <domain> 2>/dev/null | grep -iE "creat|registered" | head -1`. Brand <90 days old → likely `none` everywhere.
- **Search presence**: search the brand name in Google. 0 third-party results besides the brand's own site → `none` for organic. Mentions on industry sites / press / forums → at least `minimal`.
- **Paid ads presence**: check Google Ads Transparency Center for the brand. No ads ever → `none` for Cat 66. Check Meta Ad Library for paid social → `none` for Cat 67.
- **Social profiles**: from the site's footer / `Organization.sameAs` schema, list claimed profiles. None present → `none` for Cat 68. Profiles present but stale (>90d) → `minimal`. Active (post in last 30d) → `established`.
- **Backlinks**: without paid SEO data, partial. Branded-name search returning zero third-party mentions → `none` for Cat 69.
- **Community**: search site for `discord.gg`, `slack.com`, `/community`, `/forum`, `github.com/<org>/discussions`. None → `none` for Cat 72.
- **PR / press**: search `"<brand>" site:techcrunch.com OR site:theverge.com OR site:producthunt.com` patterns. None → `none` for Cat 77 (PR coverage).
- **Local SEO / GBP**: applicable only to local businesses (cafe, dentist, plumber, agency with physical address). Skip detection if business model isn't local.

Write the result to the report's `## Site context` under a `### Brand maturity` subsection. Include the `Bash whois` output snippet, the SERP search count, the social profile + last-post dates, etc. — evidence per claim.

**Skipping rule for off-site categories:** for any cat in the 66-81 range where the corresponding surface scored `none`:

- **Skip the full Evidence Required pass**, don't waste tokens running detection on a surface with nothing to detect.
- Mark category as **Skip** with reason `no detected presence on this channel; recommendation pending in Strategic Recommendations (STEP 5)`.
- The Strategic Recommendations step (STEP 5) will turn these Skips into prioritized "start here" recommendations rather than findings, since "you don't have X yet" is a strategic question, not an audit finding.

**If brand maturity is `none` across all 16 off-site surfaces:** display this message and recommend the customer skip the off-site audit entirely:

```
Brand maturity check: this brand has no detected off-site presence yet.

Running the off-site audit (cats 66-81) on a brand with no off-site
presence wastes tokens — every category would skip with the same reason.

Recommended: run the on-site audit (cats 1-65) now. Re-run the off-site
audit in 90+ days, after the brand has been live with active marketing.

What would you like to do?
[1] Continue with on-site audit only (cats 1-65)
[2] Run off-site anyway (will skip most cats; useful for an explicit "what should I build first" baseline)
[0] Cancel
```

**Why this matters:** an audit that says "no Discord, no LinkedIn, no paid ads, no backlinks, no PR" 16 times for a 3-week-old indie launch is condescending. The customer knows they don't have those things. The valuable output is "here's the order to build them in" — which lives in the recommendation synthesis (STEP 5), not in 16 redundant skips.

## STEP 0.7: Niche & Competitor Research (Required for off-site categories + Strategic Recommendations)

Skip this step if the user explicitly opts out of off-site categories AND opts out of recommendation synthesis. Otherwise: required.

The audit answers "what's broken on this site." Niche + competitor research adds "and here's what to do about it, given who you're competing with." Without this step, recommendations become generic ("write more content!") instead of specific ("competitor X owns query Y with a 4000-word piece + FAQ schema; ship the equivalent").

Capture:

1. **Niche definition**: in 1-2 sentences, the category the brand competes in. Pull from STEP 0.5 Discovery + the homepage hero. Examples: "AI-built site security audit tooling", "form backend for indie developers", "dev-tools community platform". Be specific, not "developer tools" (too broad).

2. **Top 3-5 search queries the brand should rank for**: derive from the brand's positioning + the audience's likely search behavior. Use the homepage's H1 + value prop as input. Quote the queries.

3. **Top 3-5 direct competitors**: identify by searching the queries above and capturing who consistently ranks in the top 5 organic results. Quote each competitor's domain + their positioning H1 from their homepage. Skip aspirational competitors (10x larger; not the right benchmark) unless they're the only ones ranking.

4. **What competitors do well** (per competitor, ~3 bullets): content depth, schema completeness, CTAs that convert, design polish, niche they own. `Fetch` each competitor's homepage and a representative inner page; capture concrete observations.

5. **Market gaps**: queries / topics / use-cases / audiences that NO competitor in the top 5 owns. The brand's opportunity. Audit gaps across these four explicit categories (don't lump them together — each routes to a different recommendation):

   - **Content gap**: a topic, query cluster, or content format (long-form guide, video, original research, comparison page) that no competitor owns. Quote: search query + top-5 SERP results showing nothing comprehensive.
   - **Schema gap**: a schema.org type (Product, FAQ, HowTo, VideoObject, Course, Event) that competitors aren't using on pages where it would qualify them for SERP features. Quote: competitor URL + missing schema.
   - **Feature / product gap**: a use-case, integration, workflow, or audience-specific feature competitors don't address. Quote: competitor positioning + the missing capability.
   - **Audience gap**: a segment (geography, company size, role, vertical, skill level, language) that competitors don't speak to specifically. Quote: competitor messaging + the unaddressed audience signal.

   Each gap is a candidate for a STEP 4.5 Strategic Recommendation. Gaps without one of these four labels are too vague to act on; tighten or drop them.

6. **Differentiation deltas**: what does THIS brand do that competitors don't? Pull from STEP 0.5 + homepage. The wedge.

Write all this to the report under a `## Competitive landscape` section. Every recommendation in STEP 5 cites this section.

**Tooling note:** without paid SEO data (Ahrefs / Semrush / Similarweb API), competitor rank/traffic data is approximate. Using SERP inspection (`Bash curl -s "https://www.google.com/search?q=..."`) gives partial visibility. Mark approximations as such; don't claim "competitor X gets 100K monthly visits" without the data source.

**Why this matters:** an audit that ends with "your site is technically broken in 12 ways, here are fixes" without context is incomplete. The customer wants to know "what would actually move the needle" — which depends entirely on what competitors are doing and what gaps exist. STEP 0.7 is the research that powers that answer.

## STEP 0.8: Component Inventory (Required, drives the recommended scan)

The audit's recommended scan is computed from observable components on the site, not from a labeled business archetype. STEP 0.8 enumerates which components exist; STEP 1.5 maps those components to cats via `references/component-cat-map.md`.

A "component" is an observable surface or signal the audit can verify in source or crawl mode without guessing the brand's self-identification. Components are NOT business categories. A site that has both a `/blog/` and a `/products/` route is BOTH a content surface and a commerce surface; the audit doesn't have to pick one.

### How to enumerate components

Run these checks in source mode (or crawl mode equivalent). Each check is a yes/no observation; record the evidence (file path, route, or rendered selector) that produced the answer.

**Surface components (routes/pages):**

- `homepage` (always present)
- `/pricing` or equivalent paid-tier surface
- `/blog`, `/posts`, `/articles`, or `/writings` (content surface)
- `/docs` or `/documentation` (documentation surface)
- `/faq` (FAQ surface)
- `/about` (entity-disambiguation surface)
- `/customers`, `/case-studies`, `/customer-stories` (social proof surface)
- `/talks`, `/speaking`, `/appearances` (speaker surface)
- `/products`, `/catalog`, `/shop`, `/store` (e-commerce surface)
- `/cart`, `/checkout` (transactional surface)
- `/courses`, `/cohort`, `/learn` (course surface)
- `/services`, `/work-with-me`, `/coaching` (service-provider surface)
- `/integrations` (integration surface; programmatic if 5+ entries)
- `/compare` (comparison surface; programmatic if 5+ competitor pages)
- `/for/{audience}` (audience-pages surface; programmatic if 5+ entries)
- `/use-cases/{case}` (use-case surface; programmatic if 5+ entries)
- `/careers`, `/jobs`, `/hiring` (job-posting surface)
- `/locations`, `/find-us`, address in footer (local-business surface)
- `/newsletter`, `/subscribe`, newsletter signup component (newsletter surface)
- Newsletter form embedded site-wide (lifecycle email surface)

**Content-shape components:**

- Author bylines on content (Person-as-author signal)
- Multiple authors across content (multi-author publisher signal)
- Single author across all content (personal-brand-by-byline signal)
- Recipe content with ingredients + instructions + yield (recipe surface)
- Event content with start dates + locations (event surface)
- Book content with ISBN or external book retailer links (book surface)
- Video embeds (YouTube, Vimeo, Mux) above the fold or in content (video surface)
- Podcast embeds or `/podcast` route (podcast surface)

**Entity-shape components:**

- Domain matches a person's name (e.g., `frankchimero.com`) (personal-brand entity signal)
- Hero copy uses first-person singular ("I help...", "I'm [Name]...") (solo-operator signal)
- Hero copy uses corporate "we" with brand-name references (organization signal)
- Multiple team members on `/about` or `/team` (multi-person organization signal)
- Single founder profile only (founder-led signal)

**Infrastructure components:**

- GA4 / GTM installed (analytics-installed signal, drives Cats 53-56, 100, 107)
- Ad pixels installed (Meta / LinkedIn / TikTok / X / Reddit / Pinterest) (paid-channel signal, drives Cats 67, 107, 108, 109)
- Email infrastructure (Resend, Postmark, SendGrid, etc.) (email-program signal, drives Cats 61-65)
- Stripe integration (commerce signal, drives Cats 91 if SaaS, 99, 60)
- Auth library (Clerk, Better Auth, NextAuth) (account-system signal, affects Cat 99 funnel-deep)
- Multi-locale routing (i18n config or `/{locale}/` URL pattern) (i18n signal, drives Cats 50-52)
- `llms.txt` at site root (LLM-discoverability signal, drives Cat 106; affects Cat 82)
- Sitemap.xml (sitemap signal, drives Cat 2)
- Robots.txt (robots signal, drives Cat 1)

**Off-site components (from STEP 0.6 maturity check, brought forward):**

- Has organic social presence (Twitter / LinkedIn / GitHub / Instagram / YouTube / TikTok / Bluesky), per-platform
- Has paid presence (search / social), per-platform
- Has community channel (Discord, Slack, subreddit, forum)
- Has PR / press coverage detected
- Has Google Business Profile
- Has affiliate program

### Output of STEP 0.8

Produce a structured list under a `## Components detected` section in the audit report. Example output:

```markdown
## Components detected

### Surface components
- homepage (src/app/page.tsx)
- /pricing (src/app/pricing/page.tsx, with tiered offers)
- /docs (src/app/docs/[...slug]/page.tsx, hub + ~25 leaf pages)
- /faq (src/app/faq/page.tsx)
- /about (src/app/about/page.tsx, with team mentions)
- /customers (src/app/customers/page.tsx)
- /compare (8 competitor comparison pages, programmatic surface)
- /integrations (30+ integration pages, programmatic surface)
- /for (7 audience pages, programmatic surface)
- /use-cases (5 use-case pages)
- /updates (changelog / product-updates with published_at + author)
- newsletter signup (footer-embedded NewsletterSignupForm)

### Entity-shape
- corporate "we" hero copy (organization signal)
- /about mentions team (multi-person organization signal)

### Infrastructure
- no GA4 / GTM detected (no `gtag` / `G-*` / `GTM-*` references)
- no ad pixels detected
- Resend email infrastructure (src/lib/email/resend.ts)
- Stripe (referenced in src/middleware.ts and admin routes)
- Better Auth-style auth (src/middleware.ts pattern)
- single-locale (lang="en", no i18n routing)
- llms.txt present (public/llms.txt + extended /llms/*.txt variants)
- sitemap present (src/app/sitemap.ts)
- robots present (src/app/robots.ts)

### Off-site (from STEP 0.6)
- Twitter @atlasforms (active per footer)
- GitHub atlasforms (active per footer)
- no LinkedIn / YouTube / Instagram / Discord detected
- no paid search detected (no ads in transparency, no AW pixel)
- no paid social detected (no FB / LinkedIn / TikTok pixels)
```

### Why this matters

The component inventory is the GROUND TRUTH the recommended scan is built from. Every cat that runs is justified by a detected component; every cat that's skipped is justified by an absent component. The customer can audit the audit: "we ran Cat 91 SoftwareApplication because /pricing was detected with tiered offers".

This replaces the previous business-model-based decision table with observable evidence. A site that defies easy categorization (personal brand + SaaS founder, publisher + e-commerce, etc.) gets the cats relevant to ALL its detected components.
