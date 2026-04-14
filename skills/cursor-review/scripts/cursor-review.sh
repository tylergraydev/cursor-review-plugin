#!/usr/bin/env bash
# cursor-review.sh — Standard code review via Cursor CLI.
#
# Usage:
#   bash cursor-review.sh              # Review uncommitted changes
#   bash cursor-review.sh main         # Review diff from 'main' to HEAD
#   bash cursor-review.sh origin/main  # Review diff from remote main to HEAD
#
# Environment variables:
#   CURSOR_REVIEW_MODEL   — Override the Cursor model (optional)
#   CURSOR_REVIEW_TIMEOUT — Timeout in seconds (default: 120)

set -euo pipefail

BASE_BRANCH="${1:-}"
TIMEOUT="${CURSOR_REVIEW_TIMEOUT:-120}"
MODEL_FLAG=""

if [[ -n "${CURSOR_REVIEW_MODEL:-}" ]]; then
    MODEL_FLAG="--model $CURSOR_REVIEW_MODEL"
fi

# Collect the diff
if [[ -z "$BASE_BRANCH" ]]; then
    # Uncommitted changes (staged + unstaged)
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

# Build the review prompt
REVIEW_PROMPT="You are a senior code reviewer. Review the following diff carefully.

For each issue you find, provide:
1. The file and approximate line number
2. The severity (critical / warning / suggestion)
3. A clear description of the problem
4. A suggested fix if applicable

Focus on:
- Bugs and logic errors
- Security vulnerabilities
- Performance issues
- Error handling gaps
- Race conditions or concurrency issues
- API misuse

Be specific and actionable. If the code looks good, say so — don't invent problems.

Here is the diff ($DIFF_DESC):

\`\`\`diff
$DIFF
\`\`\`"

echo "Sending $DIFF_DESC to Cursor for review..."
echo "---"

# Run Cursor in headless print mode
timeout "$TIMEOUT" agent -p --output-format text $MODEL_FLAG "$REVIEW_PROMPT" 2>&1

EXIT_CODE=$?
if [[ $EXIT_CODE -eq 124 ]]; then
    echo ""
    echo "[TIMEOUT] Cursor review timed out after ${TIMEOUT}s. Try increasing CURSOR_REVIEW_TIMEOUT."
fi
