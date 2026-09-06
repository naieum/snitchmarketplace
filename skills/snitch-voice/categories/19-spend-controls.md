## CATEGORY 19: Model, speech and telephony spend ceilings
> Type: posture · Groups: quick, abuse · Hop: H10 Limits and operations · Standards: CWE-770; OWASP LLM10

When every other limit fails — the caller who found the loop, the script that found the widget, the
transfer that reached a premium number — the last thing standing between the business and the
invoice is a ceiling on spend. A voice agent runs on three or four metered accounts at once: the
carrier, the transcription provider, the model, the synthesis provider, and often the agent
platform on top. Each has a cap, an alert, or both, and each ships with them off. This category
reads what the workspace says about spend: the per-call cost caps and token limits the code sets,
the provider limits and usage triggers exported into the repo, and the alerting that would make a
bad day short. Most of the real ceilings live in dashboards; this category leans on Rule 6 Skips
and says exactly which export would turn each one into a Pass.

**Boundary.** This category judges the money ceiling. Session length is Cat 17; session count and
rate are Cat 18; the destinations that cost the most are Cat 14; the alert that fires on an anomaly
is shared with Cat 27 (Cat 27 owns the audit trail and anomaly rules generally; this category owns
the spend alert specifically). Model API keys in general are snitch-security's Cat 03 and its Cat 15
owns `max_tokens` on non-voice chat endpoints — hand off by calling the Skill tool with
"snitch-security" for anything off the call path.

### Detection
- Model call parameters on the voice path: `max_tokens`, `max_output_tokens`,
  `max_response_output_tokens` (OpenAI Realtime), `maxTokens` (Vapi model config),
  `generation_config.max_output_tokens` (Gemini), LiveKit / Pipecat LLM service options, context
  trimming or summarization (`context_window_compression`, sliding-window history, `maxMessages`)
- Synthesis limits: output length caps before TTS, `max_characters`, chunking with a ceiling
- Platform cost settings in exports: Vapi per-call cost caps and analytics budgets, Retell
  billing and concurrency settings, Bland budget settings, ElevenLabs usage limits, per-agent
  spend `(unverified — confirm in the platform docs)` for each
- Carrier controls in IaC or exports: Twilio Usage Triggers (`usage.triggers.create`,
  `TriggerValue`, `UsageCategory`) and geographic permissions; Vonage / Telnyx / Plivo /
  SignalWire balance alerts and spend limits; AWS Budgets and Cost Anomaly Detection for Connect
  / Transcribe / Polly / Bedrock
- Model-provider limits referenced in docs or IaC: monthly hard limits, project budgets,
  per-key spend caps; keys created with no cap
- Model tier choices: the most expensive model on every turn versus a cheaper gate model for
  intent, verification, or refusal
- Alerting: billing webhooks, budget alarms, PagerDuty / Slack hooks on spend

### What to Search For
- No `max_tokens` (or platform equivalent) on the voice model call, so one turn can emit the
  model's maximum
- No context trimming: the full history re-sent on every turn with no cap on messages or tokens
- Tool results dumped whole into context (cite Cat 16) with no size cap
- No length cap on text sent to synthesis; a model that can produce a paragraph is synthesized
  in full
- Retries on model or provider errors that resend the whole context without a retry budget
- No per-call cost accounting in the app where the platform offers cost fields (Vapi
  `cost`/`costBreakdown` on end-of-call reports, Retell `call_cost`, Bland `price`) and no
  reaction to a high-cost call
- No usage trigger, budget, or spend alert anywhere in IaC, exports, or docs
- A single API key per provider used for the voice agent and everything else, with no per-key
  cap — a runaway on the phone line drains the whole account
