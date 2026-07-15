# Copy Bank Templates

Lift-and-deploy copy templates the brand can use today. Each template has a structure, a fill-in-the-blank version, and notes on when to use it. None of these are vendor-specific; they're patterns that work across most indie SaaS, content brands, and personal brands.

The audit surfaces this reference from STEP 4.5 when channel work is recommended (founder-led posting on X / LinkedIn, Reddit replies, comparison-page seeding, lifetime-offer launches). Customers often ask "what should I actually post?" The templates answer that without making the team start from a blank page.

## Pattern 1: Twitter / X bio (founder-personal handle)

```
I built [product]. [One-sentence positioning].
[Pricing line if relevant; e.g., $X/mo, free up to Y].
[Audience line; e.g., For people who {pain or goal}].
```

When to use: when moving from a brand handle (`@productname`) to a personal founder handle. Cat 84 founder-led brand context.

Worked example:

```
I built Atlas. Form backend for sites without a backend.
$0-$79/mo, free up to 50 submissions/mo.
For developers and no-code builders who don't want to wire up email + storage.
```

## Pattern 2: One-line app description (across stores, directories, link previews)

```
[Product]: [what it is] for [job-to-be-done], on [platforms]. [Differentiator]. [Price line].
```

When to use: app stores, directories, "made by" link previews, any place that needs the brand in 100 characters or less.

Worked example:

```
Atlas: form backend for HTML forms, on any site. Webhooks, file uploads, REST API. From $0.
```

## Pattern 3: Reddit cold reply (when someone asks the question the brand solves)

Search the relevant subreddit for the recurring question pattern. Reply only when the brand is genuinely the best answer for the asker's specific situation. Disclose ownership.

```
The thing that worked for me wasn't [common assumed solution] — it was [actual mechanism].
I [verb] using [product]: [one-sentence how it works].
I built [product] (https://[domain], [pricing]). Happy to answer questions about [adjacent topic].
There are [N] decent options now and the right one depends on [the variables].
```

When to use: r/RSI, r/programming, r/SaaS, r/IndieHackers, niche industry subreddits. Don't post promo links. Reply to genuine questions. Disclose you built it.

Worked example:

```
The thing that worked for me wasn't another keyboard, it was typing 60% less.
I use voice dictation behind one hotkey: hold the key, talk, words appear in whatever app I'm in.
I built the tool I use (https://getabe.app, $6/mo, free up to 2k words/week). Happy to answer
questions about voice setups in general — there are 4-5 decent options now and the right one
depends on whether you need offline, what platform you're on, and how technical your vocabulary is.
```

## Pattern 4: LinkedIn post (founder-led launch / milestone announcement)

```
[Direct opener — what you're announcing].

[Why it exists / what changed for you / why now].

[Specific offer or call-to-action with a clear deadline or cap].

[Honest tradeoff or "what this is NOT for" line].

[Link].
```

When to use: lifetime offer launches, version releases, milestone posts (1,000 users, 1 year, etc.), category-defining essays.

Worked example:

```
We're selling 1,000 lifetime Pro accounts at $99 each.

Pay once, use Atlas forever. The cash funds the on-device version we're shipping next quarter,
and gives me a few hundred long-term users who help decide what gets built next.

When the 1,000th sells, the offer closes. No extension.

This is for: people who already use voice dictation regularly and want to lock in.
This is NOT for: people who haven't tried voice dictation yet — try the free tier first.

[Link to honest comparison page against Wispr Flow / Superwhisper / Aqua].
```

## Pattern 5: Hero subhead (3 variants for A/B candidates)

When Cat 81 (positioning) recommends multiple drafts and a high-severity finding requires concrete copy:

**Variant A: pain-led**

```
[Pain you're feeling]. You [tried this]. It didn't fix it. [Product] [does the thing that does fix it]. [Price line].
```

**Variant B: substitute attack**

```
You bought [the thing they tried first that didn't work]. You bought [second thing]. Your [pain] is still there at [time of day]. The thing you haven't tried is [the brand's mechanism]. [Product] is [job-to-be-done] that works in [context], for [price].
```

**Variant C: quiet confidence**

```
[Product type] that gets out of your way. [One mechanism description]. [Price line]. [Trust signal — no card / cancel anytime / honest tradeoff].
```

When to use: pricing-page hero, homepage hero, top-of-funnel landing pages. Run all three for 30 days; the winner becomes the homepage. Variant B usually outconverts in indie SaaS because it names the buyer's actual prior-art and meets them where they are.

## Pattern 6: Email subject line (welcome / activation)

```
[Specific action verb] [specific thing] in [specific time]
```

When to use: welcome emails, activation reminders, post-signup nudges. Specific beats clever.

