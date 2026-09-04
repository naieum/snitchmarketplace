## CATEGORY 1: SQL Injection
> Type: sink-pattern · Groups: web, quick-core · CWE: CWE-89

**Data flow tracing required (SKILL.md Rule 7).** For every raw-SQL or `$queryRaw` / `sql.raw` / `knex.raw` call this category surfaces, trace each interpolated value back to its source before reporting. Literals and parameterized bindings are Passes; values flowing from `req.*` / `params.*` / file content / message payloads to the sink without intervening parameterization are findings. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- Raw SQL usage: `pg`, `mysql2`, `better-sqlite3`, `knex`, `@prisma/client`, `drizzle-orm` imports
- Query builder or ORM raw methods: `$queryRaw`, `$executeRaw`, `$queryRawUnsafe`, `$executeRawUnsafe`, `Prisma.raw`, `sql.raw`, `knex.raw`
- Database connection patterns without an ORM

### What to Search For
- String concatenation in SQL queries
- Template literal interpolation in queries
- Format string interpolation in queries

**Classify by call form and argument position, never by method name.** The same method is safe
or injectable depending on how it is invoked and where the value lands. Grepping the method name
produces matches; this table turns a match into a disposition.

Throughout the table, **"literal" means the value you arrive at after tracing, not the token at the
call site.** `conn.query(sql)` where `sql` was assigned from `mysql.format(...)` two lines above is
a literal-with-binds, not an unparameterized call. Trace first, then classify.

| Call form | Disposition |
|---|---|
| ``$queryRaw`...${v}...` `` — **tagged template** (backtick directly after the method) | Every `${}` slot compiles to a bound placeholder — including a plain JS string, however it was assembled. **Pass**, however tainted `v` is — *unless* a slot holds a `Prisma.Sql` value produced by `Prisma.raw(...)` (or a `Prisma.sql` fragment embedding one), which splices raw SQL text and is a finding (row 4). Judge what each slot **is**, not how it was built |
| ``$queryRaw(Prisma.sql`...${v}...`)`` — function call on a `Prisma.sql` fragment | Slots are bound; fragments compose safely. **Pass** — this is the ordinary dynamic clause-builder |
| `$queryRawUnsafe(str, ...binds)` / `$executeRawUnsafe` | Trailing arguments are bind values (**Pass**). The finding is user input inside `str`, the query text |
| `Prisma.raw(v)` / `sql.raw(v)` — anywhere, including inside a tagged template | Spliced into SQL text unbound. **Always a finding** when `v` is user-controlled |
| `knex.raw(str, [binds])` | `?` binds a value, `??` an escaped identifier. Only the bound positions are protected |
| `pg` — `client.query(text, values)` | `$1`-style placeholders with a `values` array are bound. The finding is a template literal or concatenation inside `text`. A parameterless literal query is a Pass — a missing `values` array is only relevant when `text` is non-literal |
| `mysql2` — `conn.execute(sql, params)` | True server-side prepared statement; `?` binds values. It does not support `??` identifier placeholders; choose identifiers through a trusted allow-list |
| `mysql2` — `conn.query(sql, params)` / `mysql.format(sql, params)` | Client-side interpolation via `SqlString`. The finding is concatenation or template-literal interpolation inside `sql`. `format()` escapes **scalars** — see the non-scalar rule below before passing it |
| `better-sqlite3` — `db.prepare(sql).run/get/all(params)` | Named (`:name`) and positional (`?`) params bind. The finding is user input inside the `prepare()` string |

Rules the table depends on:

- **Parameterization is per-value, not per-query.** A statement may bind one clause and concatenate
  another; the concatenated clause is still injectable. `knex.raw("... tenant = '" + t + "' AND active = ?", [true])`
  is a finding despite the real bindings array.
- **Identifier positions cannot be parameterized at all.** Column and table names, `ORDER BY`
  targets, and `ASC`/`DESC` never accept a bind parameter — which is why they get routed through
  `Prisma.raw` in the first place. The fix is an allow-list of permitted values, never "use a bind
  parameter." Proposing a placeholder here is wrong advice.
