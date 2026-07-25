## CATEGORY 47: CSRF Protection
> Type: posture · Groups: — · CWE: CWE-352

### Detection
- Forms without CSRF tokens in HTML templates
- State-changing operations on GET endpoints
- Missing SameSite cookie attributes on session cookies
- No CSRF middleware in web framework configuration
- Framework CSRF imports: `csrf-csrf`, `@fastify/csrf-protection`, `csurf` (deprecated/archived 2022 — still deployed, so still match it), `csrf_token`, `CsrfFilter`, `protect_from_forgery`, `gorilla/csrf`
- Any locally-defined verifier in a mutation handler's chain, whatever it is named — match the position and behavior, not an identifier

### What to Search For

**JavaScript/TypeScript (Express, Next.js, Fastify):**
- No token or origin verifier anywhere in a mutation handler's middleware chain. **Match the behavior, not a package name** — a locally-defined verifier counts whatever it is called, and an unrecognised name is not the same as an absent defense
- POST/PUT/DELETE routes with no CSRF token validation
- Session cookies set without `SameSite` attribute or with `SameSite=None` without `Secure`
- Forms rendered without `<input type="hidden" name="_csrf">`
- Next.js API routes accepting mutations without CSRF verification
- Custom CSRF implementations with weak tokens. What to check: the token comes from a CSPRNG
  (`crypto.randomBytes`, `SecureRandom`), is bound to the session rather than global, and is
  compared in constant time. **If the implementing module is outside the scan scope**, do not
  guess — record a Pass at Medium confidence, name the unread file, and say which of the three
  properties you could not verify

**Python (Django, Flask):**
- Django templates with forms missing `{% csrf_token %}`
- Django views decorated with `@csrf_exempt` without justification
- `CSRF_COOKIE_SECURE = False` or missing in Django settings
- Flask-WTF forms without CSRF protection enabled
- Flask routes handling POST without `CSRFProtect`
- `CSRF_ENABLED = False` in Flask configuration

**Java (Spring):**
- Spring Security with `.csrf().disable()` or `csrf(AbstractHttpConfigurer::disable)`
- Missing `CsrfFilter` in filter chain
- Thymeleaf forms without `th:action` (which auto-adds CSRF token)
- JSP forms missing `<input type="hidden" name="${_csrf.parameterName}">`

**Ruby (Rails):**
- **Rails — read `config/application.rb` before grading any controller.** `config.load_defaults`
  of `"5.2"` or later sets `action_controller.default_protect_from_forgery = true`, so every
  `ActionController::Base` subclass is protected **with no explicit line in the controller**. The
  generators stopped emitting `protect_from_forgery` in 5.2, so its absence in a modern app is the
  normal secure state and flagging it false-positives on essentially every Rails app of the last
  several years. Under `load_defaults` 5.1 or earlier — or an explicit
  `default_protect_from_forgery = false`, or an override in `config/initializers/` or
  `config/environments/*.rb` — protection exists only where `protect_from_forgery` is called
  **somewhere in the controller's ancestor chain**. `protect_from_forgery` installs a
  `before_action`, and callbacks are **inherited**: from Rails 4.0 to 5.1 the generators emitted it
  in `ApplicationController` and nowhere else, so that single line protects every subclass. Walk the
  chain up to `ActionController::Base` before reporting — flagging a subclass whose parent carries
  the call is a false positive across essentially the entire pre-5.2 population this rule exists for.
  Absence from the **whole chain** is a **High** finding against every state-changing action.
  If the deciding ancestor or config file is outside the scan scope, say which file you could not
  read and drop to Medium confidence (SKILL.md Rule 7) rather than assuming either default.
  A controller's own text is never sufficient evidence here; the deciding fact is always elsewhere
- `skip_before_action :verify_authenticity_token` without API-only justification
- `protect_from_forgery with: :null_session` on non-API controllers
- Forms without `authenticity_token`

**Go:**
- HTTP handlers accepting POST/PUT/DELETE without CSRF middleware
- Missing `gorilla/csrf` or `nosurf` middleware
- Cookie-based sessions without SameSite attribute set via `http.Cookie`

