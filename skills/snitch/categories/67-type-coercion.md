## CATEGORY 67: Type Coercion & Juggling Bypasses
> Type: sink-pattern · Groups: web · CWE: CWE-697

Category 30 (Input Validation) is about whether input is validated at all. This category is about comparisons that *look* like they're validating but are defeated by type coercion — a classic auth-bypass class.


**Data flow tracing required (SKILL.md Rule 7).** A loose comparison is safe or exploitable purely
according to what types its source can produce, and that fact is never visible at the comparison
itself. For every `==` / `!=` reaching an authorization decision, a secret, or a hash, trace the
compared value to its origin and classify the **parser**, not just the taint: form encoding
(`$_POST`, `$_GET`, `req.body` urlencoded) yields strings and arrays; JSON (`json_decode(..., true)`,
`express.json()`) yields booleans, nulls, numbers and objects too. A literal or a value that passed
through a type-narrowing check is a Pass. A value whose type the attacker chooses, reaching a loose
comparison, is a finding — and the same line of code flips between the two on the source alone.

### Detection
- **JavaScript/TypeScript:** `==` and `!=` used in comparisons involving auth, capability, or identity data (role, userId, token, csrfToken, isAdmin, password). `Boolean(x)` / truthy checks on user-supplied strings. Loose `switch` behavior.
- **PHP:** `==` and `!=` in auth checks, especially password or hash comparison. `in_array($needle, $haystack)` without the strict third argument.
- **Python:** `==` comparisons between user input and boolean / numeric values (`input == True`, `val == 1`). Implicit truthiness on container types.
- **Ruby:** `==` between String and Symbol when params come in as String.
- **Go:** map access with `value, _ := m[key]` followed by truthiness check instead of the `ok` boolean.
- **SQL:** implicit coercion — e.g., MySQL `"foo" = 0` evaluating to true, numeric columns compared to non-numeric user strings.

### What to Search For
- Loose equality in any code path that decides access, identity, or privilege
- Password / token / HMAC comparison with regular `==` instead of a constant-time comparator (`crypto.timingSafeEqual`, `hmac.compare_digest`, `hash_equals`)
- `in_array` / `indexOf` / `includes` on untrusted input without type pinning
- Hash comparison with `==`. **The output alphabet decides whether this is a total bypass or only a
  timing leak, and the risk ordering is the opposite of what it looks like:**
  - `md5` / `sha1` emit pure hex, so roughly 1 in 340 outputs match `^0e\d+$`. PHP reads those as
    floats in scientific notation, so **any two `0e…` digests compare equal**. Verified:
    `md5('240610708')` and `md5('QNKCDZO')` are both `0e…` and `==` between them is TRUE on 8.3.32
    and 7.4.33, and remains TRUE under `declare(strict_types=1)`. `===` is false. This is a complete
    authentication bypass, not a nicety.
  - `bcrypt` / `scrypt` / `Argon2` outputs start `$2y$` / `$argon2`, never numeric, so `==` on them
    cannot collide — the finding there is the **timing side-channel** only.
  Either way the fix is the library verifier (`password_verify`) or `hash_equals`, never `===`.
- Pattern: string from request compared to a number, or array compared to scalar

### Actually Vulnerable
- PHP loose comparison against a string constant, e.g. `if ($claims['role'] == 'admin')`.
  **Anchor every PHP claim to a version — the shapes changed in 8.0 and most published payloads are stale.**
  Verified against php:8.3.32 and php:7.4.33:

  | Payload | PHP 7.4 | PHP 8.3 | Still a bypass? |
  |---|---|---|---|
  | `role` is boolean `true` | TRUE | **TRUE** | **Yes — the live one.** A non-empty, non-`"0"` string is truthy, so any truthy non-string compares equal to it. PHP 8.0 did not touch bool-vs-string |
  | `role=0` (numeric) | TRUE | false | No — killed by the 8.0 string-to-number RFC |
  | `role[]=admin` (array) | false | false | No — array-vs-string `==` was never true. This shape belongs to the `strcmp($a,$b)==0` bypass, where an array argument returned NULL and `NULL==0` was true pre-8.0. Different sink |
  | two numeric strings, `'1e2'` vs `'100'` | TRUE | TRUE | **Yes** — numeric-string vs numeric-string still compares numerically |
  | `'100 '` vs `'100'` (trailing space) | false | **TRUE** | **Yes, and 8.0 made this worse** — it widened numeric strings to permit trailing whitespace |

  **The boolean case is the one that matters, and whether it is reachable depends on the source.**
  `$_POST` / `$_GET` yield strings (and arrays via `?x[]=`), so the bug is usually unexploitable there.
  `json_decode($body, true)` carries JSON's full type lattice into PHP, so the attacker picks the
  type — a body of `{"role": true}` authenticates. Trace the source before rating.
