## CATEGORY 25: N+1 Queries
> Type: performance · Groups: performance · CWE: —

### Detection
- ORM usage: `@prisma/client`, `drizzle-orm`, `typeorm`, `sequelize`, `mongoose`
- Database queries inside loops or array iteration methods
- GraphQL resolvers with per-field data fetching

### What to Search For
- ORM `findUnique`/`findFirst`/`findOne` inside `for`/`forEach`/`map` loops
- `await` database calls inside loop bodies
- GraphQL field resolvers making individual database queries without DataLoader
- Missing `include`/`select`/`populate` for relations accessed after initial query
- `fetch()` per-item in loops in server-side code

### Actually Vulnerable
- `prisma.user.findUnique()` called inside a `for` loop iterating over IDs
- `await db.query()` inside `array.map()` or `forEach()`
- GraphQL resolver fetching related records one-by-one without batching
- Fetching a list then looping to fetch each item's relations separately
- Sequential API calls per-item when a batch endpoint exists

### NOT Vulnerable
- Single queries with `include`/`select` loading relations eagerly
- Batch operations: `findMany`, `WHERE IN`, `Promise.all` with batch fetch
- GraphQL resolvers using DataLoader for batching
- Loop queries where the loop is bounded to a small known size (< 5)
- Client-side fetching in user-triggered handlers (not render loops)

### Context Check
1. Is the database call actually inside a loop or iteration?
2. Could this be replaced with a single query using `include`, `WHERE IN`, or batch fetch?
3. Is the loop bounded to a small constant or potentially unbounded?
4. Is this server-side code (performance impact) or client-side (less concern)?

### Evidence Chain
A finding's Evidence block must show:
- The query call site file:line and the enclosing loop/iteration construct (`for`/`forEach`/`map`/resolver field) file:line
- The collection driving the iteration and where it is produced (list of IDs, prior `findMany` result, GraphQL parent list)
- Why the iteration count compounds: unbounded or data-proportional (grows with rows/users/items), not a small known constant
- That no batching alternative is in use at that site (no `include`/`select`/`populate`, `WHERE IN`, `findMany`, `Promise.all` batch fetch, or DataLoader)
- That the code path is server-side and per-request reachable (API route, resolver, action) rather than a one-off script

### Confidence Scoring
- **High**: database call verifiably inside a loop iterating a data-proportional collection, on a server-side request path, with a clear batch alternative (`include`, `WHERE IN`, `findMany`, DataLoader) absent
- **Medium**: query-in-loop pattern present but the loop bound is unclear, or batching may exist at a service/middleware layer not visible at the call site
- **Low**: the iterated collection's size or origin cannot be traced (indirect helpers, dynamic dispatch), or code-path reachability is uncertain — tag `needs human verification`

### Files to Check
- `**/api/**/*.ts`, `**/routes/**/*.ts`
- `**/services/**/*.ts`, `**/resolvers/**/*.ts`
- `**/actions/**/*.ts`, `**/server/**/*.ts`
- GraphQL resolver files
