# Stack hardening: Go

Loaded when stack detection identifies Go (`go.mod`, `.go` files, `net/http`, `database/sql`). Go's
standard library parameterizes SQL and `html/template` auto-escapes — but `net/http` is bare, so
authZ, CSRF, CORS, headers, and rate limiting are all hand-rolled, and the classic trap is using
`text/template` (no escaping) for HTML.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| `fmt.Sprintf` into a SQL string instead of placeholders | SQL injection | 01 |
| `text/template` used to render HTML (no escaping) | XSS | 02 |
| `exec.Command("sh", "-c", userInput)` / shell string-building | command injection | 10 |
| `filepath.Join(base, userInput)` without containment check | path traversal | 29 |
| `http.Get(userURL)` / building outbound requests from input | SSRF / cloud-metadata | 05 / 64 |
| `gob`/`yaml`/`json.Unmarshal` into `interface{}` from untrusted data | insecure deserialization / type confusion | 65 / 67 |
| `regexp.MustCompile(userInput)` / catastrophic patterns | ReDoS | 61 |

## Framework auto-protections (do NOT flag these)

- **`database/sql` / `sqlx` placeholders (`?`, `$1`) parameterize** — only `Sprintf`-built queries
  are SQLi (01).
- **`html/template` auto-escapes** context-aware — safe for HTML. **`text/template` does NOT
  escape** — using it for HTML output is the real XSS sink (02). Check which package is imported.
- `net/http` provides **no** authZ / CSRF / CORS / headers / rate limiting — their absence is a
  real finding, not a framework default. Strong static typing reduces (not eliminates) type
  coercion issues (67).

## Hardening checklist

- Always use `database/sql`/`sqlx` placeholders; never `Sprintf` a query (01).
- Use `html/template` for any HTML response — never `text/template` (02).
- `exec.Command` with an explicit arg slice and no shell; never `sh -c` with interpolation (10).
- Clean + contain file paths: resolve against a base dir and verify the result stays inside it
  (`filepath.Clean` alone is insufficient) (29).
- AuthZ middleware on mutating handlers (28, 04); set security headers explicitly (32); CORS
  allow-list (08); rate limit (07); secrets from env (03).
- Validate/limit request bodies (`http.MaxBytesReader`) and decode into typed structs (30).

## Forbidden claims

- Flagging a placeholder query as SQLi (only `Sprintf`-built — 01).
- Flagging `html/template` output as XSS — it auto-escapes; the sink is `text/template` for HTML (02).
- Calling headers/CSRF/CORS "missing" generically — `net/http` has none by default, so quote the
  specific mutating handler that lacks the control (Rule 1).

---

*Per-stack reference informed by codex-security's curated best-practices model; reimplemented
evidence-first/defensive, cross-referenced to snitch's category numbers. Internal reference.*
