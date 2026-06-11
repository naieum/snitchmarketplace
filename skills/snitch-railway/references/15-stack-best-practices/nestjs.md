# NestJS on Railway

Full NestJS support — DI, decorators, TypeORM/Prisma, all on the long-lived Node process.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "node dist/main",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening (`main.ts`)

```ts
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(helmet({
    hsts: { maxAge: 31536000, includeSubDomains: true, preload: true }
  }));
  app.enableCors({ origin: process.env.CORS_ORIGIN, credentials: true });
  app.set('trust proxy', 1);
  await app.listen(process.env.PORT ?? 3000, '0.0.0.0');
}
bootstrap();
```

## Patterns

- TypeORM/Prisma: `${{ Postgres.DATABASE_URL }}`.
- `@nestjs/throttler` for rate limiting.
- Microservices via TCP: use `<service>.railway.internal`, not cross-project public URLs.
- Health: `@nestjs/terminus` with DB + memory checks.

## Docs

- https://docs.nestjs.com/security/helmet
- https://docs.railway.com/guides/nestjs
