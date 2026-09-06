## CATEGORY 24: AI disclosure, robocall consent and do-not-call handling
> Type: compliance · Groups: privacy · Hop: H8 Synthesis and playback · Standards: TCPA / FCC 2024 AI-voice ruling; state bot-disclosure laws; EU AI Act Art. 50

Two questions sit in the agent's first sentence and its dialer. First: does the person on the
line know they are talking to a machine, and does the machine tell the truth when asked? Under
the 2024 FCC ruling an AI-generated or cloned voice is an "artificial or prerecorded voice", so
an outbound agent inherits the identification, callback-number and opt-out duties written for
robocalls, and a growing set of state laws and the EU AI Act attach a disclosure duty to any
conversation with an AI. Second: did the business have the right to place the call at all — a
consent record that meets the current standard, a do-not-call scrub, and a calling-hours check —
and does the agent honor "stop" when it hears it? This category reads the first message, the
prompt's instructions about identity, the outbound call path, and the opt-out tooling. It reports
exposure against named rules, never a verdict.

**Boundary.** This category judges what the agent says about itself and whether an outbound call
was permitted. Secrets and authorization logic inside the prompt are Cat 10; the destination
control on the dial itself is Cat 14; the recording announcement that often shares the first
message is Cat 23; an outbound endpoint anyone can drive is Cat 18 for the throttle and Cat 14 for
the destination — this category adds the consent check that must precede the dial. A claim the
agent makes to callers that is absent from a `BLUEPRINT.md` Claim inventory is an uncapped
Finding here (SKILL.md STEP 0.5).

