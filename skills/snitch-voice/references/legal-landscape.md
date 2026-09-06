# Legal Landscape

The verified facts behind the compliance categories (Cat 23 recording consent, Cat 24 AI
disclosure and outbound consent, Cat 25 regulated-data regimes) and the report's
compliance-exposure paragraph. Every fact below carries the date it was verified and the official
page it was verified against. **Copy the `Facts verified` line into the report with the fact.** A
fact marked `(unverified — confirm at <URL>)` is written that way in the report too; it is never
asserted flat.

This skill is not a law firm and gives no legal advice. It states the regime, what it binds, the
observed pattern in the workspace, and the discovery inputs. The reader's counsel draws the line.
Never predict a fine, a regulator's decision, or a litigation outcome; never state a monetary
figure; never decide that a specific entity is in scope of a specific regime — say which inputs
would put it there.

**Re-verify before asserting.** These rules are rewritten, extended and litigated. Anti-hallucination
Rule 4: during an audit, re-check the applicable official source and record the access date; a
saved verification date is not current verification. When the source cannot be reached in the
session, the determination is a Skip naming the source, and the fact below is quoted with its
original date as background only.

Access note from the 2026-09-06 verification: several primary hosts refused automated access
(ecfr.gov, fcc.gov HTML pages, federalregister.gov). Where that happened the equivalent official
document was used (the FCC's own PDF attachments, govinfo.gov Federal Register text, or the
Cornell LII mirror of the CFR) and the URL below is the one actually read.

---

## 1. United States — robocalls, artificial voices, and consent

### The AI-voice ruling
Calls that use AI-generated or cloned voices are "artificial or prerecorded voice" calls under
the Telephone Consumer Protection Act (TCPA). They therefore require the called party's prior
express consent, and voice cloning is named as falling inside the restriction. The ruling itself
speaks of "prior express consent"; the *written* consent requirement for telemarketing comes from
the rule text in the next paragraph.
Facts verified: 2026-09-06 against https://docs.fcc.gov/public/attachments/FCC-24-17A1.pdf (FCC 24-17, CG Docket 23-362, adopted 2024-02-02, released 2024-02-08).

### What an artificial-voice call must say and offer (47 CFR 64.1200(b))
At the beginning of the message, state clearly the identity of the business responsible for the
call; during or after the message, give a telephone number; for telemarketing, provide an
automated, interactive voice- and/or key-press-activated opt-out mechanism, announced within two
seconds of the identification. Telemarketing to wireless numbers and residential lines with an
artificial voice requires prior express *written* consent (64.1200(a)(2)–(3)).
Facts verified: 2026-09-06 against https://www.law.cornell.edu/cfr/text/47/64.1200 (LII mirror; latest amendment shown 90 FR 42138, 2025-08-29).

**Audit consequence:** an outbound voice agent's first message is where identification and the
opt-out offer live. Cat 24 reads it. A missing identification is a finding against this rule; a
missing opt-out tool on a telemarketing agent is a finding against this rule.

### The proposed AI-disclosure rule is still a proposal
The FCC proposed (August 2024) a definition of "AI-generated call" and disclosure duties in
consent and at the start of the call. As of 2026-09-06 no order adopting those rules was found in
the docket. Cite the proposal, never a "rule".
Facts verified: 2026-09-06 against https://docs.fcc.gov/public/attachments/FCC-24-84A1.pdf (the NPRM). Adoption status `(unverified — confirm at https://www.fcc.gov/ecfs/search/docket-detail/23-362)`.

### The consent standard after the one-to-one rule was vacated
The 2023 "one-to-one consent" and "logically and topically related" requirements were vacated by
the Eleventh Circuit on 2025-01-24 and removed from the CFR by FCC order effective 2025-08-29.
The current standard is the ordinary-meaning test: the called party must "clearly and
unmistakably" state, before receiving the call, that they are willing to receive it.
Facts verified: 2026-09-06 against https://media.ca11.uscourts.gov/opinions/pub/files/202410277.pdf and https://www.govinfo.gov/content/pkg/FR-2025-08-29/html/2025-16641.htm.