- JS `if (req.body.role == "admin")` where `role` can be submitted as array or object (loose equality rules)
- Password compared with `==` enabling timing side-channel
- SQL query like `... WHERE user_id = ?` with a numeric column but the parameter is a non-numeric attacker string that coerces to 0, matching row 0

### NOT Vulnerable
- Strict equality (`===` / `!==`) for auth and identity checks
- Constant-time comparator for secrets
- Input type-checked or coerced (`String(x)`, `parseInt`, zod/joi validation) before comparison
- PHP: `===`, `hash_equals()`, or `password_verify()`. **`declare(strict_types=1)` is NOT a
  mitigation** — it governs coercion at function-call boundaries only and has no effect whatever on
  the `==` operator. Verified: all three bypasses above still fire under it. It is also a property of
  the *calling* file, so it does not reliably constrain even the signatures it declares. A `string`
  parameter type does not help either: two strings is precisely the magic-hash precondition
- Use of the library's own verifier (bcrypt.compare, argon2.verify) rather than raw equality

### Context Check
1. Is this comparison on a security-relevant value?
2. Is the comparison loose (`==`) or strict (`===`)?
3. Can the attacker control the **type** of the submitted value — string, number, array, **boolean, or null**? Boolean is the live bypass on current PHP and is the one most often omitted. The answer depends on the parser: form encoding yields strings and arrays; JSON yields the full type lattice.
4. If comparing secrets, is the comparator constant-time?
5. For SQL, does the column type match the bound parameter type?

### Evidence Chain
- The comparison quoted at file:line, showing the loose operator or unsafe pattern (`==`, `in_array` without strict, truthy check on a user string)
- What the comparison guards: the auth/identity/privilege decision it feeds (role check, token validation, password verification), with file:line
- The attacker-controllable side: where the compared value enters (`req.body`, `$_POST`, params) and whether its type can be shaped by the attacker (array vs string vs number, Symbol vs String)
- Mitigations checked and shown absent: no strict equality, no schema/type validation before the comparison, no constant-time comparator, no library verifier (`bcrypt.compare`, `argon2.verify`)

### Confidence Scoring
- **High**: loose comparison on a security decision where the compared value traces to request input with no type pinning (e.g., PHP `==` on a token, JS `==` role check on `req.body`), or a secret compared with plain `==` on a reachable auth path
- **Medium**: loose comparison on a security-relevant value but attacker type control unconfirmed (value passes through a framework layer that may coerce), or a non-constant-time secret comparison whose reachability is unclear
- **Low**: loose equality on values that appear internally generated or already type-validated upstream, where the coercion path could not be traced — tag `needs human verification`

### Files to Check
- `**/auth*.{js,ts,php,py,rb,go}`
- `**/middleware/**`, `**/guard*.{ts,py}`, `**/verify*.{ts,py,php}`
- Password reset, session, and token validation endpoints
- Admin / role-check helpers

### Reference
- CWE-697: Incorrect Comparison
- CWE-1024: Comparison of Incompatible Types
- CWE-208: Observable Timing Discrepancy (for secret comparison without constant-time)
- OWASP Top 10:2025 — A07 Identification and Authentication Failures
- CVSS 4.0: typically High to Critical on auth paths (AV:N, AC:L, auth bypass)
