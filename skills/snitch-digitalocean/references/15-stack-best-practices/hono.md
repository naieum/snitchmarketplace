# Hono on DigitalOcean

Verdict: `fit-matrix hono`. Docs: `stack-docs hono`.

## Landing

| Option | When |
|---|---|
| DigitalOcean Functions | Tiny request handlers |
| App Platform Node service | Hono on Node adapter |
| DOKS | Scaled-out HTTP services |

## Hardening

- `secureHeaders()` middleware (Hono's built-in helmet).
- `cors()` with explicit origin allowlist.
- `csrf()` on POST routes that mutate state.
- Functions cold-start ~hundreds of ms — keep handlers warm via scheduled pings if latency-critical.
- App Platform: `type: SECRET` envs.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | No `secureHeaders()` |
| 🔴 FAIL | Long-running compute in a Function (15min limit + cold starts) |
| 🟡 WARN | `cors({origin: '*'})` |
