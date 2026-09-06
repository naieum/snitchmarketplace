# Smart Detection

Run this at the start of every audit, before the discovery questions. It settles four things:

1. Which platforms and providers the agent is built on, and therefore which stack files to read.
2. Where each hop of the call path lives in this workspace — the webhook routes, the media
   sockets, the token endpoints, the tool definitions, the assistant configs, the client bundles.
3. The call surface: inbound, outbound, web or mobile client, or several.
4. Which categories will Skip before they run, because their subject is absent or platform-side.

Everything here is a detection signal, never a finding on its own.

---

## Step 1: run the inventory script, or grep by hand

```
python3 "${CLAUDE_SKILL_DIR}/scripts/voice-inventory.py" . --json
```

The script matches the literal strings in the tables below and prints where they are. Without
python3, grep the same tables by hand and say so in the metadata block. Either way, read every
hit before you believe it: a string in a README, a test, or a commented-out block is not a
platform in use.

## Step 2: fingerprint the stack

A voice agent is a cascade or a single speech-to-speech model, wired to a telephony or WebRTC
transport. Most repos combine two or three rows below. Read the stack file for each row that
fingerprints; when a repo carries a carrier **and** a hosted agent platform, read both.

| Stack | Grep for | Stack file |
|---|---|---|
| Twilio (Voice, Media Streams, ConversationRelay, TwiML) | `twilio` package; `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`; `X-Twilio-Signature`; `<Connect>`, `<Stream `, `<ConversationRelay`, `<Dial>`; `/incoming-call`, `/media-stream`, `/twiml`, `/voice` | `references/stacks/twilio.md` |
| Vonage, Telnyx, Plivo, SignalWire, Bandwidth | `@vonage/server-sdk`, `VONAGE_*`, NCCO `"action": "connect"`; `telnyx`, `TELNYX_PUBLIC_KEY`, `telnyx-signature-ed25519`; `plivo`, `X-Plivo-Signature-V3`; `@signalwire/`, `SWAIG`, `x-signalwire-signature`; `bandwidth-sdk`, `BW_*`, `<StartStream` | `references/stacks/carriers.md` |
| Vapi | `@vapi-ai/web`, `@vapi-ai/server-sdk`; `VAPI_*`; `api.vapi.ai`; `assistantOverrides`, `serverUrl`, `credentialId`, `x-vapi-secret`, `"type": "tool-calls"` | `references/stacks/vapi.md` |
| Retell | `retell-sdk`, `retell-client-js-sdk`; `RETELL_API_KEY`; `api.retellai.com`; `X-Retell-Signature`, `general_tools`, `llm_websocket_url`, `data_storage_setting` | `references/stacks/retell.md` |
| Bland | `bland` package; `BLAND_API_KEY`; `api.bland.ai`; `pathway_id`, `transfer_phone_number`, `max_duration`, `X-Webhook-Signature` | `references/stacks/bland.md` |
| ElevenLabs Agents | `@elevenlabs/client`, `@elevenlabs/react`, `elevenlabs`; `ELEVENLABS_API_KEY`; `/v1/convai/`; `xi-api-key`, `ElevenLabs-Signature`, `Conversation.startSession`, `built_in_tools`, `enable_auth` | `references/stacks/elevenlabs.md` |
| LiveKit Agents | `livekit-agents`, `@livekit/agents`, `livekit-server-sdk`; `LIVEKIT_API_SECRET`; `AccessToken`, `VideoGrant`, `WebhookReceiver`, `function_tool`, `CreateSIPParticipant`, `livekit.toml` | `references/stacks/livekit.md` |
| Pipecat, Daily, Vocode | `pipecat-ai`, `@pipecat-ai/client-js`, `@daily-co/daily-js`; `DAILY_API_KEY`; `TwilioFrameSerializer`, `FastAPIWebsocketTransport`, `DailyRESTHelper`, `register_function`, `bot.py`; `vocode`, `TelephonyServer` | `references/stacks/pipecat.md` |
| OpenAI Realtime, Agents SDK, xAI-compatible | `openai`, `@openai/agents-realtime`; `OPENAI_API_KEY`, `OPENAI_WEBHOOK_SECRET`; `/v1/realtime`, `client_secrets`, `session.update`, `realtime.call.incoming`, `dangerouslyAllowBrowser`; `XAI_API_KEY`, `api.x.ai/v1/realtime` | `references/stacks/openai-realtime.md` |
| Gemini Live | `@google/genai`, `google-genai`; `GEMINI_API_KEY`, `GOOGLE_API_KEY`; `live.connect`, `BidiGenerateContent`, `auth_tokens.create`, `live_connect_constraints` | `references/stacks/gemini-live.md` |
| Deepgram Voice Agent and STT | `@deepgram/sdk`, `deepgram-sdk`; `DEEPGRAM_API_KEY`; `agent.deepgram.com`, `/v1/auth/grant`, `"type": "Settings"`, `agent.think.functions`, `redact=` | `references/stacks/deepgram.md` |
| Azure Voice Live / Azure OpenAI Realtime / ACS; Amazon Connect / Lex / Nova Sonic | `azure-ai-voicelive`, `/voice-live/realtime`, `api-key`, `CallAutomationClient`; `boto3.client('connect')`, `start_outbound_voice_contact`, `lexv2`, `nova-sonic`, `invocationSource` | `references/stacks/enterprise-cloud.md` |
| Hume, Ultravox, Cartesia, AssemblyAI, Jambonz, Asterisk / FreeSWITCH, Kyutai, Synthflow, PolyAI, Sierra, Anthropic or Groq cascades | `hume`, `HUME_SECRET_KEY`; `ultravox-client`, `joinUrl`, `selectedTools`; `cartesia`; `assemblyai`, `redact_pii`; `@jambonz/node-client`, `Jambonz-Signature`; `ari-client`, `AudioSocket`, `mod_audio_stream`; `moshi`, `unmute`; `SYNTHFLOW_API_KEY`; `POLYAI_API_KEY`; `@anthropic-ai/sdk` beside any STT/TTS; `groq` audio | `references/stacks/other-frameworks.md` |

