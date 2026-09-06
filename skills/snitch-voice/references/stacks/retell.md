# Stack: Retell AI

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Retell is a hosted agent platform with two integration shapes: a Retell-hosted LLM configured through the API (`general_tools`, prompts, transfer settings) and a **custom LLM** where Retell dials out to your WebSocket and you produce every response. The custom-LLM socket carries no authentication of its own, recordings and logs are public URLs unless signed URLs are opted into, and the transfer tool can take its destination from the model. Read this before Cats 01, 02, 03, 04, 12, 13, 14, 15, 17, 21, 22 run.

## Fingerprints

- Packages: `retell-sdk` (npm), `retell_sdk` (PyPI), `retell-client-js-sdk` (browser `RetellWebClient`)
- Env: `RETELL_API_KEY`, `RETELL_AGENT_ID`
- Hosts and paths: `api.retellai.com`, `/v2/create-phone-call`, `/v2/create-web-call`, `/create-agent`, `/create-retell-llm`, `/v2/create-batch-call`
- Headers: `X-Retell-Signature`
- Keys: `llm_websocket_url`, `general_tools[]`, `general_prompt`, `begin_message`, `webhook_url`, `webhook_events`, `max_call_duration_ms`, `end_call_after_silence_ms`, `data_storage_setting`, `data_storage_retention_days`, `opt_in_signed_url`, `signed_url_expiration_ms`, `pii_config`, `guardrail_config`, `allow_user_dtmf`, `voicemail_option`, `opt_out_sensitive_data_storage` (older), `transfer_destination`, `transfer_option`, `inferred`, `predefined`, `response_variables`, `dynamic_variables`, `retell_llm_dynamic_variables`
- Socket messages: `response_required`, `reminder_required`, `update_only`, `response`, `agent_interrupt`, `tool_call_invocation`, `tool_call_result`; response fields `end_call`, `transfer_number`
- Response fields exposing artifacts: `recording_url`, `public_log_url`, `scrubbed_recording_url`, `transcript`

## Ingress and verification (H1)

- Scheme: `X-Retell-Signature: v={unix_ms},d={hex}`; HMAC-SHA256 over `raw_body + timestamp`, keyed by the **API key** (only a key carrying the webhook badge). Five-minute replay window. Optional IP allowlist.
- Helpers: Node `Retell.verify(rawBody, process.env.RETELL_API_KEY, signature)`; Python `retell.verify(raw_body, api_key=..., signature=...)`. Requires the raw body (`express.raw()`); a re-serialized body fails or, worse, is skipped.
- Custom-LLM WebSocket: Retell connects to `{llm_websocket_url}/{call_id}` and the docs specify **no authentication mechanism** on that socket. The vendor suggests IP allowlisting or a secret in the URL path. A `ws://` URL, or a `wss://` URL with no secret segment and no IP filter, is Cat 02 High: whoever reaches it can inject `response` events, set `end_call: true`, or `transfer_number`.
- Insecure shape: an Express `/retell-webhook` using `express.json()` then `Retell.verify(JSON.stringify(req.body), …)` — wrong bytes.

## Client authentication (H2)

- Safe browser credential: the `access_token` returned by `POST /v2/create-web-call`, scoped to one call, valid for about 30 seconds; browser calls `retellWebClient.startCall({ accessToken })`.
- Server-side only: `RETELL_API_KEY`.
- Anti-patterns: API key in a bundle (Cat 03); a `/create-web-call` proxy with no user auth or rate limit (Cat 04); `retell_llm_dynamic_variables` set from client input (Cat 08 / 11).

## Tools (H6)

- `general_tools[]` types: `end_call`, `transfer_call`, `press_digit`, `send_sms`, `agent_swap`, `bridge_transfer`, `cancel_transfer`, `extract_dynamic_variable`, `book_appointment` and `*_cal` scheduling tools, `code` (executes JavaScript), `mcp`, `custom` (`url`, `method`, `headers`, `query_params`, `parameters`, `timeout_ms`, `max_retry`, `speak_during_execution`, `response_variables`).
- Custom tool auth is whatever is in `headers`; empty headers is Cat 12 unauthenticated tool webhook. A bearer token in `headers` is a downstream secret held by the vendor and usually a literal in the repo (Cat 03 posture note, Cat 26).
- `code` tools run model-adjacent JavaScript: Cat 13 Critical review item; `mcp` is snitch-security Cat 45.
- `tool_call_invocation` on the custom-LLM socket is the app's own tool loop — trace as any tool handler.

## Call control (H7)

