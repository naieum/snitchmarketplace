## CATEGORY 25: HIPAA, PCI DSS, biometric and minors' regimes on the call path
> Type: compliance · Groups: privacy · Hop: H9 Storage and telemetry · Standards: HIPAA; PCI DSS 4.0; BIPA; COPPA

The content of a call decides which rules attach to every hop that touched it. A card number
spoken into a recorded line puts the recording, the transcript, and every vendor that held them
inside the card standard's scope, and the security code may not be kept after authorization in
any form, audio included. A symptom described to a clinic's agent makes the transcriber, the
model, the synthesizer and the hosted platform business associates who each need a written
agreement. A voiceprint enrolled for verification is a biometric identifier that Illinois callers
must release in writing. A child's voice kept past the request it answered is personal
information under the amended children's rule. This category reads what the flow expects to
hear, which providers see it, and what the workspace shows for each regime the discovery inputs
put in play. It reports exposure against named rules; the mechanics of stripping data are Cat 22.

**Boundary.** Cat 22 judges whether sensitive content is redacted or diverted before it lands;
this category judges which regime attaches to what lands and what the workspace evidences for it.
Voice biometrics as an authentication factor is Cat 05; verification before disclosure is Cat 06;
where artifacts land and who can reach them is Cat 21; recording consent is Cat 23. The same card
capture is one Cat 22 finding on the flow and one row here on the exposure; neither restates the
other. Generic secrets handling in a payment integration is snitch-security's Cat 13 and Cat 22 —
hand off by calling the Skill tool with "snitch-security".

**Pre-flight.** Inputs, never inferred: from discovery, the sector, whether payments are taken by
voice, whether minors or health data are expected, and the caller jurisdictions; from the STEP 0
inventory, the provider list (carrier, transcriber, model, synthesizer, platform, observability)
and any recording, transcript, or biometric feature. Two branches. **Inputs answered:** resolve
each regime in `references/legal-landscape.md` section 5 (and the CCPA voice definitions in
section 3) against the answers, then read the workspace for the pattern each regime is judged on.
**Inputs not answered:** run the pattern reads anyway — card capture, health vocabulary, voiceprint
enrollment, and minor-directed flows are visible in code — and write the regime rows generically,
attached to none, with `Exposure could not be scoped — the discovery questions were not answered`.
Agreements (a BAA, a PCI attestation, a processor contract) are almost never in a repository:
their absence is a **Skip** naming the document that would unblock it, never a finding; the
provider inventory that would need them is the evidence.

**Forbidden claims.** Never write "HIPAA-compliant", "PCI-compliant", "in violation", or their
negations as a verdict; write "captures a card security code into the transcript at `file:line`,
which the retention rule is judged on". Never predict an assessment outcome, a breach
notification, or a penalty, and never state a figure. Never decide that the business is a covered
entity, a merchant, or subject to a state statute — say which discovery answer would put it there.
Never treat a platform flag (`hipaaEnabled`, a zero-retention mode) as proof an agreement exists;
it is evidence about storage, quoted as such. Every regime line carries its `Facts verified:
2026-09-06 against <URL>` line from `references/legal-landscape.md`; the card standard's verbatim
requirement text and the health Security Rule proposal's status carry that file's hedges.

### Detection
- Payment capture: tools or prompt sections named `payment`, `card`, `pay`, `charge`,
  `collect_card`, `cvv`, `expiry`; `<Gather>` or DTMF capture of 13–19 digit strings; Twilio
  `<Pay>`; payment SDK calls inside tool handlers; platform notes that a field is not PCI-scoped
  (`<Parameter>`, `handoffData`, `welcomeGreeting`, `hints`); `compliancePlan.pciEnabled`
- Health context: sector answer; vocabulary in prompts and tools (`patient`, `appointment`,
  `prescription`, `diagnosis`, `symptom`, `insurance`, `member_id`, `provider`, `clinic`,
  `pharmacy`, `refill`); EHR or scheduling APIs; `hipaaEnabled`, `compliancePlan.hipaaEnabled`,
  zero-retention flags, `data_storage_setting`
- Biometrics: speaker-verification or voiceprint SDKs and APIs, `voiceprint`, `enroll`,
  `speaker_id`, `verify_speaker`, `voice_biometric`, embeddings stored per caller
- Minors: sector or product aimed at children, `age`, `parent`, `guardian`, `student`, `child`,
  COPPA vocabulary, audio retention on such flows
