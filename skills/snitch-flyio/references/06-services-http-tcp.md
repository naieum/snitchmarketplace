# 06 — HTTP and TCP services

Service-block config: TLS termination, force_https, ports, concurrency, internal vs public. (Machine lifecycle and health-check semantics live in `03-machines-and-apps.md`.)

## `[http_service]` — recommended

Modern HTTP entry point. Handles TLS termination, h2/h3, force_https, auto-stop/start.

```toml
[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 0
  processes = ["app"]

  [[http_service.checks]]
    grace_period = "10s"
    interval = "30s"
    method = "GET"
    timeout = "5s"
    path = "/health"

  [http_service.concurrency]
    type = "connections"
    hard_limit = 200
    soft_limit = 150
```

| Setting | Recommended | Why |
|---|---|---|
| `force_https` | `true` | Reject plain HTTP. Always. |
| `auto_stop_machines` | `"stop"` (idle) or `"off"` (always-on) | Save on idle. `"suspend"` wakes faster. |
| `auto_start_machines` | `true` | First request wakes a stopped machine. |
| `min_machines_running` | `0` (dev) / `>=1` (prod) | `0` saves money; `>=1` avoids cold-start tax. |
| Concurrency `hard_limit` | per-machine reasonable max | Above this, requests fail fast instead of queuing. |

## `[[services]]` — explicit / TCP

Older, more flexible. Use for TCP or non-HTTP protocols.

```toml
[[services]]
  protocol = "tcp"
  internal_port = 5432

  [[services.ports]]
    port = 5432

  [[services.tcp_checks]]
    interval = "15s"
    timeout = "2s"
    grace_period = "10s"
```

**Public TCP is dangerous** — anyone can `psql` to your DB without app-layer IP allowlisting. For internal Postgres, omit `[[services.ports]]` entirely; reach via 6PN at `<app>.internal:5432`.

## Internal-only services

Pattern for a private API:

```toml
# NO [http_service] block. NO [[services.ports]] block.
# Reachable only at <app>.internal:8080 from other apps in the org.

[[vm]]
  size = "shared-cpu-1x"
  memory = "256mb"

[[restart]]
  policy = "on-failure"
```

## TLS termination

Fly terminates TLS at the proxy. Inside the machine, plain HTTP on `internal_port`. The proxy injects:

| Header | Contents |
|---|---|
| `X-Forwarded-For` | Original client IP. |
| `X-Forwarded-Proto` | `https` or `http`. |
| `Fly-Client-IP` | Fly's preferred header. |

Trust the proxy in your framework:

| Framework | Setting |
|---|---|
| Rails | `config.force_ssl = true` |
| Express | `app.set('trust proxy', 1)` |
| Fastify | `trustProxy: true` |
| Flask | `werkzeug.middleware.proxy_fix.ProxyFix(app.wsgi_app, x_for=1, x_proto=1)` |

## What `state services <app>` returns

Digest exposes `force_https`, `auto_stop_machines`, `min_machines_running`, http_checks count, plus services with their protocols and internal ports. Verify:

| Check | Failure mode |
|---|---|
| `force_https: true` | Otherwise FAIL. |
| No `public_tcp` for internal services | Otherwise public exposure. |
| `internal_only` apps lack public ports | Confirms private. |

## Common mistakes

| Mistake | Cost |
|---|---|
| `force_https = false` from dev habit | Production needs `true`. |
| `[[services.ports]]` on Postgres | Exposes `psql` to public internet. |
| Long `grace_period` (5+ min) | Bad machines stay in rotation. |
| No concurrency `hard_limit` | Slow client pins all worker threads. |
| Trusting `X-Forwarded-For` without trust-proxy setup | Spoofed client IPs. |
