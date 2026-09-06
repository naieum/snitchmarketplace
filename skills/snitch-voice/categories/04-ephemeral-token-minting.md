## CATEGORY 04: Ephemeral token and client-secret minting endpoints
> Type: posture · Groups: ingress · Hop: H2 Session authentication · Standards: CWE-287, CWE-613

The correct answer to "how does the browser talk to the speech provider" is a server route that
mints a short-lived, narrowly scoped credential and hands it to one authenticated user. That route
is now the front door to the provider account, and it is often built as an open, unauthenticated
GET that returns a fresh credential to anyone who asks, with the provider's maximum TTL, with grants
that let the holder do anything in any room, or with a session configuration the client is
free to overwrite. An attacker who can call the minting route has the same thing as the key
itself, one request at a time. This category reads every credential-minting route and judges who
can call it, what it mints, for how long, with what scope, and whether the session it binds can be
rewritten by the client.

**Boundary.** This category judges the minting route and the credential it produces. A long-lived
key that skipped minting entirely and shipped to the client is Cat 03. Whether the client can
override the assistant's prompt or tools inside a minted session is Cat 11 when the override is a
platform feature, and here when the token was minted without the constraint that would have
locked it. Rate limiting the route against abuse is read here; the account-wide concurrency and
spend caps are Cat 18 and Cat 19.

### Detection
- OpenAI Realtime: `POST /v1/realtime/client_secrets`, `client_secrets.create`, `ek_` prefixed
  values, `expires_after`
- Gemini Live: `auth_tokens.create`, `authTokens.create`, `uses`, `expire_time`,
  `new_session_expire_time`, `live_connect_constraints`, `lock_additional_fields`
- Deepgram: `POST /v1/auth/grant`, `ttl_seconds`, grant JWT used as `Bearer` on `/agent`
- LiveKit: `AccessToken`, `VideoGrant`, `addGrant`, `roomJoin`, `canPublish`, `canSubscribe`,
  `roomAdmin`, `RoomConfiguration`, `ttl`
- ElevenLabs: `get-signed-url`, `getSignedUrl`, `conversation_token`, `conversationToken`,
  `enable_auth`
- Vapi: `POST /call/web`, JWT signed with the private key carrying `token.tag` /
  `token.restrictions` (`allowedOrigins`, `allowedAssistantIds`, `allowTransientAssistant`)
- Retell: `create-web-call`, `createWebCall`, `access_token`
- Daily / Pipecat: `DailyRESTHelper.get_token`, `meeting-tokens`, `is_owner`, `exp`,
  Pipecat Cloud `/start` one-time tokens
- Twilio Voice SDK: `AccessToken` with `VoiceGrant`, `ttl`, `identity`
- Route paths: `/token`, `/session`, `/client-secret`, `/ephemeral`, `/auth/grant`, `/signed-url`,
  `/web-call`, `/connect`, `/start`, `/join`

### What to Search For
- Minting routes with no authentication guard on their middleware chain, or a guard that is
  optional (`if (user)`) rather than required
