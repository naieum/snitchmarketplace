# Fastify on DigitalOcean

Verdict: `fit-matrix fastify`. Docs: `stack-docs fastify`.

## Landing

App Platform Node service / Droplet + Docker / DOKS.

## Hardening

- `@fastify/helmet`.
- `@fastify/rate-limit` backed by Redis.
- `@fastify/cors` with explicit origin allowlist.
- `@fastify/cookie` with `signed: true` and a strong `secret`.
- Session: `@fastify/session` with `connect-redis` store.
- HTTP/2 supported natively; enable for high-fanout APIs.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | No `@fastify/helmet` |
| 🔴 FAIL | No rate limit |
| 🔴 FAIL | Memory-only sessions multi-instance |
| 🔴 FAIL | Multipart uploads streaming to disk on App Platform (use Spaces multipart) |
