# Snitch Configuration

# Branding — when tool-name is set, apply references/white-label.md
tool-name: Snitch
report-title: Security Audit Report
footer-text: Scanned by Snitch

# Confidence threshold: low | medium (default) | high
# min-confidence: medium

# Ticketing integration
# Configure your ticketing system below. If no API key is available,
# Snitch generates findings-tickets.json for manual import.
# ticketing-system: jira
# ticketing-project: SEC
# ticketing-labels: security, snitch

# LLM-as-grader meta-evaluation — full spec: references/grader.md.
# The redaction hard-fail gate (Rule 5) always runs, regardless of `enabled`.
grader:
  enabled: true                            # master toggle for the 5-criteria scoring pass
  pass_threshold: 8                        # findings need >= this score to pass (max 10)
  compliance_pass_threshold: 9             # stricter bar for Type: compliance categories
  rewrite_failures: true                   # auto-rewrite findings below threshold, then re-grade
  fail_severity_threshold: low             # findings at this severity or below skip the grader
  auto_skip_scan_modes: quick, diff        # modes that skip grading by default even when enabled
  required_scan_modes: compliance, full, ultra  # modes that always grade regardless of auto_skip
