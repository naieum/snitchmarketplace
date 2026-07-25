## CATEGORY 61: ReDoS
> Type: sink-pattern · Groups: web, performance · CWE: CWE-1333

**Data flow tracing required (SKILL.md Rule 7).** A backtracking-prone regex is only a finding when attacker-controlled, length-unbounded input reaches it. Trace the matched string to its source: hardcoded or small fixed strings, length-capped input (`slice(0, n)`), and linear-time engines (Go / Rust / RE2) are Passes; a nested-quantifier or overlapping-alternation pattern applied to `req.*` without a length cap is a finding. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- Regex literals and `RegExp` / `re.compile` / `Pattern.compile` constructors
- User input passed to regex `.match`, `.test`, `.exec`, `.search`, `.replace`
- Validation libraries with custom regex: `validator.js`, `joi`, `zod` with `.regex()`, `yup` with `.matches()`
- Log parsers, URL parsers, email validators written with regex

### What to Search For
- Nested quantifiers: a group with `+` or `*` inside another group with `+` or `*` (catastrophic backtracking pattern)
- Alternation with overlap: two branches that can match the same characters, wrapped in a repeated group
- Unanchored greedy matches on attacker-controlled strings
- Regex applied to long strings without length cap on the input
- `.replace(/.../g, ...)` where the pattern could backtrack on the input

### Actually Vulnerable
- Email/URL validators with nested quantifier shapes applied to untrusted input
- A user-supplied header, query param, or body field fed to a regex with overlapping alternation
- Middleware that runs regex on `req.body` or `req.url` with no input length limit

### NOT Vulnerable
- Regex applied only to hardcoded or small fixed-size strings
- Patterns that are linear-time (no nested quantifiers, no overlapping alternation)
- Inputs length-capped to a small constant before matching (e.g., `input.slice(0, 64)`)
- Engines with guaranteed linear matching (Go `regexp`, Rust `regex`, RE2) — these cannot ReDoS

### Context Check
1. Can attacker-controlled text reach this regex?
2. Is the input length bounded before matching?
3. Does the pattern contain nested quantifiers or overlapping alternation on a repeated group?
4. Is the language's regex engine backtracking-based (JS, Python, Java, .NET, PCRE) or linear (Go, Rust, RE2)?

### Evidence Chain
- The regex sink (`RegExp`, `.test` / `.match` / `.exec` / `.replace`) at file:line, quoting the nested-quantifier or overlapping-alternation shape that backtracks
- The traced path from the matched string's source (`req.body` / `req.query` / header / param) to that sink
- The absence of a length cap (`slice(0, n)`, max-length schema) anywhere between the source and the sink
- Source classification: attacker-controlled and length-unbounded (finding) vs. hardcoded, small, or fixed-size (Pass)
- The regex engine family: backtracking (JS, Python, Java, .NET, PCRE) vs. linear (Go, Rust, RE2 — cannot ReDoS)

### Confidence Scoring
- **High**: complete trace from unbounded, attacker-controlled input to a proven catastrophic-backtracking pattern on a backtracking engine, with no length cap in between.
- **Medium**: the pattern is backtracking-prone and reachable, but the input length is partially bounded or the source is only partially traced.
- **Low**: pattern flagged heuristically, source un-traceable, or the engine is linear (RE2/Go/Rust) — tag `needs human verification`.

### Files to Check
- `**/validators/**`, `**/middleware/**`, `**/parsers/**`
- `**/schema*.ts`, `**/validate*.ts`
- Route handlers that accept free-form text or URLs

### Reference
- CWE-1333: Inefficient Regular Expression Complexity
- OWASP Top 10:2025 — A06 Insecure Design
- CVSS 4.0: typically Medium to High (AV:N, AC:L, availability impact)
