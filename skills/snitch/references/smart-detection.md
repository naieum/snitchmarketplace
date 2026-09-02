# Smart Detection Logic (mode `quick`)

## Detection Method
1. Read `package.json` (or equivalent for other languages)
2. Parse dependencies and devDependencies
3. Check for security-relevant packages

## Selecting the set — 5 to 10 categories, and the cap is real

The triggers below are candidates, not the answer. On a real stack far more of them fire than a
quick scan can carry, so the set is built and then cut:

1. **Start with `quick-core`** — every row in `categories/_index.md` whose `Groups` column contains
   `quick-core`. Resolve it from the manifest; never from a number list written here.
2. **Add every trigger below that fires** on the detected dependencies, files, and keywords.
3. **Drop anything not `active`.** Merged and deprecated rows never enter a quick scan, whatever
   number a trigger names.
4. **Cap at 10.** If more fired, rank and keep the top 10:
   - `quick-core` rows first — they are never cut
   - then `Type: sink-pattern` rows whose sink library is actually imported in source (not merely
     present in the manifest)
   - then `posture` rows for a service the project demonstrably integrates with (a Stripe key read,
     a Supabase client constructed, a Redis connection opened)
   - then everything else
   State which candidates the cap dropped and that mode `full` covers them. A quick scan that
   silently scans 22 categories is not a quick scan; one that hides the 12 it dropped is worse.
5. **Floor at 5.** If fewer than five fire, say so and offer `preset:web` or `full` rather than
   padding the set with categories nothing triggered.

## Validation Signals (mode `quick` only, and only when one fires)

Two signals survive: the ones that check a security control on a path the scan already cares
about. Test-assurance checks (does a replay script exist, is there a negative test, does this patch
look superficial) were dropped — they grade the codebase's testing practice, not its attack
surface, and this skill does not review code for anything but security.

Validation signal rules:
- Only emit a signal when you have direct code/config evidence (file + line).
- Use status: `pass`, `warn`, or `fail`.
- Keep signals scoped to selected categories.
- If a signal proves a concrete vulnerability, report it as a regular finding too.
- Never invent a signal from assumptions; no evidence means no signal.
- If neither signal fires, omit the Validation Signals section from the report entirely. An empty
  section is not evidence of anything.

Signal IDs and intent:
- `VS-005` Sensitive Flow Traceability — verify logging/trace points exist on critical auth/data paths
- `VS-006` Runtime Guardrails — verify runtime limits/kill-switches/timeouts on risky integrations

## Dependency -> Category Mapping

Every entry below is a **conditional** add, subject to the cap. `quick-core` is already in the set
before any of them is read, so nothing here re-adds it.

Found `stripe` or `@stripe/stripe-js`:
- Add Category 13 (Stripe Security)

Found `@supabase/supabase-js` or `@supabase/ssr`:
- Add Category 6 (Supabase Security)

Found any of these (npm and PyPI names are mixed — match either) — `openai`, `@anthropic-ai/sdk` / `anthropic`, `ai`, `@ai-sdk/openai`, `@langchain/core`, `langchain`, `@google/genai` / `google-genai`, `cohere-ai` / `cohere`, `@modelcontextprotocol/sdk` / `mcp`, `@anthropic-ai/claude-agent-sdk` / `claude-agent-sdk`, `@openai/agents` / `openai-agents`, `pydantic-ai`, `llamaindex` / `llama-index` — or the superseded Google SDKs `@google/generative-ai` (npm) / `google-generativeai` (PyPI), both deprecated in favour of the `genai` packages but still worth matching:
- Add Category 15 (AI API Security)

Found `resend`, `@sendgrid/mail`, or `postmark`:
- Add Category 16 (Email Services)

Found `@upstash/redis`, `ioredis`, or `redis`:
- Add Category 18 (Redis/Cache Security)

Found `twilio`:
- Add Category 19 (SMS/Communication)

Found `@clerk/nextjs`, `@auth0/nextjs-auth0`, or `next-auth`:
- Add Category 14 (Auth Providers)

Found `pg`, `mysql2`, `@prisma/client`, or `drizzle-orm`:
- Add Category 17 (Database Security)

Found `fetch`, `axios`, `got`, or `node-fetch`:
- Add Category 5 (SSRF)

