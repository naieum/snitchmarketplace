## CATEGORY 1: SQL Injection
> Type: sink-pattern · Groups: web, quick-core · CWE: CWE-89

**Data flow tracing required (SKILL.md Rule 7).** For every raw-SQL or `$queryRaw` / `sql.raw` / `knex.raw` call this category surfaces, trace each interpolated value back to its source before reporting. Literals and parameterized bindings are Passes; values flowing from `req.*` / `params.*` / file content / message payloads to the sink without intervening parameterization are findings. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- Raw SQL usage: `pg`, `mysql2`, `better-sqlite3`, `knex` imports
- Query builder or ORM raw methods: `$queryRaw`, `$executeRaw`, `sql.raw`, `knex.raw`
- Database connection patterns without an ORM

### What to Search For
- String concatenation in SQL queries
- Template literal interpolation in queries
- Format string interpolation in queries

### Actually Vulnerable
- Direct string concatenation building SQL with user input
- Template literals inserting variables directly into SQL strings
- Python format strings with user variables in SQL

### NOT Vulnerable
- Parameterized queries with placeholders ($1, ?, :name)
- ORM methods that handle escaping (Prisma, TypeORM, Sequelize)
- Queries in comments or documentation
- Queries with only hardcoded values

### Context Check
1. Does user input actually flow into this query?
2. Is there validation/sanitization before this line?
3. Is this in test code or production code?

### Evidence Chain
- The sink (raw SQL call with interpolation) quoted at file:line
- The traced variable path from source to sink, hop by hop (e.g. `req.body.name` → `buildFilter()` → `db.query()`)
- Sanitizers/parameterization checked along the path and found absent (name what was looked for: placeholders, ORM binding, escaping)
- Source classification: user-controlled (`req.*`, `params.*`, file content, message payload) vs internal/literal
- If the source could not be fully traced, state where the trace stopped

### Confidence Scoring
- **High** — complete trace from a user-controlled source to the raw SQL sink with no parameterization or escaping on the path
- **Medium** — interpolation into SQL is confirmed at the sink, but the value's source is partially traced (e.g. crosses a module boundary where the caller couldn't be confirmed as user-controlled)
- **Low** — interpolation pattern present but the source is un-traceable (dynamic dispatch, external caller, generated code) → tag `needs human verification`

### Files to Check
- `**/db*.ts`, `**/query*.ts`, `**/sql*.ts`
- `**/repository*.ts`, `**/model*.ts`
- Database migration files, raw query utilities
