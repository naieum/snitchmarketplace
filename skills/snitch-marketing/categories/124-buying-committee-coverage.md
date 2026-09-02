## CATEGORY 124: Buying-committee / stakeholder coverage (B2B multi-stakeholder messaging)

A considered B2B purchase is rarely one person's decision. A typical buying group spans
several roles: the person who will use the product day to day, the economic buyer who
controls budget and signs, an internal champion who advocates for the purchase when the
vendor isn't in the room, and one or more skeptics (security, legal, IT, procurement,
finance) whose unanswered objection quietly kills the deal. A marketing surface that
speaks to only one of these roles, usually the end user or only the economic buyer, leaves
the others unequipped, and committee deals stall on whichever stakeholder can't get their
question answered. This category audits whether the site gives each role what it needs to
say yes, or to not say no.

Scope note: this is the **audit** of stakeholder coverage on the marketing surface. It is
distinct from Cat 81 (positioning: is the value clear and differentiated at all) and Cat
110 (ICP wedge: which single segment to win first). A brand can have sharp positioning for
one persona and still leave three other committee members blind.

### The four committee roles (what each needs on the page)

| Role | The question they're answering | What the page owes them |
|---|---|---|
| **User** (will use it daily) | "Will this fit how I actually work?" | How it works, hands-on proof, a real demo / screenshots / docs, integrations, the workflow it slots into. |
| **Economic buyer** (owns budget, signs) | "Is the outcome worth the cost and the risk?" | Outcome + ROI framing, honest pricing or a clear path to it, total cost of ownership, the cost of not acting (cross-ref Cat 81 CoI/VoA). |
| **Champion** (sells it internally) | "Can I make this case to my boss without the vendor?" | A self-contained, forwardable asset: a one-pager, ROI calculator, comparison page (Cat 122), a business-case download (Cat 123) they can send up the chain. |
| **Skeptic / blocker** (security, legal, IT, procurement) | "Is this safe, compliant, and supportable?" | A reachable answer: security page, SOC 2 / ISO / compliance posture, data-handling / DPA, SSO, status / uptime page, support SLA (cross-ref Cat 60). |

The audit maps the site's content to these four roles and reports a finding for any role
the brand has left blind. The most common failure is a site that is all user-facing feature
copy with no buyer ROI frame and no security answer, or all top-down outcome/ROI copy with
nothing a hands-on evaluator can poke at.

### Pre-flight: relevance check