- TTL left at the provider maximum or unset when the provider documents a default: Deepgram
  `ttl_seconds` at 3600, Gemini `expire_time` far past the session, LiveKit `ttl` of hours or
  days, Daily tokens with no `exp`, OpenAI `expires_after` omitted (unverified — confirm each
  provider's current default in the platform docs)
- Grants broader than the session needs: LiveKit `roomAdmin`, `roomCreate`, `roomList`, wildcard
  `room`, `canPublishData` on a listen-only client; Daily `is_owner: true`; Twilio grants with
  outgoing application SIDs the client should not reach
- Gemini tokens minted without `live_connect_constraints.bidi_generate_content_setup` carrying the
  model, system instruction, and an explicit (possibly empty) `tools` array, or with `uses > 1`
  and a long expiry
- OpenAI client secrets minted with no `session` configuration bound, leaving instructions and
  tools to the client's `session.update`
- Vapi JWTs signed without `restrictions`, or with `allowTransientAssistant: true` on a public
  client; Vapi public keys with no origin restriction and no `allowedAssistantIds` (the platform
  side of that is Cat 11)
- ElevenLabs agents whose signed-URL route is reachable by anyone and whose agent has neither
  `enable_auth` nor a hostname allowlist
- Retell `create-web-call` called from a route with no session check, or the agent ID taken
  from the request
- Room or identity values taken from the request body (`room: req.body.room`,
  `identity: req.query.user`) so one user mints a token for another user's room
- `Access-Control-Allow-Origin: *` on the minting route
- No per-user or per-IP rate limit on the route
- Tokens logged, returned in error responses, or stored server-side in plaintext

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| open-minting-route | A credential-minting route is reachable without authentication | route file:line + middleware chain | Critical |
| unconstrained-session | A minted credential binds no session configuration, so the client sets the model, instructions, or tools | the mint call file:line + the absent constraint fields | High |
| over-broad-grant | The credential's grants exceed what one caller's session needs | the grant construction file:line | High |
| caller-chosen-scope | The room, identity, agent, or assistant the credential is scoped to comes from the request | the mint call + the request read | High |
| long-ttl | TTL is at the provider maximum, unset where the default is long, or days | the mint call file:line | Medium |
| wildcard-cors | The minting route allows any origin | the CORS config file:line | Medium |
| no-mint-rate-limit | The route has no per-user or per-IP limit | the route + the search | Medium |
| credential-logged | The minted value is written to logs, error bodies, or a database in plaintext | file:line | Medium |

### Actually Vulnerable

#### Critical
- `app.get('/token', async (req, res) => res.json({ token: await mint() }))` with no guard
- A Deepgram grant, LiveKit token, or OpenAI client secret returned from a public Next.js route
  handler with no session read
- A Pipecat `/connect` that creates a room and returns an owner token to any POST

#### High
- Gemini `auth_tokens.create` with only `uses`, `expire_time`, and `new_session_expire_time`
- OpenAI `client_secrets.create` with no `session` body, paired with a client that sends
  `session.update`
- LiveKit tokens with `roomAdmin: true` or `room: '*'` for end users
- `room` or `identity` from the request body

#### Medium
- Deepgram `ttl_seconds: 3600` for a one-shot session; LiveKit `ttl: '7d'`
- `cors({ origin: '*' })` on the minting router
- No rate limit; token echoed into logs

### NOT Vulnerable
- The minting route sits behind the application's session guard, read and quoted; the token
  is scoped to the caller's own identity and room, with a TTL near the session's expected
  length and grants limited to join, publish, and subscribe
- Gemini tokens with `live_connect_constraints.bidi_generate_content_setup` populated and
  `lock_additional_fields` covering instructions and tools
- OpenAI client secrets with the `session` configuration bound server-side and a client that
  never sends `session.update` for instructions or tools (quote both)
- Vapi JWTs with `restrictions.allowedOrigins` and `allowedAssistantIds`, or a public key whose
  exported restrictions are in the workspace
- ElevenLabs agents with `enable_auth` and a signed-URL route behind the app's auth
- A rate-limited, origin-restricted route where the platform's own key never leaves the server
- No client sessions in the workspace (telephony-only agent) — Skip, `not applicable`

### Context Check
1. Who can reach the minting route? Read the middleware chain, not the file location.
2. What exactly is minted: which provider, which grants, which TTL, which bound configuration?
3. Can the request influence the scope (room, identity, agent, assistant)?
4. Does the client later send a configuration frame the server did not lock?
5. Is the route rate-limited and origin-restricted?
6. Where does the minted value go besides the response?

### Evidence Chain
- The route registration file:line and its guard, or the search that established no guard
- The mint call file:line with grants, TTL, and constraint fields quoted
- The request reads that flow into the mint call
- The client's use of the credential, where relevant to the constraint row
- CORS and rate-limit configuration for the route, or the searches that established their absence

### Confidence Scoring
- **High**: the route's middleware chain is resolved and the guard is verifiably absent, or the
  mint call verifiably omits the constraint or grants the wildcard
- **Medium**: a guard may be applied by a framework convention or deployment layer not in the
  workspace, or the provider's default for an omitted field is unverified
- **Low**: the route could not be tied to a client, or the mint call's arguments are built
  dynamically from unresolved sources — tag `needs human verification`

### Severity
Critical is an open route: the credential is public. High is a credential that lets the holder
rewrite the session, act as admin, or act as another user. Medium is a long life, a wide origin,
or a missing throttle on an otherwise guarded route. Low is not used.

### Files to Check
- `**/token*`, `**/session*`, `**/auth/**`, `**/client-secret*`, `**/ephemeral*`, `**/grant*`,
  `**/signed-url*`, `**/web-call*`, `**/connect*`, `**/start*`, `**/join*`
- `pages/api/**`, `app/api/**`, `**/routes/**`, `**/handlers/**`, `server.ts`, `main.py`
- CORS and rate-limit middleware registration files
- `.env*` for TTL and grant configuration

### Reference
- CWE-287: Improper Authentication
- CWE-613: Insufficient Session Expiration
- CWE-269: Improper Privilege Management (over-broad grants)
- CWE-942: Permissive Cross-domain Policy
- Per-platform token API, default TTL, and constraint fields: `references/stacks/<platform>.md`
