# Rust on Railway

Nixpacks detects `Cargo.toml`, builds release, runs the binary.

## Build perf

For iteration speed, Dockerfile with `cargo-chef`:

```dockerfile
FROM rust:1.83-alpine AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/target/release/server /usr/local/bin/server
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/server"]
```

## railway.json

```json
{
  "build": { "builder": "DOCKERFILE" },
  "deploy": {
    "startCommand": "/usr/local/bin/server",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening (axum/tower-http)

```rust
use tower_http::set_header::SetResponseHeaderLayer;
use http::header;

let app = Router::new()
  .route("/health", get(|| async { "ok" }))
  .layer(SetResponseHeaderLayer::overriding(
    header::STRICT_TRANSPORT_SECURITY,
    HeaderValue::from_static("max-age=31536000; includeSubDomains; preload"),
  ))
  .layer(SetResponseHeaderLayer::overriding(
    header::X_CONTENT_TYPE_OPTIONS,
    HeaderValue::from_static("nosniff"),
  ));
```

## Docs

- https://rustsec.org/advisories/
- https://docs.railway.com/guides/rust
