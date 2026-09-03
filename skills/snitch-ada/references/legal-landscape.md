# Legal Landscape

The exposure reference. Categories 13, 14 and 15 load this file, and so does the report's
legal-exposure paragraph. Every date, threshold and standard version below carries the source it was
fetched from and the date it was checked. Anything that could not be verified by fetch carries an
`(unverified — confirm at <URL>)` hedge instead of an assertion.

**All verification dates in this file are 2026-09-03.** These rules move: they are amended,
extended, litigated and re-interpreted. Re-verify before quoting one into a report that will be read
by counsel or a procurement office.

---

## ADA Title II — state and local governments

`Facts verified: 2026-09-03 against https://www.ada.gov/resources/2024-03-08-web-rule/`

The Department of Justice published a final rule on 2024-04-24 setting a technical standard for the
web content and mobile apps of state and local governments. **An Interim Final Rule published in the
Federal Register on 2026-04-20 extended both compliance dates by one year.** The dates below are the
extended ones; quoting the original 2024 dates is now wrong.

| | |
|---|---|
| Who it binds | State and local government entities, and special district governments |
| Technical standard | **WCAG 2.1 Level AA** — note the version: this rule adopts 2.1, not 2.2 |
| Compliance date, population 50,000 or more | **2027-04-26** — extended by the IFR from 2026-04-24 |
| Compliance date, population under 50,000, and special district governments | **2028-04-26** — extended by the IFR from 2027-04-26 |
| Interim Final Rule | published and effective **2026-04-20**; written comments were due **2026-06-22** |

The page states the extension verbatim: "On April 20, 2026, the Federal Register published the
Department's Interim Final Rule (IFR) extending the compliance date for State and local government
entities with a total population of 50,000 or more to April 26, 2027. The compliance date for public
entities with a total population of less than 50,000, or any special district government, is
extended to April 26, 2028."

Two consequences for a report. **An IFR is interim** — it took effect immediately and took comment
afterwards, so it can be revised by a subsequent final rule. Re-verify these dates rather than
carrying them forward from an old audit. And the extension moved the date, not the standard: the
technical requirement is still WCAG 2.1 Level AA.

The IFR itself: https://www.ada.gov/assets/pdfs/2026-ifr.pdf · Federal Register:
https://www.federalregister.gov/documents/2026/04/20/2026-07663/extension-of-compliance-dates-for-nondiscrimination-on-the-basis-of-disability-accessibility-of-web

Five exceptions, each narrow:

1. **Archived web content** — created before the compliance date, kept only for reference, held in a
   designated archive area, and unchanged since it was archived. All four conditions.
2. **Preexisting conventional electronic documents** — word processing, presentation, PDF and
   spreadsheet files already available on the site before the compliance date.
3. **Third-party content posted by members of the public** — content posted by the public without a
   contractual arrangement. Content posted by a contractor is **not** covered by this exception.
4. **Individualized password-protected documents** — files about a specific person, account or
   property, in those same document formats.
5. **Preexisting social media posts** — posts published before the compliance date.

An exception removes the technical-standard obligation for that content. It does not remove the
underlying ADA duties of effective communication and reasonable modification, which continue to
apply. Never write that content is "exempt from the ADA" because an exception applies to it.

## ADA Title III — places of public accommodation

`Facts verified: 2026-09-03 against https://www.ada.gov/resources/web-guidance/`

**There is no DOJ regulation setting a technical standard for Title III websites.** The guidance
states that the Department "does not have a regulation setting out detailed standards", and rests on
the general nondiscrimination and effective-communication provisions. Businesses are told they have
flexibility in how they comply, and the guidance points to WCAG and the Section 508 Standards as
existing technical references rather than as mandates.

What that means for a report:

- Do not write that a private business "must meet WCAG 2.2 AA under the ADA". No regulation says so.
- Do write that WCAG is the standard courts, settlement agreements and DOJ guidance reference, so
  a criterion failure is the evidence a complaint is built on.
- The demand-letter pattern is real and worth naming factually: a letter arrives citing a small
  number of automated-scan findings on the home page and the conversion path, usually Level A
  failures — unlabeled inputs, images with no text alternative, controls with no accessible name,
  color-only error states, keyboard-inoperable controls. Whether the letter leads anywhere is a
  question for counsel, not for this audit. State what failed and let them decide.
- Never predict a litigation outcome, a settlement amount, or the likelihood of being sued.

## Section 508 of the Rehabilitation Act — federal agencies and ICT procurement

`Facts verified: 2026-09-03 against https://www.section508.gov/manage/laws-and-policies/, https://www.access-board.gov/ict/ and https://www.section508.gov/sell/acr/`