- **String concatenation *outside* a slot does not make the slot unsafe.** How the JS value was
  built is irrelevant; what matters is its type at the slot. `const clause = "status = " + x;`
  then `` $queryRaw`SELECT ... WHERE ${clause}` `` is a **Pass** — `clause` is a plain string, so it
  is bound as a value rather than becoming SQL text. (In this particular shape the statement also
  happens to error, but *breakage is not the test* — `` WHERE id = ${clause} `` binds cleanly and
  returns rows, and is equally a Pass. The reason is binding, full stop.) Only a `Prisma.Sql` value
  becomes SQL text. Do not flag concatenation reflexively; flag it where it lands in the query
  *string* (`$queryRawUnsafe`, `knex.raw`, driver-level `query(text)`).
- **MySQL client-side formatting is type-dependent; do not generalize it to all bindings.**
  `SqlString.escape` (mysql/mysql2 `query`, `format`) expands a plain object into `` `k` = v ``
  pairs via `objectToValues` and an array into a comma list via `arrayToList` — SQL syntax, not a
  quoted string. Establish whether the installed request parser permits those shapes and whether
  the formatter expands them in a way that changes the query's intended predicate. Do not assume
  an Express parser default across versions. For ``format("... id = ?", [req.query.id])``, trace
  the parser and any schema/type conversion before judging the argument.
  The expected scalar type must reach this client-side formatter; a schema can enforce that type
  while the formatter supplies SQL escaping. Missing parser/driver evidence leaves confidence Low.
  PostgreSQL bound objects/arrays remain parameter data; they are not MySQL-style SQL expansion.
  For `knex.raw`, read the configured client and trace whether each slot is a bound value or an
  explicit SQL fragment. Never apply the MySQL formatter rule to every Knex binding.

  **An un-traced slot is not a Pass.** If you cannot determine a slot's type — it comes from a
  helper, a cross-file assignment, or a function parameter — trace it per Rule 7. A bare identifier
  in a slot looks identical whether it holds a plain string or a `Prisma.raw` value, so "it looks
  like a string" is not evidence. Untraceable within scope → finding at Low confidence, tagged
  `needs human verification`, never a silent Pass.

### Actually Vulnerable

These are shorthand for the call-form table above; **where the two appear to disagree, the table
wins.** In particular a *tagged* template is not "a template literal in a SQL string" — its slots are
bound, and it is a Pass.

- User input concatenated into a SQL string that is then executed (`+`, `.join`, f-string, `%`, `.format`)
- A template literal **evaluated into a string** and passed as the query text — `` db.query(`... ${v}`) ``, `` $queryRawUnsafe(`... ${v}`) ``. The distinguishing test is whether the method received a *string* or a *tag*
- A `Prisma.raw` / `sql.raw` value reaching any query, including inside an otherwise-bound tagged template
- A `${}` slot whose contents you could not trace (Low confidence, `needs human verification`)
- A non-scalar reaching MySQL client-side formatting whose expansion changes the intended predicate; establish the accepted input shape and driver behavior

### NOT Vulnerable
- Parameterized queries with placeholders ($1, ?, :name) — for the *values that are bound*; check every clause
- ORM query-builder methods that escape by construction (`prisma.user.findMany`, TypeORM/Sequelize finders). This does **not** extend to the raw escape hatches — see the call-form table
- A `$queryRaw` / `$executeRaw` **tagged template**, even with a fully user-controlled `${}` slot — unless a slot contains a `Prisma.Sql` value produced by `Prisma.raw(...)` (or a `Prisma.sql` fragment embedding one), or you could not determine what the slot holds
- `$queryRawUnsafe` / `$executeRawUnsafe` whose query string is a literal and whose user values are trailing bind arguments
- `knex.raw` with a bindings array, for the clauses actually using `?` / `??`
- Queries in comments or documentation
- Queries with only hardcoded values

