## CATEGORY 9: Cryptography
> Type: posture · Groups: — · CWE: CWE-327

### Detection
- Crypto libraries: `crypto`, `bcrypt`, `argon2`, `scrypt`, `jose`
- Hashing functions: `createHash`, `md5`, `sha1` (NOT sha256 or sha512 — those are fine)
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
- SHA-256, SHA-384, SHA-512 in any context (these are strong hashes — not a finding)

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
- `**/auth*.ts`, `**/crypto*.ts`, `**/hash*.ts`
- `**/token*.ts`, `**/password*.ts`
- Encryption and key management utilities
