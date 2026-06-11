# Go on Fly.io

Excellent fit. Single static binary, minimal Dockerfile, millisecond boot.

## Dockerfile

```dockerfile
FROM golang:1.22 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/app ./cmd/server

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /out/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
```

`FROM scratch` if you don't need shell/certs/debug tools.

## fly.toml essentials

```toml
[env]
  PORT = "8080"
  GO_ENV = "production"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true

  [[http_service.checks]]
    grace_period = "5s"     # Go boots fast
    interval = "30s"
    path = "/health"
```

## Real client IP

Most Go HTTP libs don't auto-trust proxies. Use `Fly-Client-IP`:

```go
func realIP(next http.Handler) http.Handler {
  return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    if ip := r.Header.Get("Fly-Client-IP"); ip != "" {
      r.RemoteAddr = ip
    }
    next.ServeHTTP(w, r)
  })
}
```

## Graceful shutdown

```go
srv := &http.Server{Addr: ":" + os.Getenv("PORT"), Handler: handler}
go srv.ListenAndServe()

stop := make(chan os.Signal, 1)
signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
<-stop

ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
srv.Shutdown(ctx)
```

## Health endpoint

```go
http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
  if err := db.PingContext(r.Context()); err != nil {
    http.Error(w, "db: "+err.Error(), 503)
    return
  }
  w.WriteHeader(200)
})
```

## DB pool

```go
db.SetMaxOpenConns(10)
db.SetMaxIdleConns(5)
db.SetConnMaxLifetime(5 * time.Minute)
```

Match `max_open` to `max_connections / num_machines` budget.

## Common mistakes

| Mistake | Cost |
|---|---|
| `CGO_ENABLED=1` with native deps | Larger image, more attack surface. |
| No graceful shutdown | In-flight requests die. |
| Trusting `r.RemoteAddr` for client IP | That's Fly's proxy IP. |
| Hardcoded port | Mismatch with `internal_port`. |
| Logging request bodies in prod | Secret leaks. |
