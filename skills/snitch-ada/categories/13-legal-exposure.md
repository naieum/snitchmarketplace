## CATEGORY 13: Legal exposure (ADA Titles II / III, Section 508, EAA, AODA, UK PSBAR)

Categories 01–12 produce criterion failures. This category turns those failures into an **exposure read**: which accessibility regimes bind this particular surface, which of the failures already found land inside a regime's scope, and what the regime asks for that the site does not yet have. It produces one exposure paragraph and, where a regime binds and Level A criteria failed, one finding per regime. It never produces a verdict, a prediction, or a number.

Exposure is a factual read, not a legal opinion. The facts it rests on — application dates, population thresholds, standard versions, exemption sizes — move. Every one of them below carries the date it was verified and the official page it was verified against, and a fact that could not be verified is written as unverified rather than asserted. This skill is not a law firm and does not give legal advice; say that once in the report and let the reader take the findings to counsel.

**Boundary.** This category judges the surface against a **regime's scope and technical standard**. When the question is whether a barrier stops one specific person from finishing a task, that is the sibling's judge — call the Skill tool with "snitch-ux". When the same elements are judged against search and machine readability, that is the other sibling — call the Skill tool with "snitch-marketing". Inside this skill: Cat 14 audits the accessibility statement, the feedback channel and overlay widgets that this category only records the presence of; Cat 15 audits linked documents; Cat 12 judges the `lang` attribute against SC 3.1.1 and 3.1.2. This category never re-states a criterion finding from 01–12 — it cites it.

### Pre-flight

Runs whenever any criterion category ran, because exposure is a reading of their output. Selected on its own, it takes one of two branches, decided by whether there is anything to read:

1. **Criterion results in hand.** Categories 01–12 ran in this audit. Read their findings and Pass evidence and go straight to the exposure read. This is the normal path.
2. **No criterion results, but the source or the pages are in hand.** A user may select this category alone, and a surface the audit can read is not the same as nothing to read. Run a **Level A spot-read** over the representative page set first — the failures the regimes are actually judged on, and the ones demand letters cite: unlabeled inputs (3.3.2), images with no text alternative (1.1.1), controls with no accessible name (4.1.2), color-only error states (1.4.1), keyboard-inoperable controls (2.1.1). Every criterion citation it produces is labelled **`observed here, not imported from a criterion run`**, and the report says in its first sentence that the criterion sweep did not run and that this is an exposure read over a spot-read. The spot-read establishes exposure evidence; it does not stand in for Categories 01–12, and it never turns into a coverage claim.
3. **Neither.** No criterion results and no source or pages to read: Skip with `Skip — no criterion results to read; run the WCAG 2.2 AA sweep first`.

Under branch 2, the spot-read's own criterion findings belong to the categories that own them. Report the exposure here, cite the observation, and record each criterion as `Skip — <observation>; owned by Cat NN, not run` per the SCOPE RULE, so the coverage block never reads as though 01–12 ran.

Its three inputs come from the discovery block in SKILL.md and are collected **once**, never re-asked per regime:

1. **Sector** — healthcare, education, public sector, banking, transport, telecoms, retail, other.
2. **Markets and surfaces served** — US state or local government; US public accommodation; EU; Canada (federal or Ontario); UK (public sector or private).
3. **Procurement customers** — any US federal agency, any state or local government buying under a state 508-equivalent, any public-sector buyer in the EU or UK.

If the user declines to answer, do not infer from the copy. Run the category with `Skip — exposure inputs not supplied; regimes could not be scoped` and report only the presence-or-absence signals (statement, feedback channel, VPAT), which need no answers.

### Rule table

One row per regime. A finding names its row. A regime with no row here is not written about at all.

