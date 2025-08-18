---
description:  
applyTo: "*.md,**/*.md"
---

# 245: General Frontmatter Guidelines

MAINTAIN a consistent approach to YAML frontmatter in Markdown files.

## Scope of Application
- APPLY frontmatter to all Markdown files except `README.md` 
- MANDATE the application of frontmatter to all DESIGNATED "state files" (e.g., within `memory-bank/`) and all `inbox/` files.

## Core Frontmatter Structure
FOR ALL Markdown files that include frontmatter, USE the following structure and fields based on established project practices. ADHERE strictly to the specified field names and their intended use.

```yaml
---
type: [overview|log|capture|guide]
domain: [system-state|inbox|concepts|methods]
subject: [Vibe-Tools Square|General]
status: [active|new|draft]
summary: A concise one-sentence summary of the file's content and purpose.
tags: [notes-active|notes-archived] 
---
```

## Field Directives
*   **`type`**: (String) ASSIGN one of the following values describing the nature of the content:
    *   `overview`: USE for standard content notes, descriptive documents. (This is the default for most files).
    *   `log`: USE for chronological records of events or changes.
    *   `capture`: USE for raw, unprocessed information (typically in `inbox/`).
    *   `guide`: USE for instructional content.
*   **`domain`**: (String) ASSIGN one of the following values describing the broad category or area the content belongs to:
    *   `system-state`: USE for files describing the project's operational state (e.g., memory bank files).
    *   `inbox`: USE for files in the `inbox/` directory.
    *   `rules`: USE for `.github/instructions/` files.
    *   values such as `concepts`, `methods`, `patterns` may be used if the project adopts a broader knowledge management framework consistent with user practices
*   **`subject`**: (String) ASSIGN the primary thematic focus. This MUST be the specific project name (e.g., "Vibe-Tools Square") or "General" if not project-specific.
*   **`status`**: (String) ASSIGN the current state of the document. Examples include:
    *   `active`: For actively maintained and current documents.
    *   `new`: For new inbox items.
    *   `draft`: For documents under initial creation or development.
    *   `finalized`: For documents considered complete.
*   **`summary`**: (String) PROVIDE a brief, one-sentence description of the file's purpose and content. This field REPLACES any separate `purpose` field.
*   **`tags`**: (Array of Strings, Optional) USE sparingly for specific, functional tags only. Example: `notes-active`. DO NOT USE for general topical categorization.

## Fundamental Principles for Frontmatter Usage
*   **Filenames as Titles**: DO NOT use a `title` field in frontmatter. The filename MUST serve as the title.
*   **Conciseness**: ENSURE frontmatter is minimal yet fully informative.
*   **Consistency**: APPLY defined fields and their specified values consistently across all relevant files.
*   **Clarity**: ENSURE frontmatter makes the file's role and content immediately understandable.