- The largest model tier used for turns that a cheap model could gate (advisory)
- Post-call processing (summaries, embeddings, analytics) run on every call with no budget

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| no-output-token-cap | The voice model call sets no output-token cap | call file:line + the search | Medium |
| no-context-trim | Conversation history grows unbounded across the session and is resent each turn | session code file:line | Medium |
| no-tts-length-cap | Text reaches synthesis with no per-turn length ceiling and no per-session synthesized-character budget | handler file:line | Medium; High when the caller can choose the synthesized text (Cat 07 `verbatim-echo` present), because synthesis spend is then caller-driven |
| no-retry-budget | Provider-error retries resend the context with no attempt or cost budget | retry file:line | Medium |
| no-provider-ceiling | No spend limit, usage trigger, or budget for any metered provider is represented in IaC, exports, or docs | the search across IaC and exports | Medium, capped by Rule 6 — reported as Skip when nothing in the workspace speaks to it, Medium when IaC or docs show the accounts and no cap |
| shared-uncapped-key | The voice path uses the same provider key as unrelated systems and no per-key cap is documented | key usage file:line | Medium |
| no-spend-alert | No alerting on spend anywhere in the workspace | the search | Medium (Skip when platform-side only) |
| no-cost-accounting | Platform cost fields are received and ignored | end-of-call handler file:line | Low (advisory) |
| expensive-tier-everywhere | The most expensive model tier is used for every turn including gates | config file:line | Low (advisory) |

### Actually Vulnerable

#### Critical
- Not used; spend exposure is a ceiling on other findings, not a path in itself

#### High
- Not used alone. When Cat 14 or Cat 18 reports a Critical or High and this category finds no
  ceiling anywhere, cite the combination in the report's executive snapshot; the ceiling
  finding stays Medium

#### Medium
- No output-token cap on the voice model call
- Unbounded history re-sent each turn
- Retries with no budget
- IaC or docs list the metered accounts and show no usage trigger, budget, or spend limit
- A shared provider key with no per-key cap documented
- No spend alerting in a workspace that carries IaC for the rest of the stack

### NOT Vulnerable
- Output-token cap set on the voice model call and history trimmed or summarized past a
  ceiling — Pass quoting both
- Usage triggers, budgets, or spend limits present in IaC or exports for each metered provider —
  Pass per provider quoting the resource
- A per-key or per-project cap documented in the workspace for the voice path's keys
- A spend alert wired to a channel someone reads — Pass quoting the alarm and its target
- End-of-call cost fields recorded and thresholded
- Platform-side caps with no export in the workspace — Skip with the Rule 6 wording, naming the
  export (account spend settings, usage triggers, provider budget) that would unblock it. Never
  report a missing dashboard cap as a finding.

### Context Check
1. Which metered accounts does the voice path touch? Build the list from the SDKs and keys
   found in STEP 0.
2. For each: is any cap, trigger, or budget represented anywhere in the workspace — IaC,
   exports, docs, scripts? If not, that provider's row is a Skip.
3. What caps the model's output and the context size in code?
4. What caps synthesis input?
5. What do retries cost?
6. Are the voice path's keys shared with other systems?
7. Does anything alert on spend, and where does the alert go?

### Evidence Chain
- The model call file:line and its parameters
- The session or context-management code and its trimming, or the search for it
- The synthesis call and any length cap
- The retry configuration
- IaC, export, or doc file:line for each provider ceiling found, or the Rule 6 skip line per
  provider
- The alerting resource and its destination, or the search

### Confidence Scoring
- **High**: the model call is in the workspace and verifiably uncapped, or the ceiling is fully
  quoted from IaC or an export (Pass)
- **Medium**: caps may exist in a dashboard without an export, or a wrapper not fully read may
  trim context
- **Low**: the model or synthesis call could not be located → tag `needs human verification`

### Severity
Medium is the ceiling for this category on its own: a missing cap costs nothing until another
category's finding is exploited. The report's snapshot pairs a missing ceiling with the Cat 14 or
Cat 18 finding it fails to bound. Low is the advisory rows. Critical and High are not used here.

### Files to Check
- `**/agent*`, `**/bot*`, `**/session*`, `**/llm*`, `**/realtime*`, `**/pipeline*` (model calls
  and context management)
- `**/tts*`, `**/synthesis*`, `**/speak*`
- `**/*assistant*.json`, `**/*agent*.json` (model config and platform cost settings)
- `**/terraform/**`, `**/pulumi/**`, `**/cdk/**`, `**/infra/**`, `**/*.tf`, `**/serverless.yml`
  (usage triggers, budgets, alarms)
- `**/scripts/**`, `docs/**`, `README*`, `RUNBOOK*` (documented caps and alert channels)
- `.env*` (which keys the voice path uses)

### Reference
- CWE-770: Allocation of Resources Without Limits or Throttling
- OWASP LLM Top 10 (2025): LLM10 Unbounded Consumption
- MITRE ATLAS: AML.T0034 Cost Harvesting
- Per-platform cost fields, spend settings and carrier usage triggers:
  `references/stacks/<platform>.md`
