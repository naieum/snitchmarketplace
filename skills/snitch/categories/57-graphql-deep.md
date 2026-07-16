## CATEGORY 57: GraphQL Deep Security
> Type: posture · Groups: — · CWE: CWE-862

### Detection
- GraphQL server imports: `apollo-server`, `@apollo/server`, `graphql-yoga`, `mercurius`, `express-graphql`, `graphql-go`, `gqlgen`, `strawberry`, `ariadne`, `graphene`, `spring-boot-starter-graphql`, `hasura`
- GraphQL schema definitions (`.graphql`, `.gql` files, `typeDefs`, `gql` template literals)
- Resolver implementations and context configuration
- GraphQL middleware and plugin registrations

### What to Search For

**Introspection Enabled in Production:**
- Apollo Server without `introspection: false` in production configuration
- graphql-yoga without disabling introspection via plugin or configuration
- Mercurius without `graphiql: false` and introspection restriction
- Spring GraphQL without `spring.graphql.graphiql.enabled=false`
- Hasura without `HASURA_GRAPHQL_ENABLE_ALLOWLIST` in production
- gqlgen without introspection middleware restriction
- Any GraphQL server responding to `__schema` queries in production

**No Query Depth Limiting:**
- Apollo Server without `depthLimit` plugin or validation rule
- Missing `graphql-depth-limit` or equivalent depth-limiting library
- graphql-yoga without depth limit plugin
- Mercurius without `queryDepth` option
- gqlgen without depth middleware
- Spring GraphQL without `QueryComplexityInstrumentation` or depth limiting
- Strawberry without depth limit extension

**No Query Complexity Analysis:**
- No cost analysis plugin (e.g., `graphql-query-complexity`, `graphql-cost-analysis`)
- No field-level cost directives or annotations on expensive fields
- Missing complexity calculation for list fields, connections, and nested queries
- No maximum complexity threshold configured
- Spring GraphQL without `MaxQueryComplexityInstrumentation`

**Circular Fragment References:**
- No validation rule for circular fragment detection
- Missing `NoFragmentCyclesRule` or equivalent in custom validation rules
- Schemas that allow deeply nested types referencing each other without depth control

**Alias-Based Batching Attacks:**
- No limit on the number of aliases in a single query
- Missing alias count validation (allows multiplying mutations via aliases)
- No per-operation rate limiting (only per-request rate limiting)
- Mutations without idempotency keys that can be batched via aliases

**No Field-Level Authorization:**
- Resolvers returning data without checking the requesting user's permissions
- Sensitive fields (email, payment info, admin flags) accessible to all authenticated users
- No `@auth` directive, `AuthScope` decorator, or resolver-level permission checks
- Hasura without column-level permissions per role
- Missing field-level authorization in Strawberry `@strawberry.type` permission classes
- gqlgen resolvers without context-based authorization checks

**Mutation Rate Limiting Missing:**
- Mutations (create, update, delete, password reset, send email) without rate limiting
- No per-user or per-IP throttling on mutation operations
- Rate limiting only applied at HTTP level (not at GraphQL operation level)
- Subscription endpoints without connection limits

**Persisted Queries Not Enforced:**
- Apollo Server without `persistedQueries` configuration in production
- Accepting arbitrary query strings instead of only persisted query hashes
- No allowlist of approved operations in production
- `allowBatchedHttpRequests: true` without operation allowlisting

**N+1 in Resolvers Without DataLoader:**
- Nested resolvers that query the database individually per parent record
- No `DataLoader` usage for batching related entity lookups
- Django/Strawberry resolvers without `django-dataloader` or prefetch optimization
- gqlgen resolvers without generated dataloaders
- Spring GraphQL without `BatchLoaderRegistry`

### Actually Vulnerable
- Apollo Server in production with `introspection: true` (default) and no query depth limit -- allows schema extraction and deeply nested denial-of-service queries
- Resolver that returns `User` with `passwordHash` field, no `@auth` directive -- any authenticated user can query sensitive fields
- Mutation resolver for `transferFunds(amount, to)` with no rate limiting and no alias restriction -- attacker sends 100 aliased mutations in one request
- GraphQL endpoint accepting arbitrary queries in production with no persisted query enforcement -- allows any crafted query
- Nested resolver: `posts -> comments -> author -> posts -> comments` with no depth limit and no DataLoader -- exponential database queries and N+1 performance degradation
- Hasura deployment with admin secret but no role-based column permissions -- all fields accessible to the `user` role
- gqlgen resolver that calls `db.FindUser(id)` inside a list resolver without batching -- N+1 query on every list request

### NOT Vulnerable
- Apollo Server with `introspection: false`, `depthLimit(10)`, and `createComplexityLimitRule(1000)` in production
- Field-level authorization via `@auth` directive or resolver middleware checking user roles
- Persisted queries enforced via allowlist; arbitrary queries rejected in production
- DataLoader used for all nested entity resolution, preventing N+1
- Alias count limited via custom validation rule or complexity cost accounting
- Mutations rate-limited per user via Redis-backed throttle middleware
- Introspection enabled only in development/staging environments
- Public API where introspection is intentionally enabled and documented
- Hasura with granular role-based permissions on all tables and columns

### Context Check
1. Is introspection explicitly disabled in the production configuration?
2. Are query depth and complexity limits configured with reasonable thresholds?
3. Is field-level authorization enforced on sensitive fields (not just type-level)?
4. Are mutations rate-limited at the GraphQL operation level (not just HTTP level)?
5. Are persisted queries or an operation allowlist enforced in production?
6. Are DataLoaders used for nested resolvers that fetch related entities?
7. Is alias count or per-operation cost accounted for in rate limiting?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Checked GraphQL server configuration for `introspection` setting in production
2. [ ] Verified query depth limiting is configured (not just imported but actually applied)
3. [ ] Checked for query complexity analysis plugin or cost directives on expensive fields
4. [ ] Verified field-level authorization on sensitive fields (email, payment info, admin flags)
5. [ ] Checked if alias count or per-operation cost is accounted for in rate limiting
6. [ ] Verified DataLoader usage for nested resolvers that fetch related entities
7. [ ] Confirmed persisted queries or operation allowlist is enforced in production

### Confidence Scoring
- **HIGH**: GraphQL server in production with introspection enabled, no query depth limit, no complexity analysis, and sensitive fields accessible without field-level authorization. Or mutations can be batched via aliases with no alias count restriction.
- **MEDIUM**: Some protections exist (depth limit) but complexity analysis is missing. Or introspection is enabled but the API is intentionally public. Or field-level auth exists on some fields but not all sensitive ones.
- **LOW**: GraphQL endpoint is behind authentication and rate limiting at the HTTP level, which partially mitigates depth/complexity attacks. Or introspection is enabled in a documented public API.
- **SKIP**: Apollo Server with `introspection: false`, `depthLimit()`, complexity limit rules, field-level auth directives, persisted query enforcement, and DataLoaders for all nested resolvers.

### Files to Check
- `**/graphql/**`, `**/schema/**`, `**/resolvers/**`, `**/typeDefs/**`
- `**/schema.graphql`, `**/schema.gql`, `**/*.graphql`
- `**/dataloaders/**`, `**/loaders/**`
- GraphQL server configuration and plugin setup files
- `**/directives/**` (custom auth directives)
- `**/permissions/**`, `**/guards/**` (field-level auth)
- Hasura metadata directory (`metadata/`, `migrations/`)
- `graph/schema.resolvers.go`, `graph/model/` (gqlgen)
