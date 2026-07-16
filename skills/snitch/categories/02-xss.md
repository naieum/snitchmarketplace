## CATEGORY 2: Cross-Site Scripting (XSS)
> Type: sink-pattern · Groups: web, quick-core · CWE: CWE-79

**Data flow tracing required (SKILL.md Rule 7).** For every `innerHTML =`, `dangerouslySetInnerHTML`, Vue `v-html`, Angular `[innerHTML]`, or unescaped template substitution this category surfaces, trace the value back to its source. Literals are Passes. Server-rendered values that already passed through `DOMPurify` / a sanitizer are Passes (record the sanitizer's file:line). Values flowing from `req.*` / `params.*` / message payloads / agent output to the sink without sanitization are findings. Trusted-source attributes ("admin-only content") require the trace to confirm the admin gate, not assume it.

### Detection
- Frontend framework usage: React, Vue, Angular, Svelte
- Server-rendered HTML: EJS, Pug, Handlebars templates
- DOM manipulation patterns in client-side code

### What to Search For
- DOM property assignments that inject raw HTML (the `inner` + `HTML` property)
- React unsafe HTML rendering (the `dangerously` + `SetInnerHTML` prop)
- DOM write methods (the `document` `.write` method)
- Vue v-html directive
- Unescaped template output

### Actually Vulnerable
- Assigning user input directly to the DOM's raw HTML property
- Rendering user content as raw HTML in React via unsafe props
- Writing user data via DOM write methods
- Vue v-html with user-controlled content

### NOT Vulnerable
- Static HTML content assignment
- Using textContent instead of raw HTML properties
- Content sanitized with DOMPurify before use
- Admin-only or trusted source content

### Context Check
1. Where does the content come from?
2. Is there sanitization before rendering?
3. Is this admin-only or user-generated content?

### Evidence Chain
- The sink (raw HTML injection point: `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, unescaped template output) quoted at file:line
- The traced value path from source to sink, hop by hop (e.g. `req.query.q` → props → render)
- Sanitizers checked along the path and found absent (DOMPurify, framework auto-escaping, manual encoding) — or, for a Pass, the sanitizer's file:line
- Source classification: user-controlled (`req.*`, `params.*`, message payload, agent output) vs literal/trusted
- For "admin-only/trusted" claims: the trace confirming the admin gate at file:line, not an assumption

### Confidence Scoring
- **High** — complete trace from a user-controlled source to the raw HTML sink with no sanitizer on the path
- **Medium** — the unsafe rendering pattern is confirmed at the sink, but the content's origin is partially traced (e.g. comes through a store or API layer whose upstream writer couldn't be confirmed)
- **Low** — unsafe sink present but the source is un-traceable, or a claimed trust boundary (admin gate, sanitized-on-write) could not be verified → tag `needs human verification`

### Files to Check
- `**/components/**/*.tsx`, `**/components/**/*.vue`
- `**/views/**`, `**/templates/**`
- Server-rendered template files (`.ejs`, `.pug`, `.hbs`)
