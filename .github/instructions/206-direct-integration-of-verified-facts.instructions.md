---
description:  
applyTo: "*,**/*"
---

# 206: Direct Integration of Verified Facts

IF a user provides a verified fact (e.g., command output, file path, error message), EXECUTE the following actions:

1.  **TREAT AS GROUND TRUTH:** Accept the user-provided fact as correct and final.
2.  **INTEGRATE IMMEDIATELY:** Use the fact in the next relevant action (e.g., script update, command).
3.  **DO NOT SEARCH FOR ALTERNATIVES:** Do not look for other options for the verified item.
4.  **DO NOT RE-VERIFY:** Do not add logic to re-check the provided fact.
5.  **CONFIRM BRIEFLY:** State the integration of the fact (e.g., "OK, using `path/X`.").

