# Fastify on Cloudflare

Verdict + caveats: `fit-matrix fastify`. Framework docs: `stack-docs fastify`.

Default path: keep Fastify on origin, Cloudflare in front. Workers port story identical to Express — port to Hono rather than forcing Fastify through `nodejs_compat`.

## Cloudflare-specific

- `Fastify({ trustProxy: true })` — without it, `request.ip` is the local proxy IP. With CF in front this is FAIL. Tighten to CF CIDRs: `trustProxy: ["10.0.0.0/8", ...cloudflareCIDRs]`. https://fastify.dev/docs/latest/Reference/Server/#trustproxy
- `bodyLimit` set explicitly (Fastify default is 1 MB; verify). WARN if missing or `Infinity`.
- Origin reachable only from Cloudflare. FAIL if 443/80 open.
- `@fastify/cors` with explicit `origin`, never `"*"` + credentials.
- Use `CF-Connecting-IP` for true client IP.

## JSON Schema validation

Built-in schema validation is the security backbone. `additionalProperties: false` is load-bearing — without it, attackers stuff extra fields. WARN if any POST route omits it.

## Plugin notes for CF migration

- `fastify-multipart` → R2 presigned URLs.
- `@fastify/static` → serve static via Pages, not Fastify.
- `@fastify/redis` → TCP sockets or Upstash HTTP.

## Origin posture

- `@fastify/helmet` with full directives. WARN if missing.
- Cookie/session flags `secure` + `httpOnly` + `sameSite`. FAIL if missing.
- `pino` for logs; never log full request bodies in prod.
- Node 20+.

## Skill targets

- `trustProxy: true` (or CF CIDRs) when CF in front: FAIL otherwise.
- `bodyLimit` reasonable: WARN if missing.
- Schema `additionalProperties: false` on POST: WARN otherwise.
- `@fastify/cors` explicit `origin`: FAIL if `*` + credentials.
- Cookie flags: FAIL if missing.
- Origin reachable only from CF: FAIL otherwise.
- `@fastify/helmet`: WARN if missing.
