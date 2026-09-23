## CATEGORY 54: Federated Identity Deep Security (OAuth/OIDC & SAML)
> Type: posture · Groups: — · CWE: CWE-287

> **Owns:** the federated-identity protocol surface in both dialects. For OAuth/OIDC — PKCE,
> `state`, `nonce`, grant type, the registered `redirect_uri` and how the server matches it,
> refresh-token rotation, scopes, and client-secret placement. For SAML — signature verification and
> what it actually covers, the assertion's audience, recipient and validity window, replay defence,
> how the IdP's signing certificate is obtained and trusted, and `RelayState` handling. **Does not
> own:** where the resulting session token is stored, or a generic post-login
> `res.redirect(userInput)` — both are Category 4. The JWT verification algorithm is Category 63;
> XXE and entity expansion in the XML parser itself is Category 49 (this category owns what the
> signature covers, that one owns what the parser will do with hostile XML); a known-CVE version of
> a SAML library is Category 27; provider-specific config is Category 14.

### Detection
- OAuth 2.0 or OpenID Connect implementation in the application
- Authorization code flow, implicit flow, or client credentials flow usage
- OAuth libraries: NextAuth/Auth.js, Passport.js, Spring Security OAuth, Django OAuth Toolkit, Go oauth2 package
- Token storage patterns in frontend code
- Redirect URI handling and validation
- SAML libraries: `@node-saml/node-saml`, `@node-saml/passport-saml`, `passport-saml`, `samlify`,
  `saml2-js`, `python3-saml`, `pysaml2`, `djangosaml2`, `ruby-saml`, `omniauth-saml`,
  `spring-security-saml2-service-provider`, `OpenSAML`, `Sustainsys.Saml2`, `ITfoxtec.Identity.Saml2`
- SAML artifacts in the repo: `*.xml` IdP metadata, an `EntityDescriptor` or `IDPSSODescriptor`
  element, a route named `acs`, `sso`, `saml/callback`, `saml/consume`, or a `SAMLResponse` form field

### What to Search For

**Authorization Code Flow Without PKCE:**
- OAuth authorization requests missing `code_challenge` and `code_challenge_method` parameters
- NextAuth/Auth.js configuration without PKCE enabled for custom providers
- Passport.js OAuth2 strategy without `pkce: true` or `S256` code challenge
- Spring Security OAuth2 client without PKCE configuration
- Django OAuth Toolkit authorization endpoint without PKCE enforcement
- Go `golang.org/x/oauth2` usage without PKCE extension

**Missing State Parameter:**
- Authorization URL constructed without `state` parameter
- OAuth callback handler that does not validate the `state` parameter against session
- State parameter generated but never verified on callback

**Nonce Validation (OIDC):**
- ID token received without verifying `nonce` claim matches the one sent in the authorization request
- OIDC flow without sending `nonce` parameter in the authentication request
- ID token `nonce` claim not checked, allowing token replay

**Implicit Flow Usage:**
- `response_type=token` in authorization requests (implicit flow -- should be flagged)
- `response_type=id_token token` without code flow fallback
- SPA using implicit flow instead of authorization code flow with PKCE

**Token Storage** — owned by Category 4. If tokens land in `localStorage`, a global, a URL fragment,
or a cookie missing `HttpOnly` / `Secure` / `SameSite`, note the detection and report it there.

**Redirect URI Validation (the registered `redirect_uri`, not a generic redirect):**
- Redirect URI not strictly matched (e.g., prefix matching allows `https://example.com.evil.com`)
- Wildcard redirect URIs: `redirect_uri=https://*.example.com`
- Callback accepting an arbitrary `redirect_uri` value not in the registered set
- `redirect_uri` validated on the client side but not on the authorization server
- Path traversal in redirect URI: `redirect_uri=https://example.com/../evil`
- Redirect URI with different port or path accepted (e.g., `https://example.com:8080`)

**Refresh Token Issues:**
- Refresh token rotation not enforced (same refresh token can be reused indefinitely)
- No refresh token expiration or absolute lifetime
- Refresh tokens not revoked on password change or logout
- Refresh token reuse detection not implemented (compromised token not detected)

**Scope Issues:**
- Requesting more OAuth scopes than necessary (scope inflation)
- Not validating scopes on the resource server (trusting the token without checking scope claims)
- Admin scopes requested by default for all users

**Client Secret Exposure:**
- OAuth `client_secret` included in frontend JavaScript code
- Client secret in mobile application source code (reverse-engineerable)
- Client secret committed to public repository
- Client secret in client-side OAuth configuration

### Actually Vulnerable

