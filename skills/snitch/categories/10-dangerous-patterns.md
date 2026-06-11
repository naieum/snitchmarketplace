## CATEGORY 10: Dangerous Code Patterns

**Data flow tracing required (SKILL.md Rule 7).** For every dynamic-code-execution sink this category surfaces (eval-family functions, `new Function(string)`, `vm.runInContext`, `child_process.exec` with shell string, dynamic `import()` of user-controlled paths), trace the argument back to its source. Literal strings and known-safe values are Passes. Arguments built from `req.*` / `params.*` / file content / message payloads / agent output are findings. Sinks reachable only through trusted internal code paths (config loaders, build scripts) get downgraded confidence, never auto-Passed without trace evidence.

### Detection
- Dynamic code evaluation functions (JS eval, dynamic Function constructor, VM context runners)
- Shell/process execution modules (Node process spawning, shell command runners, sync variants)
- Unsafe deserialization (JSON.parse with untrusted input, YAML unsafe load, Python serialization modules)

### What to Search For
- Dynamic code evaluation patterns
- Shell command execution with user input
- Unsafe deserialization
- Unsafe YAML loading
- GraphQL introspection enabled in production: `introspection: true` in Apollo/GraphQL Yoga server config (leaks full schema)
- GraphQL server missing query depth and complexity limits (DoS vector)

### Actually Vulnerable
- User input in code evaluation
- Shell commands with concatenated user input
- Deserializing untrusted data
- YAML load without safe loader
- Apollo Server with `introspection: true` and no NODE_ENV guard (schema fully exposed)
- GraphQL server with no `depthLimit` or `queryComplexity` plugin (unbounded query cost)

### NOT Vulnerable
- Build tool configurations
- Static commands without user input
- Safe deserialization methods
- Vendor/node_modules code
- `introspection: process.env.NODE_ENV !== 'production'` (disabled in prod)
- Introspection guarded by admin-only authorization
- Depth/complexity limits configured

### Context Check
1. Does user input flow into the evaluated code or shell command?
2. Is this a build-time script or production runtime code?
3. Is the deserialized data from a trusted internal source?

### Files to Check
- `**/exec*.ts`, `**/shell*.ts`, `**/worker*.ts`
- `**/eval*.ts`, `**/script*.ts`
- Build scripts, task runners, utility scripts
