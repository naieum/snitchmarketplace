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
- **Topic selection — score business potential 0–3** before writing: 3 = the product is the
  natural hero of the solution, 2 = it genuinely helps, 1 = it can only be mentioned in
  passing, 0 = it cannot honestly appear at all. Order the queue by reachable audience ×
  business potential and let the 0s go. Traffic that cannot move the business is a traffic
  source, not a strategy. The scoring needs real product knowledge, which is why
  product-information.md is loaded first. Skip the lens entirely for a local or
  relationship business, where proximity beats searchable problems.
- **Product mentions:** earn them. The post must be useful with the product stripped out;
  the product appears where it genuinely answers the section's problem, plus one closing
  CTA tied to the post's specific intent. On a 2 or 3, weave it into the step where it is
  actually used, framed as why that step gets easier — the advice has to stay complete if
  the brand name were deleted.
- **No dead ends.** Every post's conclusion links somewhere. A post on a 2 or 3 topic gets a
  path to commercial content — directly, or through a comparison or roundup piece when a
  direct plug would read as a lurch.
- **Distribution before creation.** Answer three questions before the piece is written: who
  will this be shared with, who would link to it, and how would it rank, step by step. No
  answers, no piece. Assume search will not deliver the reader on its own.
- **Two layers on purpose:** broad pieces that open the top of the funnel and deep tactical
  pieces that serve the person who will pay. Only one layer is a known failure shape in
  either direction.
- **One lead generator, repeated.** Point every post at the same capture asset rather than a
  different download per post; people act on the sixth to eighth exposure to the same thing
  (`brand-story-and-collateral.md`).
- **Titles close loops the reader already carries** ("how do I deal with X") rather than
  opening new intellectual ones ("three interesting facts about X").
- **First-hand material is the moat.** Tactics are copyable; a real experiment, real numbers,
  or a story only this team could tell is not, and it is what separates the set from
  synthesizable output.
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
- **Mid-tier beats macro.** A creator with a few tens of thousands of followers inside the
  niche usually converts better than one with millions: the audience came for the niche and
  trusts them on it, the integration reads as native, and attribution stays clean. Plan five
  to ten per quarter, not a list of a hundred.
- **Wire attribution before the first message.** Per-creator links or codes, so the answer to
  "how do I get credited?" exists when they ask. Implementing the tracking itself is
  snitch-adsready's territory — call the Skill tool with "snitch-adsready" when the wiring
  does not exist yet.
- **Don't dictate the content.** Creators know their own voice better than the brand does.
  The worst case is honesty about a flaw, which reads as more credible than a glowing
  review.
- **Review at 90 days:** which creator produced which signups and which of those stuck.
  Double down on the one or two that worked, end the rest, and deepen the relationship with
  the winners (early access, a real say in what ships).
- **Failure modes:** template blasts with a name swapped in (each draft cites the
  creator's actual content or it isn't sent). Follower-count-only targeting. Hiding the ask.

## Newsletter & podcast sponsorships

**Job:** buy attention inside a trusted context, at niche scale, with attribution — the
middle path between display advertising nobody sees and macro-influencer spend that rarely
converts.

- **Precondition:** a product and a budget. Pre-product or pre-revenue, this playbook is
  skipped and the channel plan says so.
- **Shortlist by fit, not size:** a handful of newsletters and shows whose audience *is* the
  positioning.md target. A technical product on a general-audience show is money spent on
  the wrong room.
- **One landing page per placement**, at a path that names the show or newsletter, with a
  headline that names it too. Sponsorship traffic pointed at the homepage cannot be
  attributed and converts worse.
- **Custom copy per placement**, written for that audience's situation — and for podcasts, a
  host-read script the host is free to adapt into their own voice. The same paragraph run
  everywhere is the tell that the brand did not listen to the show.
- **Attribution per show:** a vanity path or a unique code, plus a "where did you hear about
  us" field pre-filled where the flow allows. The tracking implementation is snitch-adsready's
  — call the Skill tool with "snitch-adsready".
- **Decide at 90 days** on conversions per dollar: extend the top one or two into a longer
  arrangement, end the others.
- **Failure modes:** generic ad copy across every placement. No per-show attribution, so the
  whole test is unmeasurable. Sponsoring the biggest available audience instead of the
  closest one.

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

## Owned community (Discord, Slack, subreddit, forum, discussions)

**Job:** a place the brand owns that compounds, instead of an audience rented from a
platform. Slower to start than social, far more durable once it holds.

- **One platform, not three.** Synchronous chat, async discussions, or long-form forum —
  pick by where the audience already talks. Two half-full rooms never reach critical mass.
