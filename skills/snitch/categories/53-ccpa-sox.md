## CATEGORY 53: CCPA & SOX Compliance
> Type: compliance · Groups: — · CWE: CWE-359

### Detection
- Applications collecting personal information from California residents
- Financial applications without audit trails
- Missing data deletion or opt-out mechanisms
- Administrative access to financial data without approval workflows
- No segregation of duties in financial operations

### What to Search For

**CCPA (California Consumer Privacy Act):**
- No "Do Not Sell My Personal Information" link or mechanism in consumer-facing applications
- Missing data deletion API or endpoint for California residents (`DELETE /api/me`, `/api/data-request`)
- No opt-out mechanism for sale or sharing of personal data
- Collecting personal data without disclosure of categories collected and purposes
- No mechanism to verify consumer identity before processing data requests
- Missing response to data access requests within 45-day window (look for request handling logic)
- Collecting data from users under 16 without opt-in consent (COPPA overlap)
- No privacy policy page or route in the application
- User data shared with third-party analytics, ad networks, or data brokers without opt-out
- Missing data inventory or mapping (no documentation of what personal data is collected and where it flows)

**SOX (Sarbanes-Oxley Act):**
- Financial data modifications without audit logging (no `created_by`, `modified_by`, `audit_log` table)
- Admin users can modify financial records directly without approval workflow
- No segregation of duties: same user can create, approve, and process financial transactions
- Missing change management controls on financial systems (no PR review requirements, no deployment approvals)
- Financial reports generated from data that can be modified without audit trail
- Database admin access to financial tables without logging or access controls
- No immutable audit log for financial transactions (audit records can be deleted or modified)
- Missing access reviews or periodic recertification for users with financial system access
- Backup and recovery procedures not documented or tested for financial data
- Source code changes to financial calculation logic without review trail

**Detection Patterns (Code-Level):**

*JavaScript/TypeScript:*
- Database models for financial entities (`invoices`, `payments`, `ledger`, `transactions`) without `createdBy`, `updatedBy`, or audit trail fields
- Admin routes for financial operations with no approval or dual-control middleware
- Missing audit logging middleware on financial API routes
- User data endpoints without deletion capability

*Python (Django, Flask):*
- Django models for financial data without `django-auditlog` or `django-simple-history`
- Flask financial routes without audit logging decorator
- Missing `signals` or middleware for tracking changes to financial records
- No `delete_user_data()` or `anonymize_user()` function

*Java (Spring):*
- JPA entities for financial data without `@EntityListeners(AuditingEntityListener.class)`
- Missing Spring Data Auditing (`@CreatedBy`, `@LastModifiedBy`) on financial entities
- Financial service methods without `@PreAuthorize` role checks enforcing segregation of duties
- No audit trail service or event logging for financial transactions

*Go:*
- Financial data structs without audit fields (`CreatedBy`, `UpdatedBy`, `CreatedAt`)
- HTTP handlers for financial operations without audit logging middleware
- Missing role-based authorization on financial endpoints

*Ruby (Rails):*
- ActiveRecord models for financial data without `paper_trail` or `audited` gem
- Financial controllers without `before_action` audit logging
- Missing `acts_as_paranoid` or soft-delete on financial records (SOX requires retention)

### Actually Vulnerable
- Consumer-facing application with no "Do Not Sell" page, link, or API endpoint
- No `/api/delete-my-data` or equivalent endpoint for CCPA data deletion requests
- User personal data shared with third-party analytics (Google Analytics, Segment, Mixpanel) with no opt-out mechanism
- Financial `transactions` table with no audit trail columns and no separate audit log
- Admin panel where a single user can create an invoice, approve it, and process payment
- Financial records stored in a database where admin users have direct `UPDATE` and `DELETE` access without logging
- Audit log table where records can be modified or deleted by application code
- No privacy policy route or page in a consumer-facing application
- Financial calculation code modified without code review (no branch protection or PR requirements)
- Collecting data from minors without age gate or parental consent mechanism

### NOT Vulnerable
- Applications that do not serve California residents or do not collect personal information
- Non-financial applications (SOX requirements do not apply)
- "Do Not Sell" link present and functional, with opt-out persisted and respected across data flows
- Data deletion endpoint that removes or anonymizes all personal data and returns confirmation
- Financial entities with `@EntityListeners(AuditingEntityListener.class)` or equivalent audit trail
- Segregation of duties enforced: different roles required for creation, approval, and processing of financial transactions
- Immutable audit log using append-only storage (e.g., write-once S3 bucket, append-only database table with triggers preventing UPDATE/DELETE)
- Regular access reviews documented and enforced for financial system users
- Applications using consent management platforms (OneTrust, TrustArc) for CCPA compliance

### Context Check
1. Does the application collect personal information from California residents (CCPA applicability)?
2. Is there a "Do Not Sell" mechanism and data deletion API?
3. Does the application handle financial data subject to SOX requirements?
4. Are financial data modifications logged in an immutable audit trail?
5. Is segregation of duties enforced for financial operations (no single user can create and approve)?
6. Are there change management controls for financial system code changes?
7. Is user data shared with third parties, and is there an opt-out mechanism?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the application collects personal information from California residents (CCPA applicability)
2. [ ] Checked for "Do Not Sell" link/page/API endpoint in the application
3. [ ] Verified data deletion capability exists for user requests
4. [ ] For SOX: confirmed the application handles financial data (invoices, payments, transactions)
5. [ ] For SOX: checked for audit trail columns on financial database tables
6. [ ] Verified segregation of duties (different roles for creation, approval, processing of financial transactions)
7. [ ] Checked if a consent management platform handles CCPA compliance externally

### Confidence Scoring
- **HIGH**: Consumer-facing application collecting personal data from California residents with no "Do Not Sell" mechanism and no data deletion endpoint. Or financial application with no audit trail on transactions and no segregation of duties.
- **MEDIUM**: Privacy mechanisms exist partially (privacy policy page present but no opt-out endpoint). Or financial audit trail exists but audit records are mutable (can be updated or deleted).
- **LOW**: Application may not serve California residents or may not handle financial data subject to SOX. Or compliance may be handled by external tools (consent management platform, separate audit system).
- **SKIP**: Application does not collect personal information from California residents (CCPA not applicable). Application does not handle financial data (SOX not applicable). Or consent management platform (OneTrust, TrustArc) handles CCPA compliance externally.

### Files to Check
- `**/privacy*`, `**/consent*`, `**/opt-out*`, `**/data-request*`
- `**/models/**` (financial entities: invoices, payments, transactions, ledger)
- `**/admin/**`, `**/finance/**`, `**/billing/**`, `**/accounting/**`
- `**/audit*`, `**/changelog*`, `**/history*`
- `**/middleware/**` (audit logging, authorization)
- Privacy policy pages: `**/privacy*.tsx`, `**/privacy*.html`, `**/legal/**`
- Database migrations (check for audit trail columns on financial tables)
