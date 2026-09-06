## CATEGORY 26: Tunnel URLs, plaintext webhooks, debug routes and quickstart leftovers
> Type: posture · Groups: quick, ingress · Hop: H11 Deployment · Standards: CWE-319, CWE-489

Every voice platform ships a quickstart, and every quickstart is built to work in ten minutes:
a tunnel URL pasted into the number's webhook field, signature validation commented out because
the tunnel rewrote the host, a `.env` with every provider key in it, a test number hardcoded
for the demo, and a `/debug` route that dumps the last call. Those files get copied into
production unchanged more often than not, and the tunnel URL keeps working long after the demo
— pointing the business's phone number at whatever laptop next claims that subdomain. This
category reads the deployment surface — URLs, transports, environment handling, leftover
routes, committed secrets — and asks what a quickstart left behind.

**Boundary.** This category judges deployment residue. Whether a webhook route verifies its
signature is Cat 01 (a `validate: false` left from a tunnel session is reported there; the
tunnel URL that caused it is reported here). Whether a media socket is authenticated is Cat 02.
Provider secrets shipped in a client bundle are Cat 03; the same secrets committed in a
server-side `.env` are recorded here as deployment residue and handed to snitch-security's
hardcoded-secrets category for the secret itself — call the Skill tool with "snitch-security".
Debug endpoints off the call path are also snitch-security's.

### Detection
- Tunnel and preview hosts in TwiML, NCCO, config, or code: `ngrok-free.app`, `ngrok.io`,
  `ngrok.app`, `loca.lt`, `trycloudflare.com`, `serveo.net`, `localhost.run`, `tunnelmole`,
  `*.local`, `localhost`, `127.0.0.1`, `0.0.0.0`
- Plaintext transports on voice URLs: `http://` in `url`, `serverUrl`, `server.url`,
  `webhook_url`, `answer_url`, `event_url`, `llm_websocket_url`; `ws://` in `<Stream url>`,
  `<ConversationRelay url>`, stream and socket configuration
- Environment shortcuts: `NODE_ENV !== 'production'`, `if (process.env.DEBUG)`, `DEV_MODE`,
  `SKIP_AUTH`, `INSECURE`, `validate: false`, `skipSignatureVerification`
- Debug and introspection routes: `/debug`, `/last-call`, `/transcripts`, `/dump`, `/env`,
  `/config`, `/prompt`, `/logs`, `/admin` without a guard
- Hardcoded phone numbers in code (E.164 literals) outside test files and fixtures
- Committed secret files: `.env`, `.env.local`, `.env.production`, `private.key`, `*.pem`,
  `service-account*.json`, `credentials.json` tracked in git
- Quickstart and sample residue: files named `quickstart*`, `example*`, `sample*`, `demo*`,
  `starter*` under the deployed source; README instructions that still say "paste your ngrok
  URL"; sample assistant ids and public demo agents referenced from production config
- Deployment manifests: `Dockerfile`, `fly.toml`, `render.yaml`, `vercel.json`, `wrangler.toml`,
  `serverless.yml`, `k8s/**`, `Procfile`

### What to Search For
- A tunnel hostname anywhere the carrier or platform would read a URL from: TwiML returned by a
  route, an exported assistant config, an environment default, a README the deploy follows
- `ws://` or `http://` on a stream, webhook, or custom-LLM socket URL in anything that is not
  clearly a local-dev override
- Guards that disable verification, auth, or rate limits under an environment flag, and whether
  the flag's default is the insecure branch
- Routes that return prompt text, environment values, call lists, or transcripts with no auth
- Phone numbers hardcoded as defaults for `to`, `from`, `customer.number`, `transfer` outside
  tests
- `.env*` files present in the working tree and not in `.gitignore`, or present in git history
  (`git ls-files` shows them)
- Quickstart files under the deployed source tree that still carry the vendor's sample
  structure: no verification, host from the request header, a single handler doing everything
- Exported sample assistants or agents referenced by id from production code, or public demo
  agents that anyone can start
- Container and platform manifests that bake secrets into the image (`ENV OPENAI_API_KEY=`),
  run as root with a debug flag, or expose the media port without TLS termination in front

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| tunnel-url-in-config | A tunnel or local hostname appears where the carrier or platform reads a callback, stream, or socket URL | the URL file:line | High (Critical when it is the deployed default and nothing overrides it) |
| plaintext-voice-transport | A webhook, stream, or custom-LLM socket URL uses `http://` or `ws://` outside a clearly local override | the URL file:line | High |
| insecure-env-default | A flag disables verification, auth, or limits and its default or its production value is the insecure branch | the guard file:line + the default | High |
| debug-route-live | A route returns prompt text, environment values, transcripts, or call lists with no auth guard | the route file:line | High for prompts, env, or transcripts; Medium for call lists |
| committed-secret-file | A `.env`, key, or credential file is tracked in git | `git ls-files` output + the file path | High (the values themselves are handed to snitch-security) |
| hardcoded-number | A phone number literal is a default destination, caller ID, or transfer target in deployed code | the literal file:line | Medium |
| quickstart-shipped | A vendor sample file is in the deployed tree unchanged in its insecure shape | the file path + the shape (no verification, host from header) | Medium (its individual defects are reported in Cats 01, 02, 03) |
| secret-baked-in-image | A secret is set in a container or platform manifest rather than injected at runtime | the manifest file:line | High |

