# Report Template

The exact structure of `VOICE_AGENT_AUDIT_REPORT.md`. Read this before drafting the report. Fill in
every part in `{braces}`.

**Output path:** `{working_directory}/snitchfindings/{target_slug}/VOICE_AGENT_AUDIT_REPORT.md`.
The `{target_slug}` derives from the audited project or agent name. The JSON and CSV exports land
in the same folder as `voice_agent_audit.json` and `voice_agent_audit.csv`.

Three blocks are gates and cannot be skipped, degraded or reordered: the **executive snapshot**,
the **redaction gate**, and the **coverage block**. A report missing any of them does not save.

The structure is symmetric. Findings and passes get the same evidence rigor and the same depth. Do
not open with praise, and do not bury a Critical finding under a summary.

---

## Structure

```markdown
# Voice Agent Security Audit, {project_name OR agent_name}

> Audited by Snitch: Voice on {date_iso}.
> Target: {working_directory}. Stack: {platforms and providers from the inventory}.
> Call surface: {inbound / outbound / web-client / all}. Platform config in workspace: {exported / not exported}.
> Categories run: {N} of {M} active.

## Executive snapshot

**Impact counts:** Critical {n} - High {n} - Medium {n} - Low {n} - Passes {n} - Skips {n}

**Hops covered:** {K} of 11 call-path hops have a primary category in this selection.
{One line naming any hop with no category run, and why.}

**What a caller can do today, in three sentences:** {Sentence 1: the worst traced path, from
source hop to effect, with its finding number. Sentence 2: the worst spend or availability
exposure. Sentence 3: the worst data exposure. Each sentence names a finding; a sentence with no
finding to name says "no finding at this tier in the categories run".}

**Compliance exposure, in one sentence:** {the regimes the discovery answers put in play and the
observed patterns, each with its verified date — or "compliance categories not in this selection".}

**The three findings to read first:**

1. {Impact, Cat NN, hop, one-line summary with its evidence location}
2. {...}
3. {...}
```

### Redaction gate (blocking, always on)

Before the draft becomes a file, sweep every line of it -- findings, passes, skips, snapshot,
metadata -- against `anti-hallucination.md` Rule 9. Live secrets become X's of the same shape and
are flagged; personal data and transcript excerpts that look real become `<redacted>`; account,
assistant, and phone-number resource identifiers become X's of the same shape. Transcript fixtures,
seed data, and logged tool payloads are the three places real data hides; re-read anything quoted
from them.

The gate is not a step the report reports on. It produces no section. It either passed or the file
does not exist.

### Findings, grouped by hop then category

```markdown
## Findings

### H1 Ingress

#### Cat 01 - Webhook authenticity

##### Finding 1: {short title}
{full Finding Format block}

#### Cat 02 - Media-stream and session endpoints
{...}

### H2 Session authentication
{...}

### H6 Tool dispatch
{...}

### H7 Call control
{...}

### H9 Storage and telemetry
{...}

### H10 Limits and operations
{...}

### H11 Deployment
{...}
```

Group by hop **first** (H1 to H11, in order), category second, then by Impact within a category.
A hop with no findings still gets its heading and one line saying whether that is because its
categories passed or because they were skipped:

```markdown
### H7 Call control

No findings. Cat 14 ran and passed on both traced dial sites; Cat 15 was skipped -- no messaging
tool is defined in the workspace. This heading is not evidence that a transfer allowlist exists
platform-side; that setting was not exported.
```

That line is why the grouping is by hop. A skipped hop must be visible, not implied.

### Coverage block (blocking)

The denominator behind every claim in the report. **Every one of the 11 hops in
`references/call-path.md` appears here, exactly once.**

```markdown
## Coverage

Call path: 11 hops. Findings on {f} - Passed {p} - Skipped {s}.

| Hop | Name | Cats run | Outcome | Detail |
|---|---|---|---|---|
| H1 | Ingress | 01, 02 | Finding (2) | see Findings 1, 4 |
| H2 | Session authentication | 04, 05 | Pass | token route behind session guard `src/api/token.ts:9`; caller number never used as identity, grep for `From\b|customer.number` over src/tools/** returned 0 matches in 5 files |
| H3 | Transcription | 07 | Finding (1) | see Finding 6 |
| H5 | Retrieval | -- | Skip | category 09 not in this scan's selection |
| H7 | Call control | 14 | Skip | not applicable: no dial, transfer, or DTMF-send call in the workspace; grep for `transfer|dial|<Dial>|sendDigits` over src/** returned 0 matches in 41 files |
| H10 | Limits and operations | 17, 19 | Finding (3) | see Findings 8, 9, 11; Cat 18 and 20 not in selection |
| ... | ... | ... | ... | ... |
```

Rules for the block:

- **A hop whose every primary category was not selected is a Skip**, with the reason `category NN
  not in this scan's selection`. It is never omitted and never a Pass.
