# Elixir / Phoenix on Railway

Nixpacks supports Elixir via `mix release`. Phoenix runs cleanly with WebSockets, channels, OTP supervision.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "_build/prod/rel/yourapp/bin/yourapp start",
    "healthcheckPath": "/api/health",
    "numReplicas": 2
  }
}
```

## Hardening (`config/runtime.exs`)

```elixir
import Config

config :yourapp, YourAppWeb.Endpoint,
  url: [host: System.get_env("RAILWAY_PUBLIC_DOMAIN", "localhost"), port: 443, scheme: "https"],
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  force_ssl: [hsts: true, expires: 31_536_000, subdomains: true, preload: true],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true
```

## Patterns

- Phoenix Channels (WebSockets): public HTTPS domain (wss://). Don't use TCP proxy.
- libcluster: each Railway service has `<service>.railway.internal` — use `Cluster.Strategy.DNSPoll`.
- Long-lived processes survive across deploys until graceful shutdown — handle SIGTERM in supervisor tree.

## Docs

- https://hexdocs.pm/phoenix/overview.html
- https://docs.railway.com/guides/phoenix
