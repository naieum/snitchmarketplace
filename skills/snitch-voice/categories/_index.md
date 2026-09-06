# Category Manifest

The single source of truth for category identity and attributes. Every rule elsewhere that
depends on "which categories" resolves against this table — never against a hardcoded number list.

**Rules derived from Type.** This skill's types classify **how a finding must be written**,
because a voice agent's defects answer to three different kinds of evidence. Three types, each
with one obligation:

- `sink-pattern` — the call-path trace of `references/anti-hallucination.md` Rule 3 is
  **required**: source hop → intermediate hops → sink, each with `file:line`, and the controls
  checked and found absent. A grep match with no trace is a candidate at Low confidence tagged
  `needs human verification`, never a finding. Prose in a system prompt, a tool description, and
  the model's own judgment are never controls.
- `posture` — the finding quotes the configuration line, the route, or the code that sets the
  deciding default, or names the search that established its absence with its scope. A setting
  that lives only platform-side, with no export in the workspace, is a Skip under Rule 6.
- `compliance` — every finding names the law, regulation or standard it reports against, plus the
  observed pattern at `file:line`. It states **exposure, never a verdict**, and it carries a
  `Facts verified` hedge on anything that moves. The verified facts live in
  `references/legal-landscape.md`; a fact that reference could not verify is written with an
  `(unverified — confirm at <URL>)` hedge rather than asserted.

Type is orthogonal to Groups. A group is what a user selects in one tap; a type is how the finding
must be written.

**Groups** are the preset audit selections. A preset resolves to *every active row whose Groups
cell contains that preset's slug*, read out of this table at scan time — never to a stored ID
list. Six slugs:

- `quick` — the checks that drain accounts and leak keys most often.
- `ingress` — what reaches the server claiming to be the carrier, the platform, or a client, and
  what the deployment leaves reachable.
- `injection` — caller-influenced text reaching the instruction position, and model output
  reaching a sink.
- `actions` — who the caller is, what they may see, and what the tools may do on their word.
- `abuse` — duration, concurrency, spend, outage behavior, and the audit trail.
- `privacy` — recordings, transcripts, redaction, consent, disclosure, and sector regimes.

`full` is every active row and is therefore not listed per row. `references/scan-selection.md`
owns the menu and the alias table; it resolves against this manifest and stores no ID lists of
its own.

**Hop** is the primary call-path position from `references/call-path.md`, repeated here for the
confirm gate; that reference is authoritative for the mapping and for the coverage block.

**Standards** is the external authority a finding cites when one exists. `—` means the category
is a posture judgment with no governing spec beyond the row name.

**Status.** Four values, and the ID is permanent under all four — a number is never reused,
reordered, or renumbered:

- `active` — auditable. The file exists and the audit runs it.
- `merged→NN` — the category's checks now live in category `NN` of this skill. The row stays so
  the number stays reserved and old reports remain readable; the file becomes a short redirect
  stub, no scan selects the ID, and cross-references are rewritten to point at `NN`.
- `moved→snitch-<skill>` — the judge for these findings belongs to a sibling skill, so the checks
  live there now. The row stays reserved; this skill hands off by calling the Skill tool with that
  skill rather than auditing it here.
- `deleted` — the checks were out of scope and no sibling took them. The row stays so the number
  stays reserved and old reports stay readable; the file is removed and no cross-reference to it
  survives.

A row's Status is what decides whether it runs. Nothing selects a category by number range, so a
row changing status needs no edit anywhere that reads this manifest by attribute. Anything stating
a category *count* is a separate manual update: the "Active categories" line below and `SKILL.md`.

Active categories: 27 of 27 rows.