- **A Pass carries the evidence it ran.** "Nothing found" is not a Pass; "verified via `<search>`
  returning 0 matches across `<scope>`" is.
- **A Skip carries the reason and the unblock condition.** A platform-side row Skips with the
  verbatim Rule 6 wording whenever the workspace holds no export.
- The three totals must add to 11. If they do not, the block is wrong and the report does not save.

Category coverage is the second axis, listed after the hop table: one line per selected category
with `findings / passes / skips`, so a reader can see a category that ran and produced only Skips.

### Compliance exposure paragraph

Present only when a `Type: compliance` category ran.

```markdown
## Compliance exposure

**Inputs (from discovery):** call surface - {inbound / outbound / both} - jurisdictions of callers -
{answer} - sector - {answer} - recording - {on / off / unknown} - payments taken by voice - {answer}
- minors or health data expected - {answer}

{Regime paragraphs, one per regime the inputs put in play. Each names the regime, what it binds,
the observed pattern from this audit with its file:line, and carries its own "Facts verified:
<date> against <URL>" line copied from legal-landscape.md.}

{One sentence: this skill is not a law firm; the reader takes these patterns to counsel.}
```

Rules: never a verdict; never a fine or litigation prediction; never a scope decision the inputs do
not support. A regime whose facts are unverified in `legal-landscape.md` carries the same
`(unverified - confirm at <URL>)` hedge here.

If the discovery questions went unanswered, write one line: `Exposure could not be scoped - the
discovery questions were not answered. The regimes in legal-landscape.md are listed generically
below.` Then list them without attaching any of them to this agent.

### Skipped checks

```markdown
## Skipped checks

| What | Why | What would unblock it |
|---|---|---|
| Cat 19 spend caps (platform-side) | setting is platform-side and not represented in the workspace; not run | Export the account's spend limits and the assistant's per-call cost settings into the repo |
| Cat 23 recording consent | not applicable: no recording flag or API call in the workspace | Would run if recording is enabled platform-side - export the assistant config |
| Cat 09 retrieval injection | not in this scan's selection | Re-run with the `injection` group |
| Cat 05 voice-biometric rows | no biometric or voiceprint provider detected | Would run if a speaker-verification SDK or API were present |
```

Every Skip in the audit appears here. This table plus the coverage block is what makes the
report's limits legible.

### Needs review

Low-confidence findings, per `anti-hallucination.md`. Each carries what would raise it to Medium.
Never in the main findings list, never Critical.

### Suppressed

List every inline `snitch-voice-ignore` comment and every `.snitch-voice-ignore` entry that matched
something this run, with its rule and its reason, plus any entry that matched nothing as stale.

### Footer and metadata block

```markdown
---

Audited by Snitch: Voice, 27 categories. Get the latest version: https://snitchplugin.com/voice

## Audit metadata

| | |
|---|---|
| Date | {date_iso} |
| Target | {working_directory} |
| Stack detected | {platforms, providers, SDK versions from the inventory} |
| Call surface | {inbound / outbound / web-client / all} |
| Platform config in workspace | {files read, or "none - platform-side rows skipped"} |
| Tool inventory | {N tool definitions found, M matching the consequential-tool list} |
| Categories run | {IDs, and the preset that selected them} |
| Hops covered | {f} findings, {p} passes, {s} skips of 11 |
| Discovery inputs | {answered / not answered} |
| Scripts used | {voice-inventory.py, or "python3 unavailable"} |
| Aborted at | {"category N of M" if the user stopped the audit, otherwise omit this row} |
```

---

## Finding format

```
- **Impact:** Critical | High | Medium | Low
- **Rule:** <row name from the category's rule table> | <law / standard>
- **Hop:** H1..H11 <name>
- **Evidence:** `path/to/file.ts:47` + the exact lines, fenced; for sink-pattern categories, the
  trace: source (file:line) -> each hop (file:line) -> sink (file:line), and the controls checked
  and found absent
- **Risk:** who can do what, across which trust boundary, and what it costs
- **Fix:** the remediation with the corrected snippet or configuration
- **Confidence:** High | Medium | Low
- **Verify:** how to confirm the fix - a test call shape, a request the reader can send, a config
  value to read back - REQUIRED on Critical / High
- **Identity:** `ruleId` (`<class>.<specific>`) and `anchor` (`path::symbol`, no line numbers)
```

## A worked finding

This is the shape every finding takes. Nothing in it is optional on a Critical or High.