| Obligation | Who it binds | What must hold | Static signal | Facts verified | Severity |
|---|---|---|---|---|---|
| ADA Title II — web and mobile app rule | State and local governments, their agencies and departments, special purpose districts, Amtrak and other commuter authorities | Web content and mobile apps conform to **WCAG 2.1 Level AA**, subject to five exceptions | Sector answer is US state or local government; Level A / AA failures from 01–12 on any public-facing page; content that falls in an exception is scoped out, not counted | 2026-09-03 · ada.gov | High (Level A failure in scope) / Medium (AA only) |
| ADA Title III | Businesses and nonprofits that serve the public (public accommodations) | No discrimination in the goods and services offered to the public. **No technical web regulation has been issued**; settlements and courts have referenced WCAG | Sector answer is US public accommodation; Level A failures on the conversion path, the contact path and the account path | 2026-09-03 · ada.gov | High (Level A failure on a public path) / Medium (AA only) |
| Section 508 — Revised 508 Standards | Federal agencies developing, procuring, maintaining or using electronic and information technology, and anything sold to them | Electronic content conforms to **WCAG 2.0 Level A and AA** (provision E205.4); non-web documents are excused four criteria | Procurement answer names a federal buyer; Level A / AA failures; presence and currency of an Accessibility Conformance Report | 2026-09-03 · access-board.gov, section508.gov | High (Level A failure, or an ACR whose claims the findings contradict) / Medium (AA only) |
| Section 508 — the ACR / VPAT artifact | Vendors selling ICT to federal agencies | An Accessibility Conformance Report exists, is current, and its per-criterion claims match what the audit observed | Search the repo and the site for an ACR or VPAT document; compare each claim against the findings | 2026-09-03 · section508.gov | High (a claim the findings contradict) / Medium (no report where one is expected) |
| European Accessibility Act — Directive (EU) 2019/882 | Economic operators offering the in-scope products and services in the EU, **applicable from 28 June 2025** | The in-scope service meets the Act's accessibility requirements, and the information needed to assess that is made available | Markets answer includes the EU **and** the service is in scope: e-commerce, consumer banking, air / bus / rail / waterborne passenger transport elements, electronic communications, access to audiovisual media services, e-books and dedicated software | 2026-09-03 · eur-lex.europa.eu | High (Level A failure on an in-scope service) / Medium (AA only) |
| EAA — micro-enterprise exemption (service providers) | Service providers employing **fewer than 10 persons** with annual turnover **or** balance sheet total **not exceeding EUR 2 million** | The exemption is claimed only where both limbs hold; it does not exempt products | The user's own statement of headcount and turnover; never inferred from the site | 2026-09-03 · eur-lex.europa.eu | Pass / Low (record the exemption, do not audit against the Act's service duties) |
| EU Web Accessibility Directive — Directive (EU) 2016/2102 | Public sector bodies' websites and mobile applications in EU Member States | The site meets the referenced standard (**EN 301 549 v3.2.1**), publishes an accessibility statement naming non-accessible content and alternatives, and offers a feedback mechanism | Markets answer is EU **and** sector is public sector; statement and feedback signals from Cat 14 | 2026-09-03 · digital-strategy.ec.europa.eu | High (Level A failure) / Medium (AA only, or statement absent) |
| AODA — O. Reg. 191/11, ss. 9–19 | Designated public sector organisations, and businesses or non-profits with **50 or more employees**, in Ontario | Public websites and web content published after **1 January 2012** meet **WCAG 2.0 Level AA**, except live captions (1.2.4) and pre-recorded audio description (1.2.5); enforcement date **1 January 2021** | Markets answer includes Ontario and the size threshold is met; Level A / AA failures excluding the two excepted criteria | 2026-09-03 · ontario.ca | High (Level A failure) / Medium (AA only) |
| Accessible Canada Act (2019) | Federally regulated entities — banking, telecommunications, transportation, Government of Canada, Parliament, Crown corporations and others | Accessibility plans are prepared and published, feedback processes are set up, and progress is reported; information and communication technologies is one of the seven priority areas. The Act itself names **no WCAG level** | Markets answer is Canada-federal; presence of a published accessibility plan and feedback process (Cat 14) | 2026-09-03 · canada.ca | Medium (no published plan or feedback process) / Low (ICT findings, no named technical bar) |
| UK Equality Act 2010, s. 29 | Service providers providing a service to the public, for payment or not | No discrimination against a person requiring the service, plus the duty to make reasonable adjustments (s. 29(7)) | Markets answer includes the UK; Level A failures that leave a whole task unavailable with no alternative route | 2026-09-03 · legislation.gov.uk | High (Level A failure with no alternative route) / Medium (AA only) |
| UK PSBAR 2018 | UK public sector bodies' websites and mobile applications | The site meets the standard the guidance names (**WCAG 2.2 AA** as stated on the current guidance page) and publishes an accessibility statement covering the four required elements | Markets answer is UK public sector; statement elements from Cat 14; Government Digital Service monitors, the Equality and Human Rights Commission enforces | 2026-09-03 · gov.uk | High (Level A failure, or no statement) / Medium (AA only) |

