## CATEGORY 26: Performance Problems
> Type: performance · Groups: performance · CWE: —

### Detection
- Synchronous file system operations in request handlers
- Database queries without indexes or limits
- Full library imports in client bundles
- Missing pagination on list endpoints
- Sequential independent async operations

### What to Search For
- `fs.readFileSync`/`writeFileSync` in request handlers (not config/build scripts)
- Prisma schema fields used in `where`/`orderBy` without `@@index`
- `findMany({})`/`.find({})` without `take`/`limit` clause
- `import _ from 'lodash'` (full library) in client-side code
- List/search endpoints without pagination parameters (`skip`, `take`, `page`, `limit`)
- Sequential independent `await` calls that should be `Promise.all`
- Inline object/array literals in JSX props of mapped components (causes re-renders)

### Actually Vulnerable
- `fs.readFileSync` inside an API route handler or middleware
- Database query on a frequently-filtered field with no index defined
- `findMany({})` returning entire table with no limit
- Full lodash import (`import _ from 'lodash'`) in a client-side bundle
- API endpoint returning all records with no pagination
- Three sequential `await` calls to independent services (should be parallel)

### NOT Vulnerable
- `readFileSync` in config loading at startup or build scripts
- Queries on primary keys or already-indexed fields
- `findMany` with explicit `take`/`limit` clause
- Tree-shakeable imports (`import { debounce } from 'lodash/debounce'`)
- Endpoints with cursor/offset pagination
- Sequential awaits where each depends on the previous result

### Context Check
1. Is the sync file operation in a request handler or at startup/build time?
2. Is the unindexed field actually used in production queries?
3. Is the unbounded query on a table that will remain small or could grow large?
4. Are the sequential awaits actually independent or do they depend on each other?

### Evidence Chain
A finding's Evidence block must show:
- The measurable pattern file:line (sync FS call, unbounded `findMany`, unindexed filtered field, full-library import, sequential independent awaits)
- The enclosing request/render path (route handler, middleware, mapped component) showing the pattern executes per request or per render
- Why it compounds: per-request event-loop blocking, table growth over time, or bundle bytes shipped to every client
- For missing-index findings: the schema file:line lacking `@@index` plus the query file:line filtering/ordering on that field
- That the mitigating construct is absent (`take`/`limit`, pagination params, tree-shaken import, `Promise.all`)

### Confidence Scoring
- **High**: pattern unambiguous at file:line on a hot request/render path with mitigation clearly absent (e.g., `fs.readFileSync` inside a route handler; `findMany({})` with no `take` on a user-data table)
- **Medium**: pattern present but scale context is partial — table growth unknown, handler may be rarely invoked, or the bundler may tree-shake the import
- **Low**: cannot determine whether the code path is production-reachable or what the data scale is — tag `needs human verification`

### Files to Check
- `**/api/**/*.ts`, `**/routes/**/*.ts`, `**/middleware/**/*.ts`
- `prisma/schema.prisma` (check `@@index` directives)
- `**/components/**/*.tsx` (check imports and JSX props)
- `**/pages/**/*.tsx`, `**/app/**/*.tsx`
