---
description: 
applyTo: "*,**/*"
---


# 295: Asset Archiving Standard (Manual Workflow)

## 1. Context: Manual Archiving

This rule governs the **manual, developer-driven process** of archiving project assets (files or directories) that are deprecated or no longer in active use. It is a deliberate action taken by a human to clean up the project structure while preserving history.

**This protocol is distinct from Rule #296, which defines a safety mechanism for automated operations.**

## 2. The Core Rule: Archive, Don't Delete

You are **NEVER** permitted to delete project assets.

When a developer decides a file or directory is no longer needed, it **MUST** be moved to the root `/archives` directory.

### Example
```bash
# To archive a deprecated feature's documentation
mv docs/old-feature.md archives/docs/old-feature.md
```

## 3. Rationale

This practice ensures that all project history and context are preserved, maintaining link integrity and allowing for the retrieval of previous content. It prevents the permanent loss of information.

- Preserves complete history and context.
- Maintains link integrity.
- Allows for retrieval of previous content when needed.
- Ensures information is never permanently lost.
