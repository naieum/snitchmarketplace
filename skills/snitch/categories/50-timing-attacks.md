## CATEGORY 50: Timing Attacks

### Detection
- Non-constant-time string comparison for secrets, tokens, API keys, or MACs
- Password or HMAC verification using `==`, `===`, `.equals()`, or `!=`
- Token comparison in authentication or authorization middleware
- Signature verification without constant-time comparison functions

### What to Search For

**Node.js/TypeScript:**
- `if (token === expectedToken)` or `if (secret == storedSecret)` for auth tokens, API keys, HMAC digests
- `Buffer.compare()` used for secret comparison (returns early on mismatch)
- Missing `crypto.timingSafeEqual()` in token/HMAC verification code
- Webhook signature verification using `===` instead of `crypto.timingSafeEqual()`
- `string1 === string2` where either value is a secret, token, or hash

**Python:**
- `if token == expected_token:` for secret comparison
- `if hmac_digest == computed_digest:` instead of `hmac.compare_digest()`
- `if password_hash == stored_hash:` instead of using a proper password verification function
- Missing `hmac.compare_digest()` or `secrets.compare_digest()` in authentication code
- Webhook signature verification using `==` instead of `hmac.compare_digest()`

**Go:**
- `if token == expectedToken` or `bytes.Equal(mac1, mac2)` for secret comparison
- `strings.EqualFold()` used for secret comparison (not constant-time)
- Missing `subtle.ConstantTimeCompare()` from `crypto/subtle` package
- HMAC verification using `bytes.Equal()` instead of `hmac.Equal()` or `subtle.ConstantTimeCompare()`
- `reflect.DeepEqual()` used for comparing secret byte slices

**Java:**
- `if (token.equals(expectedToken))` for secret comparison
- `Arrays.equals(mac1, mac2)` for HMAC comparison
- Missing `MessageDigest.isEqual()` in token or digest verification
- `String.compareTo()` or `String.contentEquals()` for secret values
- Webhook signature verification using `.equals()` instead of `MessageDigest.isEqual()`

**Ruby:**
- `if token == expected_token` for secret comparison
- Missing `Rack::Utils.secure_compare()` or `ActiveSupport::SecurityUtils.secure_compare()`
- `Digest::SHA256.hexdigest(a) == Digest::SHA256.hexdigest(b)` instead of `secure_compare`
- Webhook signature verification using `==` instead of `secure_compare`

### Actually Vulnerable
- API key validation: `if (req.headers['x-api-key'] === process.env.API_KEY)` -- timing leak reveals key length and character matches
- HMAC webhook verification: `if (computedSig == receivedSig)` in any language
- Token comparison in auth middleware: `if token == stored_token` in Python
- JWT signature verification implementing custom comparison with `==`
- Go HMAC check: `if bytes.Equal(expectedMAC, messageMAC)` instead of `hmac.Equal()`
- Java API token validation: `if (request.getHeader("Authorization").equals(expectedToken))`
- Password reset token verification using direct string comparison
- CSRF token validation using `===` instead of `crypto.timingSafeEqual()`
- Ruby webhook handler: `if Digest::SHA256.hexdigest(payload) == signature`

### NOT Vulnerable
- Comparisons of non-secret values (user IDs, public identifiers, enum values)
- `crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b))` in Node.js
- `hmac.compare_digest(computed, received)` in Python
- `subtle.ConstantTimeCompare([]byte(a), []byte(b))` in Go
- `MessageDigest.isEqual(a, b)` in Java
- `Rack::Utils.secure_compare(a, b)` in Ruby
- Password verification using bcrypt, scrypt, or argon2 libraries (these are constant-time internally)
- Comparisons where the value being compared is not a secret (e.g., content types, HTTP methods)
- Rate-limited endpoints where timing differences are not exploitable in practice
- Comparisons of values that are already public (e.g., user email lookup before password check)

### Context Check
1. Is the value being compared a secret (token, API key, HMAC, signature, hash)?
2. Is a constant-time comparison function available in the language being used?
3. Could an attacker make repeated requests to measure timing differences?
4. Is the comparison in an authentication, authorization, or signature verification path?
5. Is rate limiting in place that would make timing attacks impractical?

### Files to Check
- `**/auth*.ts`, `**/auth*.js`, `**/auth*.py`, `**/auth*.go`, `**/auth*.java`, `**/auth*.rb`
- `**/middleware/**`, `**/verify*`, `**/validate*`
- `**/webhook*`, `**/callback*`, `**/signature*`
- `**/hmac*`, `**/token*`, `**/api-key*`
- `**/crypto*`, `**/security*`

### Confidence Scoring
- **HIGH**: Secret value (API key, HMAC digest, token, signature) compared using `===`, `==`, `.equals()`, or `bytes.Equal()` in an authentication or signature verification path with no rate limiting.
- **MEDIUM**: Non-constant-time comparison on a secret value, but the endpoint has rate limiting that makes timing attacks impractical. Or the comparison is in a secondary validation path (not the primary auth check).
- **LOW**: String comparison found in auth-adjacent code, but the values being compared are not secrets (e.g., user IDs, content types, HTTP methods). Or password verification uses bcrypt/argon2 (constant-time internally).
- **SKIP**: All secret comparisons use constant-time functions (`crypto.timingSafeEqual`, `hmac.compare_digest`, `subtle.ConstantTimeCompare`, `MessageDigest.isEqual`). Or no custom secret comparison exists (auth delegated to a provider).

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the value being compared is a secret (token, API key, HMAC, signature, hash) — not a public identifier
2. [ ] Verified a non-constant-time comparison operator is used (`===`, `==`, `.equals()`, `bytes.Equal()`)
3. [ ] Confirmed the comparison is in an authentication, authorization, or signature verification code path
4. [ ] Checked whether rate limiting exists on the endpoint (makes timing attacks impractical)
5. [ ] Verified no constant-time comparison function is used anywhere in the same flow
6. [ ] Confirmed the attacker can make repeated requests to measure timing differences
