# /cursor:review

Run a standard code review on your current changes using the Cursor Agent CLI.

## Instructions

1. Read the skill file at `skills/cursor-review/SKILL.md` for full context.
2. Run the review script:
   ```bash
   bash <PLUGIN_DIR>/skills/cursor-review/scripts/cursor-review.sh
   ```
3. If the user specifies a base branch (e.g., "review against main"), pass it as an argument:
   ```bash
   bash <PLUGIN_DIR>/skills/cursor-review/scripts/cursor-review.sh main
   ```
4. Present Cursor's feedback to the user.