- `transfer_call`: `transfer_destination` is either `predefined` (fixed number) or `inferred` (the model fills it from the conversation). `inferred` is the Cat 14 unrestricted-destination row unless the app constrains it elsewhere. Modes `cold_transfer`, `warm_transfer`, `agentic_warm_transfer`; `bridge_transfer`.
- Custom-LLM `response` with `transfer_number` is a raw destination sink.
- `press_digit` sends DTMF; `end_call` ends.
- Outbound: `POST /v2/create-phone-call` with `to_number`, `from_number`, `override_agent_id`, `retell_llm_dynamic_variables`; batch calls via `/v2/create-batch-call`. An app route taking `to_number` from a form is Cat 14 open-outbound-endpoint.
- Allowed inbound and outbound countries are dashboard settings (Rule 6).

## Limits (H10)

- `max_call_duration_ms` (range 60,000 to 7,200,000; documented default 3,600,000); `end_call_after_silence_ms` (documented default 600,000). Concurrency, calls-per-second and burst limits are account-side. `max_retry` on custom tools bounds tool retries, not calls.

## Recording, transcripts, retention, redaction (H9)

- Recording, transcript and logs are stored by default; the call object exposes `recording_url`, `public_log_url`, `scrubbed_recording_url`. Without `opt_in_signed_url: true` (with `signed_url_expiration_ms`, default about 24 hours) those are unauthenticated URLs — Cat 21 High when the app forwards or stores them.
- `data_storage_setting`: `everything` (default), `everything_except_pii`, `basic_attributes_only`. `data_storage_retention_days` (1 to 730); unset means no automatic deletion (unverified — confirm in the platform docs). `pii_config` names categories to scrub. Older `opt_out_sensitive_data_storage: true` still appears.

## Disclosure surfaces (H8)

- `begin_message`, `general_prompt`, `voicemail_option.message`.

## What the platform already handles (do not flag)

- `Retell.verify` on the raw body is full verification; do not ask for a separate timestamp check — the helper enforces the window.
- A `predefined` transfer destination is server-resolved; Pass with the config quoted.
- `data_storage_setting: everything_except_pii` with `pii_config` is a redaction control for Cat 22 rows when exported.
- The web-call `access_token` is single-use and short-lived; do not flag its TTL.


## Workspace shapes

The custom-LLM socket, as the starter repos ship it:

```python
@app.websocket("/llm-websocket/{call_id}")
async def llm_socket(websocket: WebSocket, call_id: str):
    await websocket.accept()          # no secret path segment, no origin or IP check
    async for msg in websocket.iter_json():
        if msg["interaction_type"] == "response_required":
            await websocket.send_json({"response_id": msg["response_id"], "content": await llm(msg["transcript"]), "end_call": False})
```

Anyone who reaches that URL can send `response` events, and a `transfer_number` in one of them is a dial sink with no control. The guarded shape puts an unguessable segment in `llm_websocket_url`, compares it on accept, and never sets `transfer_number` from model output.

The post-call verifier, done right and wrong:

```js
app.post("/retell", express.raw({ type: "application/json" }), (req, res) => {
  if (!Retell.verify(req.body.toString(), process.env.RETELL_API_KEY, req.header("x-retell-signature"))) return res.sendStatus(401);
  // wrong: express.json() upstream and Retell.verify(JSON.stringify(req.body), ...)
});
```

The transfer definition Cat 14 reads:

```json
{ "type": "transfer_call", "name": "transfer_to_billing",
  "transfer_destination": { "type": "inferred", "prompt": "the number the user asks for" } }
```

`"type": "predefined", "number": "+1555…"` is the Pass shape.

## Trace hints

- Tool arguments on the socket arrive in `tool_call_invocation.arguments`; on the hosted LLM they are posted to the custom tool's `url` as the request body.
- `retell_llm_dynamic_variables` set on `create-phone-call` or `create-web-call` land in `{{variable}}` slots of `general_prompt` and `begin_message` — resolve their source.
- The webhook payload's `call.transcript`, `call.recording_url`, `call.public_log_url` are the Cat 21 sinks; follow the consumer.

## Category quick map

| Cat | Row this stack most often fires on | Inherent Rule 6 Skips |
|---|---|---|
| 01 | webhook without `Retell.verify`; verify over re-serialized JSON | — |
| 02 | `llm_websocket_url` over `ws://` or with no secret path / IP filter | IP allowlist when configured platform-side |
| 03 | API key in a bundle | — |
| 04 | unauthenticated `create-web-call` proxy | — |
| 12 | custom tool with empty `headers`; account id from tool parameters | — |
| 13 | `code` tool; `send_sms` / booking with no confirmation | — |
| 14 | `inferred` transfer destination; `transfer_number` from the socket; `create-phone-call` from a form | allowed inbound / outbound countries |
| 17 | `max_call_duration_ms` at the maximum; `end_call_after_silence_ms` unset in an export | values when only in dashboard |
| 21 | `public_log_url` / `recording_url` forwarded without `opt_in_signed_url` | retention when not exported |
| 22 | `data_storage_setting: everything` with card or health data expected | `pii_config` when only in dashboard |
