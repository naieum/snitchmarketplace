# White-Label Configuration

When `snitch.config.md` contains a `tool-name` field, override branding in all output.

## Config Fields

| Field | Default | Effect |
|-------|---------|--------|
| `tool-name` | Snitch | Replaces "Snitch" in all output text |
| `report-title` | Security Audit Report | Report header |
| `footer-text` | Scanned by Snitch | Report footer |

## What Gets Overridden

- Report title header
- Report footer line
- Scan progress messages (e.g., "[tool-name]: scanning...")
- Post-scan "Done" message
- SARIF tool.driver.name field

## What Does NOT Change

- Category file content (references patterns, not tool name)
- SKILL.md internal instructions
- CWE/OWASP/CVSS references
- File names (SECURITY_AUDIT_REPORT.md stays the same)
