## CATEGORY 03: Provider secrets in browser and mobile voice clients
> Type: posture · Groups: quick, ingress · Hop: H11 Deployment · Standards: CWE-798, CWE-522

A voice client — a browser widget, a mobile app, a desktop companion — needs to open a session
with a speech or model provider, and the fastest way to make the quickstart work is to paste the
provider's private key into the client. Once shipped, that key belongs to everyone who opens the
page or unpacks the app: they can run the provider's models, speech, and telephony on the
business's account, mint their own sessions, and in some cases list or download the account's
recordings. This category looks for provider secrets that reach client-shipped code: private keys
in front-end source, secrets behind a public-prefix environment variable, `dangerouslyAllowBrowser`
style opt-ins, and telephony auth tokens in mobile bundles.

**Boundary.** This category judges secrets that ship to a client. The same key hardcoded in
server-only code is snitch-security's Cat 03 — hand off by calling the Skill tool with
"snitch-security". The endpoint that should be minting a short-lived credential instead is Cat 04.
A platform's public key (a key the vendor designs to be shipped) is a Pass here and its restriction
settings are Cat 11.

### Detection
- Front-end framework markers: `next.config.*`, `vite.config.*`, `app.json` / `app.config.*`
  (Expo), `ios/` and `android/` directories, `pubspec.yaml`, `*.xcodeproj`, `capacitor.config.*`,
  `electron*`
- Client voice SDKs: `@vapi-ai/web`, `retell-client-js-sdk`, `@elevenlabs/react` /
  `@elevenlabs/client`, `livekit-client`, `@livekit/components-react`, `@daily-co/daily-js`,
  `@pipecat-ai/client-js`, `@deepgram/sdk` in a browser bundle, `openai` with a browser flag,
  `@google/genai` in a browser bundle, `@twilio/voice-sdk`, `twilio-voice-react-native`
- Public-prefix environment variables: `NEXT_PUBLIC_*`, `VITE_*`, `REACT_APP_*`, `EXPO_PUBLIC_*`,
  `PUBLIC_*`, `NUXT_PUBLIC_*`, `GATSBY_*`
- Secret-shaped names: `TWILIO_AUTH_TOKEN`, `TWILIO_API_SECRET`, `VAPI_PRIVATE_KEY`,
  `VAPI_API_KEY`, `RETELL_API_KEY`, `BLAND_API_KEY`, `ELEVENLABS_API_KEY`, `OPENAI_API_KEY`,
  `DEEPGRAM_API_KEY`, `LIVEKIT_API_SECRET`, `DAILY_API_KEY`, `GEMINI_API_KEY`, `GOOGLE_API_KEY`,
  `TELNYX_API_KEY`, `VONAGE_API_SECRET`, `VONAGE_PRIVATE_KEY`, `PLIVO_AUTH_TOKEN`,
  `SIGNALWIRE_TOKEN`, `CARTESIA_API_KEY`, `ASSEMBLYAI_API_KEY`, `HUME_API_KEY`

### What to Search For
- A secret-shaped variable referenced from a file that is compiled into a client bundle
  (`src/`, `app/`, `components/`, `pages/` without a server marker, `lib/` imported by client
  code, mobile source trees)
- Public-prefix variables whose value or name is a private credential (`NEXT_PUBLIC_OPENAI_API_KEY`,
  `VITE_ELEVENLABS_API_KEY`, `EXPO_PUBLIC_TWILIO_AUTH_TOKEN`)
- `dangerouslyAllowBrowser: true` and equivalent browser opt-ins on provider SDK constructors
- Provider SDK constructors in client code taking an `apiKey` / `token` / `authorization`
  argument from anything other than a server-minted short-lived credential
- WebSocket URLs to providers built in client code with an `Authorization: Bearer <secret>` or
  `?key=` / `?token=` carrying a long-lived key
- Deepgram `Settings`, OpenAI `session.update`, or Gemini `setup` frames built client-side that
  carry tool endpoint headers or secrets
- Mobile: `Info.plist`, `strings.xml`, `BuildConfig`, `.xcconfig`, `google-services.json`,
  `app.json` `extra` blocks carrying provider secrets
- Committed `.env`, `.env.local`, `.env.production` files with client-prefixed secrets
- A "public key" or "publishable key" name whose value has the vendor's private-key shape (see
  the stack file for the key prefixes each platform uses, where documented)