| | |
|---|---|
| Who it binds | Federal agencies, when they develop, procure, maintain or use electronic and information technology |
| Technical standard | Provision E205.4 of the Revised 508 Standards: electronic content **shall conform to Level A and Level AA Success Criteria and Conformance Requirements in WCAG 2.0** |
| Revised standards effective | **2018-01-18** (final rule issued 2017-01-18) |

Two consequences that reach a private vendor:

- Section 508 binds the agency, not the vendor directly. It reaches a vendor through **procurement**:
  an agency buying software or a service must buy something that meets the standard, so the
  requirement arrives as a contract term.
- The procurement artifact is the **ACR** (Accessibility Conformance Report), produced from a **VPAT**
  (Voluntary Product Accessibility Template). The VPAT is the template; the ACR is the filled-in
  document a vendor supplies. An ACR is "a document that explains how information and communication
  technology (ICT) products such as software, hardware, electronic content, and support documentation
  meet (conform to) the Revised 508 Standards for IT accessibility", and ACRs "help Federal agency
  contracting officials and government buyers to assess ICT for accessibility when doing market
  research and evaluating proposals".

The VPAT's template editions and the per-criterion conformance wording an ACR uses — Supports,
Partially Supports, Does Not Support, Not Applicable — are **not stated on the government page**
*(unverified — confirm at https://www.section508.gov/sell/acr/ and with the template's publisher)*.
Do not put that wording in a report as if it were a government-defined vocabulary.

A snitch-ada report is **input to** an ACR, never an ACR itself — this audit does not
perform the manual passes an honest ACR requires, and its coverage block says so explicitly. When
the user is preparing a VPAT, hand them the coverage block and the skipped-checks list together, and
say plainly which criteria still need a human pass before the ACR can claim anything about them.

## European Accessibility Act — Directive (EU) 2019/882

`Facts verified: 2026-09-03 against https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019L0882`

| | |
|---|---|
| Applies from | **2025-06-28** — to products placed on the market after that date and services provided to consumers after that date (Article 2) |
| Micro-enterprise definition | Fewer than **10** persons employed, **and** annual turnover not exceeding **EUR 2 million** or an annual balance-sheet total not exceeding **EUR 2 million** (Article 3(23)) |
| Micro-enterprise exemption | Micro-enterprises **providing services** are exempt from the accessibility requirements (Article 4(5)). The exemption covers service providers, **not** product manufacturers. |
| Transitional measures (Article 32) | Products lawfully used to provide a service before 2025-06-28 may continue to be used until **2030-06-28** unless replaced during that period. Self-service terminals may continue in use until the end of their economic life, capped at **20 years**. |

Services in scope (Article 2(2)): electronic communications services; services providing access to
audiovisual media services; elements of air, bus, rail and waterborne passenger transport services;
consumer banking services; e-books and dedicated software; **e-commerce services**.

Products in scope (Article 2(1)): consumer general-purpose computer hardware and its operating
systems; self-service terminals including payment terminals, ATMs, ticketing machines, check-in
machines and interactive information screens; consumer terminal equipment for electronic
communications services; consumer terminal equipment for accessing audiovisual media services;
e-readers.

**E-commerce is the row most sites land on.** A site that sells to consumers in the EU is in scope
of a service obligation, whatever its own country of establishment, unless the micro-enterprise
exemption applies. That is a question about employee count and turnover, which STEP 0.5 does not
ask; say the exemption exists and what its thresholds are, and do not decide it for the reader.

Two facts this file could not verify by fetch:

- The harmonised standard used to demonstrate conformity is **EN 301 549** *(unverified — confirm at
  https://www.etsi.org/deliver/etsi_en/301500_301599/301549/ and the harmonised-standards references
  published in the Official Journal)*. EN 301 549 incorporates WCAG for web content; the exact
  version cited under the EAA was not established.
- The obligation on service providers to publish information explaining how the service meets the
  accessibility requirements sits in Article 13 and Annex V *(unverified — confirm at
  https://eur-lex.europa.eu/eli/dir/2019/882/oj)*. Only recital 81 was readable: information
  necessary to assess conformity with the accessibility requirements should be provided in the
  general terms and conditions, or an equivalent document. Treat the obligation as real and its exact
  scope as unconfirmed.

## EU Web Accessibility Directive — Directive (EU) 2016/2102, public sector bodies

`Facts verified: 2026-09-03 against https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32016L2102 and https://digital-strategy.ec.europa.eu/en/policies/web-accessibility`

| | |
|---|---|
| Who it binds | Public sector bodies: the State, regional or local authorities, bodies governed by public law, and associations of those. Public service broadcasters and most NGOs are excluded. |
| Requirement | Websites and mobile applications must be perceivable, operable, understandable and robust, per the harmonised standard. Content meeting a published harmonised standard gets a presumption of conformity. |
| Standard named in the directive text | EN 301 549 V1.1.2 (2015-04), pending publication of harmonised standards |
| Standard named by the Commission today | **EN 301 549 v3.2.1** — "The legal accessibility requirements in the EU are underpinned by technical criteria specified in the harmonised European standard EN 301 549 v3.2.1." |
| New websites (published after 2018-09-23) | comply by **2019-09-23** |
| Existing websites | comply by **2020-09-20** |
| Mobile applications | comply by **2021-06-23** |

Cite **v3.2.1**, not the directive's own V1.1.2. The 2016 text names the version that existed when it
was written and anticipates harmonised standards superseding it; the Commission's current policy page
names v3.2.1. Quoting V1.1.2 as the live requirement is a decade out of date.

The **WCAG version and level that EN 301 549 v3.2.1 requires is not stated** on the Commission page
*(unverified — confirm in the standard itself at
https://www.etsi.org/deliver/etsi_en/301500_301599/301549/)*. Do not assert a WCAG level as an
EN 301 549 requirement without reading the standard.

Two obligations beyond conformance, and both are checkable by Cat 14: a **detailed, comprehensive and
clear accessibility statement** explaining non-accessible content and the accessible alternatives,
and a **feedback mechanism** letting users report failures and request excluded information, with a
response within a reasonable time.

This directive is separate from the EAA. A public body in the EU is in scope of this one; a private
e-commerce or banking service is in scope of the EAA. Do not merge them into one paragraph.

## Canada — AODA (Ontario) and the Accessible Canada Act

`Facts verified: 2026-09-03 against https://www.ontario.ca/page/how-make-websites-accessible`

Ontario's Integrated Accessibility Standards Regulation, under the Accessibility for Ontarians with
Disabilities Act:

| | |
|---|---|
| Who it binds | Designated public sector organizations, and businesses or non-profits with **50 or more employees**, that control the website directly or by contract |
| Standard | **WCAG 2.0 Level AA** |
| Compliance date | **2021-01-01** — already in force |
| Exceptions | **1.2.4 Captions (Live)** and **1.2.5 Audio Description (Prerecorded)** are excepted |
| Scope limit | Applies to websites and web content published after **2012-01-01**. Intranets and extranets are exempt, except for the Government of Ontario and the Legislative Assembly. |

`Facts verified: 2026-09-03 against https://www.canada.ca/en/employment-social-development/programs/accessible-canada.html`

The Accessible Canada Act came into force in **2019**. It binds federally regulated entities —
banking, telecommunications, transportation, federal departments and agencies, Parliament, Crown
corporations, the Canadian Armed Forces, the RCMP, and First Nations band councils. It names
information and communication technologies as one of seven priority areas, and requires regulated
entities to publish accessibility plans, set up feedback processes, and report on progress. The
Accessible Canada Regulations came into force in December 2021.

The Act's page does not name a WCAG version or EN 301 549 *(unverified — confirm the technical
standard and the plan and progress-report deadlines in the Accessible Canada Regulations at
https://laws-lois.justice.gc.ca/eng/regulations/SOR-2021-241/)*.

## United Kingdom — Equality Act 2010 and PSBAR 2018

`Facts verified: 2026-09-03 against https://www.legislation.gov.uk/ukpga/2010/15/section/29`

The Equality Act 2010, section 29, prohibits a service provider from discriminating against a person
requiring the service by refusing to provide it, by the terms on which it is provided, by
terminating it, or by subjecting the person to any other detriment. Subsection (7) applies the
**duty to make reasonable adjustments** to service providers.

Like ADA Title III, this sets no technical standard. It is a general duty, and an inaccessible
service is evidence against it. Do not quote a WCAG level as an Equality Act requirement.

`Facts verified: 2026-09-03 against https://www.legislation.gov.uk/uksi/2018/952/made and https://www.gov.uk/guidance/accessibility-requirements-for-public-sector-websites-and-apps`

The Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018:

| | |
|---|---|
| Who it binds | Public sector bodies: the State, regional or local authorities, bodies governed by public law, associations of those. Public service broadcasters, most NGOs, and schools and nurseries (except essential administrative functions) are excluded. |
| Standard named in the statutory instrument | Published harmonised standards, or **EN 301 549 V1.1.2 (2015-04)** |
| Standard named by the current guidance | **WCAG 2.2 Level AA** — "Web Content Accessibility Guidelines (WCAG) 2.2 AA accessibility standard" |
| Staged dates in the statutory instrument | new websites after **2019-09-22**; existing websites after **2020-09-22**; mobile applications after **2021-06-22** |
| Date framing in the current guidance | one date: "Since 23 September 2018 all public sector websites and apps need to meet accessibility standards" |
| Relief | A disproportionate-burden exemption, assessed on size, resources and cost-benefit |
| Monitoring and enforcement | The Government Digital Service monitors compliance by sampling annually; the Equality and Human Rights Commission enforces in England, Scotland and Wales, and the Equality Commission for Northern Ireland in Northern Ireland |

**This is the one regime that names WCAG 2.2.** Every other regime in this file adopts WCAG 2.0 or
2.1. Cite the guidance page, not the 2018 statutory instrument, when stating what a UK public body
must meet today.

The two date framings do not conflict: the statutory instrument set staged commencement dates, and
the current guidance treats the obligation as fully in force and compresses them to a single line.
Cite the staged dates only when the question is when a specific obligation commenced; otherwise cite
the guidance. The guidance carries its own carve-outs for pre-existing content: pre-recorded audio
and video published before 2020-09-23, PDFs published before 2018-09-23 unless needed for a service,
and intranet or extranet content published before 2019-09-22.

The accessibility statement is a **regulatory requirement**, not a courtesy. The current guidance
requires publishing a statement explaining how accessible the site or app is and reviewing it
regularly. The six specific elements — explaining non-accessible content and why, describing
accessible alternatives, providing a contact route for reporting failures, linking to the enforcement
procedure, being reviewed regularly, and being published in an accessible format — come from the
statutory instrument; the guidance page does not restate them. Cat 14's six statement rows cover
them, against the current guidance page. Whether the statement page itself meets the criteria —
its own labels, contrast and heading order — is judged in Categories 01-12, not there.

---

## Writing rules

These govern every sentence in a report that touches this file.

1. **State exposure, never a verdict.** Name the regime, name the observed pattern, name the criteria
   that failed. "Fails SC 3.3.2 at four inputs on the checkout path" plus "consumer banking services
   are named in scope of the EAA, which applies from 2025-06-28" is exposure. "You are in breach of
   the EAA" is a verdict, and it is forbidden.
2. **The three exposure inputs are the sector, the markets, and the procurement customers.** They
   come from the five questions in STEP 0.5 and from nowhere else. Never infer a sector from a
   domain name, an EU presence from a currency selector, or a public-sector customer from a logo
   wall. If the questions were not answered, say the exposure paragraph could not be scoped and list
   the regimes generically.
3. **Never predict a litigation outcome**, a settlement figure, a regulator's decision, an
   enforcement priority, or whether a specific entity falls inside a specific regime's scope. Scope
   questions turn on facts this audit does not have — employee counts, turnover, contract terms,
   corporate structure. Present the threshold; let the reader apply it.
4. **Every regime line in a report carries its verified date.** Copy the `Facts verified` line for
   the regime you cite. A regime whose facts this file marks unverified is written with the same
   `(unverified — confirm at <URL>)` hedge, never flattened into an assertion.
5. **Watch the version numbers.** They differ per regime and a report that flattens them is wrong.

   | Regime | Standard it names |
   |---|---|
   | ADA Title II web rule | WCAG 2.1 Level AA |
   | Section 508, provision E205.4 | WCAG 2.0 Level A and AA |
   | AODA, O. Reg. 191/11 | WCAG 2.0 Level AA, less 1.2.4 and 1.2.5 |
   | EU Web Accessibility Directive | EN 301 549 v3.2.1; its WCAG level unverified |
   | UK PSBAR, current guidance | WCAG 2.2 Level AA |
   | This skill audits against | WCAG 2.2 Level AA |

   Auditing to the newer standard is a superset in practice, but never report a 2.2-only criterion —
   2.4.11, 2.5.7, 2.5.8, 3.2.6, 3.3.7, 3.3.8 — as a failure *of* a regime that adopted an earlier
   version. Report it as a WCAG 2.2 finding and say which regimes' adopted versions do not include
   it yet. UK PSBAR is currently the only regime here whose named standard includes all six.
6. **An accessibility statement is an obligation, not a defence.** Under the EU Web Accessibility
   Directive, UK PSBAR and the EAA it is required. It is never a substitute for conformance, and a
   report must not imply that publishing one reduces exposure from a criterion failure.
7. **A compliance date is the fact most likely to be stale.** ADA Title II's dates were extended by
   an Interim Final Rule two years after the final rule set them, and an interim rule can itself be
   revised by a later final rule. Never carry a date forward from a previous audit, a cached note or
   memory. Re-fetch the official page and write the date you read there, with the date you read it.
   Where the current standing of a rule is provisional — an interim rule, an open comment period, a
   pending revision — say so beside the date rather than presenting it as settled.
