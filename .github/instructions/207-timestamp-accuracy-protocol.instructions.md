---
description:  
applyTo: "*,**/*"
---

# 207: Timestamp Accuracy Protocol

FOR any timestamping requirement (e.g., logs, filenames, documentation updates), ALWAYS use a system command to fetch the current date/time. DO NOT use placeholders or manual entries.

### Required Commands
-   **For date and time:** `date +%Y-%m-%d_%H%M`
-   **For date only:** `date +%Y-%m-%d`

### Use Cases Include
-   Timestamping log entries.
-   Naming files.
-   Updating "Last Updated" fields in documentation.
