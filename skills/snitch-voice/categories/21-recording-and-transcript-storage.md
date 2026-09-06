## CATEGORY 21: Where recordings, transcripts and logs land and who can reach them
> Type: posture · Groups: quick, privacy · Hop: H9 Storage and telemetry · Standards: CWE-532, CWE-284

Every call a voice agent handles becomes at least three artifacts: an audio recording, a text
transcript, and a log line — often five, once the platform dashboard, a post-call webhook, and
an observability tool each keep a copy. Each copy has its own access control, its own retention,
and its own chance of being reachable by URL. A recording bucket with public reads, a transcript
forwarded to an automation tool over an unsigned URL, a `console.log` of the full conversation
landing in a log aggregator with a two-year retention, a platform default that keeps everything
forever: none of those is a breach yet, and every one of them is where the breach will be read
from. This category inventories where each artifact goes and asks who can reach it, for how
long, and whether anyone decided.

**Boundary.** This category judges where call artifacts land and who can reach them. What is
*in* them — card numbers, health detail, voiceprints — and whether it was redacted before
landing is Cat 22. Whether the caller consented to the recording is Cat 23. Which regime attaches
to the stored data is Cat 25. Whether the post-call webhook that carries the transcript verified
its sender is Cat 01; whether the receiving automation is authenticated is judged here as a
destination. A storage bucket policy off the call path is snitch-security's business — hand off
by calling the Skill tool with "snitch-security".

### Detection
- Recording switches: Twilio `record`, `<Record>`, `RecordingStatusCallback`,
  `recordingChannels`; Vonage NCCO `record`, `eventUrl`; Telnyx `record_start`; Vapi
  `recordingEnabled`, `artifactPlan.recordingEnabled`, `transcriptPlan`; Retell
  `data_storage_setting`, `data_storage_retention_days`, `opt_out_sensitive_data_storage`;
  Bland `record`; ElevenLabs conversation retention settings; LiveKit egress
  (`RoomCompositeEgress`, `TrackEgress`, `EgressClient`); Pipecat `AudioBufferProcessor`,
  transcript processors; Amazon Connect `RecordingBehavior`, Contact Lens
- Storage sinks: `s3.putObject`, `@aws-sdk/client-s3`, `boto3`, `gcs`, `@google-cloud/storage`,
  `BlobServiceClient`, `supabase.storage`, `fs.writeFile`, `open(..., 'wb')`
- Recording and transcript URL fields: `RecordingUrl`, `recording_url`, `recordingUrl`,
  `stereoRecordingUrl`, `transcript`, `public_log_url`, `artifact.recording`
- Log calls that mention transcript, message, utterance, or turn: `console.log`, `logger.*`,
  `print(`, `logging.*`
- Post-call forwards: `fetch(` / `axios.post(` / `requests.post(` to automation or analytics
  hosts, webhook URLs in config named `n8n`, `zapier`, `make`, `hooks.`, `webhook.site`
- Observability SDKs receiving prompts or transcripts: `langfuse`, `langsmith`, `helicone`,
  `sentry` breadcrumbs, `datadog`, `posthog` capture of conversation text

### What to Search For
- Recording enabled with no retention, deletion, or lifecycle rule anywhere in the workspace;
  platform retention keys unset (Retell `data_storage_retention_days` absent means no auto-delete
  `(unverified — confirm in the platform docs)`; ElevenLabs default retention measured in years
  `(unverified — confirm in the platform docs)`)
- Buckets or containers created or referenced with public read (`ACL: 'public-read'`,
  `PublicAccessBlock` disabled, `allUsers` reader, `Blob public access` on) and recordings written
  to them
- Recording URLs served to a browser, a CRM, or a message with no signed URL, no expiry, and no
  auth on the fetch path — including carrier recording URLs that are reachable with the account
  credentials only if the account has recording auth enabled `(unverified — confirm in the
  platform docs)`
- Full transcripts in application logs, request logs, or error reports
- Post-call webhooks forwarding the full transcript, recording URL, or caller number to a
  third-party automation over `http://`, or to a webhook URL that carries no secret and whose
  receiver is not in the workspace
- Transcripts and prompts sent to observability tools with no redaction configured and no
  retention setting in the workspace
- Dashboard-only storage on a hosted platform, with the app also copying artifacts elsewhere —
  two owners, two retentions
- Access to stored artifacts not scoped: any authenticated user of the admin app can list all
  recordings; the recordings route has no tenant or role check
