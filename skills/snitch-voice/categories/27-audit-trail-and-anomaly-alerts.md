## CATEGORY 27: Per-call audit trail and anomaly alerting
> Type: posture · Groups: abuse, privacy · Hop: H10 Limits and operations · Standards: CWE-778

Every other category in this skill describes something a caller can make the agent do. This one
asks whether anyone would know. A voice agent that transfers a call, fires a tool, dials out, or
reads back an account does so in seconds, hundreds of times an hour, with no human on the line.
Without a per-call trail — who called, what the model was told, which tools fired with which
arguments and outcomes, where the call went, what it cost — an incident is reconstructed from a
bill. Without alerts on the shapes that precede a drained account — a spend spike, a new
destination country, a burst of calls from one number, a tool firing far above its baseline — the
bill is the alert. This category reads what the code records per call and what watches the
totals.

**Boundary.** This category judges whether actions are recorded and anomalies noticed. The caps
that would have stopped the anomaly are Cat 17, 18, and 19; what the agent does when a provider
fails is Cat 20; whether the trail itself leaks transcripts or personal data is Cat 21 and 22 —
the trail this category asks for is ids, names, outcomes, and amounts, never conversation text.
Tamper-evidence and retention of application logs off the call path are snitch-security's
business — hand off by calling the Skill tool with "snitch-security".

### Detection
- Logging and audit sinks: `logger.*`, `console.*`, `logging.*`, structured audit writers
  (`audit.log(`, `auditTrail`, `events.insert(`, `call_events` tables), OpenTelemetry spans
- Call-lifecycle handlers: `call-started`, `status-update`, `end-of-call-report`, `call_ended`,
  `call_analyzed`, `StatusCallback`, `RecordingStatusCallback`, `post_call`
- Tool dispatch code: the loop that receives `tool-calls` / `function_call` / `tool_use` and
  invokes handlers
- Platform ended-reason fields: `endedReason`, `disconnection_reason`, `ended_reason`,
  `call_status`, `SipResponseCode`
- Cost fields: `cost`, `costBreakdown`, `call_cost`, `usage`, `duration_ms`, `Price`,
  `PriceUnit`
- Alerting and threshold wiring: usage triggers, budget alerts, `alert`, `pagerduty`,
  `opsgenie`, `slack` webhooks on thresholds, metrics counters (`prom-client`, `statsd`,
  `datadog`), platform spend-alert settings exported in the workspace

### What to Search For
- No per-call record at all: the lifecycle handlers exist but write nothing, or only the
  platform dashboard holds history and nothing in the workspace exports or mirrors it
- A call record that omits any of: call id, caller number (masked is fine), start and end,
  ended reason, tool calls with name and outcome, transfer or dial destinations, cost
- Tool dispatch that invokes handlers without recording name, argument summary, outcome, and
  latency — so a transfer to an unexpected number leaves no line
- Ended reasons and provider error codes received and discarded
- Audit records written to the same mutable store the app freely updates, with no append-only
  table, no write-once bucket, and no external log shipping — an incident can be edited away
- No counters or metrics on: calls per minute, calls per source number, tool calls per call,
  outbound dials per destination country, cost per call and per hour
- No alert path: no usage trigger on the carrier account exported, no budget alert on the model
  provider exported, no threshold in code that pages anyone
- Alerts that exist but fire to a channel nobody reads (a webhook to a retired integration, a
  log line with the word `ALERT`)
- Spend or volume checks that run only in a nightly job, on an agent that can drain an account
  in an hour

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| no-call-trail | No per-call record is written anywhere in the workspace and no platform export mirrors one | the lifecycle handlers file:line + the search for writers | High |
| trail-missing-actions | The call record omits tool calls, transfers, or dial destinations | the record construction file:line | High |
| trail-missing-cost | The call record omits cost or duration where the platform supplies it | the record construction file:line + the field the platform sends | Medium |
| ended-reason-dropped | Provider ended reasons and error codes are received and not stored or counted | the handler file:line | Medium |
| mutable-trail | Audit records live only in a store the app can update or delete, with no append-only or shipped copy | the store and the write path file:line | Medium |
| no-anomaly-signal | No metric or counter exists for volume, per-source rate, tool-call rate, destination country, or spend | the search across metrics and counters | High on agents with dial, transfer, or payment tools; Medium elsewhere |
| no-alert-path | Thresholds exist nowhere: no usage trigger or budget alert exported, no paging in code | the search + the Rule 6 skip line for platform-side alerts | High on agents with dial, transfer, or payment tools; Medium elsewhere |
| alert-dead-end | An alert fires to a destination that is unread, retired, or is only a log line | the alert wiring file:line | Medium |
| slow-detection | Spend or volume checks run on a schedule far slower than the rate at which the agent can spend | the schedule file:line | Medium |

