# Rails on Fly.io

Rails 7.1+ ships a Fly-friendly Dockerfile. Older versions: `fly launch` generates one. Pair with Fly Postgres or Managed Postgres.

## fly.toml essentials

```toml
[env]
  RAILS_ENV = "production"
  RAILS_LOG_TO_STDOUT = "1"
  RAILS_SERVE_STATIC_FILES = "1"
  PORT = "3000"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1
  processes = ["app"]

  [[http_service.checks]]
    grace_period = "20s"
    interval = "30s"
    path = "/up"     # Rails 7.1+; older needs a route

[processes]
  app = "bin/rails server"
  worker = "bundle exec sidekiq"

[deploy]
  release_command = "bin/rails db:prepare"
```

## Secrets

```sh
fly secrets set \
  SECRET_KEY_BASE=$(rails secret) \
  RAILS_MASTER_KEY=$(cat config/master.key) \
  -a <app>
```

`fly postgres attach <db> -a <app>` adds `DATABASE_URL` to fly secrets.

## ActionCable / WebSockets

```sh
fly redis create --name myapp-cable
fly secrets set REDIS_URL=$(fly redis status myapp-cable --json | jq -r '.private_url') -a <app>
```

Use `private_url` (rediss://). Set `config.action_cable.allowed_request_origins`.

## Trust the proxy

```ruby
# config/environments/production.rb
config.force_ssl = true
```

Default Fly proxy ranges are honored; explicit `trusted_proxies` only needed in unusual setups.

## Sidekiq

Separate process_group; scale independently:

```sh
fly scale count app=2 worker=1 -a <app>
```

## Active Storage / Tigris

`fly storage create` provisions bucket + sets AWS_* secrets. `config/storage.yml`:

```yaml
tigris:
  service: S3
  endpoint: https://fly.storage.tigris.dev
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: auto
  bucket: <%= ENV['BUCKET_NAME'] %>
```

## Common mistakes

| Mistake | Cost |
|---|---|
| `RAILS_MASTER_KEY` in [env] | Leaks `credentials.yml.enc`. |
| Missing `release_command` | Migrations don't run. |
| Web + Sidekiq in same process_group | OOM kills both. |
| `min_machines_running = 0` | Cold-start tax on every-request paths. |
| Forgetting `REDIS_URL` for ActionCable in prod | Channels break. |
