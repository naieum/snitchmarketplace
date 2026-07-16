## CATEGORY 62: Prototype Pollution
> Type: sink-pattern · Groups: web · CWE: CWE-1321

**Data flow tracing required (SKILL.md Rule 7).** For every recursive merge / clone / assign-by-string-key sink this category surfaces (`_.merge`, `_.defaultsDeep`, `Object.assign(target, untrusted)`, dynamic `obj[key1][key2] = value` with user-controlled `key1`, JSON.parse output spread into existing objects), trace the source-object's path back. Static-object merges are Passes. Merges of `req.body` / parsed JSON / query strings without a key-name allow-list are findings. The classic shape: `mergeDeep(config, req.body)` where `req.body.__proto__.isAdmin = true` flips a global.

### Detection
- Object merge / deep-merge utilities: `lodash.merge`, `lodash.defaultsDeep`, `lodash.set`, `deepmerge`, `object-assign-deep`, custom recursive merge functions
- Libraries known-vulnerable in older versions: `minimist` <1.2.6, `yargs-parser` <15.0.1, `lodash` <4.17.21, `set-value`, `mixin-deep`
- `JSON.parse` followed by spread into config or merge into existing object
- Query-string parsers that build nested objects from user input (`qs`, `express` body parser with `extended: true`)
- Direct bracket assignment from user-controlled keys: `obj[userKey] = userValue`

### What to Search For
- Deep-merge or `set`-by-path calls whose key source traces back to `req.body`, `req.query`, `req.params`, or parsed JSON from an external source
- Recursive merge functions that copy own AND inherited properties (no `Object.prototype.hasOwnProperty.call` guard)
- Bracket-assignment where the key variable is not validated against a known allowlist
- Code that reads from `obj.__proto__`, `obj.constructor.prototype`, or dynamic `["__proto__"]` access

### Actually Vulnerable
- Deep-merge of user JSON into a shared config, options, or context object
- Query parser with `extended: true` + downstream deep-merge into a template / mongoose query / feature-flag lookup
- Custom recursive merge with no check that the destination key is an own property

### NOT Vulnerable
- Merge targets created fresh with `Object.create(null)` (no prototype chain to pollute)
- Libraries patched to versions that block `__proto__` and `constructor` keys
- Validation layer (zod / joi / ajv) that strips unknown keys before the merge
- Keys pulled from a fixed allowlist before assignment

### Context Check
1. Does the merge/assignment key trace back to untrusted input?
2. Are `__proto__`, `constructor`, and `prototype` keys explicitly rejected?
3. Is the target a plain `{}` literal (has `Object.prototype`) or a null-prototype object?
4. Does a downstream lookup use `obj[dynamicKey]` or `in` checks that could hit the polluted prototype?

### Evidence Chain
- The merge/assign sink (`_.merge`, `_.defaultsDeep`, `_.set`, `Object.assign(target, …)`, or dynamic `obj[k1][k2] = v`) at file:line
- The traced path from the key/object source (`req.body` / `req.query` / `req.params` / parsed JSON) to that sink
- The absence of a proto-key guard (`__proto__` / `constructor` / `prototype` rejection, key allowlist, `hasOwnProperty` check, or null-prototype target) anywhere between source and sink
- Source classification: untrusted user input (finding) vs. static or server-built object (Pass)
- Where available, the downstream gadget the polluted prototype flips (auth flag, template behavior, query object)

### Confidence Scoring
- **High**: complete trace of user-controlled keys into a recursive merge or set-by-path on a plain `{}` target with no proto-key rejection.
- **Medium**: the merge/assign sink is reachable but the key source is only partially traced, or a partial guard is present.
- **Low**: heuristic match or un-traceable key source — tag `needs human verification`.

### Files to Check
- `**/middleware/**`, `**/config*.ts`, `**/options*.ts`
- Request body handlers, query string processors
- Template engines and rendering utilities (pollution often changes template behavior)

### Reference
- CWE-1321: Improperly Controlled Modification of Object Prototype Attributes
- OWASP Top 10:2025 — A05 Injection
- CVSS 4.0: typically High (AV:N, AC:L, impact varies by gadget available)
