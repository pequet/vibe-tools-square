---
description:  
applyTo: ".github/instructions/**/*.instructions.md"
---

# 001: Effective Rule Writing Directives

To ensure AI instructions are clear, consistent, and actionable, all `.github/instructions/` files should be written following the directives below. Adhering to these standards helps the AI interpret and execute tasks reliably and efficiently.

**When writing or modifying `.github/instructions/` files, please adhere to the following principles:**

1.  **Write Rules as Direct Commands:** Address the AI directly. Instruct the AI what it MUST or SHOULD do. Use imperative verbs (e.g., "ENSURE", "USE", "VERIFY", "APPLY").
    *   **Bad:** "This rule is about script headers."
    *   **Good:** "ENSURE all script headers conform to Template X."

2.  **Be Concise, Not Vague:** Every sentence must be a clear instruction. Eliminate fluff, but do NOT remove essential keywords, examples, or context that trigger AI action. A rule that is too succinct becomes ineffective.
    *   **Bad:** "Manage user preferences."
    *   **Good:** "IDENTIFY and NOTE user preferences for communication style (direct, detailed) and terminology."

3.  **Target AI as a Literal System:** Assume the AI will interpret instructions literally. Avoid ambiguity or nuanced language that requires interpretation beyond the direct command.

4.  **Project-Specific by Default:** Rules apply to **THIS** project using **THIS** project's defined assets and defaults (e.g., specific names, links, paths provided in the rule or by the user for this project).
    *   Do NOT include conditional language for adapting the rule or its assets for "other projects" unless the rule is explicitly a generic template for creating *new* rules.
    *   **Bad:** "Use the `Vibe-Tools Square` logo, but if you are on a different project, find that project's logo."
    *   **Good (assuming `Vibe-Tools Square` is THIS project):** "USE the `Vibe-Tools Square` logo as defined in Template X."

5.  **Use Specific Keywords & Examples:** Include explicit keywords (e.g., `vibe-tools`, `README.md`), commands (`date +%Y-%m-%d`), and examples. The AI uses these to recognize context and trigger the correct actions. Vague instructions fail.

6.  **Templates are Literal and Specific:** If a rule provides templates (e.g., for code, headers, documentation):
    *   Instruct the AI to use them EXACTLY as provided for THIS project.
    *   Clearly indicate placeholders (e.g., `[PLACEHOLDER_NAME]`) that the AI MUST populate with script-specific or context-specific information for THIS project.
    *   Defaults within templates (e.g., author name `Benjamin Pequet`, project name `Vibe-Tools Square`) are for THIS project and MUST be used unless the AI is explicitly instructed to change them for a specific instance within THIS project.

7.  **No Self-Referential "Purpose" in Rule Body:** The rule's purpose is defined by its direct commands and its frontmatter `description`. Do NOT add sections like "## Purpose of this Rule" within the rule's Markdown body.

8.  **Structure for Actionability Only:** Use headings (H2, H3) and lists ONLY if they make the direct commands clearer and more actionable. Avoid conversational section titles (e.g., "Let's Talk About Templates"). Prefer direct titles (e.g., "Script Templates").

By following these guidelines, we can create a more effective and predictable rule system.
