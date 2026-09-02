## CATEGORY 36: Business Continuity & Disaster Recovery
> Type: posture · Groups: governance · CWE: CWE-636

> **Maps to common trust-center control language:** continuity and disaster-recovery plans established and tested, backup processes established, infrastructure performance monitored.

### Detection
- Health check endpoints: `/health`, `/ready`, `/live`, `/healthz`, `/readyz`, `/livez`
- Process signal handlers: `SIGTERM`, `SIGINT`, `process.on('beforeExit')`
- Circuit breaker libraries: `opossum`, `cockatiel`, custom circuit breaker patterns
- Retry/backoff patterns: `retry`, `exponential-backoff`, `p-retry`
- IaC backup configs: Terraform `aws_db_instance` with `backup_retention_period`, RDS snapshots

### What to Search For
- Health check / readiness / liveness endpoints
- Graceful shutdown handlers (`SIGTERM`, `SIGINT`, `process.on('beforeExit')`)
- Circuit breaker patterns (library-based or custom state machines)
- Retry logic with exponential backoff
- Database connection pool failover / reconnect logic
- Backup configuration in IaC (Terraform backup resources, RDS snapshots, etc.)
- Multi-region / multi-AZ deployment configs
- Queue dead-letter configs (DLQ)
- Error recovery / fallback patterns

### Actually Vulnerable

**Severity ceiling for availability posture: Medium.** Nothing in this category is a Critical or a
High on its own. A missing health check, a missing shutdown handler, or an absent retry does not
hand an attacker anything — it makes an outage worse, which is a reliability property. This skill
reserves Critical for remote code execution, authentication bypass, and mass data exposure
(`references/standards-table.md`). Raise a finding here above Medium only when you can name an
attacker-reachable impact and evidence it: an unauthenticated endpoint whose absent rate/retry
control makes it a cheap amplification primitive, or a recovery path that restores from a source
the attacker can write to. Say which, at file:line, or keep it at Medium.

#### Medium
- No health check endpoint found in any server entry point (no `/health`, `/ready`, or equivalent)
- No graceful shutdown handler — server does not listen for `SIGTERM` or `SIGINT`
- Database connections with no reconnect logic and no connection pool (single connection, crash on disconnect)
- No circuit breaker or retry pattern for external service calls (API, database, cache)
- No dead-letter queue configuration for async message processing
- No backup configuration in IaC for production databases
- Missing connection pool failover (single-host connection string with no fallback)

#### Medium
- Health endpoint returns 200 without actually checking downstream dependencies
- Retry logic without exponential backoff (fixed delay or no delay)
- No multi-AZ or multi-region configuration in IaC

### NOT Vulnerable
- Health endpoints that check database and cache connectivity before returning 200
- Graceful shutdown draining in-flight requests before exit
- Circuit breaker libraries wrapping external API calls
- Retry with exponential backoff and jitter
- IaC with automated backup and point-in-time recovery configured
- Kubernetes liveness/readiness probes defined in deployment manifests

### Context Check
1. Does the application have a health check endpoint that verifies actual service health?
2. Does the server handle `SIGTERM` gracefully (drain connections, close pools)?
3. Are external service calls wrapped in circuit breakers or retry logic?
4. Is there backup configuration for production data stores?

### Evidence Chain
- For absences: the server entry point(s) at file:line that were read, with a statement of what was searched for (health routes, `SIGTERM`/`SIGINT` handlers, reconnect logic) and not found
- For weak patterns: the code snippet at file:line (health endpoint returning 200 unconditionally, fixed-delay retry, single-connection DB client)
- For IaC gaps: the resource block at file:line missing `backup_retention_period`, DLQ, or multi-AZ configuration
- The impact link: which production service, queue, or data store loses availability or recoverability because of the gap
- A note that platform-level resilience (Kubernetes probes, managed-DB automated backups) was checked and ruled in or out

### Confidence Scoring
- **High**: the entry point or IaC file was read end-to-end and the control is definitively absent (no health route, no signal handler, production DB resource visibly lacking backup config), or the weak pattern is quoted directly.
- **Medium**: the pattern is absent from the scanned files but resilience could live in platform configuration not in the repo (Kubernetes manifests elsewhere, managed-service defaults, external load balancer health checks).
- **Low**: cannot determine whether the deployment target provides probes/backups/failover externally, or whether the app is actually production-deployed — tag `needs human verification`.

### Files to Check
- `**/server*.{ts,js}`, `**/app*.{ts,js}`, `**/index*.{ts,js}` (entry points)
- `**/health*.{ts,js}`, `**/ready*.{ts,js}`
- `**/*.tf`, `**/docker-compose*.yml`, `**/k8s/**/*.yml`
- `**/queue*.{ts,js}`, `**/worker*.{ts,js}`
