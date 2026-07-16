## CATEGORY 59: Backup & Recovery Security
> Type: posture · Groups: — · CWE: CWE-530

### Detection
- Database backup utilities: `pg_dump`, `pg_dumpall`, `mysqldump`, `mongodump`, `pg_basebackup`, `xtrabackup`
- Backup scripts and cron jobs (`*.sh`, `crontab`, scheduled tasks)
- Cloud backup configuration: S3 bucket policies, RDS snapshot settings, Azure Backup vaults
- Backup-related file extensions in web-accessible directories (`.sql`, `.dump`, `.bak`, `.gz`, `.tar`)
- Backup/restore automation tools: `restic`, `borgbackup`, `velero`, `barman`

### What to Search For

**Database Backups Without Encryption:**
- `pg_dump` commands without piping to encryption (`gpg`, `openssl`, `age`)
- `mysqldump` output written to plain `.sql` files without encryption
- `mongodump` without `--ssl` and output not encrypted before storage
- Backup scripts writing plaintext database exports to disk or cloud storage
- S3 `PutObject` for backups without `ServerSideEncryption` parameter
- RDS snapshots without encryption enabled (`StorageEncrypted: false`)
- Backup archives (`.tar.gz`, `.zip`) without password/encryption protection

**Backup Files Accessible via Web:**
- `.sql`, `.dump`, `.bak`, `.sqlite`, `.mdb` files in `public/`, `static/`, `www/`, `htdocs/`, `wwwroot/` directories
- Database export files in web root or publicly served directories
- No `.htaccess`, nginx, or server rules blocking access to backup file extensions
- S3 buckets with backup files and public access enabled (`PublicRead`, `PublicReadWrite`)
- Backup files served by static file middleware without access restriction

**Backup Credentials Hardcoded:**
- `pg_dump` or `mysqldump` commands with `-p password` or `--password=` in scripts
- `PGPASSWORD=` set inline in backup shell scripts
- `.pgpass` or `.my.cnf` files with credentials committed to version control
- Database connection strings with embedded passwords in backup automation
- AWS credentials hardcoded in backup scripts (instead of IAM roles or instance profiles)
- Backup service account passwords in plaintext configuration files

**No Backup Verification/Restore Testing:**
- Backup scripts that never verify backup integrity (no `pg_restore --list`, no checksum validation)
- No automated restore test in CI/CD or scheduled jobs
- Missing backup size or completion status validation after backup runs
- No alerting on backup failure (exit code not checked in scripts)
- Backup jobs that silently fail without notification

**Backup Retention Policy Missing:**
- No automated cleanup of old backups (backups accumulate indefinitely)
- S3 lifecycle rules not configured on backup buckets
- No rotation or pruning logic in backup scripts
- Backup storage growing unbounded with no expiration or archival policy
- Missing compliance-driven retention periods for regulated data

**No Geo-Redundancy:**
- All backups stored in the same region/data center as primary database
- S3 backups without cross-region replication enabled
- No off-site backup copy or secondary storage location
- Single point of failure for backup storage

**S3 Buckets with Backups Publicly Accessible:**
- S3 bucket policies with `"Principal": "*"` on backup buckets
- Bucket ACLs set to `public-read` or `public-read-write`
- No `aws:SecureTransport` condition in bucket policy (allows HTTP access)
- Missing `BlockPublicAccess` configuration on backup buckets
- CloudFormation/Terraform S3 bucket definitions without access restrictions

**Password in Command Line:**
- `pg_dump -U user -W` with password piped or provided inline
- `mysqldump -u root -pMyPassword` -- password visible in process listing
- `mongodump --password=secret` in scripts or cron jobs
- Backup commands with credentials visible via `ps aux` or `/proc/*/cmdline`
- Credentials passed as command-line arguments instead of environment variables or credential files

