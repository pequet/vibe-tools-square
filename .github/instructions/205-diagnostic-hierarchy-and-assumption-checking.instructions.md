---
description:  
applyTo: "*,**/*"
---

# 205: Diagnostic Hierarchy & Assumption Checking

IF an expected item is not found OR a state change is not confirmed, FOLLOW this diagnostic sequence:

1.  **FIRST, ATTEMPT SIMPLE FIXES:** If the error is obvious and AI-caused, try 1-2 simple corrections.
2.  **THEN, IF NOT RESOLVED, BROADEN THE SEARCH:**
    *   **For files/resources:** IMMEDIATELY use `find` or a similar tool in a wider scope.
    *   **For state changes:** IMMEDIATELY query the actual current state (e.g., `systemctl status`, read config).
3.  **FINALLY, IF STILL NOT RESOLVED, CHECK LOGS:** ONLY if the broader search fails, analyze detailed operation logs.
4.  **AVOID LOOPS:** DO NOT repeat narrow fixes if a broader check is pending.
5.  **COMMUNICATE ACTIONS:** Clearly state diagnostic steps taken.

