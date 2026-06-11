# Phoenix / Elixir on Fly.io

Fly is the BEAM's natural home: long-lived processes, native distributed clustering, low-latency 6PN. `fly launch` recognizes mix projects and bakes a release.

## fly.toml essentials

```toml
[env]
  PHX_HOST = "myapp.fly.dev"
  PORT = "8080"
  # SECRET_KEY_BASE in fly secrets, not [env]

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1   # keep one warm for LiveView reconnects

  [[http_service.checks]]
    grace_period = "20s"     # BEAM boot is slower than Node
    interval = "30s"
    method = "GET"
    timeout = "5s"
    path = "/health"

[deploy]
  release_command = "/app/bin/migrate"
```

## Clustering

`<app>.internal` resolves to all running machines via 6PN — perfect for libcluster.DNSPoll:

```elixir
# config/runtime.exs
config :libcluster,
  topologies: [
    fly: [
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        polling_interval: 5_000,
        query: "#{System.get_env("FLY_APP_NAME")}.internal",
        node_basename: System.get_env("FLY_APP_NAME")
      ]
    ]
  ]
```

## Erlang cookie

Cluster nodes need a shared cookie. Fly secret, not [env]:

```sh
fly secrets set RELEASE_COOKIE=$(openssl rand -hex 32) -a <app>
```

Reference in `rel/env.sh.eex`:

```sh
export RELEASE_COOKIE="${RELEASE_COOKIE}"
```

## SECRET_KEY_BASE

```sh
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret) -a <app>
```

## Postgres

Managed Postgres or legacy Fly Postgres. Same region as the Phoenix app. Connection string in `DATABASE_URL` secret.

## LiveView

| Concern | Resolution |
|---|---|
| WebSocket reconnects on deploy | Rolling deploy briefly drops; LiveView reconnects automatically. |
| Cold start drops users | `min_machines_running = 1`. |
| Channel state | Put in `:ets` / `:persistent_term` / Postgres / Redis — NOT process state if you want survivability across deploys. |

## Common mistakes

| Mistake | Cost |
|---|---|
| `[env] DATABASE_URL=...` | Secret leaks into git. |
| No `release_command` | Migrations don't run on deploy. |
| `min_machines_running = 0` for LiveView | Cold start drops users. |
| Cluster cookie in [env] | Anyone with repo access joins your cluster. |
| Forgetting `runtime.exs` for env config | Release won't pick up Fly env. |
