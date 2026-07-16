## CATEGORY 17: Database Security
> Type: sink-pattern · Groups: modern-stack · CWE: CWE-89

**Data flow tracing required (SKILL.md Rule 7).** The raw-SQL findings here (`$queryRaw`, `$executeRaw`, `$queryRawUnsafe`, string-concatenated SQL) are SQL-injection sinks — trace each interpolated value to its source as in Category 1. Parameterized queries (`Prisma.sql`, placeholders) and hardcoded values are Passes; values from `req.*` / `params.*` reaching a raw query without parameterization are findings. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- `@prisma/client`, `drizzle-orm`, `pg`, `mysql2` imports
- `DATABASE_URL`, `POSTGRES_URL` environment variables

### What to Search For
- Connection strings in client code
- Raw SQL with user input
- Missing query safety measures

### Actually Vulnerable

#### Critical
- `DATABASE_URL` with credentials in client-side code
- Connection strings in `NEXT_PUBLIC_*` variables
- `$queryRaw` or `$executeRaw` with string interpolation (SQL injection)
- Template literals with `${userInput}` in raw SQL

#### High
- Prisma `$queryRawUnsafe` usage with any user input
- Raw SQL queries built with string concatenation
- Missing connection pooling for serverless (no PgBouncer/Prisma Accelerate)

#### Medium
- Prisma schema with `@db.VarChar` without explicit length limits
- No query timeouts configured
- Database errors exposed to users without sanitization

### NOT Vulnerable
- `DATABASE_URL` in server-only code
- Parameterized queries with `Prisma.sql` template tag
- ORM queries (Prisma/Drizzle) with proper escaping
- Raw queries with only hardcoded values

### Context Check
1. Is the raw SQL using parameterized placeholders or string interpolation?
2. Does user input actually flow into the query, or is it hardcoded/server-generated?
3. Is the database connection server-only or potentially exposed to client code?
4. Is there an ORM layer handling escaping automatically?

### Evidence Chain
- Sink file:line — the `$queryRaw`/`$executeRaw`/`$queryRawUnsafe` call or string-concatenated SQL statement
- The traced variable path from source to sink (e.g. `req.body.email` → query helper → raw query argument)
- Sanitizers/parameterization checked on that path and found absent (no `Prisma.sql` tag, no placeholder binding, no ORM escaping)
- Source classification: user-controlled (`req.*`, `params.*`) vs hardcoded/server-generated
- For connection-string exposure findings: the credential's file:line plus proof it ships to the client (`NEXT_PUBLIC_*` prefix or import from client-side code)

### Confidence Scoring
- High: complete source→sink trace shows user input interpolated into raw SQL with no parameterization, or a connection string verifiably reachable from client code
- Medium: raw SQL interpolation exists but the value passes through intermediate layers only partially traced, or posture items (missing pooling, no timeouts, unsanitized DB errors) where the deployment context is unconfirmed
- Low: the interpolated value's source cannot be traced (dynamic dispatch, external caller) → tag `needs human verification`

### Files to Check
- `prisma/schema.prisma`, `drizzle.config.ts`
- `**/db*.ts`, `lib/prisma.ts`, `lib/db.ts`
- `.env*`