### Actually Vulnerable
- Express app with session-cookie auth and state-changing POST routes where no middleware in the chain verifies a token or the request origin
- Django view with `@csrf_exempt` that performs state-changing operations (user creation, password change, fund transfer)
- Spring Security config with `.csrf().disable()` on a web application serving HTML forms
- Rails controller with `skip_before_action :verify_authenticity_token` on a non-API controller
- State-changing GET request: `GET /api/delete-account?id=123` that actually deletes data
- Session cookie set with `SameSite=None; Secure` but no CSRF token validation
- HTML form with `action="/transfer"` and no hidden CSRF token field
- Go web app using `gorilla/sessions` for auth cookies but no CSRF middleware on mutation routes
- Custom CSRF token that is static or derived from predictable values (e.g., user ID alone)
- Flask app with `WTF_CSRF_ENABLED = False` in production config

### NOT Vulnerable
- API-only backends using Bearer token authentication with no cookies (no CSRF risk)
- Endpoints behind an API gateway that handles CSRF validation
- SPA applications using `Authorization: Bearer <token>` headers (not cookie-based auth)
- Django REST Framework API views using token authentication (cookies not used)
- GraphQL endpoints authenticated via headers, not cookies
- Express routes whose chain contains a token verifier ahead of the handler — a maintained middleware (`csrf-csrf`, `@fastify/csrf-protection`), a framework-native check, or a hand-rolled double-submit/synchronizer verifier. **`csurf` itself is deprecated and archived**: its presence is evidence a defense was intended, not that it is maintained, and it must never be the *recommended fix*
- Spring Security with CSRF enabled and Thymeleaf auto-injecting tokens
- Rails controllers with `protect_from_forgery with: :exception` (default)
- Stateless APIs using JWT in Authorization header
- `@csrf_exempt` on a Django webhook endpoint that verifies requests via HMAC signature

### Context Check
1. Does the application use cookie-based authentication or sessions?
2. Are state-changing operations restricted to POST/PUT/DELETE methods?
3. Is CSRF middleware configured and applied to all relevant routes?
4. Do HTML forms include CSRF tokens?
5. Are session cookies set with `SameSite=Lax` or `SameSite=Strict`?
6. Is this an API-only backend with token-based auth (no CSRF risk)?
7. Are `@csrf_exempt` or `skip_before_action` decorators justified (e.g., webhook endpoints with signature verification)?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the application uses cookie-based authentication or sessions (not token-based auth via headers)
2. [ ] Verified state-changing operations (POST/PUT/DELETE) exist that modify data
3. [ ] Checked the application setup for a token or origin verifier by behavior (any middleware name), and for Rails read `config/application.rb` for `load_defaults`
4. [ ] Verified HTML forms include CSRF tokens (hidden input fields)
5. [ ] Checked session cookie `SameSite` attribute setting
6. [ ] For `@csrf_exempt` endpoints, verified alternative protection exists (HMAC signature, webhook secret verification)

### Confidence Scoring
- **HIGH**: Web application with cookie-based session auth, HTML forms performing state-changing operations, and no CSRF middleware or token validation anywhere.
- **MEDIUM**: CSRF middleware exists but `@csrf_exempt` or `skip_before_action` is used on state-changing endpoints without alternative protection (e.g., HMAC signature verification).
- **LOW**: Application uses `SameSite=Lax` cookies which provides partial CSRF protection, but no explicit CSRF tokens. Or CSRF protection might be handled at the API gateway level.
- **SKIP**: API-only backend using Bearer token authentication with no cookies. Or SPA using `Authorization: Bearer` headers (not cookie-based auth). Stateless JWT in Authorization header eliminates CSRF risk.

### Files to Check
- `**/middleware*.ts`, `**/middleware*.js`, `**/middleware*.py`
- `**/app.ts`, `**/app.js`, `**/server.ts`, `**/server.js`
- `**/settings.py`, `**/config.py`
- `**/SecurityConfig.java`, `**/WebSecurityConfig.java`
- `**/application_controller.rb`, `**/config/application.rb`
- `**/templates/**/*.html`, `**/views/**/*.erb`, `**/templates/**/*.jinja2`
- `**/*.go` (HTTP handler files)
