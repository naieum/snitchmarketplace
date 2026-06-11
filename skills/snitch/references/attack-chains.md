# Attack Chain Correlation

After generating all findings, analyze them for attack chains before finalizing the report.

## Common Chain Patterns

Check if multiple findings combine into a higher-severity exploit:

| Chain | Finding A | Finding B | Combined Impact | Escalated CVSS |
|-------|-----------|-----------|-----------------|----------------|
| Unauth DB Access | Missing auth on endpoint | SQL injection on same endpoint | Full database compromise without login | 9.8 |
| Session Hijack | XSS vulnerability | Missing CSP headers | Attacker steals session cookies via injected script | 9.1 |
| Cloud Takeover | SSRF vulnerability | Cloud credentials in env | Attacker reaches cloud metadata via SSRF, steals IAM credentials | 9.8 |
| RCE via Upload | File upload no validation | Path traversal | Attacker uploads malicious file to executable path | 9.8 |
| Credential Theft | Hardcoded secret in code | Public repository | Secret exposed to anyone with repo access | 9.5 |
| Brute Force | Missing rate limiting | Weak auth config | Attacker brute-forces login without throttling | 8.5 |
| Data Exfil | IDOR vulnerability | Missing logging | Attacker accesses other users' data undetected | 8.8 |
| Supply Chain | Vulnerable dependency | No SBOM/audit | Known exploit in unmonitored package | 8.0 |

## Process

1. After all individual findings are collected, check each pair for chain relationships
2. Two findings form a chain if:
   - They are in the same request path (same API route or data flow)
   - OR one finding enables/escalates the other
   - AND both are confirmed findings (not suppressed or low-confidence)
3. Only report chains where ALL links exist as confirmed findings
4. A chain's CVSS is the HIGHER of: the escalated score, or the maximum individual score

## Report Format

Add this section after individual findings, before Validation Signals:

```
## Attack Chains

### Chain 1: [Chain Name]
- **Severity:** Critical (escalated from High + High)
- **Path:** [Finding A title] (file:line) + [Finding B title] (file:line)
- **Scenario:** [1-2 sentence description of how an attacker would exploit this chain]
- **Combined CVSS:** 9.8
- **Fix priority:** P1 -- fix [which finding] first to break the chain
```

## Rules
- Only report chains where both findings are real (not hypothetical)
- Maximum 5 chains per report (focus on highest severity)
- If no chains found, omit this section entirely (don't say "no chains found")
- Chains should increase the overall risk rating if they escalate severity
