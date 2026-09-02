## CATEGORY 48: Race Conditions & Concurrency
> Type: posture · Groups: — · CWE: CWE-362

### Detection
- Non-atomic read-modify-write patterns (check-then-act)
- Module-level mutable state written during request handling (see Cross-Request State Contamination below)
- Missing database transactions around multi-step operations
- TOCTOU (time-of-check-time-of-use) in file operations
- Double-submit patterns in payment or order flows
- Missing optimistic locking or row-level locks
- Shared mutable state accessed from multiple threads or goroutines

### What to Search For

**Node.js/TypeScript:**
- Async check-then-act: `if (await getBalance() >= amount) { await debit(amount); }` without transaction
- Multiple awaits on shared state without a locking mechanism
- Missing `FOR UPDATE` or `FOR SHARE` in SELECT queries before UPDATE
- Payment flows that check balance or stock in one query and debit in another
- Redis `GET` then `SET` instead of atomic `INCR`, `DECR`, or Lua scripts
- File operations: `fs.existsSync()` followed by `fs.readFileSync()` or `fs.writeFileSync()`
- Missing mutex or semaphore around critical sections (e.g., `async-mutex` not used)

**Python:**
- `threading` module without `Lock`, `RLock`, or `Semaphore` on shared state
- Django/SQLAlchemy: `SELECT` then `UPDATE` without `select_for_update()` or `with_for_update()`
- `asyncio` tasks sharing mutable state without `asyncio.Lock`
- File TOCTOU: `os.path.exists()` followed by `open()` without atomic operations
- `check_balance(); debit()` pattern without `@transaction.atomic` in Django

**Cross-request state contamination (a confidentiality bug, not a locking bug):**
Module-level mutable state in a long-lived server process is shared by every concurrent request in
that process. When a handler writes a *per-user* value into it, the next request can read someone
else's data — no lock fixes that, because the state should not have been shared in the first place.
The finding is the scope, not the missing mutex.
- A module-level `let` / `var` / class static / Python module global / Go package-level variable
  assigned from request data (`currentUser = req.user`, `let tenantId; app.use(req => tenantId = ...)`)
- A singleton client, ORM session, or SDK instance reconfigured per request (`client.setAuth(token)`,
  `db.tenant = req.tenant`) rather than constructed or scoped per request
- Caches keyed by something that is not the tenant/user (a memo on resource id alone, in a
  multi-tenant app)
- Framework context objects stashed in a module-level variable "so helpers can reach them"
- The Pass: request-scoped storage (`AsyncLocalStorage`, `contextvars`, a Go `context.Context`
  value, a per-request DI scope), or a value that is genuinely process-wide and identical for every
  caller (a compiled regex, a config constant, a connection pool)
- Severity: **High** when the leaked value is user data, a session, or a tenant identifier — that is
  cross-tenant disclosure reachable by ordinary concurrent traffic, not a rare interleaving

**Go:**
- Goroutines accessing shared variables without `sync.Mutex`, `sync.RWMutex`, or channels
- Map access from multiple goroutines without synchronization (causes panic)
- `if value, ok := map[key]; ok { ... }` followed by `map[key] = newValue` without lock
- Missing `sync.Once` for one-time initialization in concurrent code
- File operations without `flock` or advisory locking
- Database operations without `SELECT ... FOR UPDATE` in concurrent handlers

**Java:**
- Shared mutable state without `synchronized`, `ReentrantLock`, or `AtomicReference`
- `HashMap` used instead of `ConcurrentHashMap` in multi-threaded context
- `if (map.containsKey(key)) { map.get(key) }` pattern (non-atomic check-then-act)
- Database operations without `@Transactional` or `LockModeType.PESSIMISTIC_WRITE`
- Double-checked locking without `volatile` keyword
- `SimpleDateFormat` shared across threads (not thread-safe)

**Ruby:**
- ActiveRecord: `find` then `update` without `lock` or `with_lock`
- Missing `ActiveRecord::Base.transaction` around multi-step database operations
- Thread-shared variables without `Mutex` in Rails (especially in Puma/multi-threaded servers)
- Sidekiq workers that read-modify-write shared database records without locks

