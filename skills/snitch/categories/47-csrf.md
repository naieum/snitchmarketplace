## CATEGORY 47: CSRF Protection
> Type: posture · Groups: — · CWE: CWE-352

### Detection
- Forms without CSRF tokens in HTML templates
- State-changing operations on GET endpoints
- Missing SameSite cookie attributes on session cookies
- No CSRF middleware in web framework configuration
- Framework CSRF imports: `csurf`, `csrf_token`, `CsrfFilter`, `protect_from_forgery`, `gorilla/csrf`

### What to Search For

**JavaScript/TypeScript (Express, Next.js, Fastify):**
- Missing `csurf` or `csrf` middleware in Express app setup
- POST/PUT/DELETE routes with no CSRF token validation
- Session cookies set without `SameSite` attribute or with `SameSite=None` without `Secure`
- Forms rendered without `<input type="hidden" name="_csrf">`
- Next.js API routes accepting mutations without CSRF verification
- Custom CSRF implementations that use predictable tokens

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
- Controllers missing `protect_from_forgery with: :exception`
- `skip_before_action :verify_authenticity_token` without API-only justification
- `protect_from_forgery with: :null_session` on non-API controllers
- Forms without `authenticity_token`

**Go:**
- HTTP handlers accepting POST/PUT/DELETE without CSRF middleware
- Missing `gorilla/csrf` or `nosurf` middleware
- Cookie-based sessions without SameSite attribute set via `http.Cookie`

### Actually Vulnerable
- Express app with session cookies and POST routes but no `csurf` middleware
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
- Express routes using `csurf` middleware with properly validated tokens
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
3. [ ] Checked for CSRF middleware in the application setup (csurf, csrf, protect_from_forgery, CsrfFilter)
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
