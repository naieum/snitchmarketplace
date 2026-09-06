## CATEGORY 06: Verification before account disclosure or change
> Type: sink-pattern · Groups: actions · Hop: H2 Session authentication · Standards: CWE-287, CWE-200

Once the agent has decided who it might be talking to, something has to confirm it before the
agent reads back a balance, an appointment, a diagnosis, an address, or lets the caller change
any of them. That confirmation step is usually a few knowledge-based questions, and knowledge-based
questions are weak by construction: dates of birth, last four digits, addresses, and mothers'
maiden names are available from breach data, and a voice agent can be talked into helping — by
revealing the answer in the question, by accepting a partial match, by skipping a step when the
caller is impatient, by re-running verification without limit, or by letting the model decide the
caller "sounds right". This category traces what stands between a connected caller and the first
disclosure or change, and whether it is enforced outside the model.

**Call-path tracing required (anti-hallucination Rule 3).** Trace each disclosure sink (a tool
result spoken back, a prompt that carries account data, a change tool) back to the verification
that precedes it. A gate enforced in code — the tool refuses until a server-side verified state is
set by a server-side check — is a Pass. A gate that exists only as prompt prose ("verify the caller
first"), or whose verified state the model can set, is a finding.

**Boundary.** This category judges the verification flow and what it unlocks. Whether caller ID or
voice was accepted as identity before the flow began is Cat 05. Whether a tool checks the caller's
authorization for the specific record on every call is Cat 12; whether a consequential change
requires confirmation on top of verification is Cat 13. What the agent says about other people's
data by accident (raw tool output) is Cat 16.

### Detection
- Verification tools and functions: `verifyCaller`, `verify_identity`, `checkPin`, `validateDob`,
  `confirmAddress`, `sendOtp`, `verifyOtp`, `lookupAccount`, `authenticate`
- Verified-state variables: `verified`, `isVerified`, `authenticated`, `identity_confirmed`,
  `verification_level`, `step_up`
- Disclosure tools: `getBalance`, `getAppointments`, `getOrder`, `getRecords`, `lookupPatient`,
  `getAddress`, `readLastPayment`
- Change tools: `updateAddress`, `changeEmail`, `resetPassword`, `cancelAppointment`, `reschedule`,
  `updatePayment`, `closeAccount`
- Prompt text: "verify", "confirm their identity", "ask for date of birth", "last four"
- Platform flows: Vapi tool `parameters` (static server-side values) vs `function.arguments`;
  Retell `custom` tools; ElevenLabs server tools; Amazon Connect Lambda authentication blocks;
  LiveKit `@function_tool` verification helpers

### What to Search For
- Disclosure or change tools reachable while `verified` is false or unset — read the tool
  handler, not the prompt
- The verified state set by a tool the model calls, or by a client-supplied variable, rather than
  by a server-side comparison
- Verification questions whose expected answer is in the model's context (the prompt or a tool
  result carries the DOB, so the model can confirm anything the caller says, or can read the
  answer aloud in the question)
- Partial-match acceptance: `startsWith`, `includes`, fuzzy compare, "close enough" logic, or an
  LLM-judged match on the answer
- No attempt cap or lockout on verification; unlimited re-tries within a call or across calls
  from the same number
- Verification unlocking everything at once: no step-up for higher-risk actions (payment
  changes, address changes, password resets) beyond the same two questions
- OTP sent to a number or email the caller supplied on the call, rather than one on file
- OTP compared by the model rather than server-side; OTP with no expiry; OTP reuse
- Disclosure of a third party's data: the caller asks about someone else (a spouse, a patient, an
  employee) and the tool has no relationship or authorization check
- Verification skipped on outbound calls ("we called them, so it's them"), or skipped after a
  transfer, callback, or reconnect
