# Spring Boot on Fly.io

JVM apps on Fly Machines. Use Eclipse Temurin (or Liberica) base. Tune `-Xmx` to leave 20% headroom.

## Dockerfile

```dockerfile
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY . .
RUN ./gradlew bootJar -x test

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /src/build/libs/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/app.jar"]
```

`-XX:MaxRAMPercentage=75` makes `-Xmx` proportional to machine memory.

## fly.toml essentials

```toml
[env]
  SPRING_PROFILES_ACTIVE = "prod"
  SERVER_PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1     # JIT cold-starts are slow

  [[http_service.checks]]
    grace_period = "30s"       # JVM boot is the slowest
    interval = "30s"
    path = "/actuator/health"

[[vm]]
  size = "shared-cpu-1x"
  memory = "1024mb"            # 256mb is too small
```

## Spring config

```yaml
server:
  port: 8080
  forward-headers-strategy: native    # honor X-Forwarded-*

management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      show-details: never              # don't leak internals
```

## Secrets

```sh
fly secrets set \
  SPRING_DATASOURCE_URL="jdbc:postgresql://..." \
  SPRING_DATASOURCE_USERNAME=appuser \
  SPRING_DATASOURCE_PASSWORD="..." \
  -a <app>
```

## DB pool

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
```

`(machines × pool-size) ≤ Postgres max_connections`.

## Common mistakes

| Mistake | Cost |
|---|---|
| 256MB memory | JVM OOMs constantly. Use ≥ 1GB. |
| `min_machines_running = 0` | Cold-start = JIT/JVM boot tax. |
| Default `-Xmx` (no flag) | JVM ignores cgroup memory; OOM-killer fires. |
| `/actuator/health` exposing details | Leaks DB hostnames etc. |
| Missing `forward-headers-strategy: native` | Spring sees scheme = http. |
