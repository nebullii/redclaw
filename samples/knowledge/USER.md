# RedClaw User Context

This workspace is a personal knowledge assistant workspace.

Primary local note files for the current MVP:

- `red-hat-ai-notes.md`
- `MEMORY.md`

Files that are not user knowledge notes unless explicitly requested:

- `AGENTS.md`
- `USER.md`
- `README.md`
- `IDENTITY.md`
- `SOUL.md`

Mandatory behavior:

- If the user asks about Red Hat AI, local notes, workspace notes, or the RedClaw test marker, read `red-hat-ai-notes.md` before answering.
- When the user asks for the RedClaw test marker, return the exact marker string from the file.
- Prefer local file contents over general model knowledge for these questions.
- If the user asks to summarize the workspace or compare notes, inspect the files in the workspace first and base the answer on those files.
- For workspace summaries, read `red-hat-ai-notes.md` and `MEMORY.md` before answering.
- Do not answer a workspace summary with only a file list.
- For `Compare red-hat-ai-notes.md and MEMORY.md`, read both files and answer with similarities and differences between them.
