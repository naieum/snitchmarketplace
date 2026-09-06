# Stack: Enterprise cloud voice (Azure and Amazon)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Two clouds ship voice-agent building blocks that look nothing like the startup platforms: the
model socket is fronted by identity-provider tokens, the telephony leg is a separate service
with its own callback auth, and the recording, redaction, and limit settings are portal or
infrastructure-as-code objects. Most posture rows here are Rule 6 Skips unless the IaC is in
the workspace; the code findings cluster around token brokers, callback verification, and what
Lambda or the app writes into contact records and logs.

## Azure: Voice Live, Azure OpenAI Realtime, Communication Services

### Fingerprints
- Packages: `azure-ai-voicelive` (`from azure.ai.voicelive.aio import connect`),
  `Azure.AI.VoiceLive` (NuGet), `@azure/ai-voicelive` (unverified — confirm in the platform
  docs), `azure-cognitiveservices-speech` / `microsoft-cognitiveservices-speech-sdk`,
  `azure-communication-callautomation`, `@azure/communication-call-automation`, `@azure/openai`
- Env: `AZURE_VOICELIVE_ENDPOINT`, `AZURE_VOICELIVE_API_KEY`, `AZURE_VOICELIVE_MODEL`,
  `AZURE_OPENAI_ENDPOINT`, `AZURE_OPENAI_API_KEY`, `SPEECH_KEY`, `SPEECH_REGION`,
  `ACS_CONNECTION_STRING`, `COMMUNICATION_CONNECTION_STRING`
- Hosts and paths: `wss://<resource>.services.ai.azure.com/voice-live/realtime?api-version=…&model=…`
  (or `&agent_id=&project_id=`), `wss://<resource>.openai.azure.com/openai/realtime?api-version=…&deployment=…`,
  `*.cognitiveservices.azure.com`, `sts/v1.0/issueToken`
- Headers: `Authorization: Bearer <Entra token>` (scope `https://ai.azure.com/.default`),
  `api-key` header or `?api-key=` query parameter
- Classes and keys: `DefaultAzureCredential`, `SpeechConfig`, `CallAutomationClient`,
  `IncomingCall`, `session.update`, `instructions`, `turn_detection: azure_semantic_vad`,
  `voice`, `tools`

### Ingress and verification (H1)
- **Communication Services Call Automation** callbacks carry `Authorization: Bearer <JWT>`
  with a 5-minute lifetime; validate against the vendor's OIDC / JWKS endpoint and require
  `aud` equal to the ACS resource's full ARM resource ID. Incoming-call events arrive via
  Event Grid, which has its own subscription validation handshake and (for webhook delivery)
  Entra or access-key auth. A callback route that acts on the event body without validating
  the JWT is Cat 01 `unverified-route`; a JWT check that skips `aud` is `wrong-bytes`.
- **Voice Live / Azure OpenAI Realtime** have no inbound webhook; ingress is the socket.

Insecure shape:

```python
@app.post("/acs/callbacks")
async def callbacks(request: Request):
    for event in await request.json():          # no JWT validation, no aud check
        if event["type"] == "Microsoft.Communication.CallConnected":
            await start_media_streaming(event["data"]["callConnectionId"])
```

