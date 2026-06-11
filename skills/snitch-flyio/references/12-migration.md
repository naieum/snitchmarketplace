# 12 — Migration to Fly.io

The migration question almost always reduces to: does your app run as a long-lived process from a Dockerfile? Yes → strong fit. No (static / JAMstack) → pick a CDN host.

## Decision tree

```
Static site / JAMstack?
├─ YES → not Fly. Cloudflare Pages, Netlify, Vercel.
└─ NO → Docker / Dockerfile?
   ├─ YES → strong Fly fit. fly launch.
   └─ NO → can it be containerized? Almost always yes for Rails/Django/Phoenix/Node/Go/Rust/.NET.
       ├─ Persistent disk?
       │  ├─ YES → Fly volumes (single-region) or external (RDS, S3).
       │  └─ NO → easy.
       └─ Long-lived TCP / WebSocket?
          ├─ YES → Fly is great. min_machines_running >= 1.
          └─ NO → still fine; consider Workers/serverless for short bursty.
```

## Common migration paths

### Heroku → Fly

`fly launch` detects Procfile. Heroku Postgres → Fly Postgres or Managed Postgres. Heroku Redis → Upstash-on-Fly. Workers (sidekiq) → separate process_group.

```sh
fly launch --copy-config --no-deploy   # interactive; creates fly.toml + Dockerfile
heroku config -a my-heroku-app | grep -v '=' | while read k; do
  v=$(heroku config:get $k -a my-heroku-app)
  fly secrets set --stage "$k=$v" -a my-fly-app
done
fly deploy
```

### AWS ECS / Fargate → Fly

Container builds + runs unchanged. Same image + env contract. Volumes need a different shape (Fly volumes are NVMe-attached, not EFS).

### Render / Railway → Fly

Same shape. Both Docker-or-buildpack. `fly launch` from the same repo. Migrate Postgres/Redis to Fly's managed offerings.

### VPS (DigitalOcean / Linode / Hetzner) → Fly

Containerize first. Then `fly launch`. Wins: anycast IPs, multi-region machines, managed health checks. Cost: per-VM monthly → hourly billing — calculate.

## Database migration

| From | To | Strategy |
|---|---|---|
| Heroku Postgres | Fly Postgres | `pg_dump` → `psql` over WireGuard. |
| Heroku Postgres | Managed Postgres | `pg_dump` → restore via dashboard. |
| RDS / Neon / Supabase | Fly Postgres | `pg_dump` → `psql`. Brief downtime or logical replication. |
| MongoDB Atlas | Stay on Atlas | Fly doesn't host Mongo. Use `MONGODB_URI` as fly secret. |
| MySQL | External or self-host | No Managed MySQL. PlanetScale / RDS / self-hosted. |
| Redis (any) | Upstash-on-Fly | `redis-cli --rdb` or `MIGRATE`. |
| S3 | Tigris | `aws s3 sync s3://src s3://dst --endpoint-url=https://fly.storage.tigris.dev`. |

## Cost realism

Fly's per-machine pricing is mostly cheaper than AWS Fargate, comparable to Render/Railway, more expensive than self-managed VPSes.

| Win | |
|---|---|
| Anycast IPs | Dedicated v4 = $2/mo. |
| Multi-region distribution | No extra orchestration cost. |
| Volume snapshots | Managed for you. |

| Watch-out | |
|---|---|
| GPU machines (A100, H100) | Expensive per-hour. Use `auto_stop_machines = "stop"` aggressively. |
| Bandwidth out | Free within Fly; standard rates outbound. |
| Build time | Counts as machine-time. |

Authoritative pricing: https://fly.io/pricing.

## Cutover

1. Deploy to Fly with `<app>.fly.dev`; validate end-to-end.
2. `fly certs add example.com -a <app>`. Update DNS to Fly v4/v6 with TTL=60s.
3. Watch logs/metrics 24-48h.
4. Raise TTL, decommission old origin.
5. Rollback: revert DNS to old origin.

## What `fit-matrix <stack>` returns

Per stack: verdict (`strong`/`partial`/`not-recommended`), `recommended_path`, `caveats`. Lead with the verdict; users want yes/no first, plan second.
