# Volumes and storage

Railway volumes are local NVMe attached to a single service in a single environment. They survive service restarts but are not snapshot-backed.

## Mount paths

Per-volume; common choices:
- `/data` for app-managed state.
- `/var/lib/postgresql/data` for the postgres add-on (auto-set).

## Size

Set at creation. Resize requires support intervention or migration to a fresh volume. Plan for 2× expected peak.

## Backups — the gap

Railway has no managed snapshot product. To get backups:

1. Schedule a process running `pg_dump` / `mysqldump` / `mongodump` shipped to S3-compatible storage (R2, S3, B2).
2. Run logical replication target outside Railway (Neon, RDS, Supabase) — Railway's DB stays cache.

`apply_databases` emits a GitHub Actions workflow scaffold for option 1.

## Volume + replica interaction

A volume attaches to one service instance. If you scale to N replicas, Railway picks one to receive the volume — the others run without it. **Stateful services can't horizontally scale via Railway volumes alone.** Options:

- Single replica with restart-on-failure.
- External durable storage (managed Postgres elsewhere, S3 for files).

## Recommendations

- Treat Railway volumes as fast local cache that survives restart. Not durable storage of last resort.
- Schedule logical dumps to R2/S3 daily.
- Document RTO/RPO for each stateful service.

## Docs

- https://docs.railway.com/reference/volumes
