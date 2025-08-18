---
description:  
applyTo: "*.md,**/*.md"
---

# 255: Codeblock Formatting for Copy-Pastable Content

### Purpose
To ensure that code blocks containing content intended for direct copy-pasting by the user (e.g., shell commands, configuration file snippets, environment variable examples) are formatted **without leading indentation** and **with proper spacing in Markdown files** for readability and usability.

### Rationale
Leading indentation (e.g., spaces added because the Markdown code block is part of a list item) is often included when copying text from a rendered Markdown view or even from the raw Markdown. This makes it cumbersome to paste directly into a terminal or configuration file. Lack of surrounding blank lines can also make the documentation harder to read.

### AI Behavior
When generating or editing Markdown files (e.g., `README.md`, files in `docs/`):

1.  **Identify Target Code Blocks:** This rule applies specifically to fenced code blocks where the content is likely to be copied and pasted by the user. This includes, but is not limited to:
    *   Shell commands (`bash`, `sh`, `zsh`, etc.)
    *   Configuration file examples (`.env`, `json`, `yaml`, `xml`, etc.)
    *   Code snippets intended for direct use.
2.  **Ensure No Leading Indentation:** All lines within such a code block, including the opening and closing fences (e.g., ` ```bash ` or ` ```env ` and ` ``` `), must start at the beginning of the line (column 0).
3.  **Ensure Surrounding Blank Lines:** A blank line MUST precede the opening code block fence (e.g., ` ```bash `) and a blank line MUST follow the closing code block fence (e.g., ` ``` `), especially when the code block is part of a list item or embedded within other text.
4.  **Contextual Awareness:** If a code block is part of a list item or an indented section of Markdown, special care must be taken to ensure the code block itself is *not* indented (as per point 2) and is properly separated by blank lines (as per point 3), even if the surrounding Markdown text is indented.

### Example (Incorrect)
This is wrong because the ` ```env ` block is indented with the list item.
*   Example `.env` content:
    ```env
    VAR_ONE="some value"
    VAR_TWO="another value"
    ```

### Example (Correct)
This is correct because the ` ```env ` block starts at column 0, with blank lines.
*   Example `.env` content:

```env
VAR_ONE="some value"
VAR_TWO="another value"
```

This rule helps maintain the usability and readability of documentation by making command execution and configuration straightforward for the user.
