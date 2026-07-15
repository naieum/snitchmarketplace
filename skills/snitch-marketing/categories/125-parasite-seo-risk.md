## CATEGORY 125: Parasite SEO / site-reputation-abuse risk

Google's site-reputation-abuse policy (rolled out November 2024) targets sections of an
otherwise-authoritative site that host third-party-produced content created primarily to
exploit the host domain's ranking signals. The classic shapes are a coupon subsection, a
"best X" affiliate roundup, or a sponsored-post farm bolted onto a news, education, or
government domain. The host earns trust over years; a third party rents that trust to rank
commercial content the host would never have published on its own. When the policy fires,
manually or algorithmically, the abusing section loses its borrowed ranking and can drag
scrutiny onto the rest of the domain.

This category audits the brand's **own** site for sections that match that risk pattern, so
the team can fix exposure before an action lands. It is **section-level, not page-level**: a
single page is rarely the unit Google acts on here. The audit enumerates sections, measures
where third-party commercial content concentrates, and reports the subsections that look like
they are renting the host's reputation rather than extending the host's editorial work.

Scope note: distinct from Cat 78 (affiliate / referral program health), Cat 18 (thin
content), and Cat 95 (programmatic SEO at scale). Those judge quality and scale on their own
terms. This judges one specific thing: whether a subsection looks like it exists to borrow the
host domain's reputation for third-party commercial content. A section can pass Cat 18 and Cat
95 (well-written, not mass-generated) and still match this risk pattern if it is third-party
authored, commercially loaded, and off the domain's core subject. Cross-ref Cat 70 for the
broader spam-policy surface.

### Pre-flight: relevance check

Skip with reason `not applicable` for a wholly first-party commerce site, where the entire
domain is the brand's own commercial surface and there is no editorial or authority reputation
being borrowed by a third party. Site-reputation-abuse needs a host with reputation to rent.

