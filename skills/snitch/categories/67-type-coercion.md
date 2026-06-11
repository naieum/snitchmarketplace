## CATEGORY 67: Type Coercion and Juggling Bypasses

Category 30 (Input Validation) is about whether input is validated at all. This category is about comparisons that *look* like they're validating but are defeated by type coercion — a classic auth-bypass class.

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
- Hash-comparison code using `==` on bcrypt / scrypt / Argon2 outputs (should use the library's `verify`)
- Pattern: string from request compared to a number, or array compared to scalar

### Actually Vulnerable
- PHP `if ($_POST['token'] == $stored_token)` — attacker can submit `token[]=` (array) or numeric `0` to bypass depending on stored shape
- JS `if (req.body.role == "admin")` where `role` can be submitted as array or object (loose equality rules)
- Password compared with `==` enabling timing side-channel
- SQL query like `... WHERE user_id = ?` with a numeric column but the parameter is a non-numeric attacker string that coerces to 0, matching row 0

### NOT Vulnerable
- Strict equality (`===` / `!==`) for auth and identity checks
- Constant-time comparator for secrets
- Input type-checked or coerced (`String(x)`, `parseInt`, zod/joi validation) before comparison
- Use of the library's own verifier (bcrypt.compare, argon2.verify) rather than raw equality

### Context Check
1. Is this comparison on a security-relevant value?
2. Is the comparison loose (`==`) or strict (`===`)?
3. Can the attacker control the type of the submitted value (array vs string vs number)?
4. If comparing secrets, is the comparator constant-time?
5. For SQL, does the column type match the bound parameter type?

### Files to Check
- `**/auth*.{js,ts,php,py,rb,go}`
- `**/middleware/**`, `**/guard*.{ts,py}`, `**/verify*.{ts,py,php}`
- Password reset, session, and token validation endpoints
- Admin / role-check helpers

### References
- CWE-697: Incorrect Comparison
- CWE-1024: Comparison of Incompatible Types
- CWE-208: Observable Timing Discrepancy (for secret comparison without constant-time)
- OWASP Top 10:2025 — A07 Identification and Authentication Failures
- CVSS 4.0: typically High to Critical on auth paths (AV:N, AC:L, auth bypass)
