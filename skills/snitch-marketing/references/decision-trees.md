# Decision Trees

Load when the audit ends in a state where the customer is asking "so what do I actually do next?" — and the recommendation depends on a small number of yes/no observations the audit can answer.

This reference complements `references/strategic-recommendations.md` (which produces the full prioritized brief) and `references/triage-workflow.md` (which routes individual findings to fix/accept/false-positive). Use a decision tree when the next move is gated by the answer to a single load-bearing question.

## How to use a tree

1. Find the branch closest to the customer's state from the audit (STEP 0.5 discovery, STEP 0.6 brand maturity, STEP 0.8 component inventory, and the final finding counts).
2. Walk the tree from root to leaf using observable evidence — every "yes" or "no" must be backed by something in the audit, not by a vibe.
3. Quote the audit evidence that justifies the path you took (per Rule 1).
4. Leaves are not commitments; they are the single most-likely-correct next action given the evidence. Customers can override with their own knowledge.

The trees below cover the cases where customers most often ask "what now?" and the audit can give a defensible answer in one tree-walk.

## Tree 1: What do I do next?

This is the master "the audit is done, now what" tree. Most audits route to one of the four leaves below.

```text
Is the activation funnel working? (the north-star metric, Cat 99 funnel deep)
├── No (activation <60% of installs or signups stall pre-value-delivery)
│   └── ┳━ STOP marketing. Distribution amplifies a broken product.
│       ┃  Fix activation first; resume after activation crosses the threshold.
│       ┗━ Spend 2-4 weeks on onboarding, time-to-first-value, and removing
│          the steps that produce dropoff. Re-audit Cat 53 and Cat 99 in 30 days.
└── Yes (activation works)
    │
    └── Is the wedge clear? (Cat 81 positioning)
        ├── No (positioning fuzzy, umbrella hero naming 3+ buyer types)
        │   └── ┳━ Run 10 customer-discovery calls before any other action.
        │       ┃  Use `references/customer-discovery-script.md`.
        │       ┣━ Re-do Cat 81 after the calls; rewrite hero from customer
        │       ┃  language; re-test in 30 days.
        │       ┗━ To score the candidate segments and pick the wedge, call
        │          the Skill tool with "snitch-cmo".
        └── Yes (wedge sharp, hero answers "what does this do" in 5 seconds)
            │
            └── Is there off-site presence to amplify? (STEP 0.6)
                ├── No (`none` across most surfaces)
                │   └── ┳━ Build foundational presence before any paid acquisition.
                │       ┃  Tier 1 from `references/strategic-recommendations.md`:
                │       ┃  founder-led posting + 10 discovery calls +
                │       ┃  3 named testimonials + changelog cadence.
                │       ┗━ 90 days of foundation. Re-audit off-site after.
                └── Yes (`minimal` or `established` on at least 3 surfaces)
                    │
                    └── Is one channel producing qualified intent?
                        ├── No (presence exists but no channel converts)
                        │   └── ┳━ Audit the funnel from channel to conversion.
                        │       ┃  Findings from Cat 53 (analytics) + Cat 99
                        │       ┃  (funnel deep) name the leak. Fix the leak;
                        │       ┃  re-test in 30 days.
                        └── Yes (one channel produces signups that activate)
                            └── ┳━ Scale that channel cautiously, with the
                                ┃  kill rule pre-committed (per STEP 4).
                                ┗━ Do not diversify until the channel is
                                   producing predictable signups for 60+ days.
```

The leaf the audit lands on becomes the headline recommendation in STEP 4.

## Tree 2: Should we scale this channel?

Use when the audit shows a channel producing some signups and the customer is considering paid amplification.

```text
Does the channel produce ICP-qualified intent? (signups match the buyer the site names)
├── No → Do not scale. Diagnose: is the channel reaching the wrong audience,
│        or is the wedge out of date? If positioning shifted, re-score the
│        segments by calling the Skill tool with "snitch-cmo".
└── Yes
    │
    └── Do the qualified signups activate? (per the north-star metric)
        ├── No → Do not scale. Scaling amplifies dropoff. Fix activation first.
        └── Yes
            │
            └── Does CAC payback work at current price + margin?
                (channel CAC ≤ LTV / payback target — both numbers come from the
                 customer; the audit cannot observe CAC or LTV. Ask, don't estimate.
                 Ask which CAC: blended, all marketing cost over all new customers,
                 not paid-only CAC, which flatters the channel when organic is
                 quietly assisting.)
                ├── No → Do not scale. Raise price (display tactics: Cat 115;
                │        the strategic read: call the Skill tool with
                │        "snitch-cmo"), improve conversion (Cat 60), reduce
                │        channel cost, or stop.
                └── Yes → Scale gradually with kill-rule guardrails pre-committed.
                          Stop scaling if CAC payback degrades by >25% over 30 days.
                          Judge each budget increment on its marginal return (did
                          the last increase still clear target ROAS?), not the
                          campaign's average, which hides the point of diminishing
                          returns.
```

## Tree 3: Should we test paid acquisition yet?

Use when the customer asks about Google/Meta/LinkedIn ads.

