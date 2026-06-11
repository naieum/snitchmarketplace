# Rust on Fly.io

Same shape as Go: single static binary, minimal Dockerfile, fast boot. axum / actix / hyper / poem all work.

## Dockerfile

```dockerfile
FROM rust:1.78 AS build
WORKDIR /src
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/target/release/myapp /app
EXPOSE 8080
ENTRYPOINT ["/app"]
```

For musl/static (smaller, `FROM scratch`-ready): build with `--target=x86_64-unknown-linux-musl`.

## fly.toml essentials

```toml
[env]
  PORT = "8080"
  RUST_LOG = "info"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true

  [[http_service.checks]]
    grace_period = "5s"
    interval = "30s"
    path = "/health"
```

## axum example

```rust
#[tokio::main]
async fn main() {
    let port: u16 = std::env::var("PORT").unwrap_or("8080".to_string()).parse().unwrap();
    let app = Router::new()
        .route("/health", get(|| async { "ok" }))
        .route("/", get(|| async { "Hello, Fly!" }));
    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .with_graceful_shutdown(async { let _ = signal::ctrl_c().await; })
        .await
        .unwrap();
}
```

## Real client IP

```rust
fn client_ip(headers: &HeaderMap) -> Option<&str> {
    headers.get("fly-client-ip")
        .or_else(|| headers.get("x-forwarded-for"))
        .and_then(|v| v.to_str().ok())
}
```

## DB pool (sqlx)

```rust
let pool = sqlx::postgres::PgPoolOptions::new()
    .max_connections(10)
    .connect(&std::env::var("DATABASE_URL")?)
    .await?;
```

## Common mistakes

| Mistake | Cost |
|---|---|
| Building inside the runtime image | Larger images, slower deploys. |
| `cargo run --release` in entrypoint | Recompiles every boot. Use the binary. |
| Forgetting `with_graceful_shutdown` | In-flight requests die. |
| `rust-musl` + `openssl-sys` conflict | Use `rustls` or `vendored-openssl`. |
| `FROM scratch` without `ca-certificates` | Outbound HTTPS fails. |
