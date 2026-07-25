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
- `$queryRawUnsafe` / `$executeRawUnsafe` where user input is inside the **query string** argument
- `Prisma.raw(...)` / `sql.raw(...)` applied to a user-controlled value — including inside an otherwise-tagged template
- Raw SQL assembled by string concatenation from user input, in any clause of the statement

#### High
- Missing connection pooling for serverless (no PgBouncer/Prisma Accelerate)

#### Medium
- Prisma schema with `@db.VarChar` without explicit length limits
- No query timeouts configured
- Database errors exposed to users without sanitization

### NOT Vulnerable
- `DATABASE_URL` in server-only code
- `Prisma.sql` fragments, including fragments composed into a larger `Prisma.sql` template — composition preserves the bindings
- A `$queryRaw` / `$executeRaw` **tagged template** whose every slot you have **traced** to a plain
  JS value. Concatenation *outside* the slot does not make the slot unsafe — a plain string is bound
  however it was assembled. But a slot holding a `Prisma.Sql` from `Prisma.raw(...)` is a finding,
  **and a slot you could not trace is also a finding** (Low confidence, `needs human verification`),
  because a helper-returned `Prisma.raw` is visually identical to a plain string at the call site.
  This category is reachable via `preset:modern-stack` **without** Category 1, so that rule is
  restated here rather than referenced — see `categories/01-sql-injection.md` for the full call-form
  table and the non-scalar escaping caveat
- `$queryRawUnsafe` / `$executeRawUnsafe` with a literal query string and user values passed as trailing bind arguments — the method name alone is not the finding
- ORM query-builder methods (Prisma/Drizzle finders) that escape by construction
- Raw queries with only hardcoded values

**Call form decides this category's raw-SQL dispositions, and Category 1 owns both the table and
the severity ladder.** Read `categories/01-sql-injection.md` before rating any `$queryRaw`-family
finding: the call-form table under "What to Search For", the per-value rule, and the severity
ladder with its precedence rule under "Confidence Scoring". The **raw-SQL** Critical items listed
above are sink-form starting points — apply Cat 1's downgrade-per-evidenced-constraint rule to reach the
final severity, so a finding does not get two different ratings depending on which category
surfaced it.

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
