# Interactive Findings Walkthrough

Present findings one at a time with diff previews for targeted fix application.

## Flow

For each finding (ordered by Priority: P1 first):

### Step 1: Display Finding with Diff

```
--- Finding [N/total] ---
Severity: Critical | CWE-89 | CVSS 9.1 | Confidence: High
File: src/db/users.ts:47
Author: @jane (2026-02-15)

CURRENT CODE:
  const result = db.query("SELECT * FROM users WHERE id = " + userId);

SUGGESTED FIX:
  const result = db.query("SELECT * FROM users WHERE id = $1", [userId]);

Apply this fix? [yes / skip / mark-fp / stop]
```

### Step 2: Handle Response

- **yes**: Apply the fix using file editing. Re-scan the fixed file for the same category. Display: "Verified: finding resolved" or "Warning: still present."
- **skip**: Move to next finding without action.
- **mark-fp**: Ask for a one-line reason. Add entry to `.snitch-ignore`. Move to next finding.
- **stop**: Return to post-scan menu. Remaining findings stay in report.

### Step 3: Summary

After all findings processed:
```
Walkthrough complete:
- Fixed: 5 (all verified resolved)
- Marked FP: 2 (added to .snitch-ignore)
- Skipped: 1
- Remaining: 0
```

## When to Use

Triggered when user selects "Fix one by one" from the post-scan menu.
