# NestJS on Fly.io

Larger surface than Express; same machine model. Pair with Managed Postgres + Upstash Redis.

## fly.toml essentials

```toml
[env]
  NODE_ENV = "production"
  PORT = "3000"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1

  [[http_service.checks]]
    grace_period = "15s"     # Nest boots slower than Express
    interval = "30s"
    path = "/health"

[deploy]
  release_command = "node dist/scripts/migrate.js"
```

## main.ts

```ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.set('trust proxy', 1);
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.use(helmet());
  await app.listen(process.env.PORT);
}
```

## TerminusModule for /health

```ts
@Controller('health')
export class HealthController {
  constructor(private health: HealthCheckService, private db: TypeOrmHealthIndicator) {}

  @Get()
  @HealthCheck()
  check() { return this.health.check([() => this.db.pingCheck('db')]); }
}
```

## Microservices via Redis / TCP

NestJS microservices over Redis or TCP work — Fly's 6PN supports both. Use `<app>.internal:<port>`:

```ts
ClientsModule.register([{
  name: 'B_SERVICE',
  transport: Transport.TCP,
  options: { host: 'b-service.internal', port: 3100 },
}]);
```

## TypeORM / Prisma

Set pool size to machine's CPU count + headroom:

```ts
TypeOrmModule.forRoot({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  poolSize: 10,
});
```

## Common mistakes

| Mistake | Cost |
|---|---|
| Slow boot, short `grace_period` | Health check fails before app ready. Set ≥ 15s. |
| `min_machines_running = 0` | Cold-start tax. |
| `localhost` for inter-service | Won't reach a different app; use `<app>.internal`. |
| No global `ValidationPipe` | Unsanitized bodies hit handlers. |
| Default Express body limit (100kb) | Large JSON fails silently. |
