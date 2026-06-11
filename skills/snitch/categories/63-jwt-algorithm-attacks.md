## CATEGORY 63: JWT Algorithm and Key Attacks

### Detection
- JWT libraries: `jsonwebtoken`, `jose`, `jwt-decode`, `pyjwt`, `python-jose`, `jjwt`, `golang-jwt/jwt`, `@fastify/jwt`
- Custom JWT verification code (base64-decoding header, manually checking signature)
- OAuth/OIDC implementations that trust tokens from external IdPs

### What to Search For
- `verify` calls that accept `algorithms: ['none']` or do not pin the `algorithms` option at all
- `decode` used in place of `verify` for anything beyond logging or display
- Verifier that trusts `header.alg` from the token instead of pinning it server-side
- Verifier that selects the signing key by `header.kid` without validating `kid` against an allowlist
- Symmetric HS256 verification where the "secret" is the public RSA/EC key used elsewhere for RS256/ES256 (HS↔RS confusion)
- JWKS fetchers that follow `jku` or `x5u` header URLs from the token itself (attacker-controlled key source)
- Hardcoded, short (<32 bytes), or default HS256 secrets

### Actually Vulnerable
- `jwt.verify(token, key)` with no `algorithms` option in `jsonwebtoken` (older versions respect `header.alg`, allowing `none`)
- Verifier accepting HS256 while configured with an asymmetric public key
- `kid` used as a file path or DB lookup with no validation (kid injection / path traversal)
- `jku` trusted for key discovery with no host allowlist

### NOT Vulnerable
- `algorithms` option pinned to a specific non-`none` algorithm (e.g., `['RS256']`)
- Keys selected by `kid` with an allowlist + strict format check
- Verifier rejects tokens whose `alg` does not match configured expectation
- HS256 used only with a high-entropy secret loaded from env/KMS, never alongside an asymmetric key

### Context Check
1. Is `algorithms` explicitly pinned, and does it exclude `none`?
2. Is the signing algorithm decided by server config, not by `header.alg`?
3. For asymmetric verifiers, is there any path by which HS256 verification could be accepted?
4. How is `kid` resolved — allowlist, or string-concatenated lookup?
5. Are `jku` / `x5u` headers ignored or allowlisted?

### Files to Check
- `**/auth*.ts`, `**/middleware/auth*`, `**/jwt*.ts`, `**/verify*.ts`
- Session / token issuance handlers
- OIDC callback handlers

### References
- CWE-347: Improper Verification of Cryptographic Signature
- CWE-327: Use of a Broken or Risky Cryptographic Algorithm
- OWASP Top 10:2025 — A07 Identification and Authentication Failures
- CVSS 4.0: typically Critical (AV:N, AC:L, full auth bypass)
