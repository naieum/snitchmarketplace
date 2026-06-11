# Custom Rules

Add organization-specific security rules here. Files in this directory are loaded alongside built-in categories during scans.

## Quick Start

1. Copy `example-internal-api.md` to a new file (e.g., `my-rule.md`)
2. Edit the sections to match your organization's patterns
3. Run a scan -- custom rules are automatically detected

## Format

See `references/custom-rules-format.md` in the skill directory for the full specification.

Each file should include:
- **Detection**: How to identify if this rule applies
- **What to Search For**: Grep/glob patterns
- **Actually Vulnerable**: Real issue examples
- **NOT Vulnerable**: Known false positives
- **Context Check**: Verification questions
- **Files to Check**: Relevant file patterns

## Naming

Use descriptive names: `internal-api-auth.md`, `pii-handling.md`, etc.
No numbering needed.
