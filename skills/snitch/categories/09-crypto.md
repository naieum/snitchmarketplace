## CATEGORY 9: Cryptography
> Type: posture · Groups: — · CWE: CWE-327

### Detection
- Crypto libraries: `crypto`, `bcrypt`, `argon2`, `scrypt`, `jose`
- Hashing functions: `createHash`, `md5`, `sha1`, and **`sha256`/`sha512` — do not skip the SHA-2 family at detection.** Whether a SHA-2 hash is a finding depends on what is being hashed, which you cannot know without matching it first
- Encryption patterns: `createCipheriv`, `encrypt`, `decrypt`

### What to Search For
- MD5/SHA1 for password hashing
- Math.random for security tokens
- Hardcoded encryption keys
- Weak cipher modes

### Actually Vulnerable
- Weak hashes for password storage
- Predictable random for security purposes
- Encryption keys in source code
- ECB mode or deprecated ciphers

### NOT Vulnerable
- MD5/SHA1 for checksums only
- Secure random functions for tokens
- bcrypt/argon2/scrypt for passwords
- Keys from environment variables
- SHA-256, SHA-384, SHA-512 over a **high-entropy** value — a checksum, content address, HMAC, signature, or the digest of a randomly generated API key / session token / reset token (>=128 bits from a CSPRNG). The value is unguessable, so no work factor is needed and a bare digest is correct, standard design

**Strength of primitive is not fitness for purpose.** SHA-2 is a strong *digest* and an unfit
*password KDF*; both statements are true at once. The discriminator is **the entropy of the input**,
never the strength of the hash:

| Input being hashed | Disposition |
|---|---|
| Random secret from a CSPRNG (API key, session/reset token) | **Pass** — bare SHA-2 digest is correct |
| Checksum, content address, HMAC, signature | **Pass** |
| A user-chosen password, passphrase, or PIN | **Finding, High** — CWE-916 (+ CWE-759 when unsalted). Single-pass fast hash on a guessable secret, whatever the algorithm |
| A **presented** credential hashed to look up a stored digest | **Pass** — classify by the entropy of the value that was *stored*, traced to where it was minted, not by the parameter in front of you |

Trace the hashed value to its source before deciding — two calls to the same hash function on the
same line of code get opposite dispositions purely from where their input came from.

**On a verification path, trace to the mint site, not to the parameter.** A lookup function hashes
whatever the caller presented, so that argument is attacker-controlled and low-entropy *by
construction* — an attacker can present anything. Judging it as "input" grades every credential
check as a password-hashing finding. The question is what the digest it is compared against was
minted from: find where the stored value is created (usually a sibling function writing the same
table) and classify from there. If the mint site is outside the scan scope, say so and drop to
Medium confidence rather than assuming either way.

### Context Check
1. Is the weak hash used for password storage or non-security purposes (checksums)?
2. Is Math.random used for security tokens or UI randomization?
3. Are encryption keys loaded from environment or hardcoded?

### Evidence Chain
- Quote the weak-crypto call site file:line (e.g. `createHash('md5')`, `Math.random()`, `createCipheriv` with ECB/deprecated cipher, or the hardcoded key literal)
- Show what the primitive protects: link the hash/random/cipher output to its downstream use (password storage, session/reset token, encrypted data at rest)
- For hardcoded keys: quote the key literal in source and confirm it is not a placeholder or test fixture
- For weak hashes/random: state why the use is security-relevant (not a checksum, cache key, or UI randomization)
- Note the absence of a strong alternative on the same path (no bcrypt/argon2/scrypt wrapping, no `crypto.randomBytes` fallback)

### Confidence Scoring
- **High**: Weak primitive with unambiguous security use — MD5/SHA1 hashing a password before storage, Math.random generating a session/reset token, a real encryption key string committed in source, or ECB mode encrypting sensitive data.
- **Medium**: Weak primitive present but its purpose is only partially clear from context — the hashed or encrypted value's downstream use can't be fully confirmed, or the key literal might be a test/dev placeholder.
- **Low**: Crypto library usage detected but the data being protected and the code path are un-traceable from the audited files — tag `needs human verification`.

### Files to Check
- Do not rely on filename globs alone here — credential handling routinely lives in files named for
  the *domain* (`accounts`, `users`, `session`, `signup`, `members`) rather than for crypto. The
  Detection greps above are the reliable path; treat the globs below as a starting set, not a scope
- `**/auth*.ts`, `**/crypto*.ts`, `**/hash*.ts`
- `**/token*.ts`, `**/password*.ts`
- Encryption and key management utilities
