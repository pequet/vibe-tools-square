---
description:  
applyTo: "*,**/*"
---

# 220: Memory Reset Protocol

### Initialization Protocol
UPON initialization or reset, EXECUTE this review sequence to establish context:

1.  **READ `README.md`** to understand the project structure.
2.  **REVIEW `memory-bank/development-status.md`** for the current project state.
3.  **CHECK `memory-bank/development-log.md`** for recent activities (NOTE: Newest entries are at the top).
4.  **IDENTIFY `memory-bank/active-context.md`** for the current focus and next steps.
5.  **REVIEW other `memory-bank/` files** as required by the specific task.

### System Triggers (User Commands)
-   `initialize memory bank`: Review all Memory Bank files; verify setup and REPLACE the **Example Text** with project-specific content.
-   `update memory bank`: Review and update relevant Memory Bank documentation.
-   `memory bank status`: Check if Memory Bank documentation is current and complete.
-   `describe memory bank`: Explain Memory Bank organization and file purposes.

### Memory Bank Initialization Protocol
UPON receiving the `initialize memory bank` command, EXECUTE the following sequence:

1.  **CHECK for `memory-bank/` directory.**

2.  **IF `memory-bank/` directory is missing or empty, THEN:**
    *   CREATE the `memory-bank/` directory if it does not exist.
    *   CREATE all required memory bank files (`project-brief.md`, `product-context.md`, `system-patterns.md`, `tech-context.md`, `active-context.md`, `development-status.md`, `project-journey.md`, `development-log.md`).
    *   POPULATE each file with its basic placeholder structure.
    *   NOTIFY the user that a new Memory Bank has been created and that it requires population.
    *   PROMPT the user for the necessary information, starting with `project-brief.md`.

3.  **IF `memory-bank/` files exist (i.e., from the boilerplate), THEN:**
    *   NOTIFY the user that you are beginning the initialization process.
    *   PROCESS each file sequentially (`project-brief.md` first).
    *   FOR EACH FILE:
        *   READ the entire file.
        *   IDENTIFY all `*Example...*` sections and placeholder blocks (e.g., `[Your text here]`).
        *   PROMPT the user for the correct information to replace the examples and placeholders.
        *   REPLACE the boilerplate example content with the user-provided project-specific details.

4.  **CONCLUDE by stating the Memory Bank is initialized and ready for use.**

### Documentation Updates
Update Memory Bank (especially `active-context.md`, `development-log.md`, `development-status.md`) when:
1.  Discovering new project patterns.
2.  After significant project changes.
3.  Context needs clarification.
4.  User issues `update memory bank` command.

