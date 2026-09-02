## CATEGORY 109: Landing-page-to-ad message match audit

When a visitor clicks an ad, they're a moment away from converting or bouncing. The single biggest predictor of which path they take is whether the landing page delivers the promise the ad made. Cat 66 (paid search) mentions message match as one finding among many; this category promotes the discipline to its own audit pass and applies it across every paid surface, search, social, display, YouTube, using the same evidence model.

The job: walk every visible-in-Ads-Transparency ad creative → its landing page destination, audit headline match, value-prop match, CTA match, visual continuity. The audit produces a per-ad scorecard.

### Pre-flight: relevance check

Run only when the brand has visible ads in any public ad library (Google Ads Transparency Center, Meta Ad Library, LinkedIn EU library, TikTok Creative Center, etc.). Skip with reason `no active ads in transparency centers; no message match to audit yet` if STEP 0.6 brand-maturity classified paid presence as `none`.

### Evidence required (do not skip, only when active ads visible)

**Crawl mode, required tool calls (most of this is off-site):**

1. Per `references/ads-detection-matrix.md`, fetch the brand's listings on each public ad library with active ads.
2. For each visible ad creative, capture: headline, body copy, image / video thumbnail, CTA button text, the landing page destination URL.
3. `Fetch` each landing page. Quote: H1, hero subheading, primary CTA button text, page-level hero visual.
4. Score the match per pair on four dimensions (Strong / Partial / Weak / None):
   - **Headline match**: does the LP H1 echo or directly fulfill the ad headline?
   - **Value-prop match**: does the LP hero subheading deliver on the promise the ad made?
   - **CTA match**: does the LP CTA verb match the ad CTA verb?
   - **Visual continuity**: does the LP hero visual relate to the ad image / video thumbnail?
5. Cross-reference Cat 60 (conversion & trust) on each landing page to verify trust signals are present at the conversion moment.

**Source mode, required tool calls:**

1. Identify landing-page routes (`/lp/`, `/landing/`, `/promo/`, `/get/`, `/ads/`). `Glob` and quote.
2. `Read` each landing page route. Quote H1, hero subheading, primary CTA, hero visual import.
3. If campaign briefs / ad-copy docs are versioned in the repo, cross-reference the brief's headline + value prop with the landing page's content.

### Forbidden claims

- "Message match may be weak." Quote both ad headline and LP H1 with the score.
- "CTA may not align." Quote both CTAs.
- "Visual continuity may be missing." Quote ad image filename / description and LP hero visual reference.
- Don't claim "this is causing low conversion", without the platform's conversion data, you don't know the rate. Frame as "weak message match correlates with conversion friction."

### Detection

Public-ad-library inventory + landing-page audit per ad creative + 4-dimension scorecard.

### What to Search For

- Active ad creatives in each platform's public library
- Each ad's destination URL (landing page or homepage)
- Landing-page H1, subheading, CTA, hero visual
- Headline phrasing similarity (lexical and semantic)
- CTA verb match (`Get started` vs `Sign up` vs `Try free`, different verbs imply different conversion friction)
- Hero visual continuity (the ad image's subject + the LP hero image's subject)

### Actually Hurts the Marketing Surface

- **Paid traffic lands on the homepage instead of a dedicated landing page**. The homepage cannot match a specific ad's headline because it serves all visitors at once.
  Evidence required: ad creative + destination URL = homepage URL.
- **LP H1 has no relationship to ad headline** (ad: "Cut Cloud Costs by 40%, Free Audit"; LP: "Welcome to FinOpsCo. We help teams in the cloud."). Visitor's expectation is broken at the first paragraph.
  Evidence required: both quoted.
- **CTA verb mismatch** (ad button: "Get my free audit"; LP button: "Contact sales"). Visitor expected self-serve; LP gates on sales conversation.
  Evidence required: both CTAs quoted.
- **Visual discontinuity** (ad shows a screenshot of feature X; LP hero shows feature Y; visitor disoriented).
  Evidence required: ad creative description + LP hero visual reference.
- **Multiple ads → single LP that match none of them well** (the brand runs 12 ad variations, all funnel to one homepage; impossible to message-match for all 12).
  Evidence required: 12+ ad variations + single destination URL.