**Pre-flight.** Inputs, never inferred: from the STEP 0 inventory, the call surface (inbound,
outbound, both) and the first-message and prompt locations; from discovery, the jurisdictions of
callers and the sector (for Utah's regulated-occupation duty). Two branches. **Inputs answered:**
resolve jurisdictions against `references/legal-landscape.md` sections 1, 2 and 4 and read the
surfaces against each regime in scope. **Inputs not answered:** the honesty rows and the outbound
robocall rows still run — the FCC rules need no state answer for a US outbound line — and the
state and EU rows are listed generically with `Exposure could not be scoped — the discovery
questions were not answered`. No outbound path in the inventory makes every outbound row `Skip —
not applicable: no outbound call creation in the workspace`, with the search. A hosted platform
whose first message lives only in its dashboard is a Rule 6 Skip naming the export.

**Forbidden claims.** Never write "compliant", "TCPA-compliant", "violates", or "illegal
robocall" as a verdict; write "places artificial-voice calls at `file:line` with no consent read
from a record before the dial, which the rule at 64.1200(a) is judged on". Never predict an
enforcement action or a class action, and never state a per-call or aggregate figure. Never cite
the FCC's AI-disclosure proposal as a rule; it is a proposal. Never cite California's B.O.T. Act
or New York's synthetic-performer law against a phone agent — the first is online-only and the
second exempts audio. Never report Colorado's 2027 duty as in force. Every regime line carries its
`Facts verified: 2026-09-06 against <URL>` line from `references/legal-landscape.md`; an unlisted
state is `(unverified — confirm at the state legislature's site)`.

### Detection
- First-message and greeting keys: `firstMessage`, `firstMessageMode`, `welcomeGreeting`,
  `begin_message`, `first_sentence`, `greeting`, `agent.greeting`, `instructions`,
  `system_prompt`, `general_prompt`, `task`, `<Say>` before `<Connect>`
- Identity instructions in prompts: "you are Sarah", "a human agent", "do not reveal that you are
  an AI", "if asked whether you are a bot", "never say you are automated", "pretend", persona
  names with no AI mention
- Outbound call creation: Twilio `calls.create`, Vonage `createOutboundCall`, Telnyx `calls.create`
  / `dial`, Plivo `calls.create`, Vapi `POST /call/phone` / `customer.number`, Retell
  `create-phone-call`, Bland `POST /v1/calls`, ElevenLabs `/twilio/outbound-call` and
  `/sip-trunk/outbound-call`, LiveKit `CreateSIPParticipant`, Amazon Connect
  `start_outbound_voice_contact`, campaign runners and cron jobs that dial lists
- Consent and DNC signals: `consent`, `optIn`, `tcpa`, `prior_express`, `dnc`, `doNotCall`,
  `do_not_call`, `suppression`, `scrub`, `optOut`, `STOP`, `revoke`, `unsubscribe`; time-zone
  and hour checks near the dialer (`8`, `9`, `21`, `localTime`, `tz`)
- Opt-out tooling: tools or handlers named `opt_out`, `stop_calling`, `add_to_dnc`,
  `remove_from_list`; DTMF handlers on outbound calls; end-call tools triggered by stop phrases
- Platform disclosure fields: any platform "AI disclosure" or "identify as AI" toggle exported in
  the workspace `(unverified — confirm in the platform docs)`

### What to Search For
- An outbound artificial-voice message whose first words do not identify the business (the
  business name, not just a persona name) and whose flow never gives a callback number
- A telemarketing outbound agent with no automated opt-out: no keypress or spoken-"stop" handler
  that records the revocation and ends the call
- `calls.create` (or the platform equivalent) reached from a request body, a spreadsheet, or a
  CRM list with no consent field read from a verified record before the dial, or a consent field
  that is itself supplied in the request body
- No DNC scrub on the list or the number before the dial; no local-time window check
- Prompt text instructing the agent to claim to be human, to deny being AI, or to deflect the
  question; a first message that introduces a human name with no AI mention on a line that
  reaches Utah (ask-triggered), Maine (misleading-belief test), or EU callers (Article 50)
- A regulated-occupation agent (health, financial, legal advice; Utah's high-risk interaction)
  whose first message does not disclose AI proactively
- Disclosure present in the inbound greeting but absent from the outbound `first_sentence` /
  `task`
- Disclosure text that the client can override (`assistantOverrides.firstMessage`,
  `conversation_config_override`)
- A stop-phrase handler that ends the call but writes nothing to a suppression list, so the next
  campaign dials again
- UK numbers dialed by an automated system with no consent record (PECR reg. 19) or no TPS
  check (reg. 21)

### Rule table
| Row | Regime cited | Fails when | Evidence | Severity |
|---|---|---|---|---|
| no-identification | 47 CFR 64.1200(b)(1)–(2) via the 2024 AI-voice ruling | An outbound artificial-voice message does not state the responsible business at the start, or never provides a callback number | the outbound first sentence file:line + the search for the business name and a number | High |
| no-opt-out-mechanism | 47 CFR 64.1200(b)(3) | A telemarketing outbound agent has no automated keypress or voice opt-out mechanism, or it is not offered near the identification | the outbound flow file:line + the search for a stop/opt-out handler | High |
| dial-without-consent | TCPA prior express (written) consent; the post-vacatur "clearly and unmistakably" standard | Outbound call creation with no consent value read from a verified record before the dial, or consent taken from the request body | the dial file:line + the trace of the consent value | High |
| no-dnc-or-hours-check | 47 CFR 64.1200(c) | Telephone solicitation dialer with no DNC scrub or no 8 a.m.–9 p.m. local-time check | the dialer file:line + the search | High for DNC; Medium for hours |
| claims-human | Utah 13-75-103 (ask-triggered); Maine 10 MRSA 1500-Y (misleading belief); EU AI Act Art. 50(1) where EU callers are in scope | Prompt or first message instructs the agent to claim or imply it is human, or to deny being AI when asked | the prompt text file:line | High where a listed regime is in scope; Medium otherwise |
| no-proactive-disclosure-regulated | Utah 13-75-103(2) | Sector answer is a regulated occupation and the interaction is high-risk, with no verbal disclosure at the start | the first message file:line + the discovery answer | High |
| no-disclosure-general | Maine; EU Art. 50; Colorado HB 26-1263 from 2027-01-01 (informational until then) | No AI disclosure anywhere in the first message or greeting, on a line reaching a listed jurisdiction | the greeting file:line + the search | Medium (Low for Colorado until in force) |
| disclosure-overridable | same as the row it weakens | A disclosure exists but can be removed by a client override or request variable | the override path file:line | Medium |
| stop-not-persisted | TCPA revocation handling; PECR reg. 21 for UK numbers | A stop phrase ends the call but nothing writes the number to a suppression store | the handler file:line + the search for the write | Medium |
| uk-automated-calling | PECR reg. 19 / 21 | UK numbers dialed with no consent record or no TPS check | the dialer file:line + the discovery answer | High |
| upcoming-or-unlisted | — | A named jurisdiction is not in the landscape, or a duty is not yet in force | hedge line | Low, informational |

### Actually Vulnerable

Critical is never used in this category: the exposure depends on inputs the audit does not decide
and on facts that move; High is the ceiling.

#### High
- Outbound artificial-voice campaign with no business identification at the start of the message
- Telemarketing outbound agent with no automated opt-out mechanism
- `calls.create` from a list or request with no consent value traced to a verified record
- No DNC scrub before a solicitation dial
- A prompt telling the agent to say it is human, or a first message presenting a human persona
  with a deny-AI instruction, on a line reaching Utah, Maine or the EU
- Regulated-occupation agent with no verbal AI disclosure at the start
- UK numbers dialed by an automated system with no consent record

#### Medium
- No calling-hours check on a solicitation dialer
- No AI disclosure at all on a line reaching a listed jurisdiction, with no instruction to deny
- Disclosure overridable from the client
- Stop phrase honored on the call but not persisted
- Any High shape where discovery left the jurisdictions unanswered

### NOT Vulnerable
- Outbound first sentence names the business and a callback number is given in the flow, with an
  opt-out keypress handler that writes to a suppression store — Pass quoting all three
- The dial reads `consent_at` / `consent_source` from the customer record and refuses when absent
  or revoked; the consent field is not writable from the request — Pass quoting the check
- DNC scrub and local-time window enforced in the dialer job — Pass
- First message states plainly that the caller is speaking with an AI or automated assistant and
  the prompt instructs an honest answer when asked — Pass for the honesty rows
- Inbound-only agent with no outbound path — the outbound rows Skip `not applicable`, with the
  search
- Informational (non-telemarketing) outbound calls: the opt-out row is reported as informational,
  because 64.1200(b)(3) is written for telemarketing; identification still applies
- A companion-style consumer product where SB 243 would apply is out of the business-agent
  default; cite it only when the product is a companion

### Context Check
1. Does the agent place calls, answer them, or both? Read the dialer, not the README.
2. What is the first thing an outbound callee hears, verbatim, and is it fixed or generated?
3. What does the prompt say about the agent's identity, and what happens when a caller asks?
4. Where does the consent value come from before the dial, and can the request set it?
5. Is there a DNC scrub and an hours check, and where?
6. What does "stop" do — end the call, write a record, both, neither?
7. Which jurisdictions and which sector did discovery name?

### Evidence Chain
- The first-message or greeting text with file:line, or the search over every greeting key
- The prompt lines governing identity, with file:line
- The dial file:line and the traced source of the consent value, the DNC check, and the hours
  check, or the searches that established their absence
- The opt-out handler file:line and the suppression write, or the searches
- The regime line(s) with `Facts verified: 2026-09-06 against <URL>` from
  `references/legal-landscape.md`, and the discovery answers that put them in scope

### Confidence Scoring
- **High**: the greeting, the prompt, and the dialer are in the workspace and discovery named the
  jurisdictions and sector
- **Medium**: the first message or a disclosure toggle is platform-side without an export, or
  discovery was unanswered
- **Low**: the dial path or the consent source could not be traced → tag `needs human
  verification`

### Severity
High is an outbound artificial-voice path missing a federal duty the ruling makes unambiguous
(identification, opt-out, consent, DNC) or an instruction to deny being AI where a listed regime
is in scope. Medium is the hours check, a missing-but-not-denied disclosure, overrides, and
unpersisted stops, plus any High shape with unanswered inputs. Low is upcoming or unlisted law.
Critical is never used here.

### Files to Check
- `**/outbound*`, `**/campaign*`, `**/dialer*`, `**/call*`, `**/cron/**`, `**/jobs/**`
- `**/*assistant*.json`, `**/*agent*.json`, `**/pathway*`, `**/prompts/**`, `**/*prompt*`
- `**/consent*`, `**/dnc*`, `**/suppression*`, `**/optout*`, `**/tcpa*`
- `**/tools/**` (opt-out and stop tools), `**/twiml*`, `**/ncco*`

### Reference
- `references/legal-landscape.md` section 1 (the AI-voice ruling, 64.1200(b) and (c), the consent
  standard, the FCC proposal's status, the Telemarketing Sales Rule), section 2 (Utah, Maine,
  Colorado-upcoming, California SB 243's carve-outs, the laws that do not reach voice), section
  4 (EU AI Act Article 50, UK PECR)
- Cat 10 (prompt hygiene), Cat 14 (dial control), Cat 18 (outbound throttles), Cat 23 (recording
  announcement)
