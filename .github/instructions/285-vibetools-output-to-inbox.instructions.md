---
description:  
applyTo: "*,**/*"
---

# 285: Vibe Tools Output to Inbox

### Purpose
To ensure that valuable outputs from `vibe-tools` commands (such as analyses, plans, or extensive documentation) are systematically captured and stored in the `inbox/` directory for future reference and processing.

### Trigger
When using `vibe-tools` commands that generate substantial textual output intended for review or later use (e.g., `repo`, `plan`, `doc`).

### AI Protocol
1.  **Identify Need for Saving:** Recognize when a `vibe-tools` command (e.g., `repo`, `plan`, `doc`) will produce output that should be saved.
2.  **Fetch Current Date and Time:** Before constructing the filename, execute the terminal command `date +%Y-%m-%d_%H%M` to get the current timestamp, per rule `207-timestamp-accuracy-protocol.instructions.md`.
3.  **Construct Filename:** Use the timestamp to assemble the filename according to the convention in rule `280-inbox-file-naming.instructions.md`.
    *   The description should be concise and indicate the tool used (e.g., `vibetools-plan-auth-feature`).
    *   Example: `inbox/[fetched_date_time]-vibetools-repo-analysis.md`
4.  **Execute and Save:** Run the `vibe-tools` command, including the `--save-to` option with the fully constructed path and filename.
5.  **Inform User:** After executing the command, inform the user that the output has been saved to the specified file in the `inbox/`, including the exact filename.

### Example Vibe Tools Command
```bash
# First, the AI runs 'date +%Y-%m-%d_%H%M' to get the timestamp (e.g., 2023-10-27_1430)
vibe-tools repo "Evaluate what we still need to do before this repo is ready to be pushed to GitHub as a public repository. " --save-to=inbox/2025-06-20_1630-vibetools-repo-analysis.md
```

### Rationale
This practice ensures that important generated information is not lost and can be easily found and processed later. It also keeps the primary chat/terminal output cleaner.
