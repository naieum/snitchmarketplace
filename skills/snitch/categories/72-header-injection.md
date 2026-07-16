## CATEGORY 72: HTTP/Protocol Header Injection
> Type: sink-pattern · Groups: web · CWE: CWE-113

User input concatenated into HTTP request headers, response headers, or any line-based protocol field, without stripping CR / LF / control characters. The attacker injects a delimiter (typically `\r\n`) and smuggles an extra header, an extra protocol field, or a fake response. Old class (CWE-93, CWE-113, CWE-74), still landing high-severity CVEs in 2026 because protocol parsers are everywhere AI-generated code reaches: webhook dispatchers, request-forwarding proxies, custom auth middleware, internal service callers. CVE-2026-3854 (GitHub Enterprise Server RCE, April 2026) was exactly this pattern: a push option value with a delimiter char escalated to RCE on the appliance.

**Data flow tracing required (SKILL.md Rule 7).** Trace every value written into a header sink (`res.setHeader`, `res.writeHead`, `response.headers.set`, `fetch({ headers })`, `axios.defaults.headers`, custom protocol writers) back to its source. Hardcoded header values are Passes. Header values built from `req.*` / cookies / OAuth state / push options / webhook payload / agent output without CR/LF stripping or value escaping are findings. The trace must reach the actual write call: header values often flow through `setCors(req, res)` style helpers where the unsafe write hides one layer down.

### Detection
- Any code that builds an HTTP header value from a request body, query string, header, cookie, path segment, or any other input the caller controls.
- Target functions / properties: `fetch(..., { headers: { ... } })`, `Headers.set()`, `Headers.append()`, `axios.get(..., { headers: ... })`, `http.request({ headers: ... })`, `XMLHttpRequest.setRequestHeader()`, `Response.headers.set()`, framework reply helpers that don't auto-sanitize.
- Look for string concatenation, template literals, or property assignment where the right-hand side is user-derived and the left-hand side is a header name.
- Also look at logging libraries that write user input to access logs without escaping (CRLF log forging — same family, lower severity).

### What to Search For

**Outbound headers built from request input:**
- `headers: { "X-Forwarded-User": req.headers["x-user"] }` — passes an inbound header straight through to an outbound call.
- `headers: { Authorization: \`Bearer ${req.body.token}\` }` — interpolates user input into an Authorization header.
- `headers.set("X-Webhook-Source", req.body.source)` — explicit set with no sanitization.
- Custom proxy / API-gateway code: copying every `req.headers` entry into the outbound request without filtering control chars.

**Inbound-to-outbound forwarding without filtering:**
- Webhook dispatch that takes a customer-supplied URL + custom header map and sends the outbound request as-is.
- Request-replay endpoints (debug consoles, admin tools) that take a header dict from JSON and pass it to `fetch`.
- Reverse-proxy code (e.g., on Cloudflare Workers, Express, Hono) that does `init.headers = req.headers` without stripping CR/LF.

**Protocol-field smuggling (the GHES bug shape):**
- Code that takes a user-controlled option/parameter and appends it to a string built with a known delimiter — `\n`, `\r\n`, `;`, null byte, or a custom delimiter the protocol uses to separate fields.
- Pattern: `internalHeader = "field1=" + value1 + "\nfield2=" + value2` where any of the values is user-supplied and unescaped.
- Common in: build-tool wrappers, internal-RPC clients, anything wrapping a wire protocol that uses line-based framing.

**Response-side splitting (older shape, still relevant):**
- `res.setHeader("Set-Cookie", req.query.session)` — user input flows into a response header, can split the response.
- Redirect helpers: `res.setHeader("Location", req.body.next)` without URL validation can also leak via embedded `\r\n`.

### Actually Vulnerable
- A webhook dispatcher takes `customHeaders` from a customer's webhook config and passes them straight to `fetch`. Customer sets `X-Custom: foo\r\nX-Internal-Auth: stolen-value` — the outbound request now carries an unintended `X-Internal-Auth` header that the receiving service trusts.
- A reverse-proxy on Cloudflare Workers does `headers: { ...incomingReq.headers, "X-Forwarded-For": ip }` — an inbound header containing `\r\n` smuggles arbitrary headers into the upstream request.
- A custom build-tool wrapper takes `--build-arg` values from a CI variable and injects them into an internal HTTP header that drives container provisioning. Attacker controls the variable, smuggles a privileged-mode field. (Same shape as CVE-2026-3854.)
- An admin-only "replay request" debug endpoint takes a JSON header map and forwards it. Compromised admin session escalates to internal-service access via header injection.
- A logging shim writes `console.log("login attempt: " + email)` where email is user-supplied. Email contains `\nALERT: account locked` — the log line is now two lines, the second one looks like a system event to the log analyzer.