### Do-not-call and calling hours (47 CFR 64.1200(c))
No telephone solicitation before 8 a.m. or after 9 p.m. local time at the called party's
location. National Do Not Call registrations must be honored indefinitely until removed. Prior
express invitation and established business relationships take a call outside the definition of
"telephone solicitation".
Facts verified: 2026-09-06 against https://www.law.cornell.edu/cfr/text/47/64.1200.

### Telemarketing Sales Rule (16 CFR 310)
Amended effective 2025-01-09 to reach inbound calls responding to advertisements for technical
support products. No amendment specific to AI voices was found through 2026-09-06.
Facts verified: 2026-09-06 against https://www.govinfo.gov/content/pkg/FR-2024-12-10/html/2024-28399.htm and https://www.law.cornell.edu/cfr/text/16/310.6.

### STIR/SHAKEN attests to the carrier's claim, not the caller's identity
Voice service providers must authenticate and verify caller ID for SIP calls on their IP
networks. Attestation A means the originating carrier confirms the subscriber and the number; B
confirms the subscriber but not the number; C means only that the carrier was the point of entry
and, in the FCC's words, "lacks any assertion of the calling party's identity". Nothing in any
attestation level identifies the caller to the callee's application.
Facts verified: 2026-09-06 against https://www.law.cornell.edu/cfr/text/47/64.6301 and https://docs.fcc.gov/public/attachments/FCC-20-42A1.pdf.

### FTC Impersonation Rule (16 CFR 461)
Unlawful to materially and falsely pose as a business or government, directly or by implication,
in or affecting commerce. Effective 2024-04-01. An extension to impersonation of individuals was
proposed and had not been finalized as of 2026-09-06.
Facts verified: 2026-09-06 against https://www.law.cornell.edu/cfr/text/16/part-461 and https://www.ftc.gov/legal-library/browse/rules/impersonation-government-businesses-rule.

---

## 2. United States — state AI-disclosure laws that reach voice

Only the laws below were confirmed to reach spoken conversation. Several well-known "bot" laws do
not: California's B.O.T. Act defines a bot as an automated *online* account on a public-facing
website or app, so it does not reach a phone call on its face; New York's synthetic-performer
disclosure law exempts audio-only advertising. Do not cite either against a phone agent.

### Utah — Artificial Intelligence Policy Act (Utah Code 13-75)
A supplier must disclose that the person is interacting with generative AI and not a human **if
the person asks or otherwise clearly and unambiguously prompts** about it. Regulated occupations
must prominently disclose in a "high-risk" interaction (health, financial or biometric data;
financial, legal, medical or mental-health advice), verbally at the start of a verbal
interaction. A safe harbor applies when the AI discloses at the outset and throughout. "Generative
AI" expressly includes audio. Recodified effective 2025-05-07; the chapter sunsets 2027-07-01.
Facts verified: 2026-09-06 against https://le.utah.gov/Session/2025/bills/enrolled/SB0226.pdf and https://le.utah.gov/Session/2025/bills/enrolled/SB0332.pdf.

**Audit consequence:** Cat 24 checks that the agent answers "are you a human / an AI?" honestly
and that no prompt instruction tells it to deny being AI. The proactive-disclosure duty depends on
the sector answer from discovery.

### Maine — chatbot disclosure (10 MRSA 1500-Y)
A person may not use an AI chatbot or other computer technology to engage in trade and commerce
with a consumer in a manner that may mislead a reasonable consumer into believing they are
engaging with a human being, unless the consumer is notified clearly and conspicuously. "Chatbot"
covers textual **or aural** communication. Effective 2025-09-16; a violation is an unfair trade
practice.
Facts verified: 2026-09-06 against https://www.maine.gov/pfr/consumercredit/laws_rules/new/pl294.pdf.