- **A community is a tribe, not a help desk.** A channel that only answers support questions
  is support. Four mechanics make it something people belong to:
  1. **A core belief**, statable as "we are people who believe/do X" — never the feature
     list. The strongest documented cases sold membership in an identity rather than asking
     for a behavior, and changed the behavior anyway.
  2. **A badge** — a phrase, a symbol, a ritual members use to signal they are one of the
     group.
  3. **A named villain** — a behavior or root cause, never a person or a competitor
     (`brand-story-and-collateral.md` carries the rules).
  4. **Members celebrated in public** — spotlights, featured work, amplification. When
     members remix the brand's material, feed it rather than police it: the member is the
     hero and the brand is the guide. The campaigns that compounded were the ones where the
     smallest contributor became the story.
- **Someone owns it.** A few hours a week, consistently: welcome new members by name within a
  day, answer inside a day, pin the FAQ, run something recurring. A community the founder
  shows up in compounds; one they ignore fills with spam.
- **Ethics gate applies inside the community too** — disclosure of who works for the brand,
  no manufactured enthusiasm, no seeded questions answered by the team in disguise.
- **Failure modes:** promoting an invite that has expired. Broadcast-only posting with no
  member ever featured. Starting a second community before the first is alive.

## Founder channel

**Job:** the founder's own audience, which for most small products outperforms the brand
account because people trust people. This playbook drafts *for* a named human, so the
disclosure identity in brand-voice.md is not optional here.

- **Three or four repeated themes, not ten.** A channel about everything is about nothing,
  and interest-based feeds cannot categorize a scattered account. Bio words and post words
  should agree.
- **Include the identity line.** Lead with what people came for, then close — roughly every
  third or fourth post — with a fixed, repeatable line: who this is, what they do, and who
  they can help with what. Followers do not infer that the founder is for hire, or even what
  the product is. Never *opening* with the pitch is right; never including it is the mistake.
- **Stay in category.** Adjacent topics are fine. Off-category ones confuse the audience the
  channel built, and the posts that go viral off-category rarely build the thing being built.
- **Pivot by sprinkling, never by announcement.** Shift the message gradually over months
  while staying present for the audience that already exists. Two gates before any pivot: is
  this boredom rather than a real change, and has the new position been earned in practice?
- **Voice:** the founder's, not the brand's marketing copy — specific, opinionated,
  first-hand. The product link lives in the bio and appears in posts occasionally; the
  channel is the discovery surface, the site is the conversion surface.
- **Failure modes:** posting consistently while never naming what the brand does. A cadence
  that burns out in three weeks. A personal voice that contradicts brand-voice.md badly
  enough that the two read as different companies.

## Launches & PR

**Job:** manufacture the signal that press follows. Journalists cover what is already
moving, so the cold pitch is the last step, not the first.

- **The sequence:**
  1. The founder posts the announcement on their own channels first — personal trust
     outperforms the brand account, and it keeps the narrative under the brand's control.
  2. The link-aggregator or community submission that fits the product, at the hour that
     community is awake. It decides whether the thing is interesting; the Hacker News
     playbook above governs the draft if that is the venue.
  3. The launch-directory listing, hunted by the founder rather than a stranger, on the same
     day.
  4. Newsletter and podcast placements arranged in advance so they land in the same window.
  5. Creator content timed to coincide.
  6. Only then, the press pitch — into visible traction rather than into silence.
- **Pitch an angle, not the product.** Editors and hosts book *angles*: a provocative, true
  claim adjacent to the product that a non-customer would care about. A press release that
  describes features and funding is a press release nobody runs.
- **Ride attention; do not manufacture it.** Nobody is paying attention to the brand, but
  everyone is paying attention to *something*, and that attention moves. The operational
  form is a standing weekly question: what is the niche paying attention to or angsty about
  right now, and where does the product genuinely touch it? The winning post is usually a
  wink the informed audience decodes, not a press release. Expect roughly one hit in ten, and
  expect pushback, which is itself attention. Two hard limits: the connection has to be real,
  and tragedy is not a launch window.
- **The press page is for inbound**, not for activation: logo files in both themes, brand
  colors, founder bios, a contact address, and links to coverage as it accumulates. Build it
  when the product is old enough to get asked.
- **Most launches get one window.** Use the traction from this one to seed the next quarter's
  story: what shipped, and what users said about it.
- **Failure modes:** pitching press before there is anything to point at. A "launch" with no
  single artifact to link. Recycling the same announcement across every venue verbatim
  (each venue gets its own draft, per the shared rules above).