- Verification state persisted across calls by phone number
- Sensitive data in the prompt before verification (the model "knows" the balance from turn one)

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| no-gate-before-disclosure | A disclosure or change tool executes with no server-enforced verified state on the traced path | tool handler + the trace to its guard | Critical |
| prompt-only-gate | The only verification instruction is prose in the system prompt or tool description | the prompt file:line + the unguarded handler | Critical (reported under no-gate-before-disclosure) |
| model-settable-verified | The verified state is set by a model-callable tool result or a client variable with no server-side check | the setter | Critical |
| answer-in-context | The expected verification answer is present in the model's context before or during the question | the prompt or tool result carrying it | High |
| lenient-match | A verification answer is accepted on partial, fuzzy, or model-judged match | the compare | High |
| unbounded-attempts | No attempt cap or lockout on verification | the loop + the search for a counter | High |
| no-step-up | High-risk changes require no factor beyond the basic verification | the change tool + the gate it shares | High |
| otp-to-caller-supplied | An OTP is sent to a destination the caller supplied on the call | the send call + the destination source | High |
| third-party-disclosure | Data about someone other than the verified caller is reachable with no relationship check | the tool + the absent check | High |
| gate-lost-on-reconnect | Verification is skipped after transfer, callback, reconnect, or on outbound pickup | the flow | Medium |
| verified-persisted-by-number | Verified state survives across calls keyed by phone number | the storage | Medium |

### Actually Vulnerable

#### Critical
- `getBalance` handler that reads `args.account_id` and returns the balance with no check of a
  server-side verified flag; the prompt says "always verify first"
- `setVerified` exposed as a tool the model calls after "the caller confirmed their DOB"
- `variableValues.verified = true` accepted from the client

#### High
- The customer record, DOB included, injected into the system prompt at call start
- `if (answer.includes(dob.slice(-4)))`
- No `attempts` counter; a `while (!verified)` loop the caller can drive indefinitely
- `updatePaymentMethod` behind the same two questions as `getStoreHours`
- `sendOtp({ to: args.phone })` where `args.phone` came from the caller
- `getAppointments({ patient_name })` with no relationship check to the verified caller

#### Medium
- Verification not repeated after a warm transfer or callback
- `verifiedNumbers` cache keyed by `From`

### NOT Vulnerable
- Verification performed server-side (a comparison the model never sees the answer to), the
  result stored server-side, and every disclosure or change handler checking that state before
  acting — quote the check in each handler, or the shared guard and its coverage
- The expected answer withheld from the model: the tool takes the caller's answer and returns
  only `match: true/false`
- Exact-match with normalization only (whitespace, formatting), an attempt cap with lockout,
  and a step-up factor (OTP to the number on file, in-app approval, callback) before high-risk
  changes — quote each
- OTP sent only to a destination on file, verified server-side, single-use, time-limited
- Third-party requests routed to a relationship check or refused
- A pure information line with no account data — Skip, `not applicable`, with the tool list

### Context Check
1. What can the agent disclose or change? List the tools.
2. For each, what must be true before the handler acts, and where is that enforced?
3. Who sets the verified state, and can the model or client set it?
4. Does the model ever hold the expected answer?
5. How is a match judged, and how many tries are allowed?
6. Is there a higher bar for higher-risk actions?
7. What happens on outbound, transfer, and reconnect?

### Evidence Chain
- Each disclosure or change sink file:line
- The trace from the sink back to its guard, hop by hop
- The guard's enforcement point (server code) or the search that established prose-only
- The setter of the verified state and its callers
- The comparison logic, the attempt counter, the step-up factor, or the searches that
  established their absence

### Confidence Scoring
- **High**: a disclosure or change handler traced to no server-side gate, or a model-settable
  gate, or a lenient compare quoted
- **Medium**: a guard may live in a shared middleware or platform-side flow not fully visible,
  or the handler's callers are partially traced
- **Low**: the disclosure path could not be tied to a verification flow — tag `needs human
  verification`

### Severity
Critical is disclosure or change with no enforced gate, or a gate the model controls. High is a
gate that exists but leaks its answer, accepts approximations, never locks, or does not scale
with risk. Medium is a gate that lapses across call boundaries. Low is not used.

### Files to Check
- `**/verify*`, `**/auth*`, `**/identity*`, `**/otp*`, `**/pin*`
- `**/tools/**`, `**/functions/**`, `**/handlers/**`
- `**/prompts/**`, `**/*system*`, `**/*assistant*.json`, `**/*agent*.json`
- `**/customer*`, `**/account*`, `**/patient*`, `**/order*`

### Reference
- CWE-287: Improper Authentication
- CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
- CWE-307: Improper Restriction of Excessive Authentication Attempts
- CWE-640: Weak Password Recovery Mechanism (knowledge-based answers)
- OWASP Agentic Top 10 (2025): ASI03 Identity and Privilege Abuse, ASI09 Human-Agent Trust Exploitation