### Colorado — conversational AI disclosure (HB 26-1263), effective 2027-01-01
The 2024 Colorado AI Act was repealed and re-enacted in 2026 as an automated-decision-making law
effective 2027-01-01, and the general "interacting with an AI system" duty is no longer in it.
The conversational disclosure duty now lives in HB 26-1263 (signed 2026-05-29, effective
2027-01-01): operators must disclose to a user that a conversational AI service is artificial
intelligence, covering textual, visual or aural communication. Treat as **upcoming**, not in
force, until that date.
Facts verified: 2026-09-06 against https://leg.colorado.gov/bills/sb26-189 and https://leg.colorado.gov/bills/hb26-1263.

### California — companion chatbots (SB 243), mostly out of scope for business agents
Operators must notify when a reasonable person would be misled into believing a companion
chatbot is human; covers voice, but excludes customer-service and business-operations bots and
voice-assistant devices that do not sustain a relationship across interactions. Effective
2026-01-01. A typical business voice agent is outside it; cite only where the agent is a companion
product.
Facts verified: 2026-09-06 against https://leginfo.legislature.ca.gov/faces/billTextClient.xhtml?bill_id=202520260SB243.

### Other states
No other enacted "AI caller must disclose in conversation" statute was located as of 2026-09-06.
Pending bills exist; `(unverified — confirm at the state legislature's site)` for any state the
discovery inputs name that is not listed above.

---

## 3. Call recording consent

### Federal baseline — one-party consent (18 U.S.C. 2511(2)(d))
Not unlawful for a party to the communication, or with one party's prior consent, unless the
interception is for the purpose of a criminal or tortious act.
Facts verified: 2026-09-06 against https://www.law.cornell.edu/uscode/text/18/2511.

### States requiring all-party consent for phone calls
Confirmed all-party for telephone recording, with the statute read on 2026-09-06:

| State | Statute | Nuance | Verified against |
|---|---|---|---|
| California | Penal Code 632, 632.7 | 632.7 covers cellular/cordless calls with no confidentiality element | https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?sectionNum=632.7.&lawCode=PEN |
| Florida | 934.03(2)(d) | all parties must give prior consent | http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0900-0999/0934/Sections/0934.03.html |
| Illinois | 720 ILCS 5/14-2 | surreptitious recording of private conversation without all parties' consent | https://www.ilga.gov/Documents/legislation/ilcs/documents/072000050K14-2.htm |
| Maryland | Cts. & Jud. Proc. 10-402(c)(3) | all parties' prior consent | https://mgaleg.maryland.gov/mgawebsite/Laws/StatuteText?article=gcj&section=10-402&enactments=false |
| Massachusetts | G.L. c. 272 s. 99 | turns on *secret* recording; an announced recording is not secret | https://malegislature.gov/Laws/GeneralLaws/PartIV/TitleI/Chapter272/Section99 |
| Montana | MCA 45-8-213(1)(c) | knowledge of all parties, not formal consent | https://mca.legmt.gov/bills/mca/title_0450/chapter_0080/part_0020/section_0130/0450-0080-0020-0130.html |
| New Hampshire | RSA 570-A:2 | all parties' consent | https://gc.nh.gov/rsa/html/LVIII/570-A/570-A-2.htm |
| Pennsylvania | 18 Pa.C.S. 5704(4) | all parties' prior consent | https://www.legis.state.pa.us/WU01/LI/LI/CT/HTM/18/00.057.004.000..HTM |
| Washington | RCW 9.73.030 | consent is obtained when one party announces to all others, in a reasonably effective manner, that the call is about to be recorded | https://app.leg.wa.gov/rcw/default.aspx?cite=9.73.030 |
| Connecticut | C.G.S. 52-570d (civil) | satisfied by all-party consent, or a recorded verbal notice at the start, or a tone | https://codes.findlaw.com/ct/title-52-civil-actions/ct-gen-st-sect-52-570d/ (mirror; the state site failed TLS) |
| Nevada | NRS 200.620 as read in Lane v. Allstate, 114 Nev. 1410 (1998) | all-party for phone calls by case law | https://codes.findlaw.com/nv/title-15-crimes-and-punishments/nv-rev-st-200-620/ (mirror) |
| Delaware | 11 Del. C. 1335(a)(4) vs 2402(c)(4) | privacy statute is all-party, wiretap statute is one-party; unresolved — treat as all-party | https://delcode.delaware.gov/title11/c005/sc07/index.html |
| Michigan | MCL 750.539c | written as all-party; an appellate participant exception exists and the state supreme court has not ruled — treat as all-party for a business recording | https://codes.findlaw.com/mi/chapter-750-michigan-penal-code/mi-comp-laws-750-539c/ (mirror) |
| Oregon | ORS 165.540 | **one-party for telephone calls**; all participants must be informed for in-person conversations | https://www.oregonlegislature.gov/bills_laws/ors/ors165.html |

