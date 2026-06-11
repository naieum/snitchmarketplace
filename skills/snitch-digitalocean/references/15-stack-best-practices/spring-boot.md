# Spring Boot on DigitalOcean

Verdict: `fit-matrix spring-boot`. Docs: `stack-docs spring-boot`.

## Landing

| Option | When |
|---|---|
| Droplet + systemd / Docker | Full JVM tuning control |
| DOKS | Scaled-out |
| App Platform Java buildpack | Works; heap tuning is more flexible on Droplets |

## Hardening

- `application-prod.properties` separate from default.
- `server.error.include-stacktrace=never`, `server.error.include-message=never`.
- Spring Security: `requireSecure()`, CSRF for stateful, JWT verification for stateless.
- DB: `spring.datasource.url=jdbc:postgresql://...?sslmode=require`.
- Actuator: bind `/actuator/*` to internal port OR require admin role.
- Terminate HTTPS at App Platform / LB; behind it use HTTP. `server.use-forward-headers=true`.
- Heap: Droplet/Pod size ≥ 2x `-Xmx`. Use `+UseContainerSupport`.
- Spring Boot Admin: never expose without auth.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | Actuator endpoints exposed without auth |
| 🔴 FAIL | `spring.datasource.url` without `sslmode=require` |
| 🟡 WARN | Stack trace leaking on error pages |
| INFO | `-Xmx` unset (uses 25% container memory by default) |
