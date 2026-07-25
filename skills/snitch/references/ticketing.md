# Ticket Creation

## Security: No API Keys on Engineer Machines

Primary: Use the host's configured issue-tracker integration if one exists. Create tickets through that existing authenticated connection — never ask the user for an API key.

Fallback: Generate `findings-tickets.json` for manual bulk import. No API keys needed, works on every host.

Last resort: GitHub Issues via `gh` CLI, only when `gh auth status` already succeeds. If it does not, stop at the import file.

## Flow

1. Display findings summary
2. Ask: "Create tickets for all N findings, or select specific? [all / select / cancel]"
3. If "select": show numbered list, user picks by number
4. For each selected finding, build ticket
5. Check for existing tickets with matching title prefix to avoid duplicates
6. Create or generate import file
7. Report: "Created X tickets. Skipped Y (duplicates)."

## Ticket Field Mapping

| Field | Value |
|-------|-------|
| Title | `[SEVERITY] Finding title -- file.ts:47` |
| Description | Severity, CWE, OWASP, evidence (redacted), risk, fix |
| Labels | From `snitch-security.config.md` ticketing-labels + severity tag |
| Priority | P1->Urgent, P2->High, P3->Medium, P4->Low |

## Import File Format (findings-tickets.json)

```json
[
  {
    "title": "[CRITICAL] Hardcoded API key -- src/config.ts:12",
    "description": "**Severity:** Critical | CVSS 4.0: ~9.1\n**CWE:** CWE-798\n...",
    "labels": ["security", "critical"],
    "priority": "urgent"
  }
]
```

## Config (snitch-security.config.md)

```
ticketing-system: jira | linear | github | gitlab
ticketing-project: SEC
ticketing-labels: security, snitch
```
