# 03 — Machines and Apps

A **Machine** is a Firecracker VM. An **App** groups Machines sharing config, secrets, and networking. (HTTP/TCP service config lives in `06-services-http-tcp.md`.)

## Lifecycle

```sh
fly launch                                     # bootstraps app + Dockerfile + first Machine
fly deploy                                     # build + rolling release
fly machines list -a <app>
fly machines start|stop|destroy <id> -a <app>
fly machines clone <id> --region <r> -a <app>  # copy to another region
fly scale count <n> -a <app>
fly scale memory <mb> -a <app>
```

## Restart policies

```toml
[[restart]]
  policy = "on-failure"   # default for service machines
  retries = 10
```

| Policy | Use |
|---|---|
| `no` | One-shot jobs. |
| `on-failure` | Most services. |
| `always` | Dev only — loops on bad config. |

## Health checks

Single most important hardening. Without checks, Fly can't tell broken from working machines:

```toml
[[http_service.checks]]
  grace_period = "10s"
  interval = "30s"
  method = "GET"
  timeout = "5s"
  path = "/health"
```

`/health` should:

- Return 200 when ready to serve.
- Return 503 if a critical dependency (DB) is down — Fly stops routing.
- Be cheap — runs every `interval` per machine.

For TCP services, use `[[services.tcp_checks]]` (see `06-services-http-tcp.md`).

## Image pinning

Production pins by digest, not tag:

```toml
[build]
  image = "registry.fly.io/myapp@sha256:abc..."
```

Tags get overwritten; digests don't. Rollbacks become deterministic. `bash snitch-flyio.sh fix machines [app]` flags tag-only images as `WARN`.

## Rolling deploy

Default. Stops one machine, deploys new, starts, then next. Zero-downtime when `min_machines_running >= 1`.

For schema migrations:

```toml
[deploy]
  strategy = "rolling"
  release_command = "bin/migrate"
```

Release command runs in a temporary machine before the rolling deploy. Failure aborts.

## Process groups

Split web and worker:

```toml
[processes]
  app = "bundle exec puma"
  worker = "bundle exec sidekiq"
```

Then `fly scale count app=2 worker=1`. Each scales independently.

## What to audit

`bash snitch-flyio.sh state machines <app>` digest:

| Field | Watch for |
|---|---|
| `machines_summary.by_state` | `started` count matches expected. |
| `machines_summary.without_health_checks` | Should be zero. |
| `machines_summary.by_restart_policy` | Single bucket (`on-failure`) for services. |
| `machines_summary.with_volumes` | Cross-check with volumes inventory. |

## Common mistakes

| Mistake | Cost |
|---|---|
| No health checks | Broken machines stay in rotation. |
| `restart.policy = "always"` in prod | Crash-loop on bad config burns money. |
| Image by tag | Can't reproduce a deploy. |
| `min_machines_running = 0` for prod | First request after idle pays cold-start. |
| Web + worker in same process group | One OOM kills the worker job mid-flight. |
