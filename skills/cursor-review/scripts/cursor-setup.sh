#!/usr/bin/env bash
# cursor-setup.sh — Verify that the Cursor Agent CLI is installed and ready to use.

set -euo pipefail

echo "=== Cursor Review Plugin — Setup Check ==="
echo ""

# 1. Check for 'agent' (the Cursor Agent CLI binary)
if command -v agent &>/dev/null; then
    AGENT_PATH=$(command -v agent)
    echo "[OK] agent found at: $AGENT_PATH"
else
    echo "[MISSING] 'agent' command not found on PATH."
    echo ""

    # Check if they have the IDE launcher instead
    if command -v cursor &>/dev/null; then
        CURSOR_IDE=$(command -v cursor)
        echo "  Note: You have 'cursor' at $CURSOR_IDE"
        echo "  That's the IDE launcher — it opens files in the Cursor editor."
        echo "  The review plugin needs 'agent', which is the Cursor Agent CLI."
    fi

    echo ""
    echo "  Install the Cursor Agent CLI:"
    echo "    npm install -g @nothumanwork/cursor-agents-sdk"
    echo "  or on macOS/Linux:"
    echo "    curl https://cursor.com/install -fsSL | bash"
    echo ""
    echo "  You need an active Cursor subscription (the CLI uses the same auth)."
    exit 1
fi

# 2. Quick smoke test
echo ""
echo "Running quick smoke test..."
SMOKE_RESULT=$(timeout 30 agent -p --output-format text "Reply with exactly the word: CURSOR_OK" 2>&1) || true

if echo "$SMOKE_RESULT" | grep -qi "CURSOR_OK"; then
    echo "[OK] Cursor Agent CLI is responding correctly."
else
    echo "[WARN] agent ran but gave an unexpected response."
    echo "       This may indicate an authentication or configuration issue."
    echo ""
    echo "  Response was:"
    echo "  $SMOKE_RESULT" | head -20
    echo ""
    echo "  Try running manually to debug:"
    echo "    agent -p --output-format text \"say hello\""
fi

echo ""
echo "=== Setup check complete ==="
