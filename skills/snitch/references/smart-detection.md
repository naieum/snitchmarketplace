# Smart Detection Logic (Quick Scan - Option 1)

Quick Scan always includes: Categories 1, 2, 3, 4

Then adds categories based on detected dependencies:

## Detection Method
1. Read `package.json` (or equivalent for other languages)
2. Parse dependencies and devDependencies
3. Check for security-relevant packages

## Advanced Validation Signals (Quick Scan Add-On)

Quick Scan also emits **Validation Signals** when relevant tech/features are detected.
These are evidence-backed assurance checks that complement findings without changing
the selected category set or scan mode naming.

Validation signal rules:
- Only emit a signal when you have direct code/config evidence (file + line).
- Use status: `pass`, `warn`, or `fail`.
- Keep signals scoped to selected categories.
- If a signal proves a concrete vulnerability, report it as a regular finding too.
- Never invent a signal from assumptions; no evidence means no signal.

Signal IDs and intent:
- `VS-001` Reproducibility Hooks — verify security-relevant tests/replay scripts exist for risky paths
- `VS-002` Negative Testing Coverage — verify adversarial/error-path tests exist where applicable
- `VS-003` Fix Verification Path — verify CI/local checks re-run security checks after code changes
- `VS-004` Patch Safety — detect superficial "fixes" that hide symptoms without mitigation
- `VS-005` Sensitive Flow Traceability — verify logging/trace points exist on critical auth/data paths
- `VS-006` Runtime Guardrails — verify runtime limits/kill-switches/timeouts on risky integrations

## Dependency -> Category Mapping

**Always Add:**
- Category 1 (SQL Injection) - if any database package found
- Category 2 (XSS) - if any frontend framework found
- Category 3 (Hardcoded Secrets) - always
- Category 4 (Authentication) - if any auth package found
- Category 12 (Logging and Data Exposure) - always (any project can log sensitive data)

**Conditional Adds:**

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

Found `@aws-sdk/*`, `@google-cloud/*`, or `@azure/*`:
- Add Category 11 (Cloud Security)

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

Found Keywords: `audit`, `logging`, `compliance`, `mfa`:
- Add Category 21 (SOC 2)

Found Keywords: `card`, `payment`, `stripe`, `cvv`, `pan`:
- Add Category 22 (PCI-DSS)

Found Keywords: `consent`, `gdpr`, `data-export`, `data-delete`:
- Add Category 23 (GDPR)

Found Keywords: `fips`, `fips140`, `nist`, `cipher`, `tls_min`, `openssl`:
- Add Category 34 (FIPS / Cryptographic Compliance)

Found Keywords: `iso27001`, `fedramp`, `cmmc`, `govcloud`, `cui`, `nist800`, `ato`:
- Add Category 35 (Governance Certifications)

Found any React/Vue/Angular framework or any database package (`@prisma/client`, `drizzle-orm`, `pg`, `mysql2`, `mongoose`):
- Add Category 24 (Memory Leaks)

Found any ORM (`@prisma/client`, `drizzle-orm`, `typeorm`, `sequelize`, `mongoose`):
- Add Category 25 (N+1 Queries)

Found any web framework/ORM (`next`, `express`, `fastify`, `@prisma/client`, `drizzle-orm`) or `lodash` or `moment`:
- Add Category 26 (Performance Problems)

**Always Add:**
- Category 27 (Dependency Vulnerabilities) - applies to every project with a package manifest
- Category 33 (Unused Dependencies & Bloat) - applies to every project with a package manifest

Found any auth/database/API route package (`next-auth`, `@clerk/nextjs`, `@auth0/nextjs-auth0`, `@prisma/client`, `drizzle-orm`, `express`, `fastify`):
- Add Category 28 (Authorization & Access Control / IDOR)

Found `multer`, `formidable`, `busboy`, or `@uploadthing/*`:
- Add Category 29 (File Upload Security)

Found any web framework (`next`, `express`, `fastify`, `koa`, `hono`):
- Add Category 30 (Input Validation & ReDoS)

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

Found `package.json` with `dependencies`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, or any lockfile:
- Add Category 41 (License Compliance)

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

Any project with secrets, API keys, or credentials in environment variables:
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

Found cloud SDKs (`@aws-sdk/*`, `@google-cloud/*`, `@azure/*`) OR any outbound HTTP client (`fetch`, `axios`, `got`, `node-fetch`, `undici`, `requests`, `httpx`) used with any user-influenced URL:
- Add Category 64 (Cloud Metadata Exploitation)

Found deserialization modules for non-JSON formats (`js-yaml`, `yaml`, `jackson-databind`, `Newtonsoft.Json` with TypeNameHandling, `BinaryFormatter`, Python `pickle`/`dill`/`shelve`, Ruby `Marshal`, PHP `unserialize`):
- Add Category 65 (Insecure Deserialization)

Any project with a package manifest / lockfile:
- Add Category 66 (Typosquatting & Malicious Install Scripts)

Any JavaScript, TypeScript, PHP, Python, or Ruby project with auth, password, token, or role-comparison code:
- Add Category 67 (Type Coercion Bypasses)

Found AI SDKs + agent/tool-use frameworks — npm and PyPI names mixed, match either (`@anthropic-ai/sdk` / `anthropic`, `openai`, `ai`, `@ai-sdk/*`, `@google/genai` / `google-genai`, `@google/generative-ai` / `google-generativeai` (both superseded, still deployed), `langchain`, `@langchain/core`, `langgraph`, `llamaindex` / `llama-index`, `@mastra/core`, `crewai`, `autogen`, `pydantic-ai`, `@anthropic-ai/claude-agent-sdk` / `claude-agent-sdk`, `@openai/agents` / `openai-agents`, `@modelcontextprotocol/sdk` / `mcp`) combined with a vector DB (`pinecone`, `@pinecone-database/pinecone`, `weaviate`, `chromadb`, `pgvector`, `@cloudflare/vectorize`) OR a `tools:` array / function-calling pattern:
- Add Category 68 (Agent & Indirect Prompt Injection)

## Validation Signal Activation (Auto in Quick Scan)

Trigger VS checks when relevant patterns are detected:
- `VS-001` if test folders/scripts exist and categories 1, 4, 5, 15, 17, 28, 29, 30, 39, or 40 are selected
- `VS-002` if any test framework is found (`jest`, `vitest`, `mocha`, `pytest`, `go test`) and risky categories are selected
- `VS-003` if `.github/workflows` or other CI config exists
- `VS-004` if prior findings are fixed in this session or patch-like changes are present
- `VS-005` if categories 4, 12, 20, 21, 22, 23, 37, or 38 are selected
- `VS-006` if categories 5, 7, 15, 31, 36, 37, or 40 are selected

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
69 active categories are cross-cutting and stack-agnostic).

## Example Output

```
Quick Scan selected.
Detected tech stack: Next.js, Prisma, Stripe, Supabase
Selected categories: 1, 2, 3, 4, 6, 13, 17 (7 categories)
Starting scan...
```