### Client authentication (H2)
- Safe browser credential: an Entra bearer token from your token broker (scope
  `https://ai.azure.com/.default`), or for the Speech SDK a short-lived token from
  `sts/v1.0/issueToken` (10-minute validity per the vendor's docs). ACS calling clients use a
  user access token minted by `CommunicationIdentityClient` with scopes (`voip`) and an
  expiry.
- Must stay server-side: `api-key` values, `SPEECH_KEY`, the ACS connection string.
- Anti-patterns: `?api-key=` on a browser socket URL (the documented query form is the
  browser-leak pattern); `SPEECH_KEY` in a client; a token broker with no user auth; ACS user
  tokens minted with long expiry or for any requested identity.

### Tools (H6)
- Voice Live and Azure OpenAI Realtime mirror the OpenAI Realtime event shape:
  `session.update` with `tools`, `response.function_call_arguments.done`,
  `function_call_output`. Every argument is LLM-filled; execution is in your relay (Cat 12,
  13). Voice Live agent mode (`agent_id`) attaches tools defined in the AI Foundry project —
  platform-side (Rule 6 Skip unless exported).

### Call control (H7)
- ACS Call Automation: `transfer_call_to_participant` / `TransferCallToParticipant` (target a
  phone number or ACS user), `add_participant`, `hang_up`, `send_dtmf_tones`, `start_recording`,
  outbound `create_call` with a `PhoneNumberIdentifier` target and a `source_caller_id_number`.
  Trace every target and caller-ID value (Cat 14). Number and region permissions are
  portal-side (Rule 6 Skip).

### Limits (H10)
- Session and call duration: no primitive in the socket; ACS calls last until hung up. An
  app-side timer is Cat 17.
- Concurrency and spend: resource quotas, TPM limits, and cost alerts are Azure Monitor /
  subscription objects — Rule 6 Skip unless the IaC (Bicep, Terraform) is in the workspace,
  in which case quote it.

### Recording, transcripts, retention, redaction (H9)
- ACS recording is explicit (`start_recording`), with output to a storage account you name —
  the storage account's access and retention policy are the Cat 21 evidence when the IaC is
  present. Realtime transcripts are socket events the app writes.
- Redaction: Azure AI Language PII detection is a separate service call; nothing in the
  socket redacts. Absence before a write is Cat 22.

### Disclosure surfaces (H8)
- `instructions` in `session.update`, the Foundry agent's instructions (platform-side), and
  the first `play` / `play_to_all` prompt in an ACS flow.

### What the platform already handles (do not flag)
- Entra tokens with the documented scope are the intended credential; do not flag their use.
- ACS callback JWTs, once validated with `aud`, need no additional shared secret.
- Media over TLS/SRTP; not a finding.

## Amazon: Connect, Lex, Nova Sonic on Bedrock

### Fingerprints
- Packages: `boto3` with `client('connect')`, `client('lexv2-runtime')`,
  `client('bedrock-runtime')`; `@aws-sdk/client-connect`, `@aws-sdk/client-lex-runtime-v2`,
  `@aws-sdk/client-bedrock-runtime`; `aws_sdk_bedrock_runtime`
- Env: the standard `AWS_*` set, `CONNECT_INSTANCE_ID`, `CONTACT_FLOW_ID`, `LEX_BOT_ID`,
  `LEX_BOT_ALIAS_ID`
- Calls and keys: `start_outbound_voice_contact(DestinationPhoneNumber, ContactFlowId,
  InstanceId, SourcePhoneNumber, QueueId, Attributes, AnswerMachineDetectionConfig,
  TrafficType)`, Lex Lambda `invocationSource` (`DialogCodeHook` | `FulfillmentCodeHook`),
  `sessionState.intent.slots`, `inputTranscript`, `dialogAction.type`,
  `invoke_model_with_bidirectional_stream`, `amazon.nova-sonic-*`, `toolUse` / `toolResult`,
  `RecordedParticipants`, `CommunicationLimitsConfig`, contact-flow JSON with "Set recording
  and analytics behavior" and "Set logging behavior" blocks

### Ingress and verification (H1)
- There are no webhooks. Connect and Lex invoke Lambda through IAM; the trust question is the
  Lambda's resource policy and execution role, which is infrastructure (snitch-security's IaC
  category) — Skip here with that hand-off. A self-hosted endpoint that Connect reaches through
  an API Gateway integration is Cat 01 by whatever auth the gateway enforces.
- Nova Sonic sessions are opened by your server with SigV4; a browser reaches them only through
  your relay or an AgentCore Runtime WebSocket — the relay's auth is Cat 02 / 04.

### Client authentication (H2)
- Safe browser credential: none of the model or contact APIs is meant to be called from a
  browser with long-lived keys; use Cognito identity or a relay. `AWS_SECRET_ACCESS_KEY` in a
  client bundle is Cat 03.

