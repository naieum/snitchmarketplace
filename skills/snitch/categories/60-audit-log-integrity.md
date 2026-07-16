## CATEGORY 60: Audit Log Integrity
> Type: posture · Groups: — · CWE: CWE-778

### Detection
- Logging library imports: `winston`, `pino`, `bunyan`, `morgan`, `log4js` (Node.js), `logging` (Python), `loguru`, `structlog`, `zap`, `zerolog`, `slog` (Go), `log4j`, `slf4j`, `logback` (Java), `Rails.logger`, `ActiveSupport::Logger` (Ruby)
- Audit-specific modules: custom audit trail implementations, audit middleware, event sourcing patterns
- Log shipping/aggregation configuration: CloudWatch, Datadog, Splunk, ELK, Loki, Fluentd, Logstash
- Database tables or collections named `audit_logs`, `audit_trail`, `activity_log`, `event_log`

### What to Search For

**Audit Logs Stored in Same Database as Application Data:**
- Audit log table in the same database as application tables (can be modified by compromised application)
- Audit records written via the same database connection/ORM as application writes
- No write-once or append-only storage for audit records
- Application database user has `DELETE` or `UPDATE` permissions on audit tables
- No separate audit database, schema, or storage account

**No Log Shipping to Remote/Immutable Storage:**
- Audit logs written only to local filesystem with no remote forwarding
- No log aggregation service (CloudWatch, Datadog, Splunk, ELK) configured
- Missing Fluentd, Filebeat, Logstash, or Vector configuration for log shipping
- No S3, GCS, or Azure Blob archival for long-term audit log storage
- Logs not shipped to write-once/immutable storage (S3 Object Lock, WORM storage)

**Audit Logs Without Timestamps or User Attribution:**
- Log entries missing timestamp field or using inconsistent timestamp formats
- Audit records without `userId`, `actorId`, or equivalent user identification
- Missing `action` or `event_type` field describing what was done
- No correlation ID or request ID linking audit entries to specific requests
- Timestamps not in UTC or ISO 8601 format (makes correlation difficult)

**Missing Audit Trail for Admin Actions:**
- Admin endpoints (user management, role changes, configuration updates) without audit logging
- Database schema changes, permission grants, or access control modifications not logged
- No audit trail for data deletion or bulk operations
- Admin dashboard actions not recorded (impersonation, account suspension, data export)
- Missing audit logging for authentication events (login, logout, failed attempts, password changes)

**Log Deletion Endpoints Without Authorization:**
- API endpoints that clear or delete audit logs without admin-only authorization
- Log management routes accessible to non-admin users
- No role check before log truncation or purging operations
- Database `TRUNCATE` or `DELETE` on audit tables callable from application code without authorization

**No Log Rotation Policy:**
- Logging configuration without `maxSize`, `maxFiles`, or rotation settings
- Winston transport without `maxsize` and `maxFiles` options
- Pino without `pino-rotating-file-stream` or external rotation
- Python logging without `RotatingFileHandler` or `TimedRotatingFileHandler`
- Go logging to file without `lumberjack` or equivalent rotation library
- No logrotate configuration for application audit logs
- Unbounded log files that can fill disk and cause denial of service

**Sensitive Data in Audit Logs:**
- Full request/response bodies logged including passwords, tokens, or credit card numbers
- PII (email, SSN, phone, address) written to audit logs without masking or redaction
- API keys, JWT tokens, or session IDs logged in full
- Database query logs including sensitive parameter values
- Health information, financial data, or other regulated data in log output

**Audit Logs Not Including IP/User-Agent:**
- Audit entries for security-sensitive actions without source IP address
- Missing `User-Agent` or client identification in audit records
- No geographic or device context for login and access events
- Insufficient context for incident investigation and forensics

