# Archetype: Content Site

Anything consumed by reading — attention and return visits are the product, whatever form
the writing takes (posts, docs, editions, a portfolio's case studies). The build-time trap
is specific to this archetype: infrastructure enthusiasm (taxonomies, tag clouds, five
content types) built for a corpus of zero posts. The blueprint inverts it: the smallest
structure that serves the first ten pieces, and a cadence the author will actually keep.

## Decisions this archetype forces (from the interview)

- **The entity.** Who is speaking — a named person, a team, a brand? Everything hangs on
  this: bylines, the about page, `author` schema, and whether AI search engines can
  attribute the content to a credible entity at all (GEO lives or dies on entity clarity).
  An anonymous blog is a recorded decision with a recorded cost.
- **Pillars, then one.** 3-5 topic pillars, and the ONE the first ten pieces concentrate
  on. Ten pieces on one pillar build topical authority; ten pieces on ten topics build
  nothing. The other pillars are DEFERRED entries with the trigger "pillar 1 has 8-10
  substantial pieces."
- **The honest cadence.** The sustainable number, recorded. The build is sized to it: a
  weekly writer needs exactly a post template and an index; a daily team needs more. Dead
  cadence is the archetype's signature failure — a "latest posts" section showing an
  18-month-old post is anti-marketing, so the blueprint prefers date-light design if
  cadence confidence is low (a recorded default, not a trick).
- **The reader's conversion action.** Newsletter signup / RSS / product referral /
  portfolio inquiry. Decided once, present consistently, instrumented.

## Conversion action

Default: **newsletter signup** — the only reader relationship the site owns outright.
Capture is honest: inline after the content proves worth reading, a clear what-and-how-often
promise, no entry-blocking modals. Portfolio variant: the inquiry email/form. Referral
variant: the outbound click, instrumented.

## Surface inventory and build order

1. **The post/article template** — the real product. Spec: readable measure (~65-75ch),
   strong typographic hierarchy, byline linking to the author entity, honest dates
   (updated-on beats published-on for evergreen), code blocks / figures / pull-quotes as
   the pillar demands, the conversion action once inline and once at the end, per-post
   metadata + `Article`/`BlogPosting` schema wired into the template so every future post
   inherits it for free.
2. **Home / index** — job: a new reader knows in 5 seconds whose site, what topic, why
   subscribe. Latest + a curated "start here" for the pillar (the corpus's front door for
   both new readers and AI citation).
3. **About page** — the entity page: who, credentials, why trust this voice on this
   pillar. Second-most-visited page on small content sites; not an afterthought.
4. **The first three pieces** — content enters the build order as numbered items exactly
   like pages. A content site launching with zero content is a template, not a site;
   launch-with-three is the floor.
5. **Newsletter plumbing** — a real list, a real welcome email, the promise kept.
6. **DEFERRED by default:** tags/categories (trigger: ~15+ pieces make browsing real),
   search (same), comments (trigger: someone will moderate), additional content types,
   additional pillars.

## Day-one wiring (beyond build-defaults.md)

- Full-content RSS/Atom from launch [free] — readers, aggregators, and AI crawlers all
  consume it.
- `Article` schema with the real `author` entity; `Person`/`Organization` schema on the
  about page.
- GEO defaults, since AI answers now mediate content discovery: entity-clear bylines,
  dateModified kept honest, an `llms.txt` if the corpus warrants it, and crawlability
  decisions recorded (allow or block AI crawlers is a *decision* in the blueprint — either
  is valid; silence is not).
- OG image template so every piece shares well from day one; per-piece descriptions written
  at publish time, not backfilled.
- Static rendering — content sites have no excuse for client-rendered articles.

## Handoffs

snitch-cmo for distribution (channel playbooks for taking each piece to X/LinkedIn/Reddit/
HN — writing is this archetype's build, distribution is cmo's job); snitch-marketing to
grade the live site (GEO score, schema, CWV); snitch-docwriter if the pillar is technical
documentation and the prose needs the controlled-style pass.
