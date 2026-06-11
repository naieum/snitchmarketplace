# Migrating to Railway

Decision path:

1. `bash snitch-railway.sh detect` from project repo. Capture stack + databases + native deps.
2. `bash snitch-railway.sh fit-matrix <stack>` per detected stack. Read verdict.
3. Read `references/15-stack-best-practices/<stack>.md` for stack-specific tuning.
4. If `not-recommended` (mostly static sites), point at Pages/Vercel/Netlify and stop.
5. If `strong` or `partial`, render plan with Railway-specific concerns.

## Universal migration steps

1. **Containerize or Nixpacks-ify**:
   - Working `Dockerfile` → use it.
   - Otherwise let Nixpacks auto-detect; pin runtimes in `nixpacks.toml`.
2. **Externalize state**:
   - Sessions → Redis service.
   - File uploads → R2/S3 (Railway volumes are local-only).
   - Background jobs → separate worker service.
3. **Migrate data**:
   - Postgres: `pg_dump` → restore to Railway Postgres add-on.
   - MySQL: `mysqldump` → restore.
   - MongoDB: `mongodump` → restore (or use Atlas).
   - Redis: rebuild from source-of-truth, not migrate.
4. **Rewire env vars**:
   - Move secrets to shared project vars first.
   - Reference cross-service via `${{ Postgres.DATABASE_URL }}`.
5. **DNS cutover**:
   - Lower origin TTL to 60s 24h ahead.
   - Add custom domain in Railway dashboard.
   - Wait for `status: active` in `state domains`.
   - Switch DNS to Railway's CNAME.
   - Watch logs for traffic shift.
   - After 48h, remove origin.

## Common gotchas

| Issue | Fix |
|---|---|
| Stateful services + replicas | Volumes don't share; externalize state first |
| Cron | Dedicated service with `restartPolicyType: NEVER` and schedule in app code (or cron template) |
| WebSockets | Public HTTPS domain (wss://), not TCP proxy |
| Long-running tasks > 5min | Railway won't kill, but a deploy will. Build resumability into the worker. |

## Rollback

If cutover fails:
1. Switch DNS back to origin (still up because TTL is low).
2. Investigate logs in Railway.
3. Re-attempt after fix.

## Docs

- https://docs.railway.com/guides/migrations