- Encryption at rest and in transit for self-managed storage: server-side encryption not set on
  the bucket, recordings written to local disk on a shared host

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| public-artifact-store | Recordings or transcripts are written to a store with public reads | the write file:line + the bucket policy or ACL file:line | Critical |
| unauthenticated-artifact-url | A recording or transcript URL is served or forwarded with no signature, expiry, or auth on the fetch path | the URL emission file:line + the absent signing | High |
| transcript-in-logs | Full transcripts, turns, or utterances are written to application logs | the log call file:line | High |
| unsigned-forward | A post-call forward carries transcript, recording URL, or caller number to a URL with no secret, over plaintext, or to a receiver not in the workspace | the forward file:line + the URL | High over plaintext or with no secret; Medium when secret present but receiver unknown |
| no-retention-decision | Recording is on and no retention, deletion, or lifecycle rule exists in code, config, or export | the recording switch file:line + the search for retention | Medium |
| unscoped-artifact-access | The route or query that reads artifacts has no tenant, role, or ownership check | the route file:line | High |
| observability-unredacted | Prompts or transcripts flow to an observability tool with no redaction and no retention setting in the workspace | the SDK init file:line + the search | Medium |
| no-encryption-at-rest | Self-managed artifact storage sets no server-side encryption, or writes to local disk | the storage config file:line | Medium |

### Actually Vulnerable

#### Critical
- `ACL: 'public-read'` (or equivalent) on the bucket that receives recordings, or a bucket
  policy granting anonymous `GetObject` to the recordings prefix

#### High
- `RecordingUrl` embedded in a CRM note, an email, an SMS, or a browser response with no
  signed-URL step
- `console.log(transcript)` / `logger.info({ messages })` in the turn loop or post-call handler
- A post-call `fetch('http://…', { body: JSON.stringify({ transcript, recordingUrl, from }) })`
- An admin `/recordings` route that lists every call for any signed-in user

#### Medium
- Recording on, no retention anywhere; observability SDK capturing conversation text with no
  redaction; storage with no server-side encryption; a signed forward whose receiver cannot be
  inspected

### NOT Vulnerable
- Recordings written to a private store with server-side encryption and a lifecycle rule, served
  only through short-lived signed URLs from a route that checks ownership — quote the policy,
  the lifecycle, the signing, and the check
- Platform-side storage with retention configured and exported in the workspace — Pass for the
  retention row with the export quoted; the app-side copies still need their own rows
- Logging that records call id, duration, ended reason, and tool names, never text — quote a
  sample log call
- Post-call forwards over HTTPS to a receiver in the workspace that verifies a shared secret —
  quote both ends
- Observability configured with the tool's redaction or with no conversation text captured —
  quote the config
- Recording and transcript storage both off, established by the search across config and code —
  Skip, `not applicable`

### Context Check
1. Is recording on? Where is it switched: code, exported config, or nowhere visible (Rule 6
   Skip)?
2. List every place an artifact goes: platform, bucket, log, forward, observability tool.
3. For each place: who can read it, by what path, with what credential, for how long?
4. Does any URL to an artifact leave the server unsigned?
5. Is there a retention decision anywhere, or does the data live until someone remembers?
6. Does the admin surface that reads artifacts scope by tenant or role?

### Evidence Chain
- The recording switch file:line (or the Rule 6 skip line for a platform-side default)
- Each artifact sink file:line with its destination
- The access control on each destination: bucket policy, signed-URL code, route guard, or the
  search that established their absence
- The retention rule file:line, or the search across code and config that found none
- For forwards: the URL, the transport, the secret handling, and whether the receiver is in the
  workspace
- For logs: the log call file:line and what it interpolates

### Confidence Scoring
- **High**: the sink, its destination, and its access control (or lack) are all in the workspace
  and quoted
- **Medium**: the destination is platform-side or infrastructure-side (a bucket created outside
  the repo, a dashboard retention setting) with no export
- **Low**: the artifact path could not be resolved (dynamic destination, unread SDK default) —
  tag `needs human verification`

### Severity
Critical is an artifact store anyone on the internet can read. High is an artifact reachable by
URL with no auth, a transcript in the logs, an unsigned or plaintext forward, or an unscoped
reader. Medium is an undecided retention, an unredacted observability feed, or missing
encryption. Low is not used; an artifact that lands somewhere is never cosmetic.

### Files to Check
- `**/recording*`, `**/transcript*`, `**/artifact*`, `**/post-call*`, `**/call-ended*`,
  `**/end-of-call*`
- `**/storage/**`, `**/s3*`, `**/bucket*`, `**/upload*`
- `**/logger*`, `**/logging*`, `**/observability*`, `**/telemetry*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/vapi*`, `**/retell*`, `**/bland*`,
  `**/elevenlabs*`
- `infra/**`, `terraform/**`, `cdk/**`, `pulumi/**`, `serverless.yml` (bucket policies,
  lifecycle rules)
- `.env*`, `**/config/**`

### Reference
- CWE-532: Insertion of Sensitive Information into Log File
- CWE-284: Improper Access Control
- CWE-311: Missing Encryption of Sensitive Data
- OWASP LLM Top 10 (2025): LLM02 Sensitive Information Disclosure
- Per-platform recording, retention and artifact-URL behavior: `references/stacks/<platform>.md`
