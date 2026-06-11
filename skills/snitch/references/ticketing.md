# Ticket Creation

## Security: No API Keys on Engineer Machines

Primary: Use Devin's org-level integrations (Settings > Integrations). The skill instructs Devin to create tickets through existing authenticated connections.

Fallback: Generate `findings-tickets.json` for manual bulk import. No API keys needed.

Last resort: GitHub Issues via `gh` CLI (already authenticated through Devin's GitHub integration).

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
| Labels | From `snitch.config.md` ticketing-labels + severity tag |
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

## Config (snitch.config.md)

```
ticketing-system: jira | linear | github | gitlab
ticketing-project: SEC
ticketing-labels: security, snitch
```
