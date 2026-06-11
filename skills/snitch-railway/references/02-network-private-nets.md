# Networking and private networks

Every Railway project has a private IPv6 network. Services talk directly without going through the public internet.

## Private networking

- Every service gets `<service-name>.railway.internal`.
- Listen on IPv6 `::` (or `0.0.0.0` for both stacks). Connect via `http://<service>.railway.internal:<port>`.
- Default for service-to-service traffic. Public domains add latency (DNS → CDN → back).

## When to use the public domain

| Case | Reason |
|---|---|
| User-facing client reaches the service | external traffic |
| Need public WAF / TLS termination | edge security |
| Cross-project | no shared private network |

## TCP proxies

Public TCP proxies expose a service on `<id>.proxy.rlwy.net:<port>`:

- Bypass HTTPS termination — raw TCP.
- Useful for: external DB access during migration, legacy clients without HTTPS.
- Dangerous: anything reachable here is a direct internet-facing port. Audit each one.

## Cross-project networking

Cross-project private networking is in flight. Today, services in different projects must use public domains. Co-locate services that share infrastructure (Postgres used by multiple frontends) in one project.

## Recommendations

- Default service-to-service traffic to `*.railway.internal`.
- Treat every public TCP proxy as a finding to justify.
- Set strong `Host` validation in publicly exposed services — Railway forwards the public domain in `Host`.

## Docs

- https://docs.railway.com/guides/private-networking
- https://docs.railway.com/guides/public-networking