**No fingerprint at all** is not "no voice agent". Ask: "Where does the agent take audio in?
Point me at the route, the socket, or the platform config." If the answer is "it is all in the
vendor dashboard", the audit is the tool webhooks and the client, and every platform-side
category Skips under Rule 6 unless the user exports the configuration into the workspace.

## Step 3: locate each hop

| Hop | Where to look | Signals |
|---|---|---|
| H1 Ingress | route registrations; TwiML / NCCO / SWML builders; SIP trunk and dispatch configs | paths matching `voice|twiml|incoming|call|webhook|answer|event|ncco|status|recording|tool|function|post-call`; `websocket:` handlers; `<Stream`, `<ConversationRelay`, `"type": "websocket"` |
| H2 Session auth | token routes; SIP trunk auth; caller lookup code | `/token`, `/session`, `/client-secret`, `/signed-url`, `/start`, `/connect`, `create-web-call`, `auth/grant`, `auth_tokens.create`, `AccessToken(`; `From`, `customer.number`, `sip.phoneNumber`, `caller_id` used as a lookup key |
| H3 Transcription | STT client config; DTMF handlers | `transcription`, `listen`, `stt`, `input_audio_transcription`, `initial_prompt`, `keyterms`, `hints`; `dtmf`, `<Gather`, `press_digit`, `dtmfDetection` |
| H4 Prompt assembly | prompt files; assistant configs; `session.update`; template engines | `instructions`, `system_prompt`, `systemPrompt`, `general_prompt`, `prompt:`, `firstMessage`, `{{`, `variableValues`, `dynamic_variables`, `assistantOverrides`, `customParameters` |
| H5 Retrieval | KB / RAG / CRM / calendar clients used inside the call | `knowledge`, `kb`, `vector`, `embedding`, `search`, `crm`, `hubspot`, `salesforce`, `calendar`, `zendesk`, `notes`, `summary`, `previous_call` |
| H6 Tool dispatch | tool definitions and handlers | `tools`, `functions`, `general_tools`, `selectedTools`, `built_in_tools`, `function_declarations`, `@function_tool`, `register_function`, `tool(`, `toolCallList`, `function_call_output`, `tool_call_invocation` |
| H7 Call control | dial / transfer / DTMF-send / hangup calls | `calls.create`, `<Dial>`, `transfer`, `refer`, `CreateSIPParticipant`, `sendDigits`, `press_digit`, `endCall`, `end_call`, `hangup` |
| H8 Synthesis | TTS config; output filters; first message | `tts`, `speak`, `voice`, `voice_id`, `say`, `firstMessage`, `welcomeGreeting`, `begin_message`, `first_sentence`, `greeting` |
| H9 Storage | recording flags; transcript writes; logging; webhook forwards | `record`, `recording`, `Record=`, `<Record`, `egress`, `transcript`, `console.log`, `logger.`, `s3`, `bucket`, `retention`, `data_storage`, `redact`, `pii` |
| H10 Limits | assistant config; call creation params; middleware | `maxDurationSeconds`, `max_call_duration_ms`, `max_duration`, `TimeLimit`, `time_limit`, `limit`, `silenceTimeoutSeconds`, `end_call_after_silence_ms`, `endOnSilence`, `rateLimit`, `concurrency`, `retry`, `max_tokens`, `budget`, `usage trigger` |
| H11 Deployment | env files; deploy configs; TwiML bins; docs | `.env*`, `docker-compose`, `wrangler.toml`, `vercel.json`, `serverless.yml`, `ngrok`, `trycloudflare`, `http://`, `ws://`, `NODE_ENV`, `--allow-unauthenticated` |

## Step 4: map the call surface and the consequential tools

Record, for the metadata block and the confirm gate:

- **Inbound**: a route or trunk that answers calls. **Outbound**: any `calls.create`,
  `create-phone-call`, `/v1/calls`, `outbound-call`, `start_outbound_voice_contact`,
  `CreateSIPParticipant`, or campaign runner. **Web/mobile client**: any client SDK import or a
  token-minting route. A repo can be all three.
