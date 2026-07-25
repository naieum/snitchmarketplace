#!/bin/sh
# Snitch pre-commit hook — generic version
# Scans staged files for security issues before commit.
#
# Install:
#   cp skills/snitch/hooks/pre-commit.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Bypass for emergency commits:
#   git commit --no-verify
#
# Environment variables:
#   SNITCH_TIMEOUT  — scan timeout in seconds (default: 120)
#   SNITCH_BLOCK    — set to 1 to block commit on findings (default: warn only)

set -e

# Get staged files into a temp file to handle filenames with spaces
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
git diff --cached --name-only --diff-filter=ACM > "$TMPFILE"

if [ ! -s "$TMPFILE" ]; then
  exit 0
fi

FILE_COUNT=$(wc -l < "$TMPFILE" | tr -d ' ')

echo ""
echo "  Snitch: scanning $FILE_COUNT staged file(s)..."
echo ""

# Validate and sanitize timeout (digits only)
TIMEOUT=${SNITCH_TIMEOUT:-120}
case "$TIMEOUT" in
  *[!0-9]*) TIMEOUT=120 ;;
esac

# Detect available AI tool CLI and run directly (no eval)
if command -v claude >/dev/null 2>&1; then
  if command -v timeout >/dev/null 2>&1; then
    timeout "$TIMEOUT" claude --print '/snitch diff' || {
      EXIT_CODE=$?
      if [ "$EXIT_CODE" -eq 124 ]; then
        echo ""
        echo "  Snitch: scan timed out after ${TIMEOUT}s. Commit proceeding."
        echo ""
        exit 0
      fi
      if [ "${SNITCH_BLOCK:-0}" = "1" ]; then exit "$EXIT_CODE"; fi
      exit 0
    }
  else
    claude --print '/snitch diff'
  fi
else
  # Fallback: local regex scan for critical patterns
  echo "  Snitch: No AI tool CLI found. Running lightweight pattern check..."
  echo ""

  FINDINGS=0
  while IFS= read -r FILE; do
    [ ! -f "$FILE" ] && continue

    # Hardcoded secrets
    if grep -nE '(sk_live_|sk_test_|AKIA[A-Z0-9]{16}|ghp_[a-zA-Z0-9]{36}|glpat-[a-zA-Z0-9\-]{20}|xoxb-[0-9]+)' "$FILE" 2>/dev/null; then
      echo "  !! CRITICAL: Possible hardcoded secret in $FILE"
      FINDINGS=$((FINDINGS + 1))
    fi

    # Private keys
    if grep -nE 'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY' "$FILE" 2>/dev/null; then
      echo "  !! CRITICAL: Private key found in $FILE"
      FINDINGS=$((FINDINGS + 1))
    fi
  done < "$TMPFILE"

  if [ "$FINDINGS" -gt 0 ]; then
    echo ""
    echo "  Snitch: $FINDINGS potential issue(s) found."
    if [ "${SNITCH_BLOCK:-0}" = "1" ]; then
      echo "  Commit blocked. Fix issues or bypass with: git commit --no-verify"
      exit 1
    else
      echo "  Commit proceeding (set SNITCH_BLOCK=1 to block)."
    fi
  else
    echo "  Snitch: No critical patterns found. Commit proceeding."
  fi
  echo ""
  exit 0
fi