**Facts verified: 2026-09-03.** Every date, threshold and standard version in the table was fetched from the official page on that date. Re-verify before relying on any of them; `references/legal-landscape.md` holds the same record for the whole skill.

- ADA Title II: https://www.ada.gov/resources/2024-03-08-web-rule/ — the final rule was published in the Federal Register on **24 April 2024**; an Interim Final Rule published **20 April 2026** extended the compliance dates to **26 April 2027** for entities with a total population of 50,000 or more and **26 April 2028** for entities under 50,000 and for special district governments. Five exceptions: archived web content; preexisting conventional electronic documents; third-party content posted without a contractual arrangement; individualized password-protected documents; preexisting social media posts.
- ADA Title III: https://www.ada.gov/topics/title-iii/ — the page describes coverage of businesses and nonprofits serving the public and **states no web technical standard**. Religious organisations and private clubs are outside it.
- Section 508: https://www.access-board.gov/ict/ — provision **E205.4**: "Electronic content shall conform to Level A and Level AA Success Criteria and Conformance Requirements in WCAG 2.0." Non-web documents are not required to conform to 2.4.1, 2.4.5, 3.2.3 and 3.2.4. https://www.section508.gov/manage/laws-and-policies/ — the Revised Standards final rule issued **18 January 2017** and went into effect **18 January 2018**.
- ACR: https://www.section508.gov/sell/acr/ — an ACR is "a document that explains how information and communication technology (ICT) products such as software, hardware, electronic content, and support documentation meet (conform to) the Revised 508 Standards for IT accessibility", and ACRs "help Federal agency contracting officials and government buyers to assess ICT for accessibility when doing market research and evaluating proposals".
- EAA: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019L0882 — Directive (EU) 2019/882 of **17 April 2019**, applicable from **28 June 2025**; the Article 2(2) service list and the Article 3 micro-enterprise definition ("fewer than 10 persons" and turnover or balance sheet total "not exceeding EUR 2 million") are as quoted in the table; Article 15 gives a presumption of conformity to harmonised standards.
- EU WAD: https://digital-strategy.ec.europa.eu/en/policies/web-accessibility — Directive 2016/2102, public sector bodies, **EN 301 549 v3.2.1**, accessibility statement and feedback mechanism obligations.
- AODA: https://www.ontario.ca/page/how-make-websites-accessible — AODA 2005 and O. Reg. 191/11 ss. 9–19; WCAG 2.0 Level AA less 1.2.4 and 1.2.5; designated public sector organisations or 50-or-more-employee businesses and non-profits; content published after 1 January 2012; enforcement date 1 January 2021.
- Accessible Canada Act: https://www.canada.ca/en/employment-social-development/programs/accessible-canada.html — in force 2019, seven priority areas including ICT, plans and feedback processes required, no WCAG level named in the Act.
- UK: https://www.legislation.gov.uk/ukpga/2010/15/section/29 (Equality Act 2010 s. 29 and s. 29(7)) and https://www.gov.uk/guidance/accessibility-requirements-for-public-sector-websites-and-apps (PSBAR 2018; the guidance page names **WCAG 2.2 AA**; Government Digital Service monitors, the Equality and Human Rights Commission enforces). The staged commencement dates — new sites after **22 September 2019**, existing sites after **22 September 2020**, mobile apps after **22 June 2021** — are in the statutory instrument at https://www.legislation.gov.uk/uksi/2018/952/made, which the current guidance page compresses to "Since 23 September 2018". Cite the staged dates only when the question is when a specific obligation commenced; otherwise cite the guidance.

