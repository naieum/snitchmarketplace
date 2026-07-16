## CATEGORY 12: Logging & Data Exposure
> Type: posture · Groups: web · CWE: CWE-532

### Detection
- Logging libraries: `winston`, `pino`, `morgan`, `bunyan`, `console.log`
- Error handling: `catch` blocks, error middleware, error boundary components
- Debug configuration: `DEBUG=*`, `NODE_ENV` checks

### What to Search For
- Sensitive data in logs
- Stack traces to clients
- Debug mode in production
- Verbose error responses

### Actually Vulnerable
- Passwords or tokens in log statements
- Stack traces returned in API responses
- Debug enabled in production config

### NOT Vulnerable
- Logging without sensitive data
- Development-only verbose errors
- Redacted logging
- Error tracking with PII filtering

### Context Check
1. Does the log statement include sensitive data (passwords, tokens, PII)?
2. Is verbose error output guarded by a NODE_ENV check?
3. Is this a development/debug log or production logging?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Log statement or error response is in production code (not dev-only debug logging)
2. [ ] Sensitive data (passwords, tokens, PII, secrets) actually flows into the log/response (trace the variable)
3. [ ] No redaction or filtering applied before logging/responding
4. [ ] Verbose error output is not guarded by NODE_ENV or environment check
5. [ ] Log output goes to a persistent destination (file, service) or error response is sent to clients

### Confidence Scoring
- **HIGH**: console.log or logger call with password, token, session, credit card, or PII variables. Full stack trace returned in API error response with no NODE_ENV guard. DEBUG=* or verbose mode enabled in production config.
- **MEDIUM**: Log statement includes a variable that could contain sensitive data but the variable name is ambiguous. Error response includes error details but may be guarded by an environment check elsewhere.
- **LOW**: Logging library is configured but unclear what data flows into it. Error handling exists but need to verify if sensitive data is included.
- **SKIP**: Logging explicitly redacts sensitive fields. Error responses return generic messages in production. Verbose errors guarded by NODE_ENV !== 'production'. Error tracking uses PII filtering (Sentry data scrubbing, etc.).

### Files to Check
- `**/logger*.ts`, `**/logging*.ts`
- `**/error*.ts`, `**/middleware*.ts`
- Error boundary components, API error handlers

### Error Handling Security (OWASP A10:2025)

Mishandling of exceptional conditions can expose sensitive data and create security vulnerabilities.

#### What to Search For
- `res.status(500).json({ error: err.message })` or `res.send(err.stack)` — exposing internal error details to clients
- Generic catch blocks: `catch (e) {}` or `catch (e) { /* ignore */ }` — swallowing errors silently (failing open)
- Missing finally blocks for resource cleanup (database connections, file handles, locks)
- Missing global error handler: no `process.on('unhandledRejection')` or Express `app.use((err, req, res, next))`
- Error response differentiation: different HTTP status codes or messages for "user not found" vs "password wrong" (enables user enumeration)
- Try/catch without logging: errors caught but never logged (silent failures)
- Returning raw database error messages to clients (SQL errors, connection strings in error text)

#### Actually Vulnerable
- `catch (err) { res.json({ error: err.toString() }) }` — leaks internal error details
- `catch (err) { }` — silently swallows errors, application continues in potentially invalid state
- Database connection opened in try block but not closed in finally — resource leak on error
- Different error messages for invalid username vs invalid password — user enumeration

#### NOT Vulnerable
- Generic error responses: `res.status(500).json({ error: "Internal server error" })` — safe
- Structured logging with error details server-side only (Pino, Winston) — safe
- Sentry/Datadog error capture that redacts sensitive fields — safe
- Global error boundary in React (componentDidCatch) — frontend error handling, not a data leak
