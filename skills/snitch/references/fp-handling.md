# False Positive Triage Flow

## Triage Process

For each finding, present:

```
Finding #1: [Title] -- file:line
Severity: [Level] | CWE: [id] | Confidence: [level]

[1] Confirmed -- this is a real issue
[2] False positive -- not actually vulnerable
[3] Accepted risk -- known issue, won't fix
[4] Skip -- decide later
```

## On "False positive" (option 2)

1. Ask: "Brief reason? (one line)"
2. Append to `.snitch-ignore` in project root:
   ```
   file.ts:47  CWE-89  false-positive  "reason text"  @user
   ```
3. This finding will be automatically suppressed in future scans.

## On "Accepted risk" (option 3)

1. Ask: "Brief reason and approver? (e.g., 'legacy code, removal in Q2 @manager')"
2. Append to `.snitch-ignore`:
   ```
   file.ts:47  CWE-89  accepted-risk  "legacy code, removal in Q2"  @manager
   ```

## FP Rate Tracking

After triage, calculate and display:

```
## Scan Quality
- Total findings this scan: 12
- Suppressed via .snitch-ignore: 3
- Triaged this session: 9 (7 confirmed, 2 false positive)
- Effective FP rate: 22% (historical: 2 FP out of 9 triaged)
```

## .snitch-ignore Format

```
# file:line  CWE  status  "reason"  @approver
src/config.ts:12  CWE-798  false-positive  "test key, not production"  @jane
src/legacy/api.ts:47  CWE-89  accepted-risk  "removal in Q2"  @john
```