```text
Is activation working AND wedge clear AND one organic channel producing signups?
├── No to any → Defer paid. Paid traffic on a broken funnel burns money;
│               paid traffic on fuzzy positioning learns nothing; paid traffic
│               with no organic baseline can't be measured against a counterfactual.
└── Yes to all
    │
    └── Can the team afford 90 days of paid testing at the current burn rate?
        (Per `references/discovery-flow.md` STEP 0.5.1 assumption "Paid budget")
        ├── No (budget $0 or <$500/mo) → Defer; founder-led content is higher
        │                                 leverage at this stage.
        └── Yes
            │
            └── Does the pricing produce CAC payback within 12 months?
                ├── No → Raise price or improve conversion before paid; otherwise
                │        each customer is acquired at a loss.
                └── Yes → Start small (one channel, one offer, $500-1000/mo).
                          Define the kill rule BEFORE launching: "if CAC payback
                          >18 months OR ICP match <50% after 60 days, stop."
```

## Tree 4: Which test should we run first?

Use when the audit produces multiple Critical or High findings and the customer asks "which one first?"

```text
What is the biggest uncertainty in the recommendation?
├── ICP / segment unclear     → Customer-discovery interviews
│                                (per `references/customer-discovery-script.md`)
├── Wedge / positioning fuzzy → Name the gap with Cat 81, get the drafts from
│                                 the Skill tool with "snitch-cmo", test on
│                                 10 buyers with a 5-second test
├── Pricing / WTP unclear     → Fake-door pricing test or 5 pricing interviews
│                                 (display tactics: Cat 115; the strategic read
│                                 comes from the Skill tool with "snitch-cmo")
├── Hero copy weak            → A/B test on hero variant if traffic supports it
│                                (rare for indie); else rewrite from VOC and ship
├── Channel viability         → Small-budget channel test ($500 ceiling) with
│                                 ICP-qualified-intent as the success metric
├── Onboarding / activation   → Session replay + 5 onboarding interviews;
│                                 fix the highest-dropoff step
└── Retention                 → Cohort analysis + 3 customer-success interviews
                                 with paying customers who've stuck around
```

Pick the biggest uncertainty first. Running 5 tests in parallel produces noise; the team learns more by sequencing.

## Tree 5: Brand is brand-new — what's the first move?

Use when STEP 0.6 brand maturity scored `none` across off-site surfaces and the brand has been live <90 days.

```text
Has the founder talked to 10 named target customers?
├── No → Stop everything. Talk to 10 customers in 30 days. Use the script
│        in `references/customer-discovery-script.md`. Mine their language;
│        rewrite hero from real quotes.
└── Yes
    │
    └── Does the homepage answer "what is this, who is it for, what changes if
        I use it" in 5 seconds?
        ├── No → Name the gap with Cat 81 (positioning) + Cat 117 (copy lint);
        │        get the drafts from the Skill tool with "snitch-cmo"; ship
        │        three; let three target customers pick one.
        └── Yes
            │
            └── Are there 3 named testimonials?
                ├── No → Get 3 testimonials this month. Email or text every
                │        existing customer; ask 2 questions; quote with permission.
                └── Yes → Ship the changelog page; commit to weekly updates;
                          start founder-led posting (3x/week, per Cat 84).
                          Re-audit off-site presence in 90 days.
```

The brand-new tree intentionally ignores SEO optimization, paid acquisition, partnerships, and PR. Those moves on a 3-week-old brand burn the launch window and produce no learning. Foundation first.

## Tree 6: Activation is broken — what do we fix?

Use when the north-star metric (`references/strategic-recommendations.md`) scored <60% and the audit recommended pausing marketing to fix onboarding.

```text
Where do users drop off in the first session?
├── Before any value delivery (signup → blank dashboard)
│   └── Time-to-first-value is too high. Add a sample dataset / demo project /
│       templated onboarding flow. Goal: user sees ANY working state within
│       60 seconds of signup.
├── At a setup step (auth, install, config)
│   └── Reduce setup friction. Single-click OAuth, hosted demo, optional
│       config with sensible defaults. Each setup step removed compounds.
├── At first action (user gets to the dashboard but doesn't act)
│   └── The first action isn't obvious or isn't compelling. Add an in-product
│       prompt that surfaces the highest-value action; track the click as the
│       activation event.
└── At first value delivery (user acts but the result isn't valuable to them)
    └── This is a wedge problem masquerading as an onboarding problem. The
        segment that's signing up may not be the segment that benefits from
        the product; re-score the segments by calling the Skill tool with
        "snitch-cmo".
```

## When a leaf and the customer disagree

The trees are defensible answers, not commitments. If the customer has knowledge the audit doesn't (a specific founder constraint, a competitor's signal, a regulatory change), the customer's knowledge wins. The audit's job is to make its reasoning visible so the customer can override deliberately rather than by accident.

Every leaf cites the evidence in the audit that routed there. Override means contradicting that evidence; the customer should be able to name what evidence the audit missed.

## Adding a new tree

Trees are cheap to add when an audit-end state isn't covered. To add one:

1. Name the customer question the tree answers (the root).
2. List the 2-4 observable yes/no questions that route to leaves.
3. Each leaf is a single recommended next action plus the audit cat / reference that owns the detailed playbook.
4. Cross-reference: tree N maps to which STEP 4 leaf and which strategic-recommendations.md tier?

Trees are NOT a substitute for the full Strategic Recommendations document; they are the fast-path when one specific decision is the bottleneck and the audit already knows enough to recommend.