Found any auth package (`jsonwebtoken`, `passport`, `next-auth`, `@clerk/nextjs`, `@auth0/nextjs-auth0`, `better-auth`, `express-session`):
- Add Category 7 (Rate Limiting)

Found any auth/session/JWT package (`jsonwebtoken`, `jose`, `next-auth`, `@auth/core`, `better-auth`, `@clerk/nextjs`, `@auth0/nextjs-auth0`, `express-session`, `iron-session`, `lucia`):
- Add Category 39 (Token & Session Lifetime Analysis)

Found `cors` package:
- Add Category 8 (CORS Configuration)

Found Keywords: `patient`, `medical`, `diagnosis`, `prescription`, `mrn`, `phi`:
- Add Category 20 (HIPAA)

**Compliance keyword triggers need two signals, matched as whole words.** A compliance category is
expensive and its keywords are ordinary English: `logging` is in nearly every repo, and `pan`
substring-matches `span` and `expand`. Match on word boundaries (`\bpan\b`), never on a bare
substring, and require **two distinct keywords from the same list** before adding the category. One
hit is a note in the detected-features metadata, not a selected category.

Found two or more of: `soc2`, `soc 2`, `trust services`, `control objective`, `evidence`, `mfa`,
`access review`:
- Add Category 21 (SOC 2)

Found two or more of: `pan`, `cvv`, `cvc`, `cardholder`, `card_number`, `pci`, `luhn`, `track2`:
- Add Category 22 (PCI-DSS)

Found two or more of: `consent`, `gdpr`, `dsar`, `data-export`, `data-delete`, `right to erasure`,
`lawful basis`, `processor`:
- Add Category 23 (GDPR)

Found Keywords: `fips`, `fips140`, `nist`, `cipher`, `tls_min`, `openssl`:
- Add Category 34 (FIPS / Cryptographic Compliance)

Found Keywords: `iso27001`, `fedramp`, `cmmc`, `govcloud`, `cui`, `nist800`, `ato`:
- Add Category 35 (Governance Certifications)

Found a lockfile plus either a direct dependency pinned to an open range (`*`, `latest`, `>=`) or an
install hook (`preinstall` / `postinstall` / `prepare`) in the project's own manifest:
- Add Category 27 (Dependency Vulnerabilities)

Found any auth/database/API route package (`next-auth`, `@clerk/nextjs`, `@auth0/nextjs-auth0`, `@prisma/client`, `drizzle-orm`, `express`, `fastify`):
- Add Category 28 (Authorization & Access Control / IDOR)

Found `multer`, `formidable`, `busboy`, or `@uploadthing/*`:
- Add Category 29 (File Upload Security)

Found any web framework (`next`, `express`, `fastify`, `koa`, `hono`) with a route reading a path or merging a request body:
- Add Category 30 (Input Validation)

Found `.github/workflows` directory exists:
- Add Category 31 (CI/CD Pipeline Security)

Found any web framework (`next`, `express`, `fastify`):
- Add Category 32 (Security Headers)

Found `opossum`, `cockatiel`, or patterns matching circuit breaker / retry / graceful shutdown:
- Add Category 36 (Business Continuity & Disaster Recovery)

Found `@sentry/node`, `@datadog/datadog-api-client`, `newrelic`, `prom-client`, `@opentelemetry/*`, `dd-trace`, `@grafana/*`:
- Add Category 37 (Infrastructure Monitoring & Observability)

Found `cron`, `node-cron`, `@upstash/qstash` with data cleanup patterns, or `ttl`, `retention`, `purge`, `anonymize` keywords:
- Add Category 38 (Data Classification & Lifecycle)

Found `ngrok`, `.ngrok2/`, `.ngrok/`, `NGROK_AUTHTOKEN` in env/config, or `cloudflared`, `.cloudflared/`, `TUNNEL_TOKEN`, `trycloudflare.com` URLs:
- Add Category 40 (Tunnels & DNS Security)

Found `wrangler.toml`, `wrangler.jsonc`, `.dev.vars`, `miniflare`, `CLOUDFLARE_API_TOKEN`, `CF_API_TOKEN`:
- Add Category 40 (Tunnels & DNS Security)

Found `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`, or any `*.Dockerfile`:
- Add Category 42 (Container & Docker Security)

