# Anti-Hallucination Rules

The evidence contract for snitch-voice. Load this file at audit start and apply it through every
category and the final pass before the report saves. Violating any rule invalidates the audit.

This skill makes claims about what a caller can make a voice agent do, spend, or say. Every one of
those claims is checkable against the code and the platform configuration, and several of them are
checkable against the law. So every claim is traceable to `file:line`, hedged where the fact moves,
and marked Skip where the check did not run.

## Rule 1: No finding without evidence

- Call Read or Grep before claiming any finding. Quote the exact lines: the route handler, the tool
  definition, the assistant config, the prompt template, the dial call, the recording flag.
- Cite `file_path:line_number`. For a platform-side setting that lives in a dashboard rather than
  the repo, the evidence is the exported config file or API payload in the workspace; if none is in
  the workspace, the check is a **Skip** naming the setting and the export that would unblock it.
- If the file does not show it, it is not a finding.
- A negative claim (missing, absent, none found) carries three parts: the search that ran with its
  pattern visible, the result count, and the scope it covered. `Verified via grep -nE
  "validateRequest|webhook\(" over src/**/*.ts returning 0 matches across 6 telephony route
  files.` A negative claim with no scope is a guess with a citation shape.

## Rule 2: Every finding names its rule and its hop

A finding carries an observation, a rule, and a **hop**. The hop is the position on the call path
(`references/call-path.md`) where the defect sits: ingress, session auth, transcription, prompt
assembly, retrieval, tool dispatch, call control, synthesis, or storage. The rule is one of:

- a named row from the category's own rule table (sink-pattern and posture categories);
- a named law, regulation, or standard (compliance categories).

