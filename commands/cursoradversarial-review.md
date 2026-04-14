# /cursor:adversarial-review

Run an adversarial code review using the Cursor Agent CLI. Cursor will actively try to break your code, challenge design decisions, and probe edge cases.

## Instructions

1. Read the skill file at `skills/cursor-review/SKILL.md` for full context.
2. Run the adversarial review script:
   ```bash
   bash <PLUGIN_DIR>/skills/cursor-review/scripts/cursor-adversarial-review.sh
   ```
3. If the user specifies a base branch, pass it as an argument:
   ```bash
   bash <PLUGIN_DIR>/skills/cursor-review/scripts/cursor-adversarial-review.sh main
   ```
4. Present Cursor's feedback to the user.
