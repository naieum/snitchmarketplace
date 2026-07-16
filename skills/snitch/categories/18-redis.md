## CATEGORY 18: Redis/Cache Security
> Type: posture · Groups: modern-stack · CWE: CWE-312

### Detection
- `@upstash/redis`, `ioredis`, `redis` imports
- `REDIS_URL`, `UPSTASH_REDIS_REST_URL` environment variables

### What to Search For
- Redis credentials in client code
- Unencrypted sensitive data in cache
- Missing authentication

### Actually Vulnerable

#### Critical
- `UPSTASH_REDIS_REST_TOKEN` in client-side code
- `REDIS_URL` with password in frontend
- Redis connection strings in `NEXT_PUBLIC_*` variables

#### High
- No authentication on Redis commands (open Redis instance)
- Storing sensitive data (tokens, PII) without encryption
- Cache keys predictable from user input (cache poisoning)

#### Medium
- No TTL on cached sensitive data
- Serializing full objects with sensitive fields

### NOT Vulnerable
- Redis credentials in server-only code
- Encrypted values in cache
- Public/non-sensitive data cached without encryption

### Context Check
1. Is Redis/cache used server-side only or accessible from client code?
2. Is the cached data sensitive (tokens, PII) or public/non-sensitive?
3. Are cache keys unpredictable or derived from user input?
4. Is there a TTL set on sensitive cached data?

### Evidence Chain
- The config/code snippet at file:line (e.g. `UPSTASH_REDIS_REST_TOKEN` referenced in a client component, or a cache `set` call storing a token/PII field in plaintext)
- Whether the file is client-shipped or server-only (`NEXT_PUBLIC_*` prefix, `use client` directive, import graph)
- The sensitivity of the cached data (tokens/PII vs public), established from the value being stored — not just the key name
- The missing control quoted absent at the call site (no encryption, no TTL, cache key derived from raw user input)
- Impact link: how the weakness is reachable (exposed credential, unauthenticated instance, predictable/poisonable cache key)

### Confidence Scoring
- High: Redis credential unambiguously in client-delivered code, or a sensitive value verifiably cached in plaintext at the quoted call site
- Medium: cached data looks sensitive but its classification is partly inferred, or auth/TTL/eviction may be configured outside the repo (managed Redis settings)
- Low: cannot determine whether the code is client-shipped or whether the cached data is sensitive → tag `needs human verification`

### Files to Check
- `**/redis*.ts`, `**/cache*.ts`
- `lib/redis.ts`, `lib/cache.ts`
- `.env*`