- **Time-bound promise on the ad, not honored on LP** (ad: "Limited spring discount"; LP: no spring discount visible / discount expired but ad still running).
  Evidence required: ad copy quoted + missing fulfillment on LP.
- **LP is mobile-broken from a paid mobile ad** (the ad targets mobile; the LP CLS / touch targets / load time fails on mobile per Cats 28/46/49).
  Evidence required: cross-reference mobile cats on the LP URL.
- **No trust signals at the conversion moment on LP** (Cat 60 cross-ref), the visitor came from a context (an ad they trusted enough to click); the LP must reinforce that trust at the form.
  Evidence required: LP form area without testimonials / logos / guarantees.

### NOT a Problem

- A single-product brand whose homepage IS the landing page AND whose ad headline + LP H1 align, correct (no need for a separate `/lp/` route).
- Brand running awareness / brand-bid ads with no specific conversion goal, message match still applies, but a "Strong" awareness LP looks different from a "Strong" conversion LP.
- A returning user landing on a customized home view, different audit lens.

### Context Check

1. Are LPs distinct from the homepage? Most brands running paid should have dedicated landing pages.
2. Are LPs created per ad-group or per campaign? Per-ad-group is the higher-fidelity pattern.
3. Is there a templated LP system (template + variable swap), and if so, does each variant maintain message match (Cat 95 programmatic-SEO cross-ref)?
4. Is mobile fully audited on the LPs? Most paid traffic is mobile.
5. Are LPs covered by the same A/B testing / conversion measurement as the rest of the site?

### Reference

`references/ads-detection-matrix.md`, public ad libraries per platform

Cat 66 (Paid search), channel-level audit; this category is the per-ad detail

Cat 66 (Paid channel presence), the channel-level posture behind both the search and social ads scored here

Cat 60 (Conversion & trust), trust signals at conversion moment

Cat 99 (Conversion funnel deep-audit), paid LP is one stage of the funnel

Cat 95 (Programmatic SEO), cross-reference for templated LPs

Unbounce / Instapage / Webflow LP best-practice guides: established CRO-flavored references for message-match patterns

**Severity tagging:**

- Paid traffic lands on homepage instead of LP → High.
- LP H1 has no relationship to ad headline → High.
- CTA verb mismatch (self-serve vs sales) → Critical (changes conversion expectation).
- Visual discontinuity → Medium.
- Single LP serving many disparate ads → High.
- Time-bound promise on ad not honored on LP → Critical (deceptive).
- LP mobile-broken from mobile ad → Critical.
- No trust signals at LP conversion moment → Medium.

**Fix voice:** `plain-language-designer` (primary, plain-language headline discipline) | `content-shape-editor` (backup).

Read `souls/plain-language-designer.json` before writing the Fix.

Worked fix example:

> The visitor clicked the ad because something in the ad spoke to them. Your job on the landing page is to keep speaking to them, same words, same promise, same direction. Most weak landing pages aren't poorly designed; they just don't continue the sentence the ad started.
>
> Three rules to follow.
>
> **One landing page per ad group, minimum.** Not per-ad, per-ad is overkill, but a landing page that serves all 14 of your search ad groups is a landing page that messages-matches none of them. Build dedicated LPs for the campaigns that move the most spend.
>
> **The H1 echoes the ad headline. Word-for-word when you can.** If the ad says "Cut your cloud bill 40%, free audit," the H1 says "Cut your cloud bill 40%. Free audit, 15 minutes." The visitor's eye lands on the H1 and confirms they're in the right place.
>
> **The CTA verb on the page matches the CTA verb on the ad.** If the ad button says "Get my audit," the page button says "Get my audit." Don't switch to "Sign up" or "Get started" or "Talk to sales", the visitor came expecting one specific action; honor it.
>
> Walk the page once a quarter, ad creative in one hand, LP in the other. Score each pair: headline match, value-prop match, CTA match, visual continuity. The pairs that score Weak get a rewrite, usually it's faster to rewrite the LP than to retire the ad. Plain language; same promise, same direction; the visitor stays on the road.
