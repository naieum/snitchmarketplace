# Crystal on Railway

Nixpacks supports Crystal. `crystal build src/main.cr --release` produces a fast native binary.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "./bin/server",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening (Kemal/Lucky/raw `HTTP::Server`)

```crystal
require "http/server"

server = HTTP::Server.new do |context|
  ctx = context.response
  ctx.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
  ctx.headers["X-Content-Type-Options"]    = "nosniff"
  ctx.headers["X-Frame-Options"]           = "DENY"
  ctx.headers["Referrer-Policy"]           = "strict-origin-when-cross-origin"

  if context.request.path == "/health"
    ctx.print "ok"
  else
    ctx.print "hello"
  end
end

port = ENV.fetch("PORT", "8080").to_i
server.bind_tcp("0.0.0.0", port)
server.listen
```

## Notes

- Pin compiler version in `nixpacks.toml`.
- Build is slow — Dockerfile route with caching helps on big projects.

## Docs

- https://crystal-lang.org/reference/