**JavaScript/TypeScript (NextAuth, Passport.js):**
- NextAuth custom provider without PKCE: `providers: [{ id: 'custom', ...options }]` missing `checks: ['pkce']`
- Passport OAuth2 callback not validating `state`: `passport.authenticate('oauth2')` without state check
- OAuth callback accepting any `redirect_uri` parameter without validation against the registered allowlist
- Client secret in Next.js client-side code: `process.env.NEXT_PUBLIC_OAUTH_SECRET`

**Python (Django OAuth Toolkit, Authlib):**
- Django OAuth Toolkit with `PKCE_REQUIRED = False` for public clients
- OAuth callback view not verifying `state` parameter from session
- Implicit grant type enabled: `GRANT_TYPES = ['implicit']` in Django OAuth Toolkit settings
- Flask-OAuthlib redirect URI validation using `startswith()` instead of exact match

**Java (Spring Security OAuth2):**
- Spring Security OAuth2 client registration without PKCE: missing `client-authentication-method: none` with code challenge
- `redirect-uri: "{baseUrl}/**"` with wildcard matching
- ID token `nonce` claim not verified in custom OIDC authentication handler
- Client secret in `application.properties` deployed with frontend assets

**Go:**
- `golang.org/x/oauth2` authorization URL without `oauth2.SetAuthURLParam("state", state)`
- Redirect URI validated with `strings.HasPrefix()` instead of exact match

**Ruby (OmniAuth, Doorkeeper):**
- OmniAuth with state checking turned **off**: `provider :oauth2, ..., provider_ignores_state: true`. The option defaults to `false` (state is validated), so its *absence* is the secure configuration and is never the finding — the finding is an explicit `true`, and the fix is to remove the option or get the provider to return `state`
- Doorkeeper with `force_ssl_in_redirect_uri false` in production
- Implicit grant enabled in Doorkeeper: `grant_flows %w[implicit]`

### SAML and Enterprise SSO

SAML is where enterprise deals are won and where the failure mode is worst: a successful attack on
an assertion is a silent, full-identity impersonation of any user at the tenant, including
administrators, with a valid-looking audit trail. The protocol is also unusually easy to implement
*almost* correctly — the happy path passes every manual test while the invariant that makes it
secure is absent, because a valid signature on a document says nothing about which part of the
document it covers.

**The invariant that decides most findings: the data you trust must be the data the signature
covered.** A SAML response is signed XML. An implementation that verifies the signature over one
node and then reads the user's identity out of a *separately parsed* copy of the document has
verified nothing. This is XML Signature Wrapping, and in code it looks completely reasonable.

#### What to Search For

**Signature verification disabled, partial, or absent:**
- Explicit opt-outs: `wantAssertionsSigned: false`, `wantAuthnResponseSigned: false`,
  `wantMessageSigned: false` (python3-saml `security` block), `validateSignature: false`,
  `signatureValidation` turned off, `Sustainsys` `WantAssertionsSigned = false`.
- `ruby-saml` with `settings.idp_cert` / `idp_cert_fingerprint` unset, or `response.is_valid?(true)`
  (soft validation) where the boolean suppresses the error rather than failing the login.
- A verification result that is computed and then not branched on: `const ok = validate(...)` with no
  `if (!ok) return 401`, or a `try/catch` around validation whose `catch` continues the login.
- An IdP certificate read from the incoming response or from a field the request controls rather than
  from configuration — self-signed assertions validate perfectly against their own certificate.
- Fingerprint-only trust with a weak digest (`idp_cert_fingerprint` with SHA-1) and no full cert pin.

**XML Signature Wrapping (the shape to look hardest for):**
- Two parses of the same document: the library or a verification helper is handed the raw
  `SAMLResponse`, and a *second* parser (`xml2js`, `fast-xml-parser`, `lxml`, `Nokogiri`, an XPath
  query, a regex) extracts `NameID`, `AttributeValue`, or the email out of the raw string too.
- Identity read by a document-wide XPath — `//saml:NameID`, `//AttributeValue`, `getElementsByTagName("NameID")[0]`
  — rather than from the node the verification step returned.
- Any hand-rolled assertion parsing at all next to a library that already returns a verified profile.
  The library's `profile` object is the trustworthy source; the raw document is not.

**Assertion conditions not enforced:**
- Audience not checked: `audience: false` in node-saml, a missing `sp_entity_id` / `audience`
  setting, or an `Audience` element read but never compared to the SP's own entity id.
- `Destination` / `Recipient` not compared against the ACS URL actually serving the request.
- Validity window not enforced: `NotBefore` / `NotOnOrAfter` unread, or
  `acceptedClockSkewMs: -1` in node-saml, which **disables expiry checking entirely** rather than
  setting a generous skew. A positive value is a normal, correct configuration.

**Replay:**
- `validateInResponseTo` disabled or left at a mode that never validates, with no other request
  tracking.
- No store of consumed assertion IDs — search for a cache, table, or Redis key keyed on the
  assertion `ID`, and note its absence explicitly.