```markdown
##### Finding 4: Transfer tool dials whatever number the model passes

- **Impact:** Critical
- **Rule:** Cat 14 row "model-chosen or caller-spoken destination reaches the dial API with no allowlist"
- **Hop:** H7 Call control
- **Evidence:** `src/tools/transfer.ts:18-24`

  ```ts
  export async function transferCall({ callSid, destination }: TransferArgs) {
    return twilio.calls(callSid).update({
      twiml: `<Response><Dial>${destination}</Dial></Response>`,
    });
  }
  ```

  Trace: the model's tool call arguments arrive at `src/server/tools.ts:41` (`const args =
  JSON.parse(toolCall.function.arguments)`) and are passed unchanged to `transferCall` at
  `src/server/tools.ts:58`. The tool schema at `src/tools/schema.ts:30` declares `destination` as
  a free string. Controls checked: no allowlist read (grep for `allow|whitelist|permitted` over
  `src/tools/**` returned 0 matches in 7 files), no country-code check, no E.164 validation, no
  confirmation step outside the model. The system prompt at `prompts/agent.md:22` says "only
  transfer to our support line" - prose in the prompt is not a control (Rule 3).

- **Risk:** A caller who steers the model - by asking, by injected speech, or through a planted
  CRM note - gets the agent to dial a destination of their choosing on the business's account.
  Premium-rate and international destinations bill per minute; a forwarded line carries the
  brand's caller ID. This crosses the model-to-world boundary with the business's money.
- **Fix:** Resolve the destination server-side from a fixed table the model can only name a key
  into, and reject anything else.

  ```ts
  const TRANSFER_TARGETS = { support: process.env.SUPPORT_LINE!, billing: process.env.BILLING_LINE! } as const;
  export async function transferCall({ callSid, target }: { callSid: string; target: keyof typeof TRANSFER_TARGETS }) {
    const destination = TRANSFER_TARGETS[target];
    if (!destination) throw new Error("unknown transfer target");
    return twilio.calls(callSid).update({ twiml: `<Response><Dial>${destination}</Dial></Response>` });
  }
  ```

  Change the tool schema to `target: { enum: ["support", "billing"] }`. Also enable the
  provider's geographic dialing permissions so an unexpected destination fails at the carrier
  even if the code regresses.

- **Confidence:** High
- **Verify:** Place a test call and ask for a transfer to a number that is not in the table;
  confirm the tool returns "unknown transfer target" and no outbound leg appears in the
  provider's call log.
- **Identity:** `dial-control.unrestricted-destination` at `src/tools/transfer.ts::transferCall`
```

Notes on the shape:

- **Evidence** is the quoted sink plus, for a sink-pattern category, the trace and the controls
  checked. For a posture category it is the quoted configuration line or the search that
  established its absence. For a compliance category it is the quoted prompt, config, or flow
  the regime is judged against.
- **Risk** names the actor, the boundary crossed, and the cost. It never predicts a fine.
- **Fix** opens with the action and carries the corrected snippet. It never opens with a framing
  sentence about why voice security matters.
- **Verify** is required on Critical and High: a test call shape, a request, or a value to read
  back.
- **Any fix that changes what the agent can dial, transfer to, pay, send, or say** takes
  per-finding confirmation even in a batch apply.

---

## Export columns

### JSON, `voice_agent_audit.json`

```json
{
  "tool": "snitch-voice",
  "version": "{skill metadata.version}",
  "date": "{date_iso}",
  "target": "{path}",
  "stack": ["twilio", "openai-realtime"],
  "call_surface": "inbound|outbound|web-client|all",
  "platform_config_in_workspace": true,
  "categories_run": ["01", "05", "14"],
  "counts": {"critical": 0, "high": 0, "medium": 0, "low": 0, "pass": 0, "skip": 0},
  "coverage": [
    {"hop": "H1", "name": "Ingress", "categories": ["01", "02"],
     "outcome": "finding|pass|skip", "detail": "..."}
  ],
  "findings": [
    {"id": 4, "impact": "Critical", "rule": "...", "category": "14", "hop": "H7",
     "evidence_location": "src/tools/transfer.ts:18", "evidence_snippet": "...", "trace": "...",
     "risk": "...", "fix": "...", "fix_snippet": "...", "confidence": "High", "verify": "...",
     "rule_id": "dial-control.unrestricted-destination",
     "anchor": "src/tools/transfer.ts::transferCall", "changes_agent_behavior": true}
  ],
  "skipped": [{"what": "...", "why": "...", "unblock": "..."}],
  "needs_review": [],
  "suppressed": [{"rule": "...", "reason": "...", "source": "inline|ignore-file", "matched": true}],
  "exposure": {"inputs": {}, "regimes": [{"name": "...", "facts_verified": "...", "source": "..."}]}
}
```

The exposure block carries the `facts_verified` date and source URL per regime. An export that
drops them turns a hedged fact into a bare assertion.

### CSV, `voice_agent_audit.csv`

One row per finding. Header, in this order:

```
id,impact,rule,category_id,category_slug,hop,evidence_location,evidence_snippet,trace,risk,fix,confidence,verify,rule_id,anchor,changes_agent_behavior
```

`evidence_snippet`, `trace` and `fix` are quoted and newline-escaped. Passes and skips do not
appear in the CSV; they live in the coverage block and the skipped-checks table, which the JSON
export carries in full.