Found `*.tf`, `*.tfvars`, Kubernetes manifests (`apiVersion` in YAML), or CloudFormation templates:
- Add Category 43 (Infrastructure as Code Security)

Found `openapi.yaml`, `swagger.json`, GraphQL schema files, or API route handlers with Express/Fastify/Next.js API routes:
- Add Category 44 (API Security)

Found `@modelcontextprotocol/sdk` in dependencies, or `SKILL.md` files, or `.cursor/`, `.copilot/`, or MCP server configurations:
- Add Category 45 (AI Tool Supply Chain Security)

Found any web framework with form handling (`next`, `express`, `fastify`, `django`, `flask`, `rails`, `laravel`), or `csurf`, `csrf`, `@fastify/csrf-protection`:
- Add Category 47 (CSRF)

Found payment/financial operations (`stripe`, `paypal`, `braintree`, `adyen`), inventory management, or concurrent write patterns:
- Add Category 48 (Race Conditions)

Found XML parsing libraries (`xml2js`, `fast-xml-parser`, `libxmljs`, `lxml`, `javax.xml`, `System.Xml`):
- Add Category 49 (XXE)

Found token/secret comparison, password verification, or HMAC comparison patterns:
- Add Category 50 (Timing Attacks)

Found debug/metrics endpoints (`/debug`, `/metrics`, `/health`, `/status`, `/pprof`, `express-debug`, `swagger-ui`):
- Add Category 51 (Debug Endpoints)

Found a signing-key or token-issuance surface that a source scan can actually read — a JWKS
endpoint or `kid` header, a configured token TTL, a KMS/Secrets Manager rotation setting in IaC, or
a dual-key (`*_KEY_CURRENT` / `*_KEY_PREVIOUS`) arrangement:
- Add Category 52 (Secrets Rotation)

Found California user data patterns, SOX compliance keywords (`ccpa`, `sox`, `sarbanes`, `california_consumer`, `financial_reporting`):
- Add Category 53 (CCPA/SOX)

Found OAuth/OIDC libraries (`passport-oauth2`, `openid-client`, `@auth0/*`, `oidc-provider`, `oauth2-server`):
- Add Category 54 (OAuth/OIDC)

Found Kubernetes/service mesh configs (`k8s`, `istio`, `envoy`, `linkerd`, `consul`), or microservice communication patterns:
- Add Category 55 (Microservices)

Found WebSocket libraries (`ws`, `socket.io`, `@fastify/websocket`, `websockets`, `ActionCable`):
- Add Category 56 (WebSocket Security)

Found GraphQL (`graphql`, `@apollo/server`, `type-graphql`, `nexus`, `pothos`, `graphql-yoga`):
- Add Category 57 (GraphQL Deep)

Found message queue libraries (`amqplib`, `kafkajs`, `@aws-sdk/client-sqs`, `bull`, `bullmq`, `nats`, `redis` with pub/sub):
- Add Category 58 (Message Queues)

Found backup scripts/configs, database dump utilities, or snapshot management patterns:
- Add Category 59 (Backup Security)

Found audit logging implementations, structured log libraries (`winston`, `pino`, `bunyan`), or compliance logging patterns:
- Add Category 60 (Audit Log Integrity)

Found any web framework or validator library (`validator`, `joi`, `zod`, `yup`, `class-validator`, `ajv`) with route handlers accepting free-form text:
- Add Category 61 (ReDoS)

Found Node/JS projects with merge utilities (`lodash`, `deepmerge`, `minimist`, `yargs-parser`, `set-value`, `mixin-deep`) or body parsers with nested-object expansion (`qs`, `express` with `extended: true`):
- Add Category 62 (Prototype Pollution)

Found JWT libraries (`jsonwebtoken`, `jose`, `jwt-decode`, `@fastify/jwt`, `pyjwt`, `python-jose`, `jjwt`, `golang-jwt/jwt`) or any OAuth/OIDC stack:
- Add Category 63 (JWT Algorithm & Key Attacks)

Found deserialization modules for non-JSON formats (`js-yaml`, `yaml`, `jackson-databind`, `Newtonsoft.Json` with TypeNameHandling, `BinaryFormatter`, Python `pickle`/`dill`/`shelve`, Ruby `Marshal`, PHP `unserialize`):
- Add Category 65 (Insecure Deserialization)