**Could not be verified on 2026-09-03 — write these with `(unverified — confirm at <URL>)` and never as an assertion:** EN 301 549 as the EAA's harmonised standard (Article 15's mechanism is verified, the standard is not named on the Commission pages fetched — confirm at https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019L0882); the WCAG level EN 301 549 requires (not stated at https://digital-strategy.ec.europa.eu/en/policies/web-accessibility); the EAA's Article 13 and Annex V service-provider information duty, of which only recital 81 was readable ("information necessary to assess conformity with accessibility requirements should be provided in general terms and conditions, or equivalent document"); the Accessible Canada Act's plan and reporting deadlines; the VPAT template editions and the Supports / Partially Supports / Does Not Support wording.

### Evidence required

Three inputs, in this order, cheapest first. No step invents a fact.

1. **Read the discovery answers** already recorded in the report metadata — sector, markets and surfaces, procurement customers. Do not re-ask. Do not infer a market from a currency symbol, a phone format or a domain suffix; record `not supplied` and scope the regime out.
2. **Collect the criterion results from the same report.** List every Level A failure from categories 01–12 with its SC number and its `file:line` or URL + selector, then every AA failure. A regime row is only ever cited against failures **that appeared in this report** — never against a failure remembered from another audit or assumed from a pattern. If a criterion category was skipped, say so here: an exposure read over a partial sweep is a partial read, and the coverage block already proves which criteria were never checked.
3. **Record the three presence signals** without auditing them (Cat 14 and the procurement check own the detail):
   - accessibility statement — Grep the repo for `accessibility` in route, page and nav files; in crawl mode, fetch the footer of the representative page set and follow any statement link;
   - feedback channel — a reachable email, form or phone on that statement page;
   - Accessibility Conformance Report or VPAT — Grep the repo for `VPAT`, `ACR`, `conformance report` and for `.pdf` / `.docx` links whose text names one; in crawl mode check any trust, legal, security or procurement page.
4. **Re-verify the volatile facts** against `references/legal-landscape.md` before writing any date or threshold. If the reference's verification date is older than the audit date, say the date in the finding and point at the official URL; never restate a date as current without its verification line.

Cascade caveat, for the statement sweep specifically: a footer link injected at runtime will not appear in a plain fetch of a hydration-heavy page. A statement not found in crawl mode on such a stack is `Skip — footer rendered client-side; statement presence not determined`, not an absence finding.

### Forbidden claims

- **"The site is compliant / conformant / non-compliant."** Never, in any regime, under any confidence. Conformance is a determination that follows a complete audit. Write `fails SC 1.1.1 at three images on the checkout page, inside ADA Title II scope` and stop.
- **"You are at risk of a lawsuit" / "you will be sued" / "this is litigation bait."** No prediction of litigation, enforcement action, complaints, or their outcomes. Write which criteria failed and which regime's scope they sit in.
- **"Expect a demand letter."** The observation permitted here is that Level A criteria are the lowest bar and the ones most often cited when barriers are raised. That is a statement about the criterion level, not a forecast about this site.
- **Any figure.** No damages, no settlement amounts, no fines, no penalty ranges, no legal fees, no "average cost of". This category emits no monetary number of any kind.
- **"This is what the law requires of you."** Naming a regime's stated technical standard is reporting; telling the reader what their obligations are is advice. Say once, in the exposure paragraph, that the audit is not legal advice.
- **"The EAA applies to you because you have EU visitors."** Scope is by service and market, not by traffic. Cite the Article 2(2) service list and the answers given.
- **A date or threshold with no verification line.** Every one carries `Facts verified: <date> against <URL>` or `(unverified — confirm at <URL>)`.
- **"An accessibility overlay covers this."** Presence of an overlay is not evidence under any regime in this table. Cat 14 owns the overlay finding.

### Detection

A read of this report's own criterion results against the regime scopes in the rule table, using the three discovery answers and the three presence signals. No new surface is scanned here; the only tool calls are the presence sweeps in step 3 and the fact re-verification in step 4. Anything met **while** those sweeps read a page is still met: it is routed to its owner under SKILL.md's SCOPE RULE, never scored here and never dropped.

### What to Search For

- The recorded sector, markets and procurement answers in the report metadata, and whether any of the three are `not supplied`
- Every Level A failure from 01–12 in this report, with its SC number and evidence citation
- Every AA failure from 01–12 in this report
- Which criterion categories were skipped, and why, so the exposure read states its own coverage
- An accessibility statement route, page or footer link (`accessibility`, `a11y` in route and nav files)
- A feedback channel on that page: `mailto:`, a form action, a telephone link
- `VPAT`, `ACR`, `conformance report` in the repo and on trust, legal, security and procurement pages
- Marketing copy that already claims an accessibility standard, level or certification — a claim on the surface is checked against the findings and against the Claim inventory in `BLUEPRINT.md`
- The EAA service question: does the site take orders, offer consumer banking, sell e-books, sell transport tickets or provide access to audiovisual media
- Locale and language artifacts met while reading those pages — a language switcher, `hreflang` annotations, translated or locale-prefixed routes, a locale cookie. None of them is judged here. Route each by name under the SCOPE RULE: `hreflang` and locale canonicals are marketing's Cat 50 and 51, so call the Skill tool with "snitch-marketing"; whether a person can reach and stay in their language is Cat 20 of this skill, recorded as `Skip — <observation>; owned by Cat 20, not run`. Never score one under a regime row, and never leave one unrecorded

### Actually Fails

- **A Level A failure on a surface a bound regime covers.** Evidence: the SC number and citation from 01–12, the regime row, the answer that put the site in scope, and the verification line for the regime's standard version.
- **An accessibility claim on the site the findings contradict.** "This site meets WCAG 2.1 AA" in a footer or statement, with Level A failures in the report. Evidence: the quoted claim with its `file:line` or URL, and the failing criteria. Cross-cite `BLUEPRINT.md:line` when the Claim inventory records it.
- **An Accessibility Conformance Report whose per-criterion claims the audit contradicts.** Evidence: the quoted ACR row ("Supports"), the criterion, and the failure found. This is the highest-value procurement finding in the category, because a federal buyer relied on that row.
- **A bound public-sector regime with no accessibility statement.** The EU WAD and PSBAR both require one. Evidence: the sweep that found no statement route and no footer link, plus the regime row. Detail belongs to Cat 14; this row records the exposure.
- **A regime in scope whose technical standard is a version the audit did not test against.** Title II names WCAG 2.1 AA, Section 508 names WCAG 2.0 AA, AODA names WCAG 2.0 AA; this skill tests 2.2. This is a **version-gap row about the regime**, written once per regime: name the regime, the standard version it adopts, and which new-in-2.2 criteria (2.4.11, 2.5.7, 2.5.8, 3.2.6, 3.3.7, 3.3.8) therefore do not count against it. Evidence: the regime row plus the list of new-in-2.2 criteria this audit found failures under. 2.2 is backward compatible, so a 2.2 pass covers the older bar.

  **It is never a second report of the element.** The failing element itself is reported once, by the criterion category that owns it — a 2.5.8 target-size failure is Cat 07's finding, and a 3.3.7 redundant-entry failure is Cat 10's. This category cites those findings by number and says which regimes they do and do not reach. Re-scoring the element here, under a regime row or a borrowed criterion, double-counts one piece of evidence.
- **Exposure inputs not supplied, with a public-facing surface present.** Not a failure of the site; a coverage finding at Low. Evidence: the unanswered discovery question and what it would have scoped.

### NOT a Failure

- A regime the answers put out of scope. A US-only retail site with no public-sector customers is not audited against the EU WAD; record `Pass — regime does not bind this surface, per the markets answer`, with the answer quoted.
- A micro-enterprise service provider under both EAA limbs. Record the exemption from the user's own statement of headcount and turnover, and do not audit the service duties against it. The exemption does not reach products, and it does not make the criterion findings disappear.
- Content inside a Title II exception — archived content in a designated archive area, a preexisting conventional electronic document, third-party content posted with no contractual arrangement, an individualized password-protected document, a preexisting social media post. Scope it out by naming the exception; do not count it and do not silently drop it.
- Live captions (1.2.4) and pre-recorded audio description (1.2.5) under AODA. The regulation excepts them; a finding on either is still a WCAG finding in Cat 02, just not an AODA exposure row.
- The four criteria non-web documents are excused under Section 508 — 2.4.1, 2.4.5, 3.2.3, 3.2.4 — when the surface is a document rather than a web page.
- A site with AA-only failures under a regime that binds it. That is Medium exposure, reported, not escalated to High. Level A is the escalation trigger.
- An accessibility statement that exists but is thin. Cat 14 grades it; this category only records that one exists.

### Context Check

1. Which of the three discovery answers is actually recorded, and which is `not supplied`? An unanswered question scopes a regime out, it never scopes one in.
2. Did every criterion category run? An exposure read over a half-run sweep says so in its first sentence.
3. Does each cited failure carry its own evidence citation from 01–12, or is it being restated from memory? Only cite what is in this report.
4. Is the regime's technical standard the version this audit tested? Name the version gap when a finding rests on a criterion new in 2.2.
5. Is the site making an accessibility claim anywhere — footer, statement, ACR, marketing page? A claim the findings contradict outranks every other finding in this category.
6. Does the site actually offer an EAA in-scope service, or does it merely have EU visitors?
7. Is every date and threshold in the draft carrying its verification line, and is every unverified fact marked as such?
8. Is anything in the draft a verdict, a prediction, or a number? Delete it.

### Severity

One tier per finding. **Critical is never used in this category** — a blocking barrier is already Critical in its own criterion category, and re-scoring it here double-counts the same evidence.

- **High** — a Level A failure on a surface a bound regime covers; an accessibility claim or an ACR row the findings contradict; a bound public-sector regime with no accessibility statement.
- **Medium** — only AA failures on a surface a bound regime covers; a federally-selling vendor with no ACR where a buyer would expect one; a bound Accessible Canada Act entity with no published plan or feedback process.
- **Low** — exposure inputs not supplied; a regime whose scope is genuinely uncertain from the answers given; an ICT finding under a regime that names no technical standard.
- **Pass** — a regime that does not bind this surface, recorded with the answer that scoped it out; a verified micro-enterprise exemption.

### Fix guidance

The output here is a **remediation plan**, not legal advice. Say that in one sentence, once, and then be useful.

A plan has three parts and an order:

**1. Fix Level A on the paths that matter first.** Not because a regime says so, but because Level A is the difference between "hard" and "impossible", and the conversion path is where impossible costs the most. Order the criterion findings from 01–12 by (a) Level A before AA, (b) conversion and account paths before content pages, (c) shared components before one-off pages. A single fix in a design system button closes the same finding on forty pages; a fix in one template closes one.

```
Before — the remediation list as the audit produced it
  1.4.3 contrast, /about hero          (AA, content page)
  4.1.2 unnamed icon button, /checkout (A, conversion path, shared component)
  1.1.1 silent image, /blog/2019-post  (A, archived content)

After — the same list, ordered by what it buys
  1. 4.1.2 unnamed icon button — shared <IconButton>; one change, 31 call sites
  2. 1.1.1 silent image — /blog/2019-post; in scope only if not archived under the Title II exception
  3. 1.4.3 contrast — /about hero; brand token, needs per-finding confirmation
```

**2. Publish the statement, and make it true.** Cat 14 owns the shape. The plan's job is to sequence it: the statement names what was audited, what is known and not yet fixed, and how to report a barrier. Publishing a statement that claims more than the audit found is the one move that converts a technical failure into a contradicted claim, which is the worse finding. Write the statement after the first remediation pass, not before it.

**3. Keep the audit record.** Date the audit, keep the report, keep the fixes traceable to it, and re-run after each pass. A dated record of what was found and what was done is the artifact that survives a question about the site; a certificate from a scan is not.

Where a federal buyer is in the picture, the ACR is the deliverable and the findings are its input: every criterion the audit failed is a row that cannot read "Supports". Correcting an ACR row is cheaper than defending it.

One sentence to carry into the report and no further: this audit reports observations against published standards and regime scopes; it is not legal advice, and the decisions that follow from it belong to the reader and their counsel.

### Reference

ADA Title II web and mobile app rule: https://www.ada.gov/resources/2024-03-08-web-rule/ · ADA Title III: https://www.ada.gov/topics/title-iii/

Section 508 laws and policies: https://www.section508.gov/manage/laws-and-policies/ · Revised 508 Standards, provision E205.4: https://www.access-board.gov/ict/ · Accessibility Conformance Reports: https://www.section508.gov/sell/acr/

European Accessibility Act, Directive (EU) 2019/882: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019L0882 · Commission overview: https://commission.europa.eu/strategy-and-policy/policies/justice-and-fundamental-rights/disability/union-equality-strategy-rights-persons-disabilities-2021-2030/european-accessibility-act_en

EU Web Accessibility Directive: https://digital-strategy.ec.europa.eu/en/policies/web-accessibility

AODA and O. Reg. 191/11: https://www.ontario.ca/page/how-make-websites-accessible · Accessible Canada Act: https://www.canada.ca/en/employment-social-development/programs/accessible-canada.html

UK Equality Act 2010 s. 29: https://www.legislation.gov.uk/ukpga/2010/15/section/29 · UK public sector accessibility requirements: https://www.gov.uk/guidance/accessibility-requirements-for-public-sector-websites-and-apps

WCAG versions and backward compatibility: https://www.w3.org/WAI/standards-guidelines/wcag/