- Financial: `broker`, `trade`, `order ticket`, `advisor`, FINRA vocabulary; retention settings
- Provider inventory from STEP 0: every vendor that sees audio, transcript, prompt, or tool
  payloads, including observability and analytics tools receiving transcripts

### What to Search For
- A card number or security code captured by speech or DTMF on a channel that is recorded,
  transcribed, sent to the model, or logged, with no pause/mask/handoff (Cat 22 has the mechanics;
  here it is the exposure row)
- Card data placed in a platform field the vendor documents as not PCI-scoped
- Payments taken by voice with no PCI-scoped path in the workspace at all (no `<Pay>`, no DTMF
  masking, no handoff to a payment IVR) and no attestation or scope document referenced
- Health-sector agent whose provider inventory includes vendors with no agreement referenced
  anywhere (docs, config comments, a `COMPLIANCE.md`) — record the inventory, Skip the agreements
- Health data flowing to an observability or analytics tool, or to a model provider on a
  non-enterprise tier, where the workspace shows no zero-retention or enterprise flag
- Voiceprint enrollment or verification with Illinois callers in scope and no written-release
  flow (a consent capture that produces a stored, attributable release, not a spoken "yes")
- Voice recordings retained where California callers are in scope and the privacy notice
  referenced in the workspace does not list audio or biometric information `(unverified —
  confirm the notice)`
- Child-directed flow that stores audio beyond responding to the request, or builds a
  voiceprint from a child's voice
- A "taping firm" context (discovery) with recordings retained under three years
- Vendor tiers and flags asserted in comments or READMEs with no configuration to match (a
  README claiming "HIPAA mode" while the assistant config has no such flag)

### Rule table
| Row | Regime cited | Fails when | Evidence | Severity |
|---|---|---|---|---|
| sad-retained-in-audio-or-text | PCI DSS 3.3.1 as stated in the standard's FAQ; the telephone-payment guidance | A card security code or full track data is captured by speech or DTMF into a recorded, transcribed, model-visible, or logged channel with no mechanism that renders it unrecoverable after authorization | the capture file:line + the storage/transcript path from Cat 22 + the search for pause/mask/handoff | High when payments-by-voice is answered yes; Medium when unanswered |
| pan-in-unscoped-field | PCI DSS scope; the vendor's own not-PCI-scoped note | Card data is written into a platform parameter, greeting, hint, or handoff field the vendor documents as outside its PCI scope | the field file:line + the stack file's note | High / Medium as above |
| no-pci-path | PCI DSS | Payments are taken by voice and the workspace shows no PCI-scoped capture path and references no scope document | the payment tool file:line + the searches | Medium |
| phi-to-provider-without-agreement | HIPAA 160.103 / 164.502(e) | Sector is health, a provider on the call path sees PHI, and no agreement is referenced; the agreements themselves are a Skip | the provider inventory + the search for agreement references | Medium (the finding is the inventory; the agreement is the Skip) |
| phi-to-non-covered-tool | HIPAA 164.502(e) | Transcripts or audio with health content flow to an observability, analytics, or automation tool with no agreement reference and no redaction | the forward file:line (from Cat 21) | High when health is answered yes; Medium when unanswered |
| hipaa-flag-mismatch | HIPAA | The workspace claims a HIPAA or zero-retention mode that the configuration does not set | the claim file:line + the config file:line | Medium |
| voiceprint-no-written-release | Illinois BIPA 740 ILCS 14/15(b) | Voiceprint enrollment or verification exists and Illinois callers are in scope, with no written-release capture | the enrollment file:line + the search for a release flow | High when Illinois is in scope; Medium when unanswered |
| child-audio-retained | COPPA 16 CFR 312.2, 312.5(c)(9) | A child-directed flow retains audio beyond the request it answered, or derives a voiceprint | the retention file:line | High when minors are answered yes; Medium when unanswered |
| ccpa-notice-gap | Civ. Code 1798.140 | Voice recordings or voiceprints are collected from California callers and the referenced notice does not name audio or biometric information | the collection file:line + the notice, or its hedge | Medium |
| taping-firm-retention | FINRA Rule 3170 | Discovery names a taping firm and recordings are retained under three years | the retention setting file:line | Medium |
| upcoming-or-unlisted | — | A regime discovery names that is not in the landscape, or the Security Rule proposal, or SEC voice-retention rules | hedge line | Low, informational |

### Actually Vulnerable

