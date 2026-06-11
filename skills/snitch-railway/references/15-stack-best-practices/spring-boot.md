# Spring Boot on Railway

Nixpacks supports Maven and Gradle. For predictable builds, prefer a Dockerfile with multi-stage build.

## Dockerfile

```dockerfile
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY . .
RUN ./mvnw -B -DskipTests package

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## railway.json

```json
{
  "build": { "builder": "DOCKERFILE" },
  "deploy": {
    "startCommand": "java -jar app.jar",
    "healthcheckPath": "/actuator/health",
    "healthcheckTimeout": 60,
    "numReplicas": 2
  }
}
```

## Hardening (`application.properties`)

```properties
server.port=${PORT:8080}
server.address=0.0.0.0
server.use-forward-headers=true
server.forward-headers-strategy=NATIVE

management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=never

# Spring Security
spring.security.headers.hsts=ALL
spring.security.headers.frame-options=DENY
```

## Notes

- JVM cold-start matters at low traffic — production should be always-on (`sleepApplication: false`).
- Long `healthcheckTimeout` — JVM apps take 20–60s to warm up.

## Docs

- https://docs.spring.io/spring-boot/reference/features/spring-application.html