**Database-Level (All Languages):**
- `SELECT` followed by `UPDATE` without `FOR UPDATE` clause
- Missing database transactions around operations that must be atomic
- Inventory/balance checks separated from deductions by application logic
- Missing unique constraints that could prevent duplicate inserts in race windows

### Actually Vulnerable
- Payment flow: check balance with `SELECT balance FROM accounts WHERE id=$1`, then debit with `UPDATE accounts SET balance=balance-$2 WHERE id=$1` without `FOR UPDATE` or transaction
- Coupon redemption: check if coupon is used, then mark as used in separate queries
- User registration: check if email exists, then insert -- allows duplicate accounts in race window
- File upload: check if filename exists, then write -- TOCTOU allows overwrite
- Inventory: `SELECT stock FROM products`, check `if stock > 0`, then `UPDATE stock = stock - 1` without row lock
- Go map shared between goroutines with no mutex protection
- Node.js: two concurrent requests both read balance as $100, both debit $80, final balance is $20 instead of insufficient funds
- Python Flask global variable incremented in request handler without lock
- Java `HashMap` shared between servlet threads without synchronization
- Redis `GET key`, check value, `SET key newvalue` instead of using `WATCH`/`MULTI` or Lua script

### NOT Vulnerable
- Read-only operations (no state modification)
- Idempotent operations (same result regardless of how many times executed)
- Single-row atomic updates: `UPDATE accounts SET balance = balance - $1 WHERE id = $2 AND balance >= $1`
- Database operations wrapped in `BEGIN`/`COMMIT` with `SELECT ... FOR UPDATE`
- Go code using `sync.Mutex` or channels to protect shared state
- Python code using `asyncio.Lock` or `threading.Lock` around critical sections
- Java code using `ConcurrentHashMap`, `AtomicInteger`, or `synchronized` blocks
- Redis atomic operations: `INCR`, `DECR`, `SETNX`, Lua scripts
- Operations protected by database unique constraints (duplicate inserts fail safely)
- Optimistic locking with version columns (`WHERE version = $1` on UPDATE)

### Context Check
1. Is shared state modified by concurrent requests, threads, or goroutines?
2. Is there a check-then-act pattern where the check and action are not atomic?
3. Are database operations that must be atomic wrapped in a transaction with appropriate locks?
4. Does the operation involve financial transactions, inventory, or other data where double-processing is harmful?
5. Is file access protected against TOCTOU with atomic operations or advisory locks?
6. Could this code be called concurrently by multiple users or workers?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Identified a check-then-act pattern where the check and action are not atomic
2. [ ] Confirmed the operation involves shared state that can be accessed concurrently (multiple requests, threads, goroutines)
3. [ ] Verified no transaction wrapping with appropriate isolation level or row-level locks
4. [ ] Checked if the operation involves financial data, inventory, or other data where double-processing is harmful
5. [ ] Confirmed no database unique constraints that would prevent duplicate inserts in race windows
6. [ ] Verified no optimistic locking (version columns) that would catch concurrent modifications

### Confidence Scoring
- **HIGH**: Financial transaction (payment, balance debit, inventory deduction) uses separate SELECT-then-UPDATE queries without `FOR UPDATE`, transaction wrapping, or optimistic locking. Or shared mutable state accessed from multiple concurrent threads/goroutines without synchronization.
- **MEDIUM**: Check-then-act pattern exists but the operation is not financial (e.g., duplicate user registration). Or Redis `GET`-then-`SET` used instead of atomic operations but the data is not highly sensitive.
- **LOW**: Code has a potential race condition but the endpoint is rate-limited or the operation is idempotent. Or the pattern looks racy but is single-threaded in practice (Node.js event loop with no concurrent await).
- **SKIP**: All state-modifying operations use atomic database updates, proper transactions with row locks, or optimistic locking with version columns. Read-only operations have no race condition risk.

### Files to Check
- `**/services/**`, `**/handlers/**`, `**/controllers/**`
- `**/payments/**`, `**/billing/**`, `**/checkout/**`
- `**/workers/**`, `**/jobs/**`, `**/tasks/**`
- `**/models/**`, `**/repositories/**`
- `**/*queue*`, `**/*worker*`, `**/*consumer*`
- Database migration files (check for missing unique constraints)