- **Tool inventory**: every tool definition found, with the ones matching the consequential list
  marked. The list, matched case-insensitively on the tool name, the decorated function name, the
  built-in type, or the `modelToolName`:

  | Class | Names seen across platforms |
  |---|---|
  | Transfer / forward | `transferCall`, `transfer_call`, `transfer`, `forward`, `warmTransfer`, `coldTransfer`, `bridge_transfer`, `transfer_to_number`, `transfer_to_agent`, `transfer_to_human`, `handoff`, `agent_swap`, `refer`, `escalate`, `transfer_sip_participant` |
  | Dial / place call | `dial`, `makeCall`, `make_call`, `outbound_call`, `create_call`, `place_call`, `callback`, `redial`, `CreateSIPParticipant`, `start_outbound_voice_contact` |
  | End call | `endCall`, `end_call`, `hangup`, `hangUp`, `hang_up`, `terminate`, `disconnect`, `EndConversation`, `leaveVoicemail` |
  | DTMF / keypad | `dtmf`, `sendDigits`, `send_digits`, `press_digit`, `playDtmfSounds`, `play_keypad_touch_tone`, `publish_dtmf`, `precall_dtmf_sequence` |
  | Messaging | `sendSms`, `send_sms`, `sms`, `sendText`, `send_text`, `sendEmail`, `send_email`, `notify`, `sendMessage`, `whatsapp` |
  | Money | `refund`, `payment`, `charge`, `pay`, `collect_payment`, `process_payment`, `capture_card`, `checkout`, `invoice`, `credit`, `transfer_funds`, `wire`, `donate`, `<Pay>` |
  | Account mutation and lookup | `updateAccount`, `update_account`, `updateProfile`, `update_address`, `change_password`, `reset_password`, `resetPin`, `verify_identity`, `lookup_customer`, `get_customer`, `getBalance`, `cancel_subscription`, `delete_account`, `close_account`, `unlock` |
  | Scheduling | `book_appointment`, `bookAppointment`, `check_availability`, `schedule`, `reschedule`, `cancel_appointment`, `create_event` |
  | Agentic / code execution | `bash`, `computer`, `textEditor`, `code`, `run_code`, `execute`, `shell`, `eval`, `sql`, `query`, `mcp`, `apiRequest`, `http_request`, `fetch_url`, `browse`, `code_execution`, `data_map` |
  | Data capture / state | `extract_dynamic_variable`, `update_state`, `collect_*`, `capture_*`, `save_*`, `store_*` |
  | Search (exfiltration surface) | `web_search`, `x_search`, `file_search`, `google_search`, `queryCorpus`, `search_knowledge` |

  A tool on this list whose destination, amount, recipient, or command comes from an LLM-filled
  parameter is the shape Cats 12–15 trace. A tool with a fixed destination and a verified webhook
  is a Pass with a note. The list drives which rows can fire; it never decides a finding.

## Step 5: pre-compute the Skips

Before the confirm gate, name what will Skip and why, so the reader sees it up front:

- **Not applicable** — no outbound dialing found → Cat 14's outbound rows and Cat 24's outbound
  rows; no recording flag or API → Cat 23 and the storage rows of Cat 21; no messaging tool →
  Cat 15; no retrieval client inside the call → Cat 09; no browser or mobile client → Cats 03
  and 04 (except `.env` leakage, which still runs); no biometric provider → Cat 05's voiceprint
  rows.
- **Platform-side, not exported** — hosted agent platform detected and no assistant/agent config
  in the workspace → Cat 10 (the prompt), Cat 17 and 19 (limits and spend), Cat 21 and 22
  (retention and redaction), Cat 24's first-message rows. Each Skips with the Rule 6 wording.
  Offer once: "export the assistant configuration into the repo and re-run".
- **A recorded Decision** in `BLUEPRINT.md` (STEP 0.5 of SKILL.md) that scopes out a surface —
  Skip citing the line.

## What the platform already does

Read the stack file's "What the platform already handles" section before filing against a
bare-looking handler. The mitigations that most often make a "missing" claim wrong:

| Behavior | Where to confirm it |
|---|---|
| Signature verification performed by a registered SDK middleware for every route under a prefix | the middleware registration and its options (`validate`, `skip`) |
| A hosted platform that never sends the private key to the client because its web SDK takes a public key by design | the SDK constructor call and which key name it reads |
| Session config bound server-side into an ephemeral token or client secret, so client-side updates cannot widen tools | the mint call's payload (constraints, `session`, grants) |
| Recording off by default on the carrier and never turned on in code | the absence of `Record` / `<Record>` / egress calls, established by search |
| Platform-side retention or redaction configured in an export present in the workspace | the exported config file |
| Country permissions or allowed-address lists exported in the workspace | the exported config or IaC file |

When a mitigation is confirmed, record it as a Pass with the evidence. When it is plausible but
unconfirmed (the setting is dashboard-only), the finding stays at Medium confidence with the
dashboard caveat from `references/anti-hallucination.md`.