### Actually Vulnerable

#### Critical
- Not used in this category. A missing trail does not by itself let a caller do anything; it
  lets them do it unseen.

#### High
- An `end-of-call-report` handler that returns 200 and writes nothing; tool dispatch with no
  log line per invocation; a transfer tool whose destination is never recorded
- An agent with dial, transfer, or payment tools and no counter, threshold, or alert anywhere
  in the workspace, with no platform-side alert export

#### Medium
- Cost and ended reason discarded; audit rows in the main application table with update
  rights; a `#alerts` webhook pointing at a channel the README says was retired; a nightly
  spend job as the only watchdog

### NOT Vulnerable
- A per-call record with id, masked caller, timestamps, ended reason, each tool call's name and
  outcome, destinations, and cost, written on the lifecycle handler — quote the construction
- Tool dispatch wrapped in a logger that records name, argument summary (ids, not values),
  outcome, and latency — quote the wrapper
- Records shipped to an append-only store or external log system — quote the shipping
- Counters on calls per minute, per-source rate, tool-call rate, and cost, with thresholds that
  page or block — quote the counter and the threshold action
- Carrier usage triggers or provider budget alerts exported in the workspace with their
  thresholds — Pass for the alert-path row with the export quoted
- A read-only agent with no tools, no dial, and no payment: the anomaly rows still run but the
  severities drop a tier, and the finding says why

### Context Check
1. On a call that ended one minute ago, what could be reconstructed from the workspace's own
   records: who, what was said (never), what fired, where it went, what it cost?
2. Is the record written on every lifecycle path, including errors and early hang-ups?
3. Could someone with application write access alter or delete the record?
4. What would rise first if an attacker found a dial path: a counter, an alert, or the invoice?
5. Where do alerts go, and does the destination still exist?
6. How fast can this agent spend, and how fast would the watchdog notice?

### Evidence Chain
- The lifecycle handler file:line and what it writes, or the search across writers with scope
- The tool dispatch file:line and its logging, or its absence
- The record schema or construction, listing which fields are present and absent
- The store the records land in and its mutability
- Each metric, counter, threshold, and alert file:line, or the search that found none
- Platform-side alert exports read, or the Rule 6 skip line

### Confidence Scoring
- **High**: the lifecycle handlers, dispatch loop, and alert wiring are in the workspace and
  read end to end
- **Medium**: history or alerts may live in a platform dashboard or an external monitoring
  system with no export in the workspace
- **Low**: the dispatch loop or lifecycle path could not be located (framework-managed) — tag
  `needs human verification`

### Severity
High is no trail, a trail that omits the actions that cost money, or no anomaly signal and no
alert path on an agent that can dial, transfer, or pay. Medium is a trail missing cost or ended
reason, a mutable-only trail, a dead-end alert, a slow watchdog, or the anomaly rows on an agent
with no consequential tools. Low is not used. Critical is not used.

### Files to Check
- `**/webhooks/**`, `**/events/**`, `**/call-*`, `**/end-of-call*`, `**/post-call*`,
  `**/status*`
- `**/tools/**`, `**/dispatch*`, `**/executor*`
- `**/audit*`, `**/logger*`, `**/logging*`, `**/metrics*`, `**/telemetry*`, `**/alert*`,
  `**/monitor*`
- `**/migrations/**`, `**/schema*` (call and event tables)
- `**/cron*`, `**/jobs/**`, `**/schedule*`
- Exported platform settings: `**/usage-trigger*`, `**/budget*`, `**/*alert*.{json,yaml}`

### Reference
- CWE-778: Insufficient Logging
- CWE-223: Omission of Security-relevant Information
- OWASP LLM Top 10 (2025): LLM10 Unbounded Consumption (detection side)
- MITRE ATLAS: AML.T0034 Cost Harvesting
- Per-platform ended-reason fields, cost fields and usage-trigger features: `references/stacks/<platform>.md`