Found an install hook (`preinstall` / `postinstall` / `prepare`) in the project's own manifest or in a
direct dependency, or a direct dependency whose name is within edit-distance 1 of a popular package:
- Add Category 66 (Typosquatting & Malicious Install Scripts)

Found a loose equality or type-flexible comparison (`==`, `!=`, PHP `==`, Ruby `==` on mixed types)
inside auth, password, token, or role-comparison code in a JavaScript, TypeScript, PHP, Python, or
Ruby project:
- Add Category 67 (Type Coercion Bypasses)

Found AI SDKs + agent/tool-use frameworks — npm and PyPI names mixed, match either (`@anthropic-ai/sdk` / `anthropic`, `openai`, `ai`, `@ai-sdk/*`, `@google/genai` / `google-genai`, `@google/generative-ai` / `google-generativeai` (both superseded, still deployed), `langchain`, `@langchain/core`, `langgraph`, `llamaindex` / `llama-index`, `@mastra/core`, `crewai`, `autogen`, `pydantic-ai`, `@anthropic-ai/claude-agent-sdk` / `claude-agent-sdk`, `@openai/agents` / `openai-agents`, `@modelcontextprotocol/sdk` / `mcp`) combined with a vector DB (`pinecone`, `@pinecone-database/pinecone`, `weaviate`, `chromadb`, `pgvector`, `@cloudflare/vectorize`) OR a `tools:` array / function-calling pattern:
- Add Category 68 (Agent & Indirect Prompt Injection)

## Validation Signal Activation (Auto in Quick Scan)

Trigger VS checks when relevant patterns are detected:
- `VS-005` when any selected category is `Type: compliance`, or covers authentication or logging of
  sensitive data (resolve from the manifest's Type and Title columns, not a number list)
- `VS-006` when any selected category covers an outbound integration or a rate/consumption control

## Per-stack hardening references (load on stack detection)

When the detected stack matches one below, also read the matching `references/stacks/<name>.md`
before scanning. Each names that stack's real sink patterns, the framework auto-protections to
**not** flag, and a hardening checklist cross-referenced to the category numbers above — so
findings stay precise and framework defaults aren't reported as bugs.

| Detected stack | Load |
|---|---|
| `express` / bare Node `http` backend | `references/stacks/node-express.md` |
| `react` / `next` (esp. API routes, route handlers, Server Actions) | `references/stacks/react-next.md` |
| `django` (`settings.py`, `manage.py`) | `references/stacks/python-django.md` |
| `fastapi` | `references/stacks/python-fastapi.md` |
| `flask` | `references/stacks/python-flask.md` |
| Go (`go.mod`, `net/http`, `database/sql`) | `references/stacks/go.md` |
| Rails (`Gemfile` with `rails`, `config/application.rb`, `app/controllers/`) | `references/stacks/ruby-rails.md` |

**Fall back to file contents when the layout is not conventional.** Path-based triggers miss vendored, flattened, extracted, or partially-checked-out trees. Content signals that identify a stack on their own: `Rails::Application` / `ActionController::Base` / `ActiveRecord::Base` / `.html.erb` (Rails), `django.` imports or `DJANGO_SETTINGS_MODULE` (Django), `from fastapi import` (FastAPI), `require('express')` / `express()` (Express), `next/` imports or `"use client"` (Next.js), `package main` with `net/http` (Go). A stack file that does not load is worse than one that does not exist — the scan proceeds with the category rules alone, which is exactly the state the stack file was written to correct.

Load more than one when the repo spans stacks (e.g., a Next.js frontend + a Go service). If no
per-stack reference exists for the detected stack, proceed with the category guidance alone (the
62 active categories are cross-cutting and stack-agnostic).

## Example Output

The cap is what makes this honest — on this stack fourteen triggers fire and four get cut.

```
Quick Scan selected.
Detected tech stack: Next.js, Prisma, Stripe, Supabase
Selected categories: 1, 2, 3, 4, 6, 13, 17, 28, 32, 47 (10 of 14 candidates)
Dropped for the 10-category cap: 5, 30, 62, 63 — run a Full System Scan to cover them.
Starting scan...
```