### NOT Vulnerable
- Header values built only from server-side constants, env vars, or values that have already passed a typed schema (Zod, Pydantic) where the schema rejects strings containing CR/LF.
- Header values that pass through a known sanitizer: `sanitizeHeader()`, `encodeURI()` (for the path/query case), framework helpers that explicitly strip CR/LF (e.g., the `Response` constructor in undici / Cloudflare Workers throws on header values containing `\n`).
- Authorization tokens generated server-side (JWT signed locally, opaque tokens from a secrets manager) — the format guarantees no embedded delimiters.
- Response headers built by the framework's structured helpers (`res.cookie()` in Express with the `signed` option, Fastify `reply.setCookie()`) where the helper handles encoding.
- Test fixtures, mocks, and obvious test files (`*.test.*`, `*.spec.*`, `__tests__/`).

### Context Check
1. Is the value's source actually user-controlled? Trace it back. Hardcoded strings, env vars, and server-generated tokens are not user input.
2. Does the runtime already reject CR/LF in header values? Modern fetch implementations (undici, Workers, Deno) throw on invalid header chars — this turns a vulnerability into a 500 error, not exploitation. Older `node:http`, axios with a custom transport, or string-templated raw HTTP calls do NOT have this guard.
3. Is the receiver a trust boundary? Header injection into a header that another service trusts (`X-Internal-Auth`, `X-User-Id`) is critical. Header injection into a header the receiver ignores (a vanity `X-Trace-Id`) is low-impact.
4. Is there a sanitizer between the input and the header? `value.replace(/[\r\n]/g, '')`, `sanitizeHeader()`, or a regex-validated schema are all valid mitigations. If the sanitizer runs, the pattern is fine.
5. Is the code path even reachable in production? Header-building code in dev-only debug routes (gated behind `if (env.DEV)`) is not a production exposure.

### Evidence Chain
- The header write sink quoted at file:line (`res.setHeader`, `headers.set`, `fetch({ headers })`, `writeHead`, custom protocol writer)
- The traced variable path from source to the write call, including helper hops (`setCors(req, res)`-style indirection), with file:line for each hop
- Source classification stated explicitly: request header / body / query / cookie / webhook config / CI variable / push option / agent output
- Sanitizers checked and found absent: CR/LF stripping (`replace(/[\r\n]/g, '')`, `sanitizeHeader()`), a typed schema rejecting control chars, or a runtime guard (undici / Workers / Deno throwing on invalid header chars)
- The receiver-side impact link: which downstream service or client trusts the injectable header (e.g., `X-Internal-Auth`), or why response splitting / protocol-field smuggling is exploitable in this path

### Confidence Scoring
- **High**: complete trace from user-controlled input to a header write on a runtime that does not reject CR/LF, with no sanitizer in the path, and a receiver that trusts the injectable field
- **Medium**: trace complete but the runtime likely rejects invalid header chars (turning the exploit into a 500), or the sink is confirmed while the receiver's trust in the header is unconfirmed
- **Low**: header value derives from input whose format is constrained upstream (server-generated token, validated enum) or the path appears dev-only/unreachable and could not be fully traced — tag `needs human verification`

### Files to Check
- `**/proxy*.{ts,js}`, `**/forward*.{ts,js}`, `**/gateway*.{ts,js}` (request-forwarding code)
- `**/webhook*.{ts,js}`, `**/dispatch*.{ts,js}` (outbound webhook dispatchers with custom header maps)
- `**/middleware/**` (custom auth / CORS helpers that write headers)
- API routes and handlers that call `res.setHeader` / `res.writeHead` / `headers.set` / `fetch` with constructed headers
- Logging shims and access-log formatters (CRLF log forging)

### Reference

The CVE-2026-3854 disclosure (April 2026) is the canonical recent example. A push-option value the user supplied via `git push --push-option=...` was concatenated into an internal HTTP header that GHES used to drive a service call; a delimiter character in the value smuggled an extra metadata field that escalated to RCE. The fix shape is universal: sanitize CR/LF/control chars at the point you build the header value, not at the wire.

A safe reference sanitizer:

```js
function sanitizeHeader(value) {
  return value
    .replace(/[\r\n\t\u0000-\u001F\u007F]/g, " ")
    .trim()
    .slice(0, 998);
}
```

Strips CR / LF / tab / control chars, replaces with a space, trims, clamps to RFC-allowed line length (998 chars). Safe to apply at the boundary even when the runtime would also reject; defense in depth is appropriate for header construction.

OWASP: A05:2025 Injection. CWE selection by finding shape: request-side / outbound header injection (CRLF or header smuggling into outbound requests) → CWE-93 (Improper Neutralization of CRLF Sequences); response-side splitting → CWE-113 (HTTP Response Splitting, the manifest anchor); non-HTTP line-based protocol smuggling → CWE-74 (Injection family).
