## CATEGORY 30: Input Validation & ReDoS
> Type: sink-pattern · Groups: infra-supply-chain · CWE: CWE-20

**Data flow tracing required (SKILL.md Rule 7).** Trace each user-supplied value to its sink before reporting: a path joined from `req.*` (traversal), an object merge whose source is `req.body` / user config (prototype pollution), or a backtracking regex applied to user input (ReDoS). Literals, `path.resolve` + allow-list checks, explicit field-picking, and upstream schema validation are Passes — a flagged regex or merge with a hardcoded / internal source is not a finding. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- File system operations with user input
- Object merge/assign patterns with external data
- Regular expressions in validation or parsing
- Request body handling configuration
- Template literals with dynamic content

### What to Search For
- Path traversal: `../` in user input passed to file system operations (`fs.readFile`, `path.join`)
- Prototype pollution: `__proto__`, `constructor.prototype` in object merge/spread/assign
- ReDoS: Regex with nested quantifiers (e.g., `(a+)+`, `(a|a)*`, `(.*a){x}`)
- Missing request body size limits on Express/Fastify
- `Object.assign` or spread with untrusted input without property filtering
- Template literal injection in non-SQL contexts (log forging, header injection)

### Actually Vulnerable
- `fs.readFile(path.join(baseDir, req.query.file))` without sanitizing `../` sequences
- `Object.assign(config, req.body)` allowing `__proto__` pollution
- Regex like `/^(a+)+$/` used to validate user input (catastrophic backtracking)
- Express app with no `express.json({ limit: '...' })` body size configuration
- `lodash.merge(defaults, userInput)` with unsanitized user input

### NOT Vulnerable
- File paths validated against an allowlist or using `path.resolve` with base dir check
- Object merge with explicit property picking (`{ name, email } = req.body`)
- Simple regex without nested quantifiers
- Body parser with explicit size limits configured
- Input validated through schema validation (Zod, Joi, Yup)

### Context Check
1. Does user input flow into file system operations?
2. Is object merging done with explicit property selection or raw input?
3. Does the regex have nested quantifiers that could cause backtracking?
4. Is there a body size limit configured on the HTTP framework?

### Evidence Chain
A finding's Evidence block must show:
- The sink file:line — the file system operation, object merge/assign, regex application, or template literal receiving the value
- The traced variable path from source to sink, hop by hop (e.g., `req.query.file` → `path.join` → `fs.readFile`)
- Sanitizers checked along the path and shown absent: `path.resolve` + base-dir/allow-list check, explicit property picking, schema validation (Zod/Joi/Yup), body size limits
- Source classification: user-controlled (`req.*`, params, user config) vs. hardcoded/internal — an internal source is not a finding
- For ReDoS: the regex pattern quoted with its nested quantifier, plus the file:line where user input reaches it

### Confidence Scoring
- **High**: complete source→sink trace from user input with no sanitizer on the path (e.g., `req.query.file` into `path.join` into `fs.readFile`; `Object.assign(config, req.body)`; backtracking regex validating request input)
- **Medium**: sink and pattern present but one hop of the trace is indirect (helper function, middleware), or validation may occur upstream but is not confirmed at the call site
- **Low**: the source cannot be classified (dynamic dispatch, external caller) or the regex's input origin is un-traceable — tag `needs human verification`

### Files to Check
- `**/api/**/*.ts`, `**/routes/**/*.ts`
- `**/middleware/**/*.ts`, `**/server*.ts`
- `**/validation/**/*.ts`, `**/utils/**/*.ts`
- Express/Fastify app configuration files
