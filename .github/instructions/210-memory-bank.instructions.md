---
description:  
applyTo: "memory-bank/*.md"
---

# 210: Memory Bank Protocol

## Purpose
The Memory Bank is a collection of documents designed to provide a comprehensive and persistent context for the project. It enables AI assistants and human developers to quickly understand the project's goals, technical landscape, and current status, ensuring continuity and informed decision-making across development sessions.

## Memory Bank Structure
ADHERE to the following structure for the `memory-bank/` directory. Each file serves a specific purpose in documenting the project.

-   **`.github/instructions/210-memory-bank.instructions.md`**: This rule file itself, which governs the structure and evolution of the Memory Bank.
-   **`project-brief.md`**: Outlines the project's core purpose. It should clearly define the primary goals, functional and non-functional requirements, and the precise scope of work (including what is out of scope).
-   **`product-context.md`**: Describes the "why" behind the project. It should articulate the problem being solved, the proposed solution, and the desired user experience (UX) goals.
-   **`system-patterns.md`**: Documents the technical architecture. This includes a high-level overview of the architecture, key design decisions and their rationale, and a list of major design patterns being used.
-   **`tech-context.md`**: Details the technology stack. It should list all key technologies, provide instructions for setting up a local development environment, and outline any technical constraints.
-   **`active-context.md`**: A dynamic document capturing the current state of work. It must be updated regularly to reflect the current development focus, recent significant changes, and the immediate next steps.
-   **`development-log.md`**: A reverse-chronological log of significant activities. New entries MUST be added to the top. This includes major decisions, milestones, and resolutions to critical issues.
-   **`development-status.md`**: Provides a high-level snapshot of project progress. It should summarize the overall status, list what is currently working, what remains to be done, and any known issues or blockers.
-   **`project-journey.md`**: Tracks overarching milestones and active quests, serving as a motivational anchor for the project.

## Documentation Update Protocol
To keep the Memory Bank effective, it must be kept up-to-date.

-   **`active-context.md`** should be updated at the beginning and end of development sessions.
-   **`development-log.md`**, **`development-status.md`**, and **`project-journey.md`** should be updated after any significant event or as milestones are completed.
-   Other documents should be updated as the project evolves (e.g., a new technology is introduced, or the scope changes).
-   The user command `update memory bank` should trigger a review and update of all relevant files.
-   This rule file (**`210-memory-bank.instructions.md`**) must also be edited as needed when the structure and the rules evolve from the initial described state.

## Frontmatter Standard
APPLY the following frontmatter structure to all core Memory Bank files for consistency and machine-readability.

```yaml
---
type: [overview|log]
domain: system-state
subject: Vibe-Tools Square
status: active
summary: A concise, one-sentence summary of this file's specific role.
---
```

## Timestamping
When adding timestamped entries (e.g., in `development-log.md`), retrieve the current date and time using a system command as defined in `207-timestamp-accuracy-protocol.instructions.md` to ensure accuracy.
