## CATEGORY 127: Google Business Profile feature-deprecation audit (reliance on retired GBP features)

Google retires Google Business Profile (GBP) features on its own schedule, and a marketing
surface that still depends on a feature Google has shut down does measurable harm: dead
links, CTAs that point at a sunset channel, and FAQ content that quietly disappears when the
host feature is wound down. This category audits whether the brand's own site and
local-marketing setup depend on GBP features that Google has retired or is retiring. It is
the dependency audit, not the optimization audit.

Scope note: this is distinct from Cat 79 (local SEO + GBP optimization: is the profile
claimed, is NAP consistent, are reviews answered) and from Cat 118 (GBP depth /
fill-every-field). Those judge whether the profile is well-run. This judges whether the brand
is leaning on features Google has killed. A perfectly optimized profile can still link to a
dead `*.business.site` URL or push a sunset chat channel.

Known deprecations to check (each approximate; verify against Google's current documentation
before reporting):

- **GBP chat / messaging.** Google announced the sunset of GBP messaging around July 2024
  (approx; verify current status). A "Message us on Google" CTA or embedded GBP chat widget
  may now point at a channel that no longer delivers.
- **Google Business "websites" on `*.business.site` / `*.negocio.site`.** The auto-generated
  Business Profile site builder shut down around early-to-mid 2024, and the temporary
  redirects to the GBP profile later expired (approx; verify current status). A brand still
  using one of these as its primary site link is sending customers to a dead or
  redirect-expired URL.
- **GBP Q&A as the home for core FAQs.** The Questions & Answers feature has been reported as
  deprecated / wound down around late 2025 (approx; verify current status). Treating GBP Q&A
  as the canonical home for core FAQ content risks that content vanishing with the feature.
- **Old Posts / product-post API patterns.** Legacy Posts API behaviors and product-post
  formats have changed over time (approx; verify current status). Automation built on retired
  endpoints or formats can fail silently.
- **General.** This surface changes on Google's schedule. Confirm every item above against
  Google Business Profile Help before writing a finding.

### Pre-flight: relevance check