### Actually Vulnerable
- Audit logs stored in `app_db.audit_logs` table with the application having full `DELETE` privilege -- compromised app can erase audit trail
- Express endpoint `app.delete('/api/logs', (req, res) => { AuditLog.deleteMany({}) })` with no auth middleware -- anyone can wipe audit logs
- Winston logger writing audit logs only to local file with no remote shipping -- logs lost if server is compromised or fails
- Audit middleware logging `{ action: 'login', body: req.body }` -- passwords included in audit records
- Admin route `PUT /api/users/:id/role` with no audit log entry -- privilege escalation goes unrecorded
- Python logging with `logging.basicConfig(filename='audit.log')` and no rotation -- disk exhaustion risk, no remote backup
- Audit entry: `{ event: 'data_export', timestamp: null, user: null }` -- no attribution or timestamp for sensitive action
- Rails controller logging `logger.info(params.to_json)` including sensitive form fields

### NOT Vulnerable
- Audit logs written to a separate database with append-only permissions (application user cannot UPDATE or DELETE)
- Log shipping via Fluentd to CloudWatch Logs with S3 archival using Object Lock (immutable retention)
- Structured audit entries with ISO 8601 timestamp, user ID, action, resource, IP, and user-agent
- All admin actions wrapped in audit middleware that logs before and after state
- Log deletion endpoint restricted to super-admin role with its own audit trail
- Winston with daily rotation, 90-day retention, and Datadog transport for remote aggregation
- PII fields masked in audit logs (email: `j***@example.com`, SSN: `***-**-1234`)
- Debug-level application logs (not audit logs) that are not meant to serve as audit trails

### Context Check
1. Are audit logs stored in a separate database or storage system from application data?
2. Are audit logs shipped to a remote, immutable storage destination?
3. Do audit entries include timestamp (UTC), user ID, action, resource, and source IP?
4. Are all admin and security-sensitive actions covered by audit logging?
5. Are log deletion or purging operations restricted and themselves audited?
6. Is log rotation configured with appropriate retention periods?
7. Are sensitive fields (passwords, tokens, PII) masked or excluded from audit entries?
8. Are the logs application-level audit logs or just debug/operational logs?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed audit logs are stored in the same database accessible to the application (not separate append-only storage)
2. [ ] Verified the application database user has DELETE or UPDATE permissions on audit tables
3. [ ] Checked for log shipping configuration (Fluentd, Filebeat, Logstash, CloudWatch agent)
4. [ ] Verified audit entries include timestamp (UTC), user ID, action type, and source IP
5. [ ] Confirmed admin and security-sensitive actions have audit logging middleware
6. [ ] Checked if log deletion/purging endpoints exist and whether they require admin authorization
7. [ ] Verified sensitive fields (passwords, tokens, PII) are masked or excluded from audit entries

### Confidence Scoring
- **HIGH**: Audit logs stored in the same database with application having DELETE/UPDATE privileges on audit tables. Or audit log deletion endpoint with no authorization. Or admin actions (role changes, data deletion) with no audit logging whatsoever.
- **MEDIUM**: Audit logging exists but entries lack timestamps, user attribution, or correlation IDs. Or logs are written to local filesystem only with no remote shipping. Or sensitive data (passwords, tokens) is included in log entries.
- **LOW**: Application-level audit logging is minimal but a managed platform (Vercel, AWS) provides infrastructure-level logging. Or the logging gaps are in non-security-sensitive operations.
- **SKIP**: Audit logs in separate append-only storage with immutable retention. Log shipping to CloudWatch/Datadog/Splunk with S3 archival. Structured entries with UTC timestamps, user IDs, actions, and source IPs. PII masked. Admin actions fully covered.

### Files to Check
- `**/audit/**`, `**/audit-log/**`, `**/activity-log/**`, `**/event-log/**`
- `**/middleware/audit*`, `**/middleware/logging*`
- `**/logger.*`, `**/logging.*`, `**/log-config.*`
- Winston/Pino/Bunyan configuration files and transport definitions
- `**/config/logging*`, `**/config/log*`
- Database migration files creating audit/log tables
- Admin route handlers and controllers
- Fluentd, Filebeat, Logstash, Vector configuration files
- `logrotate.d/` configuration, `log4j2.xml`, `logback.xml`
- CloudFormation/Terraform defining CloudWatch Log Groups, S3 log buckets