### Actually Vulnerable

#### Critical
- The only stream or webhook URL in the workspace is a tunnel hostname and nothing in the
  deployment manifest overrides it — the production phone number points at a tunnel

#### High
- `wss://${process.env.HOST || 'abc123.ngrok-free.app'}/media-stream`
- `<ConversationRelay url="ws://…">` or `llm_websocket_url: "ws://…"` in an exported config
- `if (process.env.NODE_ENV !== 'production') app.use(noAuth)` where the deploy never sets
  `NODE_ENV`
- `GET /debug/prompt` returning the system prompt; `GET /env` returning `process.env`
- `.env.production` tracked in git; `ENV TWILIO_AUTH_TOKEN=…` in a Dockerfile

#### Medium
- `to: process.env.TEST_NUMBER || '+1555…'` as a deployed default; a `speech-assistant` sample
  file deployed unchanged; an unguarded `/calls` list route

### NOT Vulnerable
- Tunnel hostnames confined to `.env.example`, `README`, or a file the deploy manifest does not
  include, with the production URL injected from the environment — quote the manifest and the
  environment read
- `ws://` only in a local-development override guarded by a flag whose default is the secure
  branch — quote the guard and the default
- Debug routes registered only under a development flag whose production value is verified in
  the deployment manifest
- `.env*` in `.gitignore` and absent from `git ls-files`; secrets injected at runtime from a
  secret manager or platform secret store — quote the injection
- Phone numbers in test files, fixtures, and documented allowlists (the allowlist is Cat 14's
  Pass)
- Sample files present in a `examples/` directory the deploy does not build — record as
  "verify not shipping" per the auto-exclude rule, not as a finding

### Context Check
1. Which files does the deploy actually ship? Read the manifest, the build config, and the
   `.dockerignore` before calling a file deployed.
2. Where does the production callback URL come from? Environment, config, hardcoded literal?
3. Which guards depend on an environment flag, and what is that flag's value in the manifest?
4. Is anything in `git ls-files` a secret or key file?
5. Do any routes expose internals, and are they behind a guard the manifest actually enables?
6. Are any sample files in the shipped tree, and are they still in their sample shape?

### Evidence Chain
- The URL or literal file:line and the file's role (returned TwiML, exported config, env default)
- The deployment manifest lines that set or fail to set the overriding value
- The guard file:line with its flag and the flag's production value, or the search that found
  none
- `git ls-files` output for secret-shaped paths, and the `.gitignore` entries checked
- For quickstart residue: the file path, the vendor sample it matches in shape, and the specific
  insecure lines (cross-referenced to the category that owns each)

### Confidence Scoring
- **High**: the deployed tree and the manifest are in the workspace and the residue is in a
  file the manifest ships, with no override
- **Medium**: the deploy manifest is elsewhere (platform dashboard, CI secrets), so whether the
  literal is overridden could not be read
- **Low**: the shipped file set could not be determined (monorepo with dynamic build targets) —
  tag `needs human verification`

### Severity
Critical is a production number pointed at a tunnel with nothing overriding it. High is a
plaintext voice transport, an insecure default under an environment flag, a live debug route
exposing prompts, environment, or transcripts, a committed secret file, or a secret baked into an
image. Medium is a hardcoded number, a shipped sample in its sample shape, or an unguarded call
list. Low is not used.

### Files to Check
- `**/twiml*`, `**/ncco*`, `**/*assistant*.json`, `**/*agent*.json`, `**/vapi*`, `**/retell*`
- `.env*`, `.gitignore`, `.dockerignore`, `Dockerfile`, `fly.toml`, `render.yaml`,
  `vercel.json`, `wrangler.toml`, `serverless.yml`, `k8s/**`, `Procfile`
- `**/routes/**`, `**/api/**`, `**/debug*`, `**/admin*`
- `README*`, `docs/**` (deployment instructions the team actually follows)
- `**/quickstart*`, `**/example*`, `**/sample*`, `**/demo*`, `**/starter*`

### Reference
- CWE-319: Cleartext Transmission of Sensitive Information
- CWE-489: Active Debug Code
- CWE-798: Use of Hard-coded Credentials (handed to snitch-security for the values)
- CWE-1188: Initialization of a Resource with an Insecure Default
- Per-platform quickstart shapes and known tunnel pitfalls: `references/stacks/<platform>.md`
