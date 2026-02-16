Summarize this Claude Code session into a diary-style journal entry.

Steps:
1. Ensure the directory ~/Documents/ai-agent-dairy-journal/ exists (create if needed)
2. Review the full conversation context to understand what was discussed and accomplished
3. Derive a short slug from the session's main topic (lowercase, hyphenated, e.g. "nightfox-colorscheme")
4. Determine today's date in YYYY-MM-DD format
5. Build a journal entry in this exact format:

```
# [Task Title]

- **Date**: YYYY-MM-DD
- **Project**: [repo/project name or cwd]

## Goal
[What the user wanted to accomplish]

## Interaction Log
1. **User**: [what the user asked/requested]
   **Claude**: [what Claude did — investigated, suggested, executed, etc.]
   **Result**: [outcome — success, error, decision made]

2. **User**: [follow-up request or feedback]
   **Claude**: [next action taken]
   **Result**: [outcome]

(continues for each meaningful exchange)

## Changes Made
- [file]: [what changed]
- ...

## Takeaways
[Insights, patterns, or lessons from this interaction]
```

6. Write the entry to ~/Documents/ai-agent-dairy-journal/YYYY-MM-DD-slug.md
   - If that file already exists, read it and append the new entry separated by a line containing only `---`
7. Show the user the full generated journal entry and the file path where it was saved
