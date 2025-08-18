---
description:  
applyTo: "*.sh,**/*.sh"
---

# 290: Script Attribution & Branding

**Ensure consistent and professional attribution, documentation, and branding for all scripts.**

When creating or modifying scripts in this project:

1.  **Analyze Script Context:** Determine purpose, execution method (interactive, automated), and project importance.
2.  **Select Appropriate Tier:**
    *   **Tier 1 (Interactive/Banner):** For interactively run scripts desiring prominent terminal branding.
        *   *Avoid:* Cron jobs, headless automation, frequently executed background processes, or scripts called by other scripts where terminal output is disruptive.
    *   **Tier 2 (Standard Attributed):** For core project utilities or public-facing tools needing comprehensive source code header documentation.
    *   **Tier 3 (Minimal Utility):** For small helpers, simple wrappers, or internal utilities where a concise reference to the main project is sufficient.
3.  **Apply Chosen Template:** Use the appropriate template from the "AI Resource: Script Templates" section below. Populate all bracketed placeholders (e.g., `[YYYY-MM-DD]`, `[Detailed description...]`) with script-specific information for this project.

## Script Templates

**Use the appropriate template below. Defaults for project (`Vibe-Tools Square`), author (`Benjamin Pequet`), GitHub repository (`pequet/vibe-tools-square`), and support links are for this project.**

### Tier 1 Template: Interactive/Banner Script
```bash
#!/bin/bash

# Standard Error Handling
set -e  # Exit immediately if a command exits with a non-zero status.
set -u  # Treat unset variables as an error when substituting.
set -o pipefail  # Causes a pipeline to return the exit status of the last command in the pipe that failed.

# ASCII Art Banner (Project-Specific - Printed to Terminal)
echo "
█ █ █  Vibe-Tools Square
 █ █   Version:  1.0.0
 █ █   Author:   Benjamin Pequet
█ █ █  Github:   https://github.com/pequet/vibe-tools-square/
"

# Purpose:
#   [Detailed description of the script's purpose, what problems it solves,
#    and its main functionalities.]
#
# Usage:
#   ./your_script_name.sh [options] [arguments]
#   [Provide clear examples if applicable]
#
# Options:
#   --option1        [Description of option1 and its effect.]
#   -h, --help       Show this help message and exit.
#
# Dependencies:
#   [List any external tools, libraries, or environment variables required.]
#
# Changelog:
# 1.0.0 - [YYYY-MM-DD] - Initial release or summary of changes.
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

# ... rest of your script code ...
```

### Tier 2 Template: Standard Attributed Script
```bash
#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# █ █ █  Vibe-Tools Square: Audio Processing & Transcription System
#  █ █   Version: 1.0.0
#  █ █   Author: Benjamin Pequet
# █ █ █  GitHub: https://github.com/pequet/vibe-tools-square/
#
# Purpose:
#   [Detailed description of the script's purpose, what problems it solves,
#    and its main functionalities.]
#
# Usage:
#   ./your_script_name.sh [options] [arguments]
#   [Provide clear examples if applicable]
#
# Options:
#   --option1        [Description of option1 and its effect.]
#   -h, --help       Show this help message and exit.
#
# Dependencies:
#   [List any external tools, libraries, or environment variables required.]
#
# Changelog:
#   1.0.0 - [YYYY-MM-DD] - Initial release or summary of changes.
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

... rest of your script code ...

```

### Tier 3 Template: Minimal Utility Script
```bash
#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Author: Benjamin Pequet
# Purpose: [Brief one-line description of the script's function.]
# Project: https://github.com/pequet/vibe-tools-square/ 
# Refer to main project for detailed docs.

... rest of your script code ...
```

## General Requirements Checklist
For ALL scripts created or modified in this project, ensure:

*   **Shebang:** Script starts with `#!/bin/bash`.
*   **Error Handling:** Standard error handling block (`set -e`, `set -u`, `set -o pipefail`) is present immediately after shebang.
*   **Placeholders Filled:** All bracketed placeholders in the chosen template are filled with script-specific information for this project.
*   **ASCII Art (Tiers 1 & 2):** Use the Vibe-Tools Square ASCII art example provided in the templates.

## README.md Verification & Recommendation
When appropriate for this project (e.g., project setup, adding new scripts, `README.md` modification):

1.  **Verify `README.md`:** Check for presence of "Author" and "Support the Project" sections consistent with script template details for this project.
2.  **Recommend Changes:** If sections are missing/incomplete, recommend their addition/update to user, providing this structure for this project:

```markdown
## Support the Project

If you find this project useful and would like to show your appreciation, you can:

- [Buy Me a Coffee](mdc:https:/buymeacoffee.com/pequet)
- [Sponsor on GitHub](mdc:https:/github.com/sponsors/pequet)

Your support helps in maintaining and improving this project. Thank you!
```