- Signed-URL or token responses cached in `localStorage` with no expiry, or a session credential
  reused across users

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| private-key-in-client | A provider private key, auth token, or API secret is referenced from client-shipped source or a mobile bundle | file:line + the build boundary that ships it | Critical |
| public-prefix-secret | A private credential is exposed through a public-prefix environment variable | the variable name file:line + its client read | Critical |
| browser-opt-in | A server SDK is instantiated in the browser with a "dangerously allow browser" style flag and a real key | constructor file:line | Critical |
| session-frame-carries-secret | A client-built session or settings frame includes tool endpoint headers, secrets, or server-side auth | the frame builder file:line | High |
| credential-in-mobile-config | A provider secret sits in a mobile config file or build constant | file:line | High |
| long-lived-credential-cached | A minted session credential is stored client-side without expiry or reused across users | the storage file:line | Medium |
| committed-env-with-client-prefix | A `.env*` file with public-prefixed provider secrets is tracked | the file + `.gitignore` state | Medium (High if the value is a real key) |

### Actually Vulnerable

#### Critical
- `new OpenAI({ apiKey: process.env.NEXT_PUBLIC_OPENAI_API_KEY, dangerouslyAllowBrowser: true })`
  in a component
- `VITE_ELEVENLABS_API_KEY` read in a React hook that opens the conversation socket
- `Vapi(process.env.NEXT_PUBLIC_VAPI_PRIVATE_KEY)` or a Vapi web client constructed with the
  private key
- `LIVEKIT_API_SECRET` imported in a client bundle to mint tokens locally
- A Twilio Auth Token in a mobile app's build config used to fetch access tokens directly

#### High
- Deepgram Voice Agent `Settings` built in the browser with `functions[].endpoint.headers`
  carrying an API key
- OpenAI Realtime `session.update` sent from the client with server-side tool auth in it
- Provider secrets in `Info.plist`, `strings.xml`, or Expo `extra`

#### Medium
- A signed URL or short-lived token cached in `localStorage` past its validity
- Committed `.env.local` with a public-prefixed provider variable whose value is a placeholder

### NOT Vulnerable
- A vendor-designated public key (Vapi public key, ElevenLabs agent ID with `enable_auth` or an
  allowlist, LiveKit URL) shipped to the client — Pass, with a pointer to Cat 11 for its
  restriction settings
- A short-lived credential minted server-side and passed to the client per session: an OpenAI
  `ek_`-prefixed client secret, a LiveKit access token with grants and TTL, a Deepgram grant JWT,
  an ElevenLabs signed URL or conversation token, a Retell web-call access token, a Daily meeting
  token — quote the client read and the minting route (the route itself is Cat 04)
- A secret referenced only from server-marked files (`server/`, `api/`, `app/api/**/route.ts`,
  `'use server'`, `getServerSideProps`, Next.js server components with no `'use client'`
  ancestor) — Pass here and snitch-security's Cat 03 for its handling
- A public-prefix variable whose value is genuinely public (a project ID, a region, a public key)
- No client code in the workspace — Skip, `not applicable`, with the search

### Context Check
1. Which files are compiled into a client bundle? Read the framework's client/server boundary
   markers, not just directory names.
2. Is the key the vendor's public or private key? Check the name, the prefix (where the stack
   file documents one), and where the vendor's docs say it may live.
3. What does the client actually send to the provider: a long-lived key or a per-session
   credential?
4. If a credential is minted, is it scoped and short-lived, or a key by another name?
5. For mobile, what ends up in the shipped binary's config?

### Evidence Chain
- The secret reference file:line
- The build boundary: the marker or import chain that shows the file ships to the client
- The variable's definition (env file, config, build constant) with its value redacted
- For Pass rows: the minting route and the credential's TTL or scope, quoted

### Confidence Scoring
- **High**: a private-key-shaped credential is read in a file demonstrably compiled into the
  client, or a browser opt-in flag is set with a real key
- **Medium**: the file's client/server side depends on a build configuration not read, or the
  key's public/private nature is undocumented for that vendor
- **Low**: the bundle boundary could not be resolved — tag `needs human verification`

### Severity
Critical is a private credential the client ships: the account is the attacker's. High is a
narrower secret (a tool endpoint header, a mobile config constant) or one whose reach is limited
by scope. Medium is hygiene around minted credentials and committed placeholders. Low is not
used.

### Files to Check
- `src/**`, `app/**`, `components/**`, `pages/**`, `public/**`, `static/**`
- `ios/**`, `android/**`, `app.json`, `app.config.*`, `Info.plist`, `strings.xml`, `*.xcconfig`
- `.env*`, `next.config.*`, `vite.config.*`, `webpack.config.*`, `capacitor.config.*`
- `**/*voice*`, `**/*call*`, `**/*agent*`, `**/*conversation*` under client trees

### Reference
- CWE-798: Use of Hard-coded Credentials
- CWE-522: Insufficiently Protected Credentials
- CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
- Per-platform public-vs-private key design and client auth pattern: `references/stacks/<platform>.md`