### Actually Vulnerable
- Cron job: `pg_dump mydb > /var/www/html/backup.sql` -- plaintext database backup in web root
- Backup script with `PGPASSWORD=supersecret pg_dump ...` -- credential in script, visible in process list
- S3 backup bucket with `"Effect": "Allow", "Principal": "*", "Action": "s3:GetObject"` -- anyone can download backups
- `mysqldump -u root -pPassword123 production > backup.sql` -- password on command line, backup unencrypted
- RDS instance with `StorageEncrypted: false` and automated snapshots -- backups stored unencrypted
- Backup script that runs `pg_dump` but never checks exit code or verifies output file size -- silent failures
- All backups stored in `us-east-1` S3 bucket only, same region as primary RDS -- no geo-redundancy
- Backup files with `.sql.gz` extension served by Express `express.static('public')` without exclusion

### NOT Vulnerable
- Backup script that pipes `pg_dump` through `gpg --encrypt` before writing to encrypted S3 bucket
- Credentials sourced from AWS Secrets Manager or HashiCorp Vault in backup automation
- S3 backup bucket with `BlockPublicAccess: true`, SSE-S3 encryption, and lifecycle rules
- Automated restore test running nightly in CI that validates backup integrity
- Backup retention policy with 30-day active, 90-day archive, configured via S3 lifecycle rules
- Cross-region replication enabled on backup S3 buckets
- `.pgpass` file with `chmod 600` permissions, not committed to version control
- Development database backups without encryption (non-production, no real data)
- RDS automated backups with encryption enabled and managed by cloud provider

### Context Check
1. Are database backups encrypted both in transit and at rest?
2. Are backup files stored outside of web-accessible directories?
3. Are backup credentials sourced from secret managers or environment variables (not hardcoded)?
4. Is there automated backup verification and periodic restore testing?
5. Is there a defined backup retention and rotation policy?
6. Are backups stored in multiple geographic regions?
7. Are S3 or cloud storage buckets for backups configured with restrictive access policies?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed backup files are not stored in web-accessible directories (public/, static/, www/)
2. [ ] Verified backup output is encrypted before storage (piped through gpg, openssl, age, or stored in encrypted S3)
3. [ ] Checked backup scripts for hardcoded credentials (inline passwords, PGPASSWORD in script)
4. [ ] Verified backup scripts check exit codes and have alerting on failure
5. [ ] Confirmed S3 backup buckets have `BlockPublicAccess` enabled and restrictive bucket policies
6. [ ] Checked for backup retention and rotation policy (lifecycle rules, pruning logic)
7. [ ] Verified this is not a development-only backup process with no real sensitive data

### Confidence Scoring
- **HIGH**: Database backup written to web-accessible directory without encryption. Backup script with hardcoded credentials visible in process listing. S3 backup bucket with public access enabled. Or backup script with no exit code checking (silent failures).
- **MEDIUM**: Backups are encrypted but stored only in a single region with no geo-redundancy. Or backup retention exists but no automated restore testing to verify backup integrity.
- **LOW**: Backups are managed by a cloud provider (RDS automated backups, managed database snapshots) which handles encryption, retention, and redundancy at infrastructure level.
- **SKIP**: Backup script encrypts with GPG before uploading to encrypted S3 bucket with BlockPublicAccess, lifecycle rules, and cross-region replication. Credentials from secrets manager. Automated restore tests in CI.

### Files to Check
- `**/backup/**`, `**/backups/**`, `**/scripts/backup*`, `**/cron/**`
- `**/Makefile` (backup targets), `**/docker-compose.yml` (backup volumes)
- `crontab`, `**/cron.d/**`, scheduled task definitions
- `*.sh` scripts containing `pg_dump`, `mysqldump`, `mongodump`
- Terraform/CloudFormation defining S3 buckets, RDS snapshots, backup vaults
- `.pgpass`, `.my.cnf` (database credential files)
- Web server configuration (nginx.conf, apache .htaccess) for file extension blocking
- `public/`, `static/`, `www/`, `dist/` directories for stray backup files
