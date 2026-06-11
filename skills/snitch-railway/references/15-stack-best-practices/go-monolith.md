# Go monolith on Railway

Nixpacks detects `go.mod`, builds the binary, runs it. Tiny image, fast cold start.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "./out/server",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

For more control, Dockerfile:

```dockerfile
FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /out/server ./cmd/server

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /out/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

## Hardening (`net/http`)

```go
mux := http.NewServeMux()
mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
    w.WriteHeader(200)
})

handler := securityHeaders(mux)

addr := ":" + os.Getenv("PORT")
srv := &http.Server{
    Addr:              addr,
    Handler:           handler,
    ReadHeaderTimeout: 10 * time.Second,
    ReadTimeout:       30 * time.Second,
    WriteTimeout:      30 * time.Second,
    IdleTimeout:       60 * time.Second,
}

func securityHeaders(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload")
        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
        next.ServeHTTP(w, r)
    })
}

log.Fatal(srv.ListenAndServe())
```

## Docs

- https://go.dev/doc/security/best-practices
- https://docs.railway.com/guides/go