Required for domains that carry editorial, informational, educational, institutional, or news
authority and also host one or more commercial subsections (`/reviews`, `/coupons`, `/deals`,
`/partners`, `/sponsored`, `/best-*`, a "resources" hub, a guest-contributor blog). Borderline
(a content brand with a small shop, or a media site with a deals page): run it, scoped to
whether any subsection's authorship and commercial density diverge sharply from the editorial
core.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md` to confirm the domain's core subject and whether it
   carries borrowable reputation (editorial / informational / institutional) or is purely
   first-party commerce. This decides whether the category applies at all.
2. Enumerate sections / routes. Use the sitemap, route config, nav, and the content directory
   tree (`Bash find . -type d` under the content root, or the framework's route manifest).
   Record the section taxonomy you found and the path you used to find it.
3. For each section, sample representative pages (3 to 5, or all if fewer). Measure
   affiliate-link and sponsored-CTA density per section: count outbound affiliate / "Buy now"
   / "Get deal" links and divide by page or word count. Compute the site mean across sections,
   then flag outlier sections sitting far above it (a `/reviews` or `/coupons` section running
   roughly 2x the site mean or higher is an outlier worth flagging). Quote the counts and the
   `file:line` of representative links.
4. For each outlier section, check authorship. Look at bylines, author frontmatter / author
   fields, "in partnership with" / "sponsored by" / "presented by" labels, and external author
   domains. Quote the `file:line` of the authorship signal that diverges from the editorial
   core.
5. Check topical alignment: does the outlier section's subject sit on the domain's core topic,
   or has it drifted onto an unrelated commercial vertical? Record both subjects.

**Crawl mode, required tool calls:**

1. Fetch the sitemap and nav; enumerate sections from visible structure. If neither a sitemap
   nor a navigable section structure is reachable (no sitemap, JS-gated nav), Skip the section
   enumeration with reason `section taxonomy not enumerable from crawl; cannot measure
   per-section density` rather than guessing at sections.
2. Fetch representative pages per section (3 to 5). Run the same density measurement: affiliate
   / sponsored-CTA links per page, site mean, outlier sections. Record `URL + selector` for the
   links you counted.
3. For outlier sections, capture authorship from the rendered byline / sponsorship label and
   quote `URL + selector`. If authorship is not rendered on the page, record it as
   `authorship not determinable from crawl` rather than asserting first- or third-party.

### Forbidden claims

- "This section is parasite SEO." You cannot prove a contractual host / third-party
  relationship from the outside; this is **advisory**. Write: "this section matches the risk
  pattern Google's site-reputation-abuse policy targets and warrants review," then quote the
  authorship signal and the measured link / CTA density.
- "Google will penalize this." You cannot predict enforcement. State the exposure and the
  measured signals; let the team decide.
- "This content is third-party." Only if you quoted a divergent authorship signal (sponsored
  label, external byline, partner attribution). Absent that, write `authorship unclear` and
  drop the severity.
- "This section's links are affiliate." Only if the link carries an affiliate marker (tracking
  parameter, known network domain, `rel="sponsored"`, disclosure). Otherwise count it as a
  commercial CTA, not an affiliate link, and say which.

### Detection

Section-level enumeration, then per-section affiliate / sponsored-CTA density measured against
the site mean to isolate outlier subsections, then an authorship check (first-party editorial
vs third-party / sponsored) and a topical-drift check on those outliers. Advisory match against
the site-reputation-abuse pattern, grounded in the context file's statement of the domain's
core subject and reputation type.

### What to Search For

- A subsection whose affiliate / sponsored-CTA density runs far above the site mean (a
  `/reviews`, `/coupons`, `/deals`, or `/best-*` hub against an otherwise editorial domain)
- Third-party authorship concentrated in one subsection: guest / sponsored bylines, "in
  partnership with", "presented by", external author domains that diverge from the editorial
  core
- A subsection whose subject has drifted off the domain's core topic onto an unrelated
  commercial vertical (a finance brand's blog suddenly running CBD or casino roundups)
- A "resources" or contributor hub that is open to outside submissions and reads as a place to
  place links rather than an extension of the site's own work
- A commercial subsection that ranks on the host domain's authority but whose content the
  editorial core clearly did not produce

### Actually Hurts the Marketing Surface

- **An authority / editorial domain has a subsection with third-party authorship and high
  commercial-intent drift.** The section matches the policy pattern directly: outside content,
  commercially loaded, ranking on the host's reputation. This is the configuration enforcement
  targets, and the exposure is to the section's rankings and to scrutiny of the domain.
  Evidence required: the divergent authorship signal quoted (`file:line` or `URL + selector`) +
  the section's measured affiliate / sponsored-CTA density vs the site mean.
- **A commercial subsection's link / CTA density is a sharp outlier against the site.** Even
  without confirmed third-party authorship, a section running far above the site mean on
  affiliate / "buy" intent reads as built to monetize the host's traffic rather than to inform.
  Evidence required: per-section density table + the site mean + the outlier section's
  representative links (`file:line` or `URL + selector`).
- **A subsection has drifted off the domain's core subject onto an unrelated commercial
  vertical.** Topical drift plus commercial intent is the tell that the section is using the
  domain as a ranking host, not continuing its work.
  Evidence required: the domain's core subject (from the context file) + the outlier section's
  subject + representative pages.
- **An open contributor / "write for us" hub functions as a link-placement surface.** Outside
  submissions with their own commercial links, sitting under an authoritative domain, match the
  sponsored-farm shape whether or not money changed hands on any single post.
  Evidence required: the submission / contributor signal quoted + the commercial-link density of
  the hub.

### NOT a Problem

- A wholly first-party commerce site. The entire domain is the brand's own commercial surface;
  there is no host reputation being borrowed and the policy does not apply.
- Genuinely staff-written editorial reviews, even with affiliate links, where the author is the
  site's own team and the section sits on the domain's core subject. First-party commercial
  editorial is not site-reputation abuse.
- An isolated affiliate link inside otherwise first-party editorial. One link does not make a
  rented subsection; density against the site mean is what matters.
- A clearly labeled sponsored section that is small, transparently disclosed, and not built to
  rank on the host's authority (a single partner post, plainly marked, not a roundup farm).
  Note it for disclosure hygiene (Cat 78), not as a policy-exposure finding.

### Context Check

1. Does the domain carry borrowable reputation (editorial, informational, institutional), or
   is it wholly first-party commerce? If the latter, the category does not apply.
2. What is the domain's core subject, and which sections sit on it versus off it?
3. Which section, if any, is an outlier on affiliate / sponsored-CTA density against the site
   mean, and by how much?
4. Is the outlier section's content authored by the editorial core, or by guests / sponsors /
   external domains? Is that determinable from the evidence, or unclear?
5. Is the exposure a genuine third-party-on-authority-host configuration, or first-party
   commercial editorial that happens to carry links? (Different finding, different severity.)
6. If a sponsored section exists, is it small and labeled, or built as a roundup designed to
   rank on the host's authority?

### Reference

Google "Site reputation abuse" spam policy:
https://developers.google.com/search/docs/essentials/spam-policies#site-reputation-abuse

Cross-ref Cat 78 (affiliate / referral program health), Cat 18 (thin content), Cat 95
(programmatic SEO at scale), Cat 70 (spam-policy surface).

**Severity tagging:**
- Subsection with third-party authorship + high commercial-intent drift on an authority /
  editorial domain → High (policy exposure).
- Outlier commercial-intent density on a subsection with moderate drift or unclear authorship
  → Medium.
- A single, clearly labeled sponsored page → Low (note, disclosure hygiene, not policy
  exposure).
- First-party commercial editorial flagged only for affiliate-link hygiene → defer to Cat 78,
  not a finding here.

**Fix voice:** `solutions-architect` (primary) | `mike-monteiro` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Treat this as a boundary problem, not a content problem. You have an editorial domain that
> earned its ranking, and one subsection that is sitting on that ranking with content the
> editorial core did not produce. That is the configuration Google's site-reputation-abuse
> policy is written to catch. I cannot prove a host / third-party arrangement from the outside,
> and you should not state one in the report. What I can show is the pattern: `/reviews` runs
> roughly three times the affiliate-link density of the rest of the site, the bylines say "in
> partnership with," and the subject has drifted off your core topic. That is enough to act on.
>
> Make the call explicitly, with a rollback path, instead of leaving it implicit:
>
> 1. **Draw the line.** Separate the domain's own editorial work from third-party commercial
>    content. Anything authored by an outside party, or built primarily to rank on your
>    authority, is on the wrong side of the line.
> 2. **Move the high-risk content off the host's reputation.** The reversible option is to
>    migrate the third-party commercial subsection to its own domain or subdomain that ranks on
>    its own merits. The host stops lending its trust; the section keeps its content. If the
>    section is worth keeping, it can survive on its own ranking, and if it cannot, that tells
>    you what it was.
> 3. **For anything that stays, change its operating model.** Bring it under the editorial
>    core: your own staff, your own subject, normal commercial-link density, clear disclosure
>    (Cat 78). First-party editorial that carries affiliate links is not the same risk; the
>    fix is to make it genuinely first-party, not to hide the links.
> 4. **Close the door that opened this.** An open "write for us" hub is a standing intake for
>    exactly this content. Gate it, or shut it.
>
> Verify: re-run the per-section density measurement after the change. No subsection should sit
> far above the site mean on commercial intent while carrying third-party authorship on the
> host domain. Keep the section taxonomy and the density numbers on file, so the next person to
> add a "deals" page can see where the line is before they cross it.