- An in-memory request store on a multi-instance deployment, which is a replay gap in practice;
  report it as Medium with the deployment assumption stated.

**Trust bootstrapping:**
- IdP metadata fetched at runtime over plain HTTP, or from a URL a tenant admin supplies with no
  validation.
- Metadata signature not verified when the metadata is fetched rather than checked in.
- A multi-tenant SP that resolves the IdP certificate by an identifier taken from the assertion
  itself instead of from the tenant the login started for.

**`RelayState` and downgrade:**
- `RelayState` used directly as a redirect target with no allowlist — the SAML dialect of the same
  bug the `redirect_uri` rules above cover.
- `signatureAlgorithm: "sha1"` / `digestAlgorithm: "sha1"`, or an accepted-algorithm list that
  permits SHA-1 or, worse, leaves the algorithm to the incoming document.

#### Actually Vulnerable
- A Node SP calls `saml.validatePostResponseAsync(body)` and then, for convenience, also does
  `parseStringPromise(Buffer.from(body.SAMLResponse, "base64"))` and reads the email from the second
  parse. An attacker wraps the original signed assertion and adds their own unsigned one; the
  signature still verifies and the email comes from the attacker's copy.
- `python3-saml` settings with `"wantAssertionsSigned": false` and `"wantMessagesSigned": false` —
  the SP accepts an entirely unsigned assertion, so anyone who can reach the ACS URL can log in as
  anyone.
- `new SAML({ cert: idpCert, audience: false, acceptedClockSkewMs: -1 })` — the assertion is signed,
  but it is accepted for any audience and forever. An assertion captured from a different SP that
  shares the IdP logs the attacker in here.
- An ACS handler with no consumed-assertion store and `validateInResponseTo` off: an assertion
  observed once (in a log, a proxy, a browser history) can be posted again.
- A multi-tenant SP that looks up the signing certificate by the `Issuer` in the incoming response.
  An attacker registers their own tenant, signs an assertion for a victim's `NameID` with their own
  key, and the SP fetches the attacker's certificate to validate it.
- `res.redirect(req.body.RelayState)` in the ACS handler with no allowlist.

#### NOT Vulnerable
- A library call that returns a verified profile, with every identity attribute read from that
  profile object and nothing read from the raw document. Quote the profile access in the Pass.
- Options simply absent where the installed version's default is safe. Context Check 4 in Category 4
  applies here with force: `@node-saml/node-saml` defaults `wantAssertionsSigned` to true and
  validates `InResponseTo` by default in current versions, and option names changed across major
  versions (`cert` became `idpCert` in v5). Read the installed package before calling an absent
  option a disabled one — a v5 config using `idpCert` is correctly configured, not missing a cert.
- An `audience` set to the SP's entity id, a `Destination` compared against the ACS URL, and a
  positive `acceptedClockSkewMs`.
