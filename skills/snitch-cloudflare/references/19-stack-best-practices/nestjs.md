# NestJS on Cloudflare

Verdict + caveats: `fit-matrix nestjs`. Framework docs: `stack-docs nestjs`.

Default path: keep Nest on origin, CF in front (Tunnel + WAF). Workers port theoretically possible under `nodejs_compat` but DI container + decorator stack inflates bundle and cold start; if rewriting, port to Hono / Workers-native.

## Cloudflare-specific

- `app.set("trust proxy", true)` (Express adapter) or Fastify-adapter equivalent. Without it, `req.ip` is wrong with CF in front. FAIL otherwise.
- Origin reachable only from Cloudflare. FAIL if 443/80 open.
- `app.enableCors({ origin: ["https://example.com"], credentials: true })` — never `*` + credentials.
- Stack traces stripped in prod (`AllExceptionsFilter` doesn't echo `error.stack` when `NODE_ENV === "production"`).

## Global ValidationPipe (security backbone)

```ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,            // strip unknown props
  forbidNonWhitelisted: true, // reject extras
  transform: true,
  forbidUnknownValues: true
}));
```

`whitelist: true` + `forbidNonWhitelisted: true` is load-bearing — without it, attackers stuff extra fields. FAIL if missing.

## Auth + Guards

`@UseGuards()` on every controller. Common bug: forgetting it on a controller and shipping a public endpoint. Configure a global guard with explicit `@Public()` decorator pattern.

## Rate limiting

`@nestjs/throttler` works in-process. Better: let Cloudflare do it pre-origin via WAF Rate Limiting Rule.

## Skill targets

- Global `ValidationPipe` with `whitelist: true`: FAIL if missing.
- `trust proxy` (Express) / proxy trust (Fastify) when CF in front: FAIL otherwise.
- `helmet` middleware: WARN if missing.
- Cookie/session flags: FAIL if missing `secure` + `httpOnly`.
- `@Body() body: any` patterns: WARN.
- Origin not publicly reachable: FAIL if 443 open.
- Stack traces stripped in prod: WARN otherwise.
