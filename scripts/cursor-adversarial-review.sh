#!/usr/bin/env bash
# cursor-adversarial-review.sh — Adversarial code review via Cursor CLI.
#
# Like cursor-review.sh, but Cursor actively tries to break the code,
# challenge design decisions, and find edge cases.
#
# Usage:
#   bash cursor-adversarial-review.sh              # Review uncommitted changes
#   bash cursor-adversarial-review.sh main         # Review diff from 'main' to HEAD
#   bash cursor-adversarial-review.sh origin/main  # Review diff from remote main to HEAD
#
# Environment variables:
#   CURSOR_REVIEW_MODEL   — Override the Cursor model (optional)
#   CURSOR_REVIEW_TIMEOUT — Timeout in seconds (default: 180)

set -euo pipefail

BASE_BRANCH="${1:-}"
TIMEOUT="${CURSOR_REVIEW_TIMEOUT:-180}"
MODEL_FLAG=""

if [[ -n "${CURSOR_REVIEW_MODEL:-}" ]]; then
    MODEL_FLAG="--model $CURSOR_REVIEW_MODEL"
fi

# Collect the diff
if [[ -z "$BASE_BRANCH" ]]; then
    DIFF=$(git diff HEAD 2>/dev/null || git diff 2>/dev/null)
    DIFF_DESC="uncommitted changes"
else
    DIFF=$(git diff "$BASE_BRANCH"...HEAD 2>/dev/null || git diff "$BASE_BRANCH" HEAD 2>/dev/null)
    DIFF_DESC="changes from $BASE_BRANCH to HEAD"
fi

if [[ -z "$DIFF" ]]; then
    echo "No changes detected ($DIFF_DESC). Nothing to review."
    exit 0
fi

# Build the adversarial review prompt
REVIEW_PROMPT="You are a skeptical, adversarial code reviewer. Your job is to actively
try to break this code and find every possible issue. Do NOT be polite — be thorough
and aggressive in your analysis.

Your approach:
1. **Try to break it**: Think of inputs, states, and conditions that would cause
   failures, crashes, or incorrect behavior.
2. **Challenge assumptions**: Question every design decision. Why was this approach
   chosen? What are the tradeoffs? What alternatives would be better?
3. **Probe edge cases**: What happens with empty inputs? Null values? Extremely
   large inputs? Concurrent access? Network failures? Disk full?
4. **Question security**: Could this be exploited? Is there injection risk? Are
   secrets handled properly? Are permissions checked?
5. **Stress the architecture**: Does this scale? Does it create coupling that will
   hurt later? Is it testable? Will it be maintainable in 6 months?

For each finding, provide:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- The specific file and location
- A concrete scenario that demonstrates the problem
- What you'd do differently

Be ruthless. If you can't find real issues, that's fine — say the code is solid.
But don't go easy just to be nice.

Here is the diff ($DIFF_DESC):

\`\`\`diff
$DIFF
\`\`\`"

echo "Sending $DIFF_DESC to Cursor for adversarial review..."
echo "(This is the aggressive mode — Cursor will try to break your code.)"
echo "---"

# Run Cursor in headless print mode
timeout "$TIMEOUT" agent -p --output-format text $MODEL_FLAG "$REVIEW_PROMPT" 2>&1

EXIT_CODE=$?
if [[ $EXIT_CODE -eq 124 ]]; then
    echo ""
    echo "[TIMEOUT] Adversarial review timed out after ${TIMEOUT}s. Try increasing CURSOR_REVIEW_TIMEOUT."
fi
