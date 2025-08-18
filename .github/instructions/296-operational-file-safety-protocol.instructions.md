---
description: 
applyTo: "*,**/*"
---


# 296: Operational File Safety Protocol (Automated Workflow)

## 1. Context: Automated Operations

This rule is a **NON-NEGOTIABLE SAFETY PROTOCOL** for all **automated operations** and scripts. Its single purpose is to prevent accidental data loss when a script needs to write to a path that is already occupied.

**This protocol is distinct from Rule #295, which defines the manual process for archiving project assets.** This is a safety mechanism, not an archiving workflow.

## 2. The Core Rule: NEVER Delete. EVER.

You are **ABSOLUTELY PROHIBITED** from using `rm`, `rm -r`, or `rm -rf` in any script or automated command. There are no exceptions. Data preservation is the highest priority.

## 3. The Required Action: Rename for Safety

If a script or automated process must clear a path (e.g., before creating a symlink or writing a new file), it **MUST** rename the existing file or directory to a timestamped backup.

Use this **EXACT** pattern:
```bash
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
mv "/path/to/item" "/path/to/item.bak-${TIMESTAMP}"
```
*Note: Paths are quoted to handle spaces and special characters safely.*

This action clears the way for the script to proceed without destroying any pre-existing data.