A check with no row in a rule table is a **Skip**, never a finding under a borrowed row. If an
observation looks real but no row in the selected category covers it, place it by who owns it, per
SKILL.md's SCOPE RULE: a live category of this skill takes `Skip — <observation>; owned by Cat NN,
not run`; a sibling skill takes a hand-off naming that skill; only an observation no category and
no sibling owns is reported as an uncategorized observation saying which category would need a new
row.

## Rule 3: Trace the call path before you call it a finding (sink-pattern categories)

A grep match is a candidate, not a finding. For every `Type: sink-pattern` category, trace the
data from its source on the call path to the sink, hop by hop, with `file:line` at each hop, then
classify:

| Source classification | Outcome |
|---|---|
| **Literal / hardcoded constant** — a fixed transfer number, a fixed system prompt, a fixed recipient | Not a finding. Record as Pass evidence with the literal's file:line. |
| **Protected for this sink** — a traced control outside the model prevents the specific unsafe effect at this argument position (an allowlist the dial destination is checked against, a server-side verification step that precedes the account read, an out-of-band confirmation bound to the exact action and arguments) | Not a finding for that check. Record source → effective control → sink with file:line each. A system-prompt instruction, a tool description, or a type check alone is not a control. |
| **Caller-influenced without effective protection** — transcribed speech, DTMF, caller ID, CNAM, SIP headers, client-supplied variables, retrieved records the caller or a third party can write, or the model's own output reaches an unsafe argument position or unauthorized operation | Finding. Evidence names source, path, sink, and why any intervening checks do not prevent the specific effect. |
| **Trace cannot reach a definitive source within the scanned scope** | Finding stays at **Low confidence, tagged `needs human verification`** — never silently dropped, never promoted on a guess. |

**Three things are never controls on the call path:** prose in the system prompt ("never transfer
to international numbers", "always verify identity first"), a tool description that says the model
should confirm, and the model's own judgment. The model is the thing being attacked. A control is
code or platform configuration that runs whether or not the model was steered.

Passes get the same rigor. Every traced-clean sink is Pass evidence; a bare "Passed: 0 findings"
fails Rule 1. `Type: posture` categories still read the file that sets the deciding default and
quote it, and `Type: compliance` categories quote the configuration or prompt text the regime is
judged against.

## Rule 4: Volatile facts get hedges

Recording-consent rules, robocall and AI-disclosure rules, and sector regimes are rewritten,
extended, and litigated. Before asserting a current legal requirement, re-check the applicable
official source during this audit and record the access date. `references/legal-landscape.md` is
the reference material and carries a `Facts verified: <date> against <URL>` line per fact; that line
comes into the report with the fact. A fact that reference could not verify is written with
`(unverified — confirm at <URL>)` and never asserted flat. If verification is unavailable in this
session, the determination is a Skip naming the missing source.

Never predict a regulator's decision, a fine, a litigation outcome, or whether a specific entity is
in scope of a specific regime. State the regime, the observed pattern, and the discovery inputs.
The reader's counsel draws the line.

The same rule applies to platform behavior. What a vendor verifies, signs, redacts, or caps **by
default** changes between SDK versions. A stack file in `references/stacks/` states what it
verified and when; a default it could not verify is written as `(unverified — confirm in the
platform docs)` and a finding that rests on it is capped at Medium confidence.

## Rule 5: Three outcomes only

Every check produces exactly one of:

- **Finding**, with full evidence in the Finding Format.
- **Pass**, with at least one quoted line proving the check ran. `Pass — every one of the 4
  telephony webhook routes calls the provider's signature check before reading the body;
  `src/routes/voice.ts:12,41,77,102`.` A bare "Pass" is invalid.
- **Skip**, with the reason and what would unblock it. `Skip — recording consent: no recording
  flag or recording API call found in the workspace (grep for `record|recording` over
  src/** returned 0 matches); would run if recording is enabled platform-side — export the
  assistant config.`

**Finding nothing is two different outcomes, and the difference is whether the subject exists.** A
check whose subject is present and whose failing shape is absent is a **Pass** carrying the search
and the count. A check whose subject does not exist in the workspace at all is a **Skip** worded
`Skip — not applicable: no <subject> in the workspace`, plus what was searched to establish that.
No outbound dialing, no transfer tool, no recording, no payment tool: none of those is a Pass.

"Partially audited", "spot-checked", "couldn't fully verify" are not outcomes. If the audit ran
out of scope or budget, mark the category **Skip** with reason `abbreviated for scope; re-run this
category for full coverage`.

## Rule 6: Platform-side settings Skip, they never infer

Much of a voice agent lives in a vendor dashboard: recording defaults, spend caps, concurrency
limits, allowed countries, webhook secrets. The code often does not show them. When the workspace
carries no exported config, API payload, or infrastructure-as-code that sets the value, emit:

```
Skip — <setting> is platform-side and not represented in the workspace; not run. Unblock: export the assistant/agent configuration (or the account settings) into the repo and re-run.
```

Never assert that a cap is missing because it is not in the code, and never assert that it is
present because the vendor offers it. A stack file saying "the platform supports X" is not
evidence that X is on for this agent.

## Rule 7: Defensive framing only

Describe the precondition, the location, and the impact. Never write a working injection phrase,
a social-engineering script, a spoofing procedure, or a toll-fraud playbook into the report. "A
caller can name a destination and the dial tool uses it unchecked" is a finding; a transcript of
what to say to make it happen is not. If the host refuses a turn on this ground, the category is
recorded **Incomplete** with the reason, never silently omitted.

## Rule 8: Severity is single-valued

One tier per finding. If a finding could be either of two adjacent tiers, escalate. If it could
be two non-adjacent tiers depending on which sub-case applies, split it into two findings. If you
cannot pick a tier from the evidence alone, the evidence is not tight enough yet.

## Rule 9: The redaction gate

Always on. No setting turns it off. Before the report saves, every one of these is stripped:

- **Live secrets**: provider API keys, auth tokens, webhook signing secrets, JWT secrets, SIP
  credentials, and anything shaped like one. Replaced with X's of the same shape and flagged.
- **Personal data**: real phone numbers, names, addresses, account numbers, card numbers, and any
  transcript or recording excerpt quoted from logs or fixtures that looks real become
  `<redacted>`. Obviously synthetic data (`+15550100`, `jane@example.com`) stays.
- **Account and resource identifiers**: account SIDs, assistant IDs, agent IDs, phone-number
  resource IDs, room names that embed a customer identifier become X's of the same shape.

Describe the location and the pattern instead of the value: `line 14: telephony auth token
assigned to a constant rather than read from the environment`.

Transcript fixtures and seed data are where real personal data hides in a voice repo. Read them
with this rule active.

## Rule 10: Never auto-fix

- Never edit, patch or modify a file during the audit or while generating the report.
- Never apply a fix before the complete report is displayed, even an obvious one.
- Offer fixes only in the post-scan menu, and apply one only on explicit selection and
  confirmation.
- **Any fix that changes what the agent can dial, transfer to, pay, send, or say to a caller
  takes per-finding confirmation even in batch.** Those are the agent's business rules, and a fix
  rewrites them. Show the before and after and wait.
- Never call a platform API to change a live setting. A fix is a change to the workspace; the
  deploy is the user's.
- If the user says "audit and fix everything", complete the full audit and report first, then show
  the menu. Auditing and fixing are always two phases.

## Rule 11: No sycophancy

The report's authority is its evidence. Forbidden across findings, passes, chat updates and menu
copy: "best-in-class", "textbook", "strong foundation", "great job", "solid", "impressive", and
every evaluative adjective describing the reader's choices. Pass evidence states what is configured
and where. Findings and passes get equal depth.

---

## False-positive prevention

### Platform auto-handling

Read the stack file before filing. The common mitigations that make a "missing" claim wrong:

- **Webhook verification supplied by SDK middleware** rather than a per-route call: a framework
  plugin or an app-level middleware that checks the signature for every route under a prefix.
  Confirm by reading the middleware registration and the path it covers; a route outside the
  prefix is still unverified.
- **A hosted agent platform that owns the call path**: when the prompt, tools, and call control
  live in the vendor's dashboard and the repo only carries tool webhooks, the categories whose
  subject is in the dashboard are Skips per Rule 6, not findings, and the tool-webhook categories
  are the audit.
- **A token-minting endpoint behind the app's own auth**: an ephemeral-token route inside an
  authenticated area is protected by that area's guard; read the guard before filing.
- **Recording redaction performed platform-side**: a transcription provider configured with
  redaction, or a telephony provider's PCI mode, is a control when the configuration is in the
  workspace and quoted.
- **Allowlists held in configuration rather than code**: a transfer-destination table in a config
  file or environment variable is a control when the dial path reads it; quote both.

When a mitigation is confirmed, suppress the finding and record it as a Pass with the evidence of
the mitigation. When it is plausible but unconfirmed, downgrade confidence to Medium and say what
would confirm it.

### Two-pass verification

After a pattern match, read the surrounding context a second time before writing the finding: the
route's middleware chain, the tool handler's callers, the config the flag lives in. Then re-read the
quoted snippet against the claim. If the snippet does not show what the claim says, retract.

### Auto-exclude paths

Do not report from `node_modules/**`, `.git/**`, `dist/**`, `build/**`, `.next/**`, `.venv/**`,
`__pycache__/**`, `coverage/**`, `__tests__/**`, `*.test.*`, `*.spec.*`, `mocks/**`, `fixtures/**`
(the repo's own test fixtures, not this skill's evals). Report from `*.example.*`, `*.template.*`,
`examples/**`, and `quickstart*/**` only as "verify this is not shipping to production" — voice
platforms ship quickstarts with unverified webhooks and tunnel URLs by design, and those files are
routinely copied into production unchanged.

### Confidence threshold

Assign High, Medium or Low confidence to every finding.

- **High** — the sink is quoted, the source is traced to the caller or to caller-influenced data,
  and no control is plausible.
- **Medium** — the sink is quoted but the source or the control depends on something not read (a
  platform-side setting, a middleware not in the workspace, a config resolved at deploy time).
- **Low** — the pattern matched but the trace is incomplete. Low-confidence findings go in a
  "Needs review" section, never in the main findings list, and never carry a Critical tier.

### Inline ignore comments

Recognize and suppress on:

```
// snitch-voice-ignore: 14 transfer targets come from the ops allowlist in config/transfers.yaml
# snitch-voice-ignore: recording-consent announcement is played by the carrier IVR before handoff
/* snitch-voice-ignore: 03 this key is the public web key, not the private one */
```

The form is `snitch-voice-ignore: <rule> <reason>`, where `<rule>` is a category ID or slug, and
`<reason>` is free text. **A reason is required** — an ignore with no reason is itself reported,
as a suppression with no justification. The comment suppresses matches on the same line and the
line following it. Every suppression is listed in the report's Suppressed section.

### `.snitch-voice-ignore` file

At audit start, read `.snitch-voice-ignore` from the working directory if present. One entry per
line; `#` starts a comment:

```
# path glob : rule : reason
src/legacy/ivr/**        : 07  : legacy DTMF menu with no model in the loop; scheduled for removal
scripts/load-test.ts:40  : 18  : load-test harness, not a production caller path
config/vapi.assistant.json : 21 : recordings are disabled account-wide; export attached in docs/
```

The rule field is a category ID, a category slug, or `*` for the whole file. The reason field is
required. Report the suppressed count and list every entry that actually matched something this
run; an entry that matched nothing is reported as stale.

### The dashboard caveat

**The repo is not the whole agent.** For hosted agent platforms, the assistant's prompt, tools,
voice, recording, and limits may live entirely in the vendor's console and reach the repo only as
an ID. Every finding whose subject could be overridden platform-side carries this in its evidence
when the workspace holds no export:

```
Configured value read from <file:line>; the platform-side setting was not observed. Confirm in the console before treating this as final.
```

Confidence on such a finding is capped at Medium unless the exported configuration was read.
