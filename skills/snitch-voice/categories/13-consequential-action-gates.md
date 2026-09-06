## CATEGORY 13: Confirmation, limits and idempotency on consequential tools
> Type: sink-pattern · Groups: quick, actions · Hop: H6 Tool dispatch · Standards: CWE-862, CWE-841; OWASP LLM06

Some tools change the world: move money, issue a refund, change the address a card ships to,
cancel a policy, book or cancel an appointment, reset a password, place an order. A voice agent
runs those on the model's say-so, and the model's say-so is a function of what it heard. Three
failure shapes recur. The agent "confirms" by hearing "yes" — a word the transcriber produces from
noise, from an earlier answer, or from a caller who was asked a different question than the one the
tool executes. The agent executes an amount or target the caller named with no server-side ceiling
or eligibility check, so the model's arithmetic is the control. And the agent retries or replays a
call, so one confirmed refund becomes three. This category traces every consequential tool from
the argument the model supplies to the backend write and asks what, outside the model, gates it.

**Call-path tracing required (anti-hallucination Rule 3).** For each consequential tool, trace the
arguments (amount, target, date, identifier) from the model's tool-call payload to the write, and
trace the confirmation — whatever the code treats as the caller's agreement — from its source to
the point where it unlocks the write. A confirmation is a control only when it is bound to the
exact action and arguments the backend executes, is checked by code rather than by the model, and
cannot be satisfied by a transcript token alone. A server-side cap or eligibility check is a
control when it runs at the write. Prose in the prompt ("always confirm before refunding") is never
a control.

**Boundary.** This category judges the gate between the model's decision and the write. Whether
the request came from the platform and whose record it touches is Cat 12. Whether the caller was
verified at all is Cat 06. The dial, transfer, and DTMF sinks are Cat 14, and message sends are Cat
15 — those tools are consequential too, but their destination logic is judged there and only their
confirmation gate is judged here. The spend ceiling that bounds a runaway is Cat 19. A payment
integration's own key handling is snitch-security's Cat 13 — hand off by calling the Skill tool
with "snitch-security".

### Detection
- Tool definitions whose name or description contains: refund, charge, pay, payment, transfer,
  send money, withdraw, deposit, credit, cancel, close, delete, update address, change email,
  change phone, reset password, reschedule, book, order, purchase, renew, upgrade, downgrade,
  prescribe, discharge, approve, escalate to human with account changes
- Backend calls those handlers reach: payment SDK charge/refund/payout calls, banking or ledger
  APIs, CRM update calls, scheduling APIs, EHR write APIs, `UPDATE` / `DELETE` statements,
  `db.*.update` / `.delete` / `.create` on customer-facing records
- Confirmation code: `confirmed`, `confirmation`, `userConfirmed`, `awaitingConfirmation`,
  `pendingAction`, state machines with a confirm step, tools named `confirm*`, prompt text that
  asks the model to confirm, DTMF confirmation prompts (`<Gather>`), OTP/SMS confirmation sends
- Idempotency: `idempotencyKey`, `Idempotency-Key`, `requestId`, `toolCallId` reuse checks,
  deduplication by call ID
- Retry logic around tool execution: `retry`, `p-retry`, `backoff`, platform tool retries,
  `maxRetries`

### What to Search For
- A write executed directly from the tool handler with no intervening confirmation state:
  `case "issueRefund": return payments.refund(args.chargeId, args.amount)`
- Confirmation represented by a boolean the *model* sets (`args.confirmed: true`, a tool
  parameter "userConfirmed") — the model can set it without asking
- Confirmation derived from a transcript match (`/yes|yeah|correct/i.test(transcript)`) with no
  binding to which question was asked or which arguments are pending
- No read-back: the code never plays the exact amount, target, and date back before the write
  (a read-back is not a control on its own, but its absence removes the caller's chance to catch
  a wrong transcription)
- Pending action stored, then executed on the *next* tool call regardless of what that call
  carries — the shape where the caller hears a benign confirmation and a different pending action
  fires (also reachable from Cat 09 injection)
- Amount, quantity, or date arguments passed to the write with no server-side maximum, minimum,
  or eligibility rule (refund ≤ original charge, ≤ N per day, order total ≤ limit, appointment
  within business hours)
- Target arguments (destination account, new address, new email) applied without a cooling-off,
  a second factor, or a notification to the previous contact channel
- No idempotency key on payment or ledger calls, or a key derived from something the model
  controls; retries that re-issue the write
- One tool that both reads and writes (`manageAccount` with an `action` argument) so the read
  tool's permissions cover the write