| ID | Slug | Title | Type | Groups | Hop | Standards | Status |
|----|------|-------|------|--------|-----|-----------|--------|
| 01 | webhook-authenticity | Telephony and platform webhook authenticity | posture | quick, ingress | H1 | CWE-345, CWE-306 | active |
| 02 | media-stream-and-session-endpoints | Media-stream sockets, SIP ingress and realtime session endpoints | posture | quick, ingress | H1 | CWE-306, CWE-319 | active |
| 03 | client-credential-exposure | Provider secrets in browser and mobile voice clients | posture | quick, ingress | H11 | CWE-798, CWE-522 | active |
| 04 | ephemeral-token-minting | Ephemeral token and client-secret minting endpoints | posture | ingress | H2 | CWE-287, CWE-613 | active |
| 05 | caller-identity-trust | Caller ID, CNAM and voice as identity | sink-pattern | quick, actions | H2 | CWE-290, CWE-287 | active |
| 06 | caller-verification-before-disclosure | Verification before account disclosure or change | sink-pattern | actions | H2 | CWE-287, CWE-200 | active |
| 07 | speech-and-dtmf-injection | Injection through transcribed speech and DTMF | sink-pattern | quick, injection | H3 | CWE-1427; OWASP LLM01 | active |
| 08 | call-metadata-and-variable-injection | Injection through call metadata and dynamic variables | sink-pattern | injection | H4 | CWE-1427; OWASP LLM01 | active |
| 09 | retrieved-content-injection | Injection through retrieved records and tool results | sink-pattern | injection | H5 | CWE-1427; OWASP LLM01 | active |
| 10 | system-prompt-hygiene | Secrets, authorization logic and leakage in the system prompt | posture | quick, injection | H4 | CWE-200; OWASP LLM07 | active |
| 11 | assistant-config-tampering | Client-supplied assistant and session configuration | posture | injection, ingress | H4 | CWE-602, CWE-915 | active |
| 12 | tool-authorization | Tool webhook authentication and per-call authorization | sink-pattern | quick, actions | H6 | CWE-306, CWE-639; OWASP LLM06 | active |
| 13 | consequential-action-gates | Confirmation, limits and idempotency on consequential tools | sink-pattern | quick, actions | H6 | CWE-862, CWE-841; OWASP LLM06 | active |
| 14 | dial-and-transfer-control | Outbound dial, transfer, forwarding and DTMF-send control | sink-pattern | quick, actions, abuse | H7 | CWE-20, CWE-862 | active |
| 15 | messaging-tools-on-call | SMS and email sends from the call path | sink-pattern | actions | H7 | CWE-20, CWE-862 | active |
| 16 | tool-output-and-error-handling | Tool results and errors reaching speech or sinks | sink-pattern | injection | H6 | CWE-209; OWASP LLM05 | active |
| 17 | session-limits | Call duration, silence, idle and turn limits | posture | quick, abuse | H10 | CWE-400, CWE-770 | active |
| 18 | concurrency-and-throttling | Inbound concurrency, per-caller throttles and callback loops | posture | abuse | H10 | CWE-770, CWE-799 | active |
| 19 | spend-controls | Model, speech and telephony spend ceilings | posture | quick, abuse | H10 | CWE-770; OWASP LLM10 | active |
| 20 | resilience-and-fail-safe | Outage behavior, dead air, forced hang-up and human fallback | posture | abuse | H10 | CWE-636, CWE-755 | active |
| 21 | recording-and-transcript-storage | Where recordings, transcripts and logs land and who can reach them | posture | quick, privacy | H9 | CWE-532, CWE-284 | active |
| 22 | sensitive-data-redaction | Card, health, identity and voiceprint data in transcripts, logs and prompts | posture | privacy | H9 | CWE-312, CWE-359; PCI DSS 4.0 | active |
| 23 | recording-consent | Recording announcement and consent capture | compliance | privacy | H9 | US state wiretap statutes; GDPR Art. 6, 13 | active |
| 24 | ai-disclosure-and-outbound-consent | AI disclosure, robocall consent and do-not-call handling | compliance | privacy | H8 | TCPA / FCC 2024 AI-voice ruling; state bot-disclosure laws; EU AI Act Art. 50 | active |
| 25 | regulated-data-regimes | HIPAA, PCI DSS, biometric and minors' regimes on the call path | compliance | privacy | H9 | HIPAA; PCI DSS 4.0; BIPA; COPPA | active |
| 26 | deployment-hygiene | Tunnel URLs, plaintext webhooks, debug routes and quickstart leftovers | posture | quick, ingress | H11 | CWE-319, CWE-489 | active |
| 27 | audit-trail-and-anomaly-alerts | Per-call audit trail and anomaly alerting | posture | abuse, privacy | H10 | CWE-778 | active |

**Hop ownership.** Every hop H1–H11 in `references/call-path.md` is the primary hop of at least
one category, so the report's coverage block can list all eleven with a category-backed outcome.

**Boundary with siblings.** snitch-security judges the same repository's code off the call path:
its Cat 01 owns the SQL construction a voice tool argument reaches (Cat 12 and 16 here own the
argument), its Cat 03 owns server-only hardcoded secrets (Cat 03 here owns the client bundle), its
Cat 15 owns prompt injection at a text chat input (Cat 07 here owns transcribed speech), its Cat
19 owns standalone SMS endpoints (Cat 15 here owns sends from the call), its Cat 56 owns generic
WebSocket servers (Cat 02 here owns media-stream sockets), and its Cat 68 owns non-voice agent
tool surfaces (Cats 12–16 here own the voice agent's). snitch-ux judges whether a caller
understands the agent; snitch-ada judges the phone flow's accessibility. Each category file
states its own half in one Boundary paragraph.
