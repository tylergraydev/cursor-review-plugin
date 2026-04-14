# Cursor Review Plugin for Claude Code

A Claude Code plugin that uses [Cursor's Agent CLI](https://cursor.com/cli) to provide a second-opinion code review from a different AI stack.

## Why?

When the same model writes and reviews code, it tends to overlook its own blind spots (sycophancy bias). This plugin sends your diffs to Cursor for an independent review — catching things Claude might miss, and vice versa.

Inspired by the [Codex plugin for Claude Code](https://github.com/openai/codex-plugin-cc).

## Commands

| Command | Description |
|---|---|
| `/cursor:review` | Standard code review — bugs, security, performance, style |
| `/cursor:adversarial-review` | Adversarial review — actively tries to break your code |

Both commands review uncommitted changes by default, or accept a base branch argument (e.g., `main`).

## Prerequisites

- **[Claude Code](https://claude.ai/code)** installed
- **[Cursor Agent CLI](https://cursor.com/cli)** installed (`agent` binary on PATH)
- **Active Cursor subscription**

Verify your setup:

```bash
agent -p --output-format text "say hello"
```

## Installation

### As a Claude Code plugin

```bash
claude plugin add <your-github-username>/cursor-review-plugin
```

### Manual installation

Copy the `cursor-review-plugin` directory into your Claude Code skills folder:

```bash
cp -r cursor-review-plugin ~/.claude/skills/cursor-review
```

## Usage

From Claude Code, just say:

- `"Review my changes with Cursor"` or `/cursor:review`
- `"Adversarial review with Cursor"` or `/cursor:adversarial-review`
- `"Review my changes against main with Cursor"` (to diff against a branch)

## Configuration

Set environment variables to customize behavior:

| Variable | Default | Description |
|---|---|---|
| `CURSOR_REVIEW_MODEL` | (Cursor default) | Override the model (e.g., `gpt-5`, `claude-sonnet-4-6`) |
| `CURSOR_REVIEW_TIMEOUT` | `120` (standard) / `180` (adversarial) | Timeout in seconds |

## How it works

1. Collects your git diff (uncommitted changes or branch comparison)
2. Constructs a review prompt tailored to the review mode
3. Pipes it to `agent -p --output-format text` (Cursor's headless mode)
4. Returns structured feedback in the conversation

The plugin is strictly **read-only** — it never modifies your files.

## License

MIT
