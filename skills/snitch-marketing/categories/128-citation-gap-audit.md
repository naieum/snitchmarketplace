## CATEGORY 128: Citation-gap audit (uncited verifiable claims)

Content that states a verifiable claim (a statistic, a quantity, a ranking, a "studies show")
without a source nearby asks the reader to take it on faith. That hurts two things at once.
Human raters and ordinary readers can't check it, so the page reads as assertion rather than
evidence, and the trust dimension of E-E-A-T takes the hit. AI answer engines, which
preferentially cite claims that carry a checkable source, skip past the bare number in favor
of a competitor's sourced version of the same fact. This category extracts the verifiable
claims in a page's content and flags the ones with no citation in roughly the same passage,
then reports an uncited-claim ratio for the page.

A citation here means a source the reader or an answer engine can actually follow: a nearby
outbound link, a footnote or reference marker, or an explicit named-and-linkable source.
"Nearby" means the claim sentence plus the sentence adjacent to it, roughly 200 characters,
not a references dump three screens down that the claim never points to. The claim types to
extract and re-author:

- Statistics and percentages: "73% of teams report…"
- Absolute quantities: "processes 2M requests a day"
- Authority attributions: "according to Gartner", "research shows", "studies show"
- Superlatives and rankings: "the leading", "#1", "the fastest"
- Temporal claims: "since 2019", "as of 2026"
- Comparative claims: "3x faster than the alternative"

Scope note: distinct from Cat 59 (AI-content tells, which detects stats that sound invented
and generic filler phrasing) and `references/citability-scoring.md` (which scores passage
citability and answer-length fitness). This category asks one narrow question: does each
verifiable factual claim carry a source the reader or an LLM can follow? It is about sourcing,
not fluency, and not whether the number is plausible.

### Pre-flight: relevance check

