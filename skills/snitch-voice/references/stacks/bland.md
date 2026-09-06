# Stack: Bland AI

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Bland is a hosted outbound-first platform: one `POST /v1/calls` places a call with a `task` prompt or a `pathway_id`, and most of the dangerous parameters (`transfer_phone_number`, `max_duration`, `record`, `retry`, `voicemail`) ride on that single request. The repo therefore usually holds the code that builds that request from user input, which is where Cats 14, 17, 21, 24 land. Read this before they run.

## Fingerprints

- Packages: `bland` (PyPI), `bland-client-js-sdk`, `bland-ai`
- Env: `BLAND_API_KEY`, `BLAND_AUTHORIZATION`
- Hosts and paths: `api.bland.ai/v1/calls`, `/v1/pathway`, `/v1/tools`, `/v1/agents`
- Headers: `authorization: <key>` (no Bearer prefix in the docs), `X-Webhook-Signature`
- Keys: `phone_number`, `task`, `pathway_id`, `from`, `transfer_phone_number`, `transfer_list`, `max_duration`, `record`, `voicemail` (`message`, `action`, `sms`), `tools`, `dynamic_data`, `webhook`, `webhook_events`, `metadata`, `request_data`, `guard_rails`, `encrypted_key`, `dialing_strategy`, `retry`, `precall_dtmf_sequence`, `block_interruptions`, `first_sentence`
- Custom tool keys: `name`, `description`, `url`, `method`, `headers`, `body` with `{{input.x}}`, `input_schema`, `response`, `timeout`, `authentication` (Bearer / API key header / Basic / None)

## Ingress and verification (H1)

- Post-call and event webhooks carry `X-Webhook-Signature`: HMAC-SHA256 hex over the body with a secret generated once in the developer portal. The vendor's own snippet compares with `===`; a constant-time compare is the Cat 01 non-constant-compare row. An enterprise JWT option with a public JWKS exists.
- No SDK helper; app code computes and compares.
- Insecure shape: a `/bland-webhook` that writes `call.transcript` to the CRM with no signature check.

## Client authentication (H2)

- There is no browser credential; every call is created server-side with the API key. An API key in a client bundle is Cat 03 Critical. A `/start-call` app route that takes `phone_number` and `task` from a form without auth is Cat 14 open-outbound-endpoint and Cat 24 (robocalls from the business's number).

## Tools (H6)

- Custom tools post to `url` with `headers` and a `body` templated from `{{input.*}}` (model-filled). `authentication: "No Authentication"` is Cat 12. Headers may reference vendor-held secrets; literals in the repo are Cat 26. `{{input.*}}` in a URL path is an injection / SSRF surface (Cat 08 / snitch-security Cat 05).
- Pathways carry transfer and webhook nodes; an exported pathway JSON is the auditable config.

## Call control (H7)

- `transfer_phone_number` and `transfer_list` on the call request; a value derived from `request_data` or user input is Cat 14. Pathway transfer nodes with a model-filled number are the same row.
- `from` sets caller ID (must be a number on the account or BYO carrier via `encrypted_key`).
- `precall_dtmf_sequence` sends digits before the conversation; `dynamic_data` fetches external data mid-call.
- Outbound geography is account-side (Rule 6).

## Limits (H10)

- `max_duration` in minutes (default documented on the API page; treat unset as a Cat 17 finding only with the export or request builder quoted). `retry` with `voicemail.action` can redial; no attempt cap in code is Cat 18. Concurrency is account-side.

## Recording, transcripts, retention, redaction (H9)

- `record` defaults to false per the docs. Transcripts and `recording_url` arrive in the webhook payload and in the dashboard. No redaction switch documented on the pages read (unverified). Retention is dashboard-side (Rule 6).

## Disclosure surfaces (H8)

- `first_sentence`, `task`, `voicemail.message`, pathway start node text.

## What the platform already handles (do not flag)

- `record: false` by default: do not flag recording consent unless `record: true` is set.
- A `transfer_phone_number` that is a literal in the request builder is server-resolved; Pass.
- The platform verifies its own carrier webhooks; Cat 01 here is about the app's post-call and tool routes.


## Workspace shapes

The form-to-call route that makes a robocaller out of the account:

```ts
app.post("/api/call-me", async (req, res) => {                 // no auth, no rate limit, no consent record
  await fetch("https://api.bland.ai/v1/calls", { method: "POST",
    headers: { authorization: process.env.BLAND_API_KEY! },
    body: JSON.stringify({ phone_number: req.body.phone, task: req.body.script, transfer_phone_number: req.body.transfer, record: true }) });
  res.sendStatus(202);
});
```

Four rows in one handler: Cat 14 open-outbound-endpoint (`phone_number`) and unrestricted-destination (`transfer_phone_number`), Cat 08 (`task` from the request is the whole prompt), Cat 24 (no consent check before an outbound AI call), and Cat 23 (`record: true` with no announcement in `first_sentence`).

## Trace hints

- `request_data` and `dynamic_data` results are interpolated into `task` at call time; resolve where each value comes from.
- Pathway JSON exports are the config of record for transfer nodes and webhook nodes.

## Category quick map

| Cat | Row this stack most often fires on | Inherent Rule 6 Skips |
|---|---|---|
| 01 | post-call webhook with no `X-Webhook-Signature` check; `===` compare | JWT / JWKS option when not exported |
| 03 | API key in a bundle | — |
| 12 | tool with `authentication: None` | — |
| 14 | `transfer_phone_number` / `phone_number` from a form; pathway transfer with a model-filled number | outbound country restrictions |
| 17 | `max_duration` unset in the request builder | account defaults |
| 18 | `retry` with no attempt cap | — |
| 21 | `record: true` with `recording_url` forwarded | retention |
| 24 | outbound `task` calls with no consent check in code | — |
