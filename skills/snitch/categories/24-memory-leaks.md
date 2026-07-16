## CATEGORY 24: Memory Leaks
> Type: performance · Groups: performance · CWE: —

### Detection
- Frontend frameworks: React, Vue, Angular, Svelte with lifecycle hooks
- Event-driven patterns: `addEventListener`, `.on()`, `.subscribe()`
- Timer functions: `setInterval`, `setTimeout`
- Connection patterns: WebSocket, database connections, streams

### What to Search For
- `addEventListener` without corresponding `removeEventListener` in cleanup
- `useEffect` with timers or listeners but no cleanup return function
- `setInterval`/`setTimeout` without clearing in cleanup
- Module-scope `Map`/`Set` that grow without eviction or size limits
- WebSocket/stream/connection opened without corresponding close
- `.on()`/`.subscribe()` without `.off()`/`.unsubscribe()` in cleanup

### Actually Vulnerable
- Event listeners added in component mount without removal on unmount
- `useEffect` creating intervals/subscriptions with no cleanup return
- Module-level caches (`Map`, `Set`, `Object`) that grow unbounded
- Database connections opened per-request without pooling or closing
- WebSocket connections without close handlers

### NOT Vulnerable
- Event listeners with proper cleanup in `useEffect` return or `componentWillUnmount`
- `setInterval` with matching `clearInterval` in cleanup
- Caches with TTL, LRU eviction, or size limits
- Connection pools (e.g., Prisma client singleton)
- One-time static listeners (e.g., `process.on('uncaughtException')`)

### Context Check
1. Is there a cleanup function that removes the listener/timer?
2. Is this a module-level singleton (acceptable) or per-request allocation?
3. Does the cache have eviction or size limits?
4. Is the connection pooled or per-request?

### Evidence Chain
- The allocation site at file:line (listener registration, `setInterval`, cache insert, connection open)
- The missing counterpart verified absent (no `removeEventListener`/`clearInterval`/cleanup return/`close()` in the same scope or unmount path)
- Why it compounds: the trigger frequency (per-render, per-request, per-message) that makes growth unbounded
- Lifetime classification: module-level singleton (one-time) vs per-instance/per-request allocation that repeats

### Confidence Scoring
- High: allocation sits in a repeated path (component effect, request handler, message callback) with the cleanup verifiably absent
- Medium: cleanup is not co-located but may happen elsewhere (parent unmount, framework disposal, external teardown), or growth appears bounded in practice
- Low: cannot determine the invocation frequency or the object's lifecycle → tag `needs human verification`

### Files to Check
- `**/components/**/*.tsx`, `**/hooks/**/*.ts`
- `**/lib/**/*.ts`, `**/utils/**/*.ts`
- `**/services/**/*.ts`, `**/workers/**/*.ts`