Skip with reason `not applicable` for pure-online SaaS / e-commerce, personal brands, and any
business with no physical location or service area. Use the same local-business gate as Cat
79: a physical address on `/contact` or footer, "Visit us" / "Hours" copy, a named service
area, or an inherently local industry (restaurant, dentist, plumber, retail with stores). If
none of those are present, Skip. Required only for confirmed local businesses. If the brand is
local but you cannot determine which GBP features it depends on, run the on-site checks and
Skip the profile-side checks with a reason, rather than guessing.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md` to confirm the brand is local and to learn its declared
   primary site and contact channels. A `business.site` URL recorded there as the primary
   domain is itself a finding.
2. `Grep` the source for links to `business.site` and `negocio.site` (e.g.
   `grep -rniE "(business|negocio)\.site"`). Quote each match with file:line. This is the
   highest-severity signal.
3. `Grep` for GBP chat dependence: "Message us on Google", "Message on Google", "Chat on
   Google", embedded GBP messaging widgets, or links into the messaging deep-link. Quote with
   file:line.
4. `Grep` for references that route core FAQs to GBP Q&A ("ask us on Google", "see our Google
   Q&A", links into the GBP questions panel). Quote with file:line.
5. Check any in-repo automation (scheduled posts, sync scripts) for old Posts / product-post
   API patterns. Record the file:line and the endpoint / format referenced. Do not assume an
   endpoint is dead without verifying its current status.

If a check cannot run (no source access to a given file, automation lives outside the repo),
Skip that check with the reason and the path you could not reach. Do not infer dependence you
cannot see.

**Crawl mode, required tool calls:**

1. Fetch the homepage, `/contact`, and the footer; scan rendered HTML for `business.site` /
   `negocio.site` links and for GBP chat CTAs. Quote the link text + href, or the CTA +
   selector.
2. Follow any `*.business.site` / `*.negocio.site` link and record the actual response (live
   page, redirect, expired redirect, dead). The destination's current state is the evidence,
   not the assumption.
3. If the brand's GBP is publicly viewable on Google Maps, note which potentially-retired
   features it still surfaces (a messaging button, a linked Business Profile site, a Q&A panel
   used as the FAQ). Capture what you observe; do not judge profile quality here (that is Cat
   79 / 118).
4. Before reporting any feature as retired, confirm its current status in Google Business
   Profile Help and record the date you checked.

### Forbidden claims

- "GBP chat is dead." Name the deprecation, give its approximate date, state that you verified
  current status against Google's documentation (with the date), and quote the CTA / widget
  you found. No deprecation claim without that chain.
- "This `business.site` link is broken." Fetch it and record the actual response first. A live
  or redirecting URL is a different finding from a dead one.
- "The GBP is misconfigured." Out of scope; that is Cat 79 / 118. This category only flags
  dependence on a retired feature, with the link / widget / CTA quoted as evidence.
- "GBP Q&A no longer works." Confirm current status before claiming. Report the dependence and
  the verification date, not an assumed shutdown.

### Detection

On-site grep for `business.site` / `negocio.site` links + GBP chat CTAs + GBP-Q&A-as-FAQ
references, plus a crawl-time fetch of each suspect destination to record its real response,
all cross-checked against Google's current feature-status documentation before any finding is
written.

### What to Search For

- Links to `business.site` or `negocio.site`, especially used as the primary site or in the
  footer / nav
- "Message us on Google" / "Chat on Google" CTAs, or embedded GBP messaging widgets
- Copy that routes core FAQ content to GBP Q&A as its canonical home
- Automation or scripts built on old Posts / product-post API patterns
- Leftover "powered by Google" auto-site badges or template artifacts from the retired
  Business Profile website builder

### Actually Hurts the Marketing Surface

- **A live `*.business.site` / `*.negocio.site` URL used as the primary or site link.**
  Customers are sent to a destination that is dead or whose redirect has expired; the brand
  has no real first-party site at that link.
  Evidence required: the link file:line or href + the actual fetched response (dead /
  expired-redirect) + the Google Help status check with date.
- **A GBP chat / "Message on Google" CTA.** The CTA points customers at a messaging channel
  Google has sunset, so the message may never reach the brand.
  Evidence required: the CTA text + selector or file:line + the deprecation named with
  approximate date and the verification date.
- **Core FAQs depending on GBP Q&A.** The canonical home for FAQ answers sits inside a feature
  being wound down; the content can vanish with it and is not on the brand's own surface.
  Evidence required: the on-site reference routing users to GBP Q&A (file:line / selector) +
  verification of the feature's current status.
- **Automation built on retired Posts / product-post API patterns.** Scheduled local content
  can fail silently when the underlying feature or endpoint changes.
  Evidence required: the script file:line + the endpoint / format referenced + its current
  status per Google's documentation.

### NOT a Problem

- A standard Google Maps embed (the place embed or directions iframe). Not deprecated; keep
  it.
- A current, valid GBP profile link (a `g.page`, `maps.app.goo.gl`, or Maps place URL that
  resolves). A working profile link is not a retired feature.
- A real first-party website on the brand's own domain. The brand is not relying on the
  retired Business Profile site builder.
- A GBP that still shows a Q&A panel the brand does not depend on, where the canonical FAQs
  live on the brand's own site. Presence on the profile is not the same as dependence.
- A feature you suspect is retired but cannot confirm against Google's current documentation.
  Skip with reason rather than reporting an unverified deprecation.

### Context Check

1. Is the brand actually local (Cat 79 gate), and which GBP features can you observe it
   depending on?
2. For each suspected retired feature, what is its current status per Google Business Profile
   Help, and on what date did you check?
3. Is the `business.site` / `negocio.site` link the primary site, a secondary reference, or
   absent? What does the URL actually return today?
4. Does any customer-facing CTA route to GBP chat, and is there a working fallback (phone,
   form, email) if that channel is gone?
5. Are core FAQs hosted on the brand's own surface, or do they depend on GBP Q&A as their only
   home?
6. Is any local-marketing automation built on endpoints or post formats that Google has
   changed?

### Reference

Google Business Profile Help, feature-status and supported-features pages:
https://support.google.com/business/. Confirm the current status of every feature above here
before reporting. Deprecation dates shift; treat the approximate dates in this category as
pointers, not as settled fact.

Cross-ref Cat 79 (local SEO + GBP optimization), Cat 118 (GBP depth audit), and
`references/local-services-playbook.md`.

**Severity tagging:**
- A live `*.business.site` / `*.negocio.site` URL used as the primary or site link → High (dead or redirect-expired destination for real customers).
- A "Message on Google" / GBP-chat CTA → Medium (sends customers to a sunset channel).
- Core FAQs depending on GBP Q&A as their canonical home → Medium (content can disappear with the feature).
- Automation on retired Posts / product-post API patterns → Medium (silent failure of local content).
- A minor or legacy reference to a retired feature with no customer-facing impact → Low (cleanup).

**Fix voice:** `analytics-engineer` (primary) | `solutions-architect` (backup).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> Start with the destination, not the opinion. Before you report anything, open Google
> Business Profile Help, confirm the current status of each feature you flagged, and write
> down the date you checked. Deprecation timelines move; a finding that names a feature as
> retired without that check is an attribution claim you can't support.
>
> Then fix by impact, measured the same way every time:
>
> 1. **The `business.site` link.** This is the one that costs you tracked clicks. Fetch the URL
>    and record what it returns. If it's dead or the redirect has expired, every visit to it is
>    a lost session you can see in the gap between clicks on that link and landings on a real
>    page. Repoint it to the brand's own domain in the footer, nav, contact page, and
>    `LocalBusiness` schema, then confirm the new destination resolves.
> 2. **The "Message on Google" CTA.** It points at a channel Google has wound down, so you
>    can't even measure whether those messages arrive. Replace it with a contact path you can
>    instrument: a phone link, a form with a submit event, or email. Pick the one whose
>    completion you can actually count.
> 3. **FAQs living in GBP Q&A.** If the answer customers need only exists inside a feature
>    being deprecated, it disappears when the feature does, and you have no record of the
>    traffic it was serving. Move the canonical FAQ content onto the brand's own page
>    (cross-ref FAQ schema), where you own the analytics, and let the profile point to it
>    rather than hold it.
> 4. **Automation on old Posts / product-post patterns.** Confirm the endpoint or format
>    against current documentation before you touch it. If it's retired, the job is failing
>    silently and your "posts published" number is fiction. Rebuild it on a supported path, or
>    retire the job and the metric with it.
>
> Verify: re-fetch every link you repointed, re-check each feature's status on the date you
> ship the fix, and keep that date in the record. The decision you're enabling is simple: are
> we still sending customers and budget at a feature Google has turned off? You can only answer
> that if the destination is measured, not assumed.