Facts verified: 2026-09-06 against the URLs in the table.

**Audit consequence:** a voice agent that records must announce recording before it starts,
in a form that satisfies the strictest state it may reach. Cat 23 reads the first message and
the recording start order. The skill never decides which states a business "reaches"; the
discovery answer on caller jurisdictions is the input, and a national inbound line is treated as
reaching all of them.

### Voice as personal and biometric data under CCPA/CPRA (Civ. Code 1798.140)
"Biometric information" includes voice recordings from which a voiceprint can be extracted;
audio is listed as personal information; biometric information processed to uniquely identify is
"sensitive personal information".
Facts verified: 2026-09-06 against https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?sectionNum=1798.140.&lawCode=CIV.

---

## 4. European Union and United Kingdom

### EU AI Act, Article 50 — applies from 2026-08-02
Providers must ensure AI systems intended to interact directly with natural persons are designed
so that those persons are informed they are interacting with an AI system, unless obvious. The
2026 Digital Omnibus did **not** move this date; it granted a four-month transitional period (to
2026-12-02) only for the Article 50(2) synthetic-content marking duty for systems already on the
market. Deployer duties in 50(3)–(4) cover emotion recognition and deepfakes.
Facts verified: 2026-09-06 against https://eur-lex.europa.eu/eli/reg/2026/1744/oj (Regulation (EU) 2026/1744) and https://artificialintelligenceact.eu/article/50/ (Article text; the eur-lex HTML of 2024/1689 truncated before the Articles).

### GDPR — recording is processing; voice can be biometric data
Processing is lawful only on an Article 6 basis; Article 13 information is due at the time the
data are obtained; Article 9 prohibits processing biometric data for the purpose of uniquely
identifying a person absent an exception, and voice data become biometric when processed by
specific technical means allowing unique identification (the logic of Recital 51).
Facts verified: 2026-09-06 against https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32016R0679.

### UK PECR — automated calling systems need prior consent (reg. 19); live marketing calls and the TPS (reg. 21)
Transmitting recorded matter for direct marketing by an automated calling system requires the
subscriber's previously notified consent and caller-ID presentation. Unsolicited live marketing
calls may not be made to numbers on the TPS register or to subscribers who objected; caller ID
must be presented. An AI voice agent playing generated speech is treated as recorded matter under
reg. 19 in the regulator's reading `(unverified — confirm at https://ico.org.uk)`.
Facts verified: 2026-09-06 against https://www.legislation.gov.uk/uksi/2003/2426/regulation/19 and https://www.legislation.gov.uk/uksi/2003/2426/regulation/21.

---

## 5. Sector regimes on the call path

### PCI DSS — sensitive authentication data must not be retained after authorization, including in audio
The card standard's FAQ states that storing card validation codes or values in any form of
digital audio recording after authorization is a violation of the requirement (3.3.1 in v4.x). The
telephone-payments guidance says sensitive authentication data must not be stored after
authorization even if encrypted, and if received and recorded must be rendered unrecoverable on
completion of authorization.
Facts verified: 2026-09-06 against https://www.pcisecuritystandards.org/faqs/1210/ (June 2025) and the v3.0 (2018) telephone-payment guidance. The verbatim v4.0.1 requirement text `(unverified — confirm at https://www.pcisecuritystandards.org/document_library/)`.

