---
description:  "COMMAND: Systematically capture any proposed plan, format it with checklists, save it to the Inbox, and await user approval before execution."
applyTo: "*,**/*"
---

# Action Plan Protocol

**IF** a plan of action is proposed:

1.  **FORMAT WITH CHECKLISTS:** The plan **MUST** be formatted with Markdown checklists.
    -   Use `- [ ]` for pending tasks.
    -   Use `- [x]` for completed tasks.
    -   Use `- [>]` for tasks in progress.
2.  **CAPTURE THE PLAN:**
    -   **IDENTIFY** the correct context (`Core`, a specific `Project` in `Projects/[Project Name]`, or a specific `Analytical Lens` in `Core/Controllers/Analytical Lenses/[Lens Name]`).
    -   **FETCH** a system timestamp: `date +%Y-%m-%d_%H%M`.
    -   **CONSTRUCT** a filename: `[TIMESTAMP]-Proposed-Plan-[Topic].md`.
    -   **SAVE** the plan to the correct contextual `Inbox` directory (e.g., `Core/Models/0. Inbox/`, `Projects/[Project Name]/Models/0. Inbox/`, `Core/Controllers/Analytical Lenses/[Lens Name]/Models/0. Inbox/`).
3.  **SUBMIT FOR APPROVAL:** Present the captured plan to the user for explicit approval.
4.  **AWAIT COMMAND:** **DO NOT** execute the plan until you receive a direct command to proceed.
5.  **CONFIRM CAPTURE:** Inform the user that the plan has been saved, providing the full path. 