### Context Check
1. Does user input actually flow into this query?
2. Does a traced control prevent SQL syntax at this argument position? A schema's string/length checks alone do not protect concatenated SQL text; binding the parsed value does.
3. Is this in test code or production code?

### Evidence Chain
- The sink (raw SQL call with interpolation) quoted at file:line
- The traced variable path from source to sink, hop by hop (e.g. `req.body.name` → `buildFilter()` → `db.query()`)
- Sanitizers/parameterization checked along the path and found absent (name what was looked for: placeholders, ORM binding, escaping)
- Source classification: user-controlled (`req.*`, `params.*`, file content, message payload) vs internal/literal
- If the source could not be fully traced, state where the trace stopped

### Confidence Scoring

**Severity ladder** (SKILL.md requires Severity + CVSS on every finding):
- **Critical** (CVSS ~9.0-9.8) — user input becomes SQL text on a reachable, unauthenticated path: concatenation into a raw query, `$queryRawUnsafe` with a built string, `Prisma.raw` on a request value
- **High** (CVSS ~7.0-8.9) — same splice with one evidenced reachability or expressivity constraint under the precedence rule below; an identifier position alone is not such a constraint
- **Medium** (CVSS ~4.0-6.9) — remaining SQL influence is demonstrably constrained or the sink is reachable only from an internal/admin surface; apply the precedence rule below. The mere presence of a length cap or schema is not a severity reduction
- An untraceable source lowers **confidence**, not severity by itself. State potential impact and the unknown preconditions; do not imply confirmed exploitation

**Precedence — apply in this order, or two auditors will grade the same finding differently.**
Start at **Critical** based on the *sink form* alone. Then downgrade **one tier per reachability
constraint you have actually evidenced** — either *reachability* (an auth gate you located, an
internal-only surface) or *expressivity* (the attacker can influence the statement but provably
cannot append arbitrary SQL — e.g. the value passes through an escaping identifier quoter such as
knex's `??`). Never downgrade on an assumed constraint: if you
cannot point to the guard, the finding stays at its sink-form tier.

A third axis, distinct from both: **unreachable entrypoint** — the file containing the sink is not
wired into any build target or run script (no import chain from an entrypoint, absent from
`package.json` scripts, referencing models or exports that no longer exist). This is evidence the
code never executes, which is not a guard and not an expressivity limit. Establish it from the build
and script graph, never from "it looks unused", and say so in the finding — dead code gets wired up.

**Position is not expressivity.** A `Prisma.raw` / `sql.raw` in an `ORDER BY` is **Critical**, not
High: `raw` splices arbitrary text, so `?sort=id) UNION SELECT ...` is not confined to a column
name. Being in an identifier position only earns a downgrade when something *escapes* the identifier
(`??`, `escapeId`, an allow-list lookup). Unescaped `raw` anywhere is full statement control.

Severity is about the sink and its reachability; Confidence below is about how completely you traced it. Rate them independently.

- **High** — complete trace from a user-controlled source to the raw SQL sink with no parameterization or escaping on the path
- **Medium** — interpolation into SQL is confirmed at the sink, but the value's source is partially traced (e.g. crosses a module boundary where the caller couldn't be confirmed as user-controlled)
- **Low** — interpolation pattern present but the source is un-traceable (dynamic dispatch, external caller, generated code) → tag `needs human verification`

### Files to Check
- `**/db*.ts`, `**/query*.ts`, `**/sql*.ts`
- `**/repository*.ts`, `**/model*.ts`
- Database migration files, raw query utilities
- **Framework route handlers, where most queries actually live in modern apps:**
  `**/api/**/route.ts` (Next.js App Router), `**/pages/api/**`, `**/actions/**` and `"use server"`
  files (Server Actions), `**/server/**`, `**/routers/**` (tRPC), `**/resolvers/**` (GraphQL),
  `**/lib/prisma.ts` and equivalent client singletons
- Do not build your inventory from this list alone — enumerate the route tree, then grep it. A
  name-based glob misses `app/api/patients/[mrn]/route.ts`, which is where the queries are