Worked example:

```
Send your first form submission in 5 minutes
```

NOT: "Welcome to Atlas!" (vendor-framed; tells the reader nothing).

## Pattern 7: Comparison page positioning sentence

For each `/compare/{competitor}` page, the page leads with one sentence that names the honest tradeoff:

```
[Brand] is [shorter / cheaper / simpler / faster / more X] than [Competitor]. [Competitor] is better at [specific thing]. Use [Brand] if [trigger condition]; use [Competitor] if [trigger condition].
```

When to use: every comparison page on the site. Cat 95 (programmatic SEO) specifically calls for honest comparison content.

Worked example:

```
Atlas is cheaper and simpler than Formspree. Formspree is better at advanced spam filtering and has been around longer. Use Atlas if you want a free-forever tier with no usage caps and your spam needs are normal; use Formspree if you need fine-grained spam controls or want a longer-tenure vendor.
```

## Pattern 8: "Things X is NOT for" section (Cat 111 trust artifact #5)

```
[Product] is NOT a good fit for:

- [Use case 1] — try [appropriate alternative] instead.
- [Use case 2] — [reason it's not a fit].
- [Use case 3] — [planned for future / never planned].
```

When to use: homepage scroll, dedicated `/not-for` page, footer link. Naming what the product doesn't do increases credibility on what it does.

Worked example:

```
Atlas is NOT a good fit for:

- HIPAA-regulated forms collecting PHI — we don't have a BAA.
  Try Formstack or Cognito Forms.
- Multi-step survey flows with branching logic — we're a backend, not a survey tool.
  Try Typeform or Tally.
- Heavy payment forms (we don't do PCI). Try Stripe Checkout.
```

## Pattern 9: FAQ entry (lead with the buyer's actual question)

Most FAQs lead with vendor-framed questions ("How accurate is X?", "What features do I get?"). Lead with the buyer's actual question instead, identified from `references/customer-discovery-script.md` output.

```
Q: [The exact question a real customer asked, verbatim from a discovery call]
A: [Honest answer, no marketing dress-up]. [Concrete next step or link].
```

When to use: FAQ rewrite per Cat 81 / Cat 35. Shipped in week 2 of the 30/60/90 plan after discovery calls produce the verbatim questions.

Worked examples (from a real discovery call):

```
Q: "What happens if my internet drops?"
A: It doesn't work offline today. The audio gets sent to the API for transcription. We're working on an on-device mode for the next quarter. If you need offline-only, [competitor] is your best option today.

Q: "Is my voice training a model somewhere?"
A: No. Here's exactly what happens to your audio: [diagram]. Audio is deleted within 60 seconds of transcription. Transcripts are not stored on our servers. You can verify this on our privacy page.
```

## Pattern 10: Show HN post (Hacker News launch with a wedge angle)

The post is not "Show HN: I built another [category] tool." It's "Show HN: I built [category] specifically for [audience] because [trigger story]."

```
Show HN: [Product, with the wedge audience named]

[2-3 sentence trigger story: why you built it, what made you write the first line of code].

[2-3 sentences on what makes this different from the existing options. Name competitors if relevant. Be honest about where they're better].

[Link to the homepage and to a comparison / "why this and not [main competitor]" page].

[Closing question that invites genuine discussion, not "what do you think?"].
```

When to use: Cat 77 PR launches when the brand has wedge clarity, 10+ testimonials, and a compelling demo. Don't launch on HN before that.

Worked example:

```
Show HN: I built voice dictation specifically for people whose wrists hurt

I was told I'd be in pain forever. The split keyboard didn't fix it. The vertical mouse didn't fix it. Typing 60% less was the thing that actually fixed it, and that meant voice dictation that worked everywhere I type.

The existing tools fell into two camps: built-in OS dictation (Win+H, Mac dictation), which was so bad it soured most people on the category, OR Wispr Flow at $15/mo with cloud transcription that takes a screenshot of your screen as part of its processing. Neither worked for me.

Atlas is voice dictation behind one hotkey, $6/mo, no card to try, audio deleted after transcription, no screenshots. Honest comparison page against Wispr Flow / Superwhisper / Aqua here: [link].

If you've also tried solving wrist pain with hardware that didn't fix it, what worked for you?
```

## Pattern 11: Cold customer-discovery email (recruits real interviews, not feature feedback)

The wording matters more than it seems. The customer who shows up to the call already expecting a pitch will deflect every question; the customer who shows up understanding it's a research call will tell you what's true. The "I'm not going to pitch you" line and the "where it breaks" line do the heavy lifting.

