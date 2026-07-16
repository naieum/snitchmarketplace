## CATEGORY 20: HIPAA
> Type: compliance · Groups: compliance · CWE: CWE-200

### Detection
- Health-related data models: `patient`, `medical`, `diagnosis`, `prescription`, `treatment`
- Healthcare terms in schemas, APIs, or variables: `PHI`, `ePHI`, `clinical`, `healthcare`
- Medical identifiers: `mrn`, `medical_record`, `insurance_id`, `health_plan`, `provider_npi`

### What to Search For
- PHI logged to console or logging systems
- Unencrypted health data storage
- Missing audit trails on health endpoints
- PHI exposed in URLs or query parameters
- Health data in error messages

### Actually Vulnerable

#### Critical
- `console.log`, `logger.*` with patient data, diagnosis, prescription, or medical records
- Health data stored without `encrypt`, `cipher`, or `aes` protection
- Patient IDs or MRNs in URL path segments or query parameters
- Patient data leaked in catch blocks or error responses

#### High
- Health endpoints without audit log decorators or middleware
- HTTP (non-HTTPS) endpoints handling health data
- Health data endpoints without role-based access control checks
- No data retention/deletion patterns for health records

### NOT Vulnerable
- Health-related variable names in test files with mock data
- Encrypted PHI with proper key management
- Audit-logged health endpoints with RBAC
- Development/staging environments with synthetic data

### Context Check
1. Is this in test code or production code?
2. Is the data actually PHI (protected health information)?
3. Is there encryption or audit logging applied elsewhere in the stack?
4. Does the application actually handle healthcare data?

### Evidence Chain
- The code snippet at file:line showing PHI handled unsafely (logged, stored unencrypted, placed in a URL, or included in an error response)
- Why the data qualifies as PHI — actual patient/medical fields flowing through the code, not just health-flavored variable names
- The missing safeguard verified absent (no encryption call, no audit-log middleware, no RBAC check on the route)
- Reachability: production code path, not test/mock or synthetic data
- Impact link: which PHI is exposed and where it lands (logs, URL, response body)

### Confidence Scoring
- High: production code demonstrably handling real PHI with the safeguard verifiably absent (e.g. a patient record passed to `console.log` in a live route)
- Medium: health-related identifiers present but PHI status inferred from naming, or the safeguard may exist at another layer (infrastructure encryption, gateway audit logging)
- Low: cannot confirm the application handles real healthcare data or that the data is PHI → tag `needs human verification`

### Files to Check
- `**/patient*.ts`, `**/medical*.ts`, `**/health*.ts`
- `**/ehr/**`, `**/clinical/**`
- API routes handling health data
- Database schemas with health-related tables
