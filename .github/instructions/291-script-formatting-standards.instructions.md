---
description: 
applyTo: "**/*.sh,*.sh"
---

# 291: Script Formatting Standards

**Ensure consistent formatting and organization for all shell scripts.**

## Script Structure

ALL shell scripts MUST follow this organizational structure:

```bash
#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Attribution header (per 290-script-attribution-standards.instructions.md)

# --- Global Variables ---
# All script-level variables defined here

# --- Function Definitions ---

# *
# * Function Group Name
# *
function_name() {
    # Function implementation
}

# *
# * Another Function Group
# *
another_function() {
    # Function implementation
}

# --- Script Entrypoint ---
main "$@"
```

## Formatting Rules

### Section Headers
- **Major sections:** Use `# --- Section Name ---`
- **Function groups:** Use the three-line format:
  ```bash
  # *
  # * Group Name
  # *
  ```

### Code Organization
1. **Variables first:** All global variables at the top after attribution
2. **Functions second:** Grouped logically with clear headers
3. **Execution last:** Single entrypoint at the bottom

### Spacing and Indentation
- **Consistent indentation:** Use 4 spaces for function bodies
- **Blank lines:** One blank line between functions, two between major sections
- **Comments:** Inline comments should be concise and helpful

### Function Naming
- Use `snake_case` for function names
- Group related functions under descriptive headers
- Order functions logically (utilities first, main logic last)

## Error Handling
- All scripts MUST use `set -euo pipefail`
- Functions should validate inputs and fail gracefully
- Error messages should be clear and actionable

## Terminal Output Standards
- **Minimal and professional**: No emojis, or verbose messaging.
- **Reusable output functions**: Use consistent wrapper functions like `print_step()` and `print_error()`. These functions should:
    - Print a simple message to `stdout` or `stderr` for immediate user feedback.
    - Call a separate `log_message()` function to write a more detailed, timestamped entry to a persistent log file.
- **Progress only**: Show the current step, not "about to do" and "completed" pairs. For example, just "Checking dependencies" is sufficient.
- **Clean errors**: Format errors clearly (e.g., `ERROR: message`) and direct them to `stderr`.
- **Script attribution**: Use the standard header template from `290-script-attribution-standards.instructions.md`, not `echo` statements, for branding.

## Scripting Best Practices
- **Strict Initialization Order**: The `main` function must load dependencies and validate the environment in the correct order before executing core logic:
    1.  Initialize logging with a default path.
    2.  Load configuration (which may override the log path).
    3.  Check for required command-line tool dependencies (`rsync`, `flock`, etc.).
    4.  Validate that necessary file paths and directories exist.
    5.  Acquire a concurrency lock.
    6.  Run the core script logic.
- **Concurrency Locking**: For scripts that might be run automatically (e.g., by `cron` or `launchd`), use `flock` to create a lock file and prevent multiple instances from running simultaneously.
- **Single Entrypoint**: All script logic should be contained within functions and orchestrated from a single `main()` function at the end of the script, called with `main "$@"`.