Skip with reason `not applicable` for B2C / single-buyer e-commerce, personal brands,
transactional sites, and any purchase one person makes alone on a credit card. Required for
B2B SaaS, mid-market / enterprise services, sales-led or demo-gated motions, and any
considered purchase with multiple internal approvers. Borderline (self-serve PLG that also
sells up-market): run it, scoped to whether the up-market path equips the buyer and the
skeptic, since the self-serve path already serves the user.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md` ICP + top objections: who are the named stakeholders
   in this brand's actual deals, and what does each one object to? The committee roles are
   grounded in the real buyer, not assumed.
2. Inventory the marketing surface against the four roles. For each role, find the page /
   section that serves it and quote it; or record its absence with the routes you checked.
   - User: feature pages, `/product`, `/how-it-works`, demo, docs, `/integrations`.
   - Economic buyer: `/pricing`, ROI / outcome copy, case studies with business results.
   - Champion: any forwardable, self-contained asset (one-pager, business case, calculator).
   - Skeptic: `/security`, `/trust`, `/compliance`, `/legal`, `/dpa`, status page, SSO mention.
3. Identify which role the homepage hero addresses. A hero that only names one role is a
   signal the rest of the site likely under-serves the others.

**Crawl mode, required tool calls:**

1. Fetch the homepage, nav, footer, and pricing page; map the visible destinations to the
   four roles. Footer and nav are where security / trust / compliance links usually live, if
   they exist at all.
2. For any claimed sales-led motion ("Book a demo", "Contact sales"): check whether anything
   exists for the champion to take into an internal conversation, or whether every path
   requires the vendor to be present.

### Forbidden claims

- "The site only talks to one persona." Name the role it serves, quote the copy, and list the
  routes you checked for the missing roles before judging.
- "There's no security information for buyers." Show the footer / nav / sitemap you checked;
  a `/security` page that exists but is unlinked is a different finding (discoverability, not
  absence).
- "Champions have nothing to share." First confirm there is no forwardable asset, no
  comparison page (Cat 122), and no business-case download (Cat 123).

### Detection

Role-coverage mapping (four roles) + per-role evidence presence + discoverability of the
serving page, grounded in the context file's real stakeholders and objections.

### What to Search For

- A homepage that addresses exactly one role (all feature/workflow copy, or all top-down ROI
  copy) with no path to the others
- No pricing or outcome/ROI framing on a sales-led B2B site (economic buyer left to guess)
- No `/security`, `/trust`, `/compliance`, DPA, or SSO signal on a site selling to companies
  that have a security review (skeptic has no answer; the deal stalls in procurement)
- No self-contained, forwardable asset for the champion (every path requires the vendor in
  the room; cross-ref Cat 99 B2B dark funnel, Cat 123 business-case asset)
- A security / trust page that exists but is unlinked from nav and footer (present but
  undiscoverable)
- "For everyone" copy that names no role specifically (fails coverage and Cat 81 audience
  clarity simultaneously)

### Actually Hurts the Marketing Surface

- **A whole committee role is left blind.** The site equips one role and ignores the others;
  the deal stalls on whichever stakeholder can't self-serve their question.
  Evidence required: the served role's copy quoted + the routes checked for each missing role.
- **No answer for the security / procurement skeptic on a site that sells to companies.** The
  most common silent deal-killer: legal/IT/security has no page to point to, so the purchase
  never clears review.
  Evidence required: nav + footer + sitemap checked, no trust/security/compliance surface found.
- **Nothing the champion can forward.** Every conversion path requires the vendor present; the
  internal advocate has no self-contained artifact to circulate.
  Evidence required: CTA inventory showing only vendor-present paths (demo/contact), no
  one-pager / calculator / business case (cross-ref Cat 123).
- **Economic buyer has no outcome or cost frame.** All workflow/feature copy, no ROI, no
  pricing path, no cost-of-inaction (cross-ref Cat 81).
  Evidence required: the feature-led surface quoted + absence of buyer-facing outcome/pricing.
- **The serving page exists but is undiscoverable.** Security or pricing buried where the
  relevant stakeholder won't find it.
  Evidence required: the page URL + the nav/footer that omits it.

### NOT a Problem

- A genuine single-buyer self-serve motion (solo developer, individual creator, prosumer)
  where one person decides and pays. There is no committee to cover.
- A pure PLG free tier where the product itself is the user-facing proof and an enterprise
  page covers the buyer + skeptic for the up-market path.
- A deliberately lean site that routes the skeptic's questions to a linked, reachable trust
  page rather than spreading them across every page. Coverage is about being answerable, not
  about repeating security copy everywhere.
- Early-stage brands with no enterprise motion yet, where adding a compliance page would be a
  claim they can't back (flag as a "start here when you move up-market" note, not a finding).

### Context Check

1. What does the context file say the actual buying group looks like for this brand? Which
   roles appear in real deals?
2. For each role, is there a page / section / asset that answers its core question, and is it
   discoverable from nav or footer?
3. Which single role does the homepage hero serve? Is that the right one for the wedge (Cat
   110), and does the rest of the site reach the others?
4. On a sales-led motion: can the champion advance the deal internally without the vendor in
   the room?
5. Does the skeptic (security / legal / procurement) have a reachable, honest answer, or does
   the deal depend on no one asking?
6. Are coverage gaps a genuine absence, or present-but-undiscoverable? (Different fix.)

### Reference

Published B2B buying-group research consistently puts a complex B2B purchase at roughly six to
ten decision-makers, each arriving with their own information. The positioning frame each of them
needs is in `souls/positioning-strategist.json` (internal voice reference).

Loss Aversion + Status-Quo Bias for the skeptic's "do nothing is safest" default (see
`references/mental-models.md`).

**Severity tagging:**
- No security / procurement answer on a site that sells into companies with a security review → High.
- A whole committee role left blind (no page or asset serves it) → High.
- Champion has nothing forwardable on a sales-led motion → Medium.
- Economic buyer has no outcome/ROI/pricing frame → Medium (compounds with Cat 81).
- Serving page present but undiscoverable → Medium.
- Single-role hero that the rest of the site compensates for → Low (note, not a break).

**Fix voice:** `positioning-strategist` (primary) | `indie-commerce-founder` (backup).

Read `souls/positioning-strategist.json` before writing the Fix.

Worked fix example:

> The page is talking to one person. It's a great pitch for the engineer who'll use the
> tool, and it says nothing to the two other people who actually have to approve the
> purchase. Those deals don't get a "no" — they get silence, because the buyer can't find the
> ROI and security can't find a page to clear.
>
> Map the site to the four people in the room:
>
> 1. **The user** (well covered): keep the feature depth and the demo.
> 2. **The economic buyer**: add the outcome and the cost of waiting, not just the feature
>    list — what changes for the business, and what it costs to stay as-is (Cat 81 CoI/VoA).
>    Give them a real pricing path, even if it's "starts at $X, talk to us above Y seats."
> 3. **The champion**: give them one thing they can forward without you — a one-page business
>    case or an ROI calculator (Cat 123) — so they can sell it up the chain on Tuesday when
>    you're not on the call.
> 4. **The skeptic**: ship a `/security` (or `/trust`) page and link it from the footer. SOC 2
>    status, where data lives, SSO, a DPA on request. The goal isn't to win this person; it's
>    to not lose the deal in their review (Cat 60).
>
> Verify: walk the site once as each of the four roles and ask "could this person get their
> one question answered without emailing sales?" Every "no" is a stalled deal you can't see in
> the funnel because it never converts far enough to register (Cat 99 dark funnel).
