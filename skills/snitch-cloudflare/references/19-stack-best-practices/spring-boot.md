# Spring Boot on Cloudflare

Verdict: `proxy-only` (JVM doesn't run on Workers; Containers beta eventual). Pattern: Spring on its host + CF in front + Tunnel; `/actuator`, `/admin`, `/swagger-ui`, `/h2-console` behind Access.

`stack-docs spring-boot`.

## Cloudflare-specific

Trust proxy headers:

```yaml
server:
  forward-headers-strategy: native
```

## Actuator lockdown

`/actuator/env` exposing `SPRING_DATASOURCE_PASSWORD` is the classic compromise.

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info        # NOT *
  endpoint:
    health:
      show-details: never
    env:
      keys-to-sanitize: ["password","secret","key","token","credential"]
```

Put behind Access regardless.

## H2 console

`/h2-console` enabled in prod = direct DB shell. Disable in prod profile.

## Cookies / CSRF

Cookie config: `secure: true`, `http-only: true`, `same-site: lax`. CSRF default for state-changing requests; cookie-based with `CookieCsrfTokenRepository.withHttpOnlyFalse()` for SPA backends. Disabling CSRF only safe with token-auth.

## CSP / HSTS

CF Transform Rules at edge are simpler; in-app, `headers(h -> h.contentSecurityPolicy(...).httpStrictTransportSecurity(...))`. Don't double-set HSTS.

## CVEs

- Log4Shell — log4j-core < 2.17.1 → FAIL.
- Spring4Shell — Spring < 5.3.18 / 5.2.20 → FAIL.

## CF tips

- Cache `/static/**` long TTL via Cache Rules.
- WS / SSE: CF default 100s timeout, configurable up to ~24h on Pro+.
- HTTP/3 transparent to Kestrel/Tomcat.

## Skill targets

- `forward-headers-strategy: native`: FAIL if missing.
- Actuator exposure restricted to `health,info`: FAIL if `*`.
- `health.show-details: never`: FAIL otherwise.
- `/h2-console` disabled in prod: FAIL otherwise.
- Log4j ≥ 2.17.1; Spring patched: FAIL otherwise.
- Origin reachable only from CF: FAIL otherwise.
- `/actuator/*` behind Access: WARN.