Critical is never used in this category: the flow that captures the data is Cat 22's finding at
its own severity; this category's rows are exposure reads whose weight depends on inputs the
audit does not decide.

#### High
- Card security codes captured into a recorded or transcribed channel with no pause, mask, or
  handoff, on an agent where payments-by-voice is answered yes
- Card data in a field the vendor documents as not PCI-scoped
- Health-content transcripts forwarded to an analytics or automation tool with no agreement
  reference and no redaction, on a health-sector agent
- Voiceprint enrollment with Illinois callers in scope and no written-release capture
- Child-directed flow retaining audio or building a voiceprint

#### Medium
- The same shapes where discovery left the relevant answer blank
- Payments by voice with no PCI-scoped path and no scope document referenced
- Provider inventory with PHI exposure and no agreement references (the inventory is the finding,
  the agreements are the Skip)
- A README or comment claiming a compliance mode the configuration does not set
- CCPA notice gap; taping-firm retention gap

### NOT Vulnerable
- Card capture handed to a PCI-scoped IVR or `<Pay>` step during which the agent's recording
  and transcription are paused, with the pause and resume quoted — Pass for the PCI rows
- DTMF masking configured on the carrier or platform and exported in the workspace — Pass
- Health-sector agent whose configuration sets the platform's no-storage mode and whose provider
  list is documented with agreement references — Pass for storage, Skip for the agreements'
  contents (not in the workspace)
- No payment, health, biometric, or minor-directed flow in the inventory and discovery answers
  matching — Skip, `not applicable`, with the searches
- A written-release flow for voiceprints: an attributable, stored consent artifact captured
  before enrollment — Pass quoting the capture
- A `BLUEPRINT.md` Decision that no payments are taken by voice, with the code matching — Skip
  citing the line; if a payment tool exists anyway, the Decision does not waive the row

### Context Check
1. What does the flow expect to hear? Read the tools and prompt sections, not the marketing.
2. Which providers see audio, transcript, prompt, and tool payloads? Build the list from the
   inventory.
3. For card data: where is it captured, and what happens to the recording and transcript during
   capture?
4. For health data: what does the configuration set, and what does the workspace reference about
   agreements?
5. For biometrics: is a voiceprint created or compared, and what consent artifact precedes it?
6. For minors: is any flow child-directed, and how long is audio kept?
7. Which discovery answers put which regime in play, and which stay generic?

### Evidence Chain
- The capture or feature file:line (payment tool, health tool, voiceprint call, child flow)
- The storage or forward path from Cat 21 / Cat 22 with file:line
- The provider inventory from STEP 0
- The configuration flags read (compliance modes, retention, redaction) with file:line, or the
  search that established their absence
- The agreement references found, or the Skip naming the document that would unblock it
- The regime line(s) with `Facts verified: 2026-09-06 against <URL>` from
  `references/legal-landscape.md`, and the discovery answers that put them in scope

### Confidence Scoring
- **High**: the capture, the storage path, and the configuration are all in the workspace and
  discovery answered the relevant question
- **Medium**: the storage default or compliance mode is platform-side without an export, or the
  relevant discovery answer is blank
- **Low**: the flow's data path could not be resolved → tag `needs human verification`

### Severity
High is a regime the inputs put in play meeting the observed pattern it is judged on. Medium is
the same pattern with the regime uncertain, a control that is platform-side and unexported, a
claim-versus-configuration mismatch, or an inventory whose agreements cannot be read. Low is the
informational unlisted or not-yet-final row. Critical is never used here.

### Files to Check
- `**/tools/**`, `**/payment*`, `**/pay*`, `**/card*`, `**/billing*`
- `**/patient*`, `**/appointment*`, `**/clinic*`, `**/ehr*`, `**/fhir*`
- `**/voiceprint*`, `**/biometric*`, `**/speaker*`, `**/enroll*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/config/**`, `.env*`
- `COMPLIANCE.md`, `SECURITY.md`, `docs/**`, `**/privacy*`, `**/notice*`

### Reference
- `references/legal-landscape.md` section 5 (PCI DSS retention of sensitive authentication data
  and the telephone-payment guidance, HIPAA business associates and the Security Rule proposal's
  status, Illinois BIPA voiceprints and written release, COPPA audio files and the request
  exception, FINRA Rule 3170) and section 3 (CCPA voice and biometric definitions)
- Cat 05 (biometrics as a factor), Cat 06 (verification), Cat 21 (storage), Cat 22 (redaction
  mechanics), Cat 23 (recording consent)
