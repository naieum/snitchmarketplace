# Rails on Railway

Railway is one of the cleanest Rails homes. Nixpacks detects `Gemfile.lock`, runs `bundle install`, starts `rails server`.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "bundle exec rails server -b 0.0.0.0 -p $PORT",
    "healthcheckPath": "/up",
    "numReplicas": 2
  }
}
```

Rails 7.1+ ships `/up` as default health endpoint.

## Hardening (`config/environments/production.rb`)

```ruby
config.force_ssl = true
config.ssl_options = {
  hsts: { expires: 1.year, subdomains: true, preload: true },
  redirect: { exclude: ->(request) { request.path == '/up' } }
}

# Trust the Railway proxy
config.action_dispatch.trusted_proxies = [
  IPAddr.new('0.0.0.0/0')  # Railway's proxy is internal; trust forwarded headers
]
```

## Patterns

- Sidekiq: separate Railway service, same Postgres + Redis services.
- ActiveStorage: configure S3 (R2-compatible); volumes won't survive replica scaling.
- ActionCable: public domain (wss://). Don't use TCP proxy.

## Docs

- https://guides.rubyonrails.org/security.html
- https://docs.railway.com/guides/rails
