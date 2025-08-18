---
description:  
applyTo: "*,**/*"
---

# 270: Avoid Redundancy

### Core Principle
**Information, code, and rules should exist in exactly one place.** Duplication creates maintenance burdens, inconsistencies, and confusion.

### AI Behavior
When working with this codebase:

1.  **Identify Redundancy:** Proactively identify when information, code, or rules exist in multiple places. Pay special attention to duplication between:
    *   Separate rule files (`.instructions.md` files).
    *   Auto-generated rules and prefixed, manually crafted rules.
    *   Memory Bank documentation and rule definitions.
    *   Multiple code files implementing the same functionality.

2.  **Recommend Consolidation:** When redundancy is detected, recommend consolidating to a single source by determining the most appropriate location, removing duplicates, and creating references where needed.

3.  **Manage Auto-Generated Content:** For auto-generated files like the derived-cursor-rules and the vibe-tools rules, recognize when they duplicate manual rules and suggest clearing the redundant auto-generated content.

4.  **When Creating New Content:** Ensure any new content, code, or rules do not duplicate existing information and are placed in the most logical location.

### Documentation Practice
When documenting the system, USE cross-references and links instead of duplicating information. Clearly indicate the canonical source for all information.