Skip with reason `no verifiable claims present` for pages that make no checkable factual
assertions: pure brand or voice copy, navigation, contact, login, legal boilerplate. Required
for blog posts, articles, landing pages, comparison pages, case studies, and any page that
asserts statistics, quantities, rankings, or attributed research. Borderline (a feature page
with one or two stat callouts): run it, scoped to those callouts rather than the whole page.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md` for first-party data: does the brand legitimately own
   any of these numbers, and what is the methodology? A claim sourced to the brand's own
   labeled benchmark is cited. The same number stated as independent fact is not.
2. Read the content files (MDX / MD / HTML) for the page under audit. Extract every sentence
   that carries a verifiable claim of one of the six types above.
3. For each extracted claim, check the surrounding passage (the claim sentence plus the
   adjacent sentence, roughly 200 characters) for a citation: an outbound link, a footnote or
   reference marker, or a named-and-linkable source. Record present or absent, with the quoted
   claim and the quoted surrounding text.
4. Compute the uncited-claim ratio (uncited claims over total verifiable claims) and list each
   uncited claim with its quote.

**Crawl mode, required tool calls:**

1. Fetch the rendered article or landing content. Extract the same claim sentences from the
   visible text. Read the rendered DOM, not just the raw HTML, since some citations are
   client-rendered.
2. For each claim, check the rendered passage for a nearby link or visible source attribution.
   Record present or absent with the quote, and compute the same ratio.
3. If the page can't be retrieved (auth wall, JS failure), Skip with reason `content not
   retrievable in crawl mode; re-run in source mode against the content files`.

### Forbidden claims

- "This statistic is false / made up." This category does not judge truth, only sourcing. That
  judgment belongs to Cat 59. Write "claim X carries no nearby source," not "claim X is invented."
- "The page has no citations" without quoting a claim and showing the absence. Quote the exact
  claim sentence and the surrounding passage that contains no source.
- "Everything here is uncited." Report the ratio with the count of claims you extracted and the
  count you found sourced.
- Treating first-party data as a gap when it is clearly labeled as the brand's own measurement
  with a methodology note. That is acceptable sourcing (see NOT a Problem).

### Detection

Per-claim extraction (six claim types) + per-claim citation-presence check within the ~200-character
passage + an uncited-claim ratio for the page, with every uncited claim quoted alongside the
surrounding text that lacks a source.

### What to Search For

- Percentage and statistic sentences ("X% of…", "N out of M…") with no link or source in the
  same passage
- "According to [authority]" / "research shows" / "studies show" / "experts agree" with nothing
  to follow
- Superlatives and rankings ("the leading", "#1", "the fastest", "the most") stated as fact
  rather than as the brand's own positioning, with no source
- Year-anchored or temporal claims ("since 2019", "as of 2026", "in the last decade") with no
  source for the dated fact
- Comparative performance claims ("3x faster", "half the cost", "more accurate than") with no
  benchmark or source a reader can reach
- A references section or footnotes that exist but that no in-body claim actually points to
  (sourced in theory, unlinked in practice)

### Actually Hurts the Marketing Surface

- **A cluster of uncited statistics on a trust-load-bearing page.** YMYL, authority, or money
  content where the reader has to take the numbers on faith; raters and answer engines both
  discount it.
  Evidence required: the uncited claim sentences quoted + the surrounding passages showing no
  source + the page's uncited-claim ratio.
- **Attributed authority with nothing to follow.** "According to [source]" or "research shows"
  with no link or citation; the attribution implies rigor the page never backs up.
  Evidence required: the attribution sentence quoted + the absence of a linkable source in the passage.
- **First-party data dressed as independent fact.** The brand's own number stated as if it were
  a neutral industry finding, with no "our" framing and no methodology.
  Evidence required: the claim quoted + the context-file note that this is the brand's own
  measurement + the absence of first-party labeling on the page.
- **Comparative or superlative claims stated as fact without a source.** "3x faster", "the
  leading", with no benchmark or citation a reader or an LLM can check.
  Evidence required: the comparative claim quoted + the absence of a source in the passage.
- **Footnotes or references that no claim points to.** A reference list exists but the in-body
  claims don't connect to it; the citation is decorative.
  Evidence required: the reference block + the uncited claim sentences that never link to it.

### NOT a Problem

- Opinion or voice statements that aren't verifiable claims ("we think onboarding should be
  effortless"). There is nothing to cite.
- A claim already accompanied by an adjacent linked source. Sourced is sourced.
- First-party data clearly labeled as the brand's own measurement with a methodology note ("in
  our benchmark of 500 runs…"). Honest first-party data is a citation, not a gap.
- Common-knowledge statements no reader would expect a source for ("the web runs on HTTP").
- A single isolated stat on an otherwise-sourced page. Note it; don't escalate the whole page.

### Context Check

1. Does the context file name any first-party data the brand legitimately owns, and is it
   labeled as such on the page or stated as independent fact?
2. Is the page trust-load-bearing (YMYL, authority, money) or a lower-stakes marketing page?
   The same uncited ratio carries more weight on the former.
3. For each uncited claim, is it genuinely verifiable, or is it opinion / voice that needs no
   source?
4. Does a references section exist that the in-body claims simply fail to link to (a wiring
   fix), or is there no sourcing at all (a research fix)?
5. What is the uncited-claim ratio, and is it concentrated in one section or spread across the
   whole page?

### Reference

Google Search Quality Rater Guidelines, the Trust dimension of E-E-A-T (Google's own guidance
names Trust the most important member of the family): https://developers.google.com/search/blog/2022/12/google-raters-guidelines-e-e-a-t

Cross-ref `references/eeat-assessment.md` (trust scoring), `references/citability-scoring.md`
(statistic-density dimension, rubric item 4), Cat 59 (AI-content tells, invented-stat
detection), Cat 32 (the Person / author row: who is making the claim), Cat 82 (AI-search
citation: why sourced claims get cited).

**Severity tagging:**
- High uncited-claim ratio on YMYL / authority / money content → High.
- Attributed authority ("according to…", "research shows") with no followable source → High
  (implies rigor it doesn't have).
- First-party data stated as independent fact → Medium (compounds with Cat 59).
- Scattered uncited stats on a standard marketing page → Medium.
- A few gaps on otherwise-sourced content → Low.
- References exist but in-body claims don't link to them → Low (wiring fix).

**Fix voice:** `honest-design-critic` (primary) | `content-shape-editor` (backup).

Read `souls/honest-design-critic.json` before writing the Fix.

Worked fix example:

> You wrote "73% of teams ship faster with us" and then you wrote nothing else. No link, no
> study, no footnote. You're asking a stranger to believe a number because you typed it with
> confidence. That isn't evidence. That's a vibe.
>
> Two people just walked away. The reader who wanted to check it and couldn't. And the answer
> engine that had to choose between your bare number and a competitor's version of the same
> fact with a source attached. It cited the one that did the homework. You did the work to find
> that stat, or you'd better have. So show it.
>
> Walk the page and pull every claim a person could check: the percentages, the "research
> shows", the "fastest", the "since 2019". For each one, ask the only question that matters
> here. Where does the reader go to confirm this? If the answer is nowhere, you have two honest
> moves. Link the source you got it from, right next to the claim, not buried in a footnote
> nobody scrolls to. Or, if the number is your own, say so in plain words: "In our benchmark of
> 500 deployments…", and show how you measured it. Your own data, labeled and explained, is a
> citation. Your own data dressed up as an industry fact is just dishonest.
>
> Then there's the claim you can't source, because it doesn't have one. You know the one. Cut
> it. A number you can't back isn't a marketing asset. It's a liability sitting there waiting
> for someone to call it.
>
> Verify: read the page again as someone who doesn't trust you yet, because most of your
> readers don't. Every checkable claim should either point somewhere or be labeled as yours.
> The ones that can do neither don't get to stay.