- IdP certificates checked into configuration or loaded from a secrets manager, pinned per tenant.
- SSO delegated wholesale to a provider that owns the assertion handling (WorkOS, Clerk, Auth0,
  Okta's SDKs, Microsoft Entra libraries) where the application only consumes the provider's own
  session. Name the provider and the call.
- Test fixtures containing sample assertions and self-signed certs under `*.test.*`, `__tests__/`,
  or a `fixtures/` directory — a committed IdP certificate is public key material and is not a
  secret finding.

#### Evidence Chain
- The SP configuration object quoted at file:line, with the specific option and its value — or, for
  an absent option, the installed version's default quoted from `node_modules/` or the version's
  documentation, per the "omitted is not disabled" rule.
- The ACS handler quoted at file:line, and the line where the user's identity is read — stating
  explicitly whether that read comes from the verified profile or from a separate parse of the raw
  document. This sentence is the whole finding for a wrapping report.
- For condition findings: which of audience, recipient/destination, validity window, or replay is
  unenforced, and the absence demonstrated (the setting quoted as disabled, or the check searched
  for across the handler and its helpers and confirmed missing).
- For trust-bootstrapping findings: where the signing certificate comes from, traced to its source —
  config, metadata URL, secrets manager, or the incoming document.
- The impact in one sentence, naming the victim class: any user at this tenant, or any user at any
  tenant, and whether administrators are included.

#### Confidence Scoring
- **HIGH**: signature verification explicitly disabled; identity read from a separate parse of the
  raw response alongside a verification call; the signing certificate resolved from the incoming
  assertion; `acceptedClockSkewMs: -1` or `audience: false` quoted in config.
- **MEDIUM**: a condition check is absent from the handler but could live in a wrapper or a
  framework filter not resolved in scope; or replay defence is missing but the deployment's
  instance count (and therefore the practical exploitability of an in-memory store) is unknown.
- **LOW**: the SP configuration is assembled at runtime from environment values the scan cannot
  read, or the flow terminates in a provider SDK whose behavior is not in the repository — tag
  `needs human verification` and keep the finding.

### NOT Vulnerable
- Authorization code flow with PKCE (`code_challenge_method=S256`) enforced
- State parameter generated, stored in session, and validated on callback
- Nonce sent in OIDC authentication request and verified in ID token
- Redirect URIs validated with exact string match against a registered allowlist
- Refresh token rotation enabled (new refresh token issued on each use, old one invalidated)
- Scopes minimized to only what the application requires
- Client secrets stored server-side only, never exposed to frontend code
- A **confidential** client that omits PKCE but validates the OIDC `nonce` claim in the ID token
  obtained from the token endpoint, and disregards every token until that check succeeds. Current
  best-current-practice recommends PKCE for confidential clients too, and names the OIDC nonce as
  the one sanctioned alternative — so nonce-with-validation is a Pass, and "it's a backend client"
  on its own is not. Record which of the two you found, quoted. (Nonce does not protect a *public*
  client: an attacker can call the token endpoint with the stolen code directly.)
- Proper client secret management in a secrets manager for confidential clients
- Implicit flow disabled; authorization code flow with PKCE used for SPAs and mobile apps
- `provider_ignores_state` absent from an OmniAuth provider block — the default is `false`, so state
  is being validated

### Context Check
1. Is PKCE used for public clients (SPAs, mobile apps, CLI tools)?
2. Is the `state` parameter generated, stored in session, and validated on callback?
3. Is the `nonce` claim verified in OIDC ID tokens?
4. For a confidential client without PKCE: is the OIDC `nonce` claim verified in the ID token, with tokens disregarded until it passes?
5. Are redirect URIs strictly validated with exact match against a registered allowlist?
6. Is refresh token rotation enabled with reuse detection?
7. Are OAuth scopes minimized to the least privilege needed?
8. Is the client secret kept server-side only (not in frontend code or mobile apps)?
9. Is implicit flow disabled in favor of authorization code flow with PKCE?
10. (SAML) Is the identity read from the verified profile the library returned, or from a second
    parse of the raw response? Answer this before any other SAML check — it decides the most severe
    finding in the category.
11. (SAML) Are the assertion's audience, recipient/destination, and validity window all enforced,
    and is there a store that would reject a replayed assertion id?
12. (SAML) Where does the IdP signing certificate come from, and on a multi-tenant SP, is it
    resolved from the tenant the login started for rather than from the assertion?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Determined if the OAuth client is public (SPA, mobile, CLI) or confidential (server-side)
2. [ ] Checked authorization request for `code_challenge` and `code_challenge_method` parameters (PKCE)
3. [ ] Verified `state` parameter is generated, stored in session, and validated on callback
4. [ ] For a confidential client without PKCE, checked whether the OIDC `nonce` is sent AND verified in the ID token
5. [ ] Verified redirect URI validation uses exact string match against a registered allowlist
6. [ ] Confirmed client secret is not exposed in frontend code or client-side configuration
7. [ ] Checked if refresh token rotation is enabled with reuse detection

### Confidence Scoring
- **HIGH**: Authorization code flow without PKCE for a public client (SPA, mobile app). Or redirect URI validation uses prefix matching instead of exact match. Or `provider_ignores_state: true`. Or client secret exposed in frontend code.
- **MEDIUM**: State parameter is generated but not validated on callback. Or refresh token rotation is not enforced. Or implicit flow is used but the application is being migrated.
- **MEDIUM (not Low)**: PKCE is absent on a confidential client **and** no verified OIDC `nonce` covers it — best current practice recommends PKCE here too, so this is a real gap, not an exemption.
- **LOW**: PKCE is absent on a confidential client but a `nonce` is sent and its verification could not be traced to a specific line — tag `needs human verification`.
- **SKIP**: Authorization code flow with PKCE, state validation, nonce verification. Redirect URIs with exact string match. Client secrets server-side only. Auth managed by a provider (Clerk, Auth0) with secure defaults.

### Files to Check
- `**/auth*`, `**/oauth*`, `**/oidc*`, `**/login*`, `**/callback*`
- `**/providers/**`, `**/strategies/**`
- `**/*next-auth*`, `**/*authOptions*`, `**/[...nextauth]*`
- `**/passport*`, `**/omniauth*`, `**/doorkeeper*`
- `**/saml*`, `**/sso*`, `**/acs*`, `**/*metadata*.xml`, `**/idp*`, `**/sp-metadata*`
- `**/SecurityConfig.java`, `**/application.properties`, `**/application.yml`
- `**/settings.py` (Django OAuth Toolkit config)
- `**/token*`, `**/session*`, `**/cookie*`
- Frontend code: `**/store/**`, `**/context/**`, `**/hooks/useAuth*`