### Tools (H6)
- Lex: fulfillment is the Lambda; slot values are LLM- or ASR-filled and reach the Lambda in
  `sessionState.intent.slots`. Nova Sonic: `toolUse` events with LLM-filled input, answered
  with `toolResult`. Bedrock Agents tools are action groups (Lambda or OpenAPI). Every one is
  Cat 12 / 13 in the Lambda: identity from the contact (the `CustomerEndpoint` address is the
  caller ID and is a lookup signal only — Cat 05), never from a slot.

### Call control (H7)
- Outbound: `start_outbound_voice_contact` with `DestinationPhoneNumber` and
  `SourcePhoneNumber`; trace both (Cat 14). Transfers are contact-flow blocks ("Transfer to
  phone number") — a flow that transfers to a number stored in a contact attribute the Lambda
  set from a slot is `unrestricted-destination`. Outbound campaigns carry
  `CommunicationLimitsConfig` (platform-side unless the campaign IaC is present).
- Country and number restrictions are instance settings (Rule 6 Skip).

### Limits (H10)
- Concurrent calls per instance, outbound-campaign limits, and Bedrock quotas are service
  quotas — Rule 6 Skip unless the IaC is present. A Lambda that dials in a loop with no attempt
  cap is Cat 18 in code.

### Recording, transcripts, retention, redaction (H9)
- Recording is set per flow in "Set recording and analytics behavior"; Contact Lens redaction
  requires both `Agent` and `Customer` in `RecordedParticipants` (a flow that records only
  one side is not redacted). Recordings land in the instance's S3 bucket; the bucket policy is
  the Cat 21 evidence when IaC is present.
- **Contact attributes are the leak.** Values a Lambda returns and the flow stores as contact
  attributes appear in Contact Search and CloudWatch; the vendor's guidance is to keep
  sensitive values out of attributes, use "Set logging behavior" to disable logging around
  card capture, and use encrypted "Store customer input" for DTMF card entry (Cat 22).
- Retention is an instance data-storage setting (Rule 6 Skip).

### Disclosure surfaces (H8)
- The "Play prompt" blocks at the top of the inbound flow and the Lex bot's welcome intent;
  Nova Sonic `systemPrompt` in the session start event. Cat 23 and 24 grep the flow JSON and
  the prompt.

### What the platform already handles (do not flag)
- IAM-invoked Lambda has no signature to check; do not file Cat 01 against it.
- Contact Lens redaction, when both participants are recorded and it is enabled in the flow
  export, covers the recording and transcript rows.
- Bedrock Guardrails, when attached in the exported config, are a documented pre-model gate
  for Cat 07's advisory rows — a Pass with the guardrail quoted, never a substitute for
  tool-side authorization.

## Category quick map

| Cat | Azure fires on | Amazon fires on | Inherent Rule 6 Skips |
|---|---|---|---|
| 01 | ACS callback without JWT + `aud` validation | — (IAM; hand off IaC) | Event Grid subscription auth |
| 02, 04 | `?api-key=` sockets; token broker without user auth; long ACS user tokens | relay or AgentCore socket with no auth | — |
| 03 | `SPEECH_KEY`, `api-key`, connection string in a client | AWS keys in a client | — |
| 05 | — | `CustomerEndpoint` address used as identity | — |
| 12, 13 | relay tool handlers acting on arguments | Lambda acting on slots or `toolUse` input | Foundry agent tools; action-group IaC |
| 14 | `transfer_call_to_participant` / `create_call` targets from arguments | `DestinationPhoneNumber`, transfer-to-number from attributes | portal / instance number permissions |
| 17, 18, 19 | no call timer; quotas and cost alerts absent from IaC | Lambda dial loops; campaign limits absent from IaC | service quotas, cost alerts |
| 21, 22 | recording storage policy; no PII service before writes | sensitive values in contact attributes; one-sided `RecordedParticipants`; logging not disabled at card capture | instance retention settings |
| 23, 24 | `instructions` and first `play` prompt | flow "Play prompt" and Lex welcome intent | — |
| 26 | `http://` callback URLs; keys in `local.settings.json` | keys in `serverless.yml` / `template.yaml` | — |