```
Hi [name],

I'm [your name], the founder of [product]. I'm spending 30 minutes
each with 20 customers this month to understand what's working and
what isn't.

I'm not going to pitch you anything, and I'm not going to ask if
you'd buy a feature. I just want to hear about your workflow and
where it breaks. Honest answers are worth more to me than polite
ones.

Can we set up a half-hour call this week or next?

[scheduling link]

Thanks,
[name]
```

When to use: recruiting customer-discovery interviews per `references/customer-discovery-script.md`. Send to: most-recent paid, longest-tenured paid, highest-revenue paid, lowest-engagement paid (about to churn), high-usage non-converted, mid-usage non-converted, low-usage non-converted. Two cohorts of 10.

Variations:

For users who haven't converted from free to paid:

```
Hi [name],

You signed up for [product] [N] days ago and haven't gone Pro. That's
useful data for me. I'm trying to understand why people stick with the
free tier (totally fine), why some upgrade, and what's blocking those
who don't.

15 minutes, no pitch, no upsell. I just want to understand your
workflow and where [product] fits or doesn't.

[scheduling link]

Thanks,
[name]
```

For long-tenured paying users:

```
Hi [name],

You've been a [product] customer for [N] months. I'm trying to learn
what you actually do with it day-to-day, what almost made you cancel,
and who you'd recommend it to.

30 minutes. I won't pitch you a new feature. I'll just listen.

[scheduling link]

Thanks,
[name]
```

## Pattern 12: Sales narrative homepage scroll structure

For brands with strong positioning but weak homepage narrative, the scroll matches the 6-part narrative arc (Cat 81). Each section answers a specific question for the reader who scrolls, and the sequence builds belief, not just feature awareness.

```
Hero (above fold):       INSIGHT
                         The shift the buyer already feels.
                         Not the brand's claim; the world the buyer lives in.
                         "Cookies are over." / "Your hands hurt at 4pm."

Section 1:               ALTERNATIVES
                         What they've tried that didn't work.
                         Names competitors and substitutes by name. Honest about what those do well.

Section 2:               PERFECT WORLD
                         What life looks like when the problem is solved.
                         Brand isn't introduced yet. Pure outcome, vivid.

Section 3:               INTRODUCING THE SOLUTION
                         How this product delivers the perfect-world outcome.
                         Mechanism, screenshot, demo, the unique attributes from positioning step 2.

Section 4:               PROOF
                         Three named testimonials with role + photo. Demo video.
                         Customer logo bar. Screen recording of the workflow.
                         Specific metrics where defensible.

CTA section:             ASKING FOR THE SALE
                         Specific ask, time-bound.
                         Try free for 14 days, no card.
                         Book a demo this week.
                         Buy the lifetime tier before the cap closes.
                         Generic CTAs ("learn more") fail this section.
```

When to use: SaaS homepage rewrites where Cat 81 finds a strong position but a weak narrative arc. Most "feature-list scroll" homepages benefit from this restructure even when individual section content is good.

Worked example skeleton (using the Atlas/RSI wedge from earlier patterns):

```
Hero:    "Your wrists shouldn't hurt at 4pm."
         You bought the split keyboard. You bought the vertical mouse.
         The pain came back anyway.

Section 1 (Alternatives):
         What you've already tried:
         - Built-in OS dictation (Win+H, Mac Dictation): so bad it makes most people give up on voice.
         - Wispr Flow ($15/mo): solid product, but cloud-processed with screenshots-during-capture privacy.
         - Superwhisper ($8.49/mo, Mac-only): on-device privacy, but Mac-only and pricier.
         - Doing nothing and pushing through pain: not a sustainable plan.

Section 2 (Perfect world):
         What if your hands didn't hurt by 4pm?
         You'd type 60% less without losing speed.
         You'd write the same emails, code reviews, tickets, with your voice.
         You'd close your laptop at 5pm without ice packs.

Section 3 (Solution):
         [Brand] is voice dictation behind one hotkey, on Windows and Mac.
         Hold Ctrl+Shift+Space, talk, your words appear at your cursor in any app.
         Audio is deleted after transcription. No screenshots, no stored transcripts.
         $6/month. Free up to 2,000 words a week.

Section 4 (Proof):
         [3 named testimonials with photos]
         [30-second demo video]
         [Logo bar: works in Slack, Gmail, VS Code, Notion]
         [Screen recording of the actual workflow]

CTA:     Try free, no card.
         Download for Windows  •  Download for Mac
         3-second install.
```

When to use: Cat 81 high-severity narrative finding, in conjunction with Pattern 5 (three hero variants). Pattern 5 produces the hero candidate; Pattern 12 produces the structure for the rest of the scroll.

## Pattern 13: "Shouldn't and won't" (injustice → relief line)

