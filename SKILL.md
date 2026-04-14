---
name: cursor-review
description: >
  Use Cursor's AI agent to review code changes from a second perspective.
  Provides standard and adversarial code review via the Cursor CLI (`agent`).
  Trigger this skill when the user asks for a Cursor review, a second-opinion review,
  an adversarial review using Cursor, or wants to cross-check code with Cursor's models.
  Also trigger when the user says "/cursor:review" or "/cursor:adversarial-review".
compatibility:
  requires:
    - Cursor Agent CLI (`agent`) installed and authenticated (https://cursor.com/cli)
---

# Cursor Review Plugin for Claude Code

This plugin gives you two slash-style commands that invoke the Cursor CLI
to review code — providing a genuine second opinion from a different AI stack.

## Why a second opinion matters

When the same model writes and reviews code, it tends to be blind to its own
mistakes (sycophancy bias). Cursor uses different models and different system
prompts, so its reviews catch things Claude might miss — and vice versa.

## Commands

### `/cursor:review`

Runs a standard code review on the current uncommitted changes (or a specified
diff). Cursor examines the changes for bugs, logic errors, security issues,
performance problems, and style concerns, then returns structured feedback.

**Usage patterns the user might say:**
- "Review my changes with Cursor"
- "Get a Cursor review"
- "Second opinion on this diff"
- "/cursor:review"

### `/cursor:adversarial-review`

Runs an adversarial review where Cursor actively tries to break the code.
It probes edge cases, questions architectural decisions, challenges assumptions,
and plays devil's advocate on design choices. This is the mode you want before
merging high-stakes changes.

**Usage patterns the user might say:**
- "Do an adversarial review with Cursor"
- "Try to break my code with Cursor"
- "Cursor adversarial review"
- "/cursor:adversarial-review"

## How it works

1. The plugin collects the diff (uncommitted changes by default, or a branch
   comparison if specified).
2. It constructs a review prompt and passes it to `agent` (Cursor's CLI) in
   headless print mode (`-p --output-format text`).
3. Cursor's response is captured and returned to the conversation.

## Execution

When the user triggers a review, run the appropriate script:

### Standard Review

```bash
bash <SKILL_DIR>/scripts/cursor-review.sh [base-branch]
```

- If `base-branch` is omitted, reviews uncommitted changes (`git diff`).
- If provided, reviews the diff between that branch and HEAD.

### Adversarial Review

```bash
bash <SKILL_DIR>/scripts/cursor-adversarial-review.sh [base-branch]
```

Same diff logic, but with an adversarial prompt that instructs Cursor to
actively try to find problems and challenge design decisions.

## Setup

The user needs:

1. **Cursor Agent CLI installed**: install via `npm install -g @nothumanwork/cursor-agents-sdk` or Cursor's installer
2. **An active Cursor subscription** (the CLI uses the same auth)
3. **`agent` on PATH**: verify with `which agent` or `where agent`

Run the setup check:
```bash
bash <SKILL_DIR>/scripts/cursor-setup.sh
```

## Output

The review results are returned as text directly in the conversation. The
plugin does not modify any files — it is strictly read-only.

## Customization

You can set environment variables to customize behavior:

- `CURSOR_REVIEW_MODEL`: Override the model Cursor uses (e.g., `gpt-5`, `claude-sonnet-4-6`)
- `CURSOR_REVIEW_TIMEOUT`: Timeout in seconds (default: 120)