**Audit consequence:** any flow where a card number or security code is spoken or keyed into a
recorded, transcribed, or model-visible channel is Cat 22's finding on the flow and Cat 25's
exposure row. A platform's own note that a first-message or parameter field is not PCI-scoped is
evidence for the same finding.

### HIPAA — a vendor handling PHI on the call path is a business associate and needs a written agreement
A business associate is one who creates, receives, maintains, or transmits protected health
information on behalf of a covered entity; the relationship must be documented in a written
contract meeting 164.504(e). The 2025 Security Rule proposal was not final as of 2026-09-06.
Facts verified: 2026-09-06 against https://www.law.cornell.edu/cfr/text/45/160.103 and https://www.law.cornell.edu/cfr/text/45/164.502. Security Rule proposal status `(unverified — confirm at https://www.reginfo.gov)`.

**Audit consequence:** on a health-sector agent every provider that sees audio, transcript, or
the prompt (carrier, transcriber, model, synthesizer, hosted platform, observability tool) is a
business associate. The workspace rarely holds the agreements; Cat 25 records the provider list
as the finding's evidence and the agreements as a Skip naming what would unblock it.

### Illinois BIPA — a voiceprint is a biometric identifier; written release before collection
Biometric identifier includes a voiceprint. An entity must inform in writing and receive a
written release before collecting. Since 2024-08-02, repeated collection of the same identifier
from the same person by the same method is a single violation.
Facts verified: 2026-09-06 against https://www.ilga.gov/Documents/legislation/ilcs/documents/074000140K10.htm, https://www.ilga.gov/Documents/legislation/ilcs/documents/074000140K15.htm and https://www.ilga.gov/Documents/legislation/ilcs/documents/074000140K20.htm.

**Audit consequence:** voice biometrics on the call path (speaker verification, voiceprint
enrollment) is Cat 25's row when Illinois callers are in scope; Cat 05 judges the same feature as
an authentication factor.

### COPPA (16 CFR 312, amended 2025) — a child's voice is personal information
Personal information includes an audio file containing a child's voice and biometric identifiers
such as voiceprints. Exception: an audio file containing only a child's voice, used to respond to
a specific request and deleted immediately after. The amended rule was effective 2025-06-23 with
compliance by 2026-04-22 for most provisions.
Facts verified: 2026-09-06 against https://www.govinfo.gov/content/pkg/FR-2025-04-22/html/2025-05904.htm, https://www.law.cornell.edu/cfr/text/16/312.2 and https://www.law.cornell.edu/cfr/text/16/312.5.

### FINRA taping rule (Rule 3170)
Applies only to "taping firms"; recordings must be retained for at least three years. General
broker-dealer voice-retention obligations under SEC recordkeeping rules
`(unverified — confirm at https://www.sec.gov)`.
Facts verified: 2026-09-06 against https://www.finra.org/rules-guidance/rulebooks/finra-rules/3170.

---

## How the compliance categories use this file

- **Cat 23 (recording consent)** cites section 3: the federal baseline, the all-party table, and
  GDPR Article 13 where EU callers are in scope. Its inputs are the recording flag from the
  inventory and the caller-jurisdiction answer from discovery.
- **Cat 24 (AI disclosure and outbound consent)** cites section 1 (the AI-voice ruling, 64.1200(b)
  and (c), the consent standard), section 2 (Utah, Maine, Colorado-upcoming, California SB 243
  where applicable), and section 4 (Article 50, PECR) by the jurisdictions in scope. Its inputs
  are the call surface and the first-message and prompt text.
- **Cat 25 (regulated-data regimes)** cites section 5 (PCI DSS, HIPAA, BIPA, COPPA, FINRA) and the
  CCPA voice definition, by the sector, payments, minors and health answers from discovery.
- **The compliance-exposure paragraph** in `references/report-template.md` copies each regime's
  `Facts verified` line beside the observed pattern.

Every fact above that moved between drafting and verification is recorded in the category that
cites it as the *current* state; the older belief is not preserved anywhere in this skill.