- Batch or loop constructs where one confirmation unlocks unbounded writes ("cancel all my
  appointments")

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| unconfirmed-write | A consequential write executes from the tool handler with no confirmation state checked by code on the traced path | trace + write file:line | Critical for money and identity-contact changes; High otherwise |
| model-asserted-confirmation | The confirmation is a value the model supplies in the tool arguments, or a bare transcript token, not bound to the pending action | the argument or match file:line | Critical / High as above |
| unbound-pending-action | A stored pending action executes without re-checking that the confirmation named its exact action and arguments | store file:line + execute file:line | High |
| no-server-cap | Amount, quantity, date, or eligibility is bounded only by the model's arguments | write file:line + the search for a cap | High |
| no-second-channel | A contact-detail or destination-account change applies with no second factor, notification, or delay | write file:line | High |
| non-idempotent-write | A money or ledger write has no idempotency key, or retries re-issue it | write file:line + retry file:line | High |
| read-write-merged | A single tool exposes both read and write behind an `action` argument | schema file:line | Medium |
| no-read-back | The exact arguments are never played back to the caller before the write | handler file:line | Medium (reported only alongside a confirmation finding) |

### Actually Vulnerable

#### Critical
- Refund, payment, transfer, payout, or credit issued straight from the tool handler
- Shipping address, email, phone, or beneficiary changed on `args.confirmed === true`
- Confirmation by transcript regex with the pending amount or target never re-checked

#### High
- Appointment, order, subscription, or policy cancelled or changed with no code-level
  confirmation state
- A pending action that fires on the next "yes" whatever it was in answer to
- Refund amount not capped at the original charge; order quantity uncapped; date unvalidated
- No idempotency key on a charge or refund; retry wrapper around a ledger call

#### Medium
- `manageBooking({ action: "cancel" | "view" })` style merged tools
- Read-back absent where a confirmation gate does exist in code

### NOT Vulnerable
- A two-step server-side state machine: the first tool call records a pending action with its
  exact arguments and a nonce; the write tool requires the nonce and re-validates the arguments
  against the stored ones — Pass quoting both steps
- Confirmation collected out of band (DTMF PIN, SMS OTP to the number on file, push approval)
  and verified by code before the write
- Server-side caps at the write: refund ≤ charge, daily limits, eligibility rules — Pass quoting
  the check at the sink
- Idempotency keys derived from the tool call ID or a server nonce, with the payment SDK's
  idempotency mechanism used
- Consequential tools absent from the inventory (informational agent) — Skip, `not applicable`,
  with the tool list
- Human handoff before any write: the tool only creates a ticket for a person to action — Pass,
  noting that the ticket content is model-authored (Cat 16 for what it contains)

### Context Check
1. Which tools change state? Build the list from the handlers' backend calls, not from names.
2. For each: what does the code check between the model's request and the write? Read the
   handler top to bottom.
3. Where does the confirmation value come from, and is it bound to these arguments?
4. What bounds the arguments at the write, independent of the model?
5. What happens on retry, timeout, or a duplicate tool call with the same arguments?
6. Is there a second channel for changes to how the business reaches or pays the caller?
7. Does one confirmation unlock one write, or many?

### Evidence Chain
- The tool handler file:line and the backend write file:line
- The traced path of each consequential argument from the tool-call payload to the write
- The traced path of the confirmation from its source (argument, transcript, DTMF, OTP, state
  store) to the point it unlocks the write, and what binds it to the arguments
- Controls checked at the write and found absent: caps, eligibility, idempotency, second channel
- Retry and duplicate handling around the write

### Confidence Scoring
- **High**: complete trace from the tool payload to the write with no code-level gate, or a
  gate fully quoted for the Pass
- **Medium**: the write passes through a service layer whose checks were not fully read, or a
  cap may live in the payment provider's dashboard without an export
- **Low**: the handler's dispatch to the write could not be resolved → tag `needs human
  verification`

### Severity
Critical is money or the caller's contact/payout details changed on the model's word alone.
High is any other state change without a code-level gate, an unbound pending action, a missing
cap, a missing second channel, or a non-idempotent money write. Medium is structural weakness
around an existing gate. Low is not used.

### Files to Check
- `**/tools/**`, `**/functions/**`, `**/handlers/**`, `**/actions/**`
- `**/payments/**`, `**/billing/**`, `**/refund*`, `**/orders/**`, `**/booking*`, `**/appointments/**`
- `**/session*`, `**/state*`, `**/pending*`, `**/confirm*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/pathway*` (tool schemas and any `confirmed` parameters)

### Reference
- CWE-862: Missing Authorization
- CWE-841: Improper Enforcement of Behavioral Workflow
- CWE-799: Improper Control of Interaction Frequency
- OWASP LLM Top 10 (2025): LLM06 Excessive Agency
- OWASP Agentic Top 10 (2025): ASI02 Tool Misuse and Exploitation, ASI09 Human-Agent Trust
  Exploitation
- Platform confirmation and human-in-the-loop primitives where they exist:
  `references/stacks/<platform>.md`
