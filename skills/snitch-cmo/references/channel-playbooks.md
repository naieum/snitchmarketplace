# Channel playbooks

Per-channel drafting rules for Drafting mode. Shared rules first, then one playbook per
channel. Every playbook assumes the foundation is loaded (brand-voice.md and
product-information.md always; positioning.md for anything persuasive) and every draft
carries the provenance header defined in SKILL.md.

**Shared rules (all channels):**

- Claims obey the evidence gate; angle and voice come from the foundation, not generic
  marketing instinct.
- One draft = one angle. A draft trying to say three things says nothing; split it.
- Write for the channel's native reader, not for the brand. The test: would a member of
  that channel who has never heard of the product find the post worth their time *even if
  they never click*?
- Drafts land in `marketing/drafts/<date>-<channel>-<slug>.md`. Human publishes.

---

## Blog / long-form

**Job:** own a pillar query and be citable — by readers and by AI answer engines.

- **Structure:** answer-first. Title states the question or claim; the first paragraph is a
  complete, standalone, correct answer (it's what answer engines extract). Then structured
  H2s, one idea per section, evidence per claim.
- **Angle source:** a pillar and example title from content-strategy.md, or a competitor
  gap from competitor-analysis.md (comparison posts must keep the "where they win" honesty
  — a comparison that never concedes anything convinces no one).
- **Product mentions:** earn them. The post must be useful with the product stripped out;
  the product appears where it genuinely answers the section's problem, plus one closing
  CTA tied to the post's specific intent.
- **Failure modes:** listicle padding. Intro throat-clearing before the answer. Invented
  stats to sound authoritative (evidence gate). Keyword-stuffed headings that read as
  written for a crawler.
- **Handoff:** for on-page SEO mechanics (title tag, schema, internal links), the published
  page is snitch-marketing's territory — note it in the draft report.

## X (Twitter)

**Job:** compressed insight that earns a follow; distribution for pillars; build-in-public
credibility.

- **Structure:** single post by default — one observation, one concrete detail, no hashtag
  pile. Thread only when the content genuinely has 3+ steps; first post of a thread must
  stand alone.
- **Register:** brand-voice.md `## Register by channel` (default: tersest register; cut
  every word that survives cutting).
- **Angle source:** a real build detail, a number from product-information.md, a sharp take
  a pillar owns. Screenshots of real product beats described product.
- **Failure modes:** engagement-bait questions. "🧵 1/14" padding. Hype adjectives the
  banned list catches. Posting the LinkedIn draft unchanged.

## LinkedIn

**Job:** reach the buying-committee reader; fuller register than X, same voice.

- **Structure:** hook line that states the tension in the reader's job (not "excited to
  announce"), short paragraphs, one concrete story or number, plain close — a question only
  if it's one the author actually wants answers to.
- **Angle source:** positioning.md's "alternative we replace" makes the best LinkedIn
  material: name the status-quo pain the target lives with, show the wedge.
- **Failure modes:** broetry line breaks. Humble-brag framing. "Agree?". Announcing
  features nobody outside the team can care about — translate every feature to the
  reader's outcome before posting.

## Reddit

**Job:** be a useful, disclosed community member whose product is sometimes the honest
answer. Reddit converts trust, not impressions — and it detects marketing instantly.

- **Disclosure is non-negotiable** (ethics gate): every post and comment uses the identity
  from brand-voice.md `## Disclosure identity`. "I built this" posts, honestly framed,
  are a respected genre on most maker-adjacent subreddits; undisclosed promotion is the
  fastest ban available.
- **Before drafting:** identify the target subreddit's self-promotion rules (many allow it
  only on set days, with flair, or at a comment-to-post ratio) and state them in the
  provenance header. A draft that violates the sub's rules doesn't get written.
- **Structure:** plainest register the brand has. Lead with the problem and what was
  learned building the solution; the product link goes where the sub's rules put it. Invite
  criticism and mean it — the comment section is the post.
- **Failure modes:** the "just found this cool tool" astroturf (blocked, ethics gate).
  Cross-posting one draft to eight subs (each sub gets its own or none). Defensiveness in
  drafted comment replies. Any invented "we" scale ("our users love") a solo project can't
  evidence.

## Hacker News

**Job:** a Show HN or a substantive post that survives the most claim-hostile audience on
the internet.

- **Show HN rules:** title is "Show HN: <what it literally is>" — no superlatives, no
  mystery. The first comment (drafted alongside the post) explains what it is, why it was
  built, the stack, honest limitations, and what feedback is wanted. Limitations up front
  is the credibility move: HN forgives gaps, not concealment.
- **Every claim gets pre-hostile-review:** before the draft is done, re-read it as the top
  skeptical commenter and fix what they'd catch (evidence gate, applied adversarially).
  Pricing, license, and self-hosting answers should be ready because they will be asked.
- **Failure modes:** marketing voice of any kind (HN's register is brand-voice.md's
  plainest, minus even mild promotion). Overclaiming novelty ("first ever" invites the
  comment proving otherwise). Ignoring the sub-question everyone asks ("how is this
  different from X" — competitor-analysis.md is the prep for exactly this).

## Newsletter

**Job:** compound the audience the product owns — the list nobody's algorithm can take
away.

- **Structure:** one issue = one useful idea from a pillar, written to be worth reading
  with the product stripped out, plus at most one product note (a real change, honestly
  sized). Subject line states the idea, no clickbait gap.
- **Cadence:** content-strategy.md's confirmed cadence; a skipped issue beats a padded one.
- **Failure modes:** the "here's everything we did this month" changelog dressed as a
  newsletter. Borrowed-authority roundups with no original point. Growth-hack subject
  lines the banned list catches.

## Creator / influencer outreach

**Job:** a researched shortlist and honest first-touch drafts — not a volume play.

- **Shortlist format:** 5–15 creators, each with: where they publish, why *their audience*
  matches positioning.md's target (cite a specific piece of their content read this run),
  and what's genuinely in it for them (early access, a real story, revenue share the user
  approved — never implied payment the user hasn't offered).
- **First-touch draft:** short, specific to their named work, upfront about who's asking
  (disclosure identity) and what's being asked, easy to decline. One follow-up maximum in
  the sequence; no "bumping this" chains.
- **Failure modes:** template blasts with a name swapped in (each draft cites the
  creator's actual content or it isn't sent). Follower-count-only targeting. Hiding the ask.

## UGC video briefs

**Job:** a brief a creator (or the founder with a phone) can shoot from without inventing
claims.

- **Brief format:** hook (first 2 seconds, the pain in the viewer's words), beats (3–6
  shots/lines, each tied to a real capability with its product-information.md evidence
  noted in the brief so the creator can't drift into overclaim), demo moment (the product
  visibly doing the thing — real UI, not described UI), close (one CTA), plus the "never
  say" list from positioning.md's `## Claims we never make` and brand-voice.md's banned
  list.
- **Tone:** native to the platform it's for (specify which); a UGC brief that produces an
  ad reads as an ad and dies as both.
- **Failure modes:** scripting testimonial-style lines for a creator who hasn't used the
  product ("I've been using this for months" from someone who hasn't is a fake review —
  ethics gate). Claims in the brief without evidence pointers. Briefing outcomes the demo
  can't visibly show.