```
You shouldn't have to [pain/injustice], and with [product], you won't.
```

A universal sound-bite generator: "shouldn't" names the pain as an injustice (loss framing, which outpulls gain framing), "won't" promises the relief. Works on headers, ad copy, intake scripts, billboards. Repeat one canonical version verbatim.

Worked examples:

```
Your sales team shouldn't waste hours on manual reports — with Atlas automations, they won't.
You shouldn't get ripped off by insurance companies. If you hire us, you won't.
Your legs shouldn't look like that — and after this procedure, they won't.
```

When to use: Cat 81 pain-led hero drafts (Pattern 5 Draft A), ad creative for Cat 67, anywhere the problem line exists but reads flat.

## Pattern 14: Decision-trigger close (+ fence-sitter email)

```
If you're struggling with [problem], [buying X / signing today] is the right decision.
```

The fence-sitter's only real question is "is this the right decision?" — they'll say "let me think about it" hoping it gets affirmed at home, where you won't be. Answer it verbatim: tie the verdict to the named problem, never a bare "you should buy." Place on the pricing page, in proposals, at the end of sales conversations.

Fence-sitter follow-up email skeleton:

```
[Warm open — reference the real conversation.]

I want to be really clear:

[Restate their problem in their own words, with its cost — one short paragraph.]

If I've heard you correctly, signing today is the right move, because it solves
exactly that problem. [One-line concrete next step.]
```

When to use: Cat 60 / Cat 99 conversion findings where the funnel has traffic and trust but weak asks; any recommendation replacing a "Learn more" CTA.

## Pattern 15: Founder identity line (the Trojan-horse close)

```
By the way, I'm [name]. I'm a [role]. If you're [struggling with X], I can help you [outcome].
```

For founder channels: lead with content people actually want, close with this fixed line in roughly every 3rd-4th post. Followers won't infer what the founder sells; the line says it, identically, until it's memorized.

When to use: Cat 84 findings "no recurring identity/offer line" or "topics scattered"; pairs with Pattern 1 (bio) and Pattern 4 (LinkedIn post).

## Pattern 16: Customer-welfare mission line

```
We exist so that [person] no longer has to experience [pain].
```

Derived by asking "who is worse off without this product, and how?" Replaces inward-facing mission copy ("our mission is to build the best X") on about pages and in PR boilerplate. A bystander should hear it and think "the world needs that."

When to use: Cat 81 "mission copy inward-facing" finding; Cat 77 press-kit boilerplate; about-page rewrites.

## How to use this reference

The audit recommends specific templates from this bank when the strategic-recommendation surface calls for channel work. Don't dump all 16 templates on every recommendation; pick the ones that fit the actual move.

Examples:

- Cat 84 (founder-led brand) recommendation → Pattern 1 (Twitter/X bio), Pattern 4 (LinkedIn post).
- Cat 77 (PR / launches) recommendation → Pattern 10 (Show HN), Pattern 4 (LinkedIn announcement).
- Cat 95 (programmatic SEO) for `/compare/*` pages → Pattern 7 (comparison positioning sentence).
- Cat 111 (trust artifact audit) for "not for" section → Pattern 8.
- Cat 81 (positioning) high-severity → Pattern 5 (3 hero variants).
- Cat 35 (FAQ schema) + Cat 81 high-severity → Pattern 9 (FAQ entries).
- Customer-discovery recommendation (from STEP 4.5) → Pattern 11 (cold customer-discovery email, with the variations for free-to-paid and long-tenured cohorts).
- Cat 81 high-severity narrative finding → Pattern 12 (Sales narrative homepage scroll structure), in conjunction with Pattern 5 (three hero variants).
- Flat problem line in hero or ad creative (Cat 81 / Cat 67) → Pattern 13 ("shouldn't and won't").
- Weak or passive ask at the conversion moment (Cat 60 / Cat 99) → Pattern 14 (decision-trigger close + fence-sitter email).
- Cat 84 "no identity line" / scattered-topics finding → Pattern 15 (founder identity line).
- Cat 81 inward-facing mission finding → Pattern 16 (customer-welfare mission line).

## Cross-references

- `references/customer-discovery-script.md`, the input that produces the verbatim language these templates render.
- `references/feedback-signals.md`, the framework for classifying customer language into hero / FAQ / comparison candidates.
- Cat 81 (positioning), the deeper framework these templates serve.
- Cat 84 (founder-led brand), the channel context for Patterns 1, 4, 10.
- Cat 77 (PR launches), the launch context for Pattern 10.
- Cat 95 (programmatic SEO), the comparison context for Pattern 7.
- Cat 111 (trust artifact audit), the trust context for Pattern 8.
