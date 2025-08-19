---
description: AI rules derived by SpecStory from the project AI interaction history
globs: *
---

## HEADERS

## TECH STACK

## PROJECT DOCUMENTATION & CONTEXT SYSTEM

## CODING STANDARDS

*   All files in `#file:src` must follow Tier 3 attribution:
    ```
    # Author: Benjamin Pequet
    # Purpose: [Brief one-line description of the script's function.]
    # Project: https://github.com/pequet/vibe-tools-square/ 
    # Refer to main project for detailed docs.
    ```
*   `#file:install.sh` already follows the attribution standard rules.
*   `#file:run-prompt.sh`, as the main entry point, must have proper attribution using Tier 1 format with ASCII art banner, detailed purpose, usage, options, dependencies, changelog, and support info.

## DEBUGGING

*   **CRITICAL:** During testing, only use `gemini` and `gemini-2.0-flash` models to avoid incurring excessive costs. 

## WORKFLOW & RELEASE RULES

*   **CRITICAL:** When refactoring code, especially core utilities or shared scripts, make changes incrementally, one change at a time, with thorough testing after each change to avoid breaking existing functionality. This is particularly important for functions like `execute_ask_task`, `execute_repo_task`, and `execute_plan_task` in `core.sh`.
*   **CRITICAL:** During refactoring, pay close attention to parameter handling between `run-prompt.sh`, task configuration files, and templates. Ensure command-line arguments are correctly processed to replace placeholders in configuration files, and that the final parameters are passed correctly to the `vibe-tools` command.

## REFERENCES

### Extensive Chat Mode Rules

### Copilot Instructions File
* The `copilot-instructions.md` file is a temporary buffer for ideas and notes. It should not contradict existing rules. If content in this file is redundant with existing rules, it should be removed. If something is not right in that document, it should be removed. Good ideas can be used to create new rules.

### System Pillars
*   **GitHub Instructions (.github/instructions/*.instructions.md)**
    *   **Role**: The foundational rules and protocols - our "North Star," "Ten Commandments," and "Gospel"
    *   **Concerns**: Define precise behaviors, protocols, and standards
    *   **Responsibilities**: Establish canonical rules for all operations
    *   **Key Characteristic**: Single source of truth for all behavioral rules
*   **Chat Modes (.github/chatmodes/*.chatmode.md)**
    *   **Role**: Mode-specific behavior profiles that reference the instructions
    *   **Concerns**: Define the operational approach for specific work contexts
    *   **Responsibilities**:
        *   Reference (not duplicate) instructions
        *   Outline workflows for specific work modes
        *   Define task prioritization and execution style
    *   **Extensive Mode Specifically**:
        *   **When to Use**: For complex, multi-step tasks requiring autonomous completion
        *   **Key Features**:
            *   Task classification and prioritization
            *   Aggressive autonomous execution
            *   Thorough documentation in memory bank
            *   Complete problem solving without interruption
            *   Systematic workflow following protocols
*   **Memory Bank System (memory-bank/*.md)**
    *   **Role**: Persistent project context storage
    *   **Concerns**: Project state, history, requirements, and technical details
    *   **Responsibilities**:
        *   Store project context across sessions
        *   Track development progress and history
        *   Define project requirements and technical specifications
    *   **Key Files**:
        *   **State Files**: development-status.md, development-log.md
        *   **Context Files**: product-context.md, tech-context.md, project-brief.md
        *   **Planning File**: project-journey.md

### Collaborative Chat Mode
*   A new `Collaborative.chatmode.md` has been created specifically for planning sessions. This chatmode:
    *   Facilitates exploration of ideas while guiding toward structured plans
    *   Is ideal for initial planning and periodic plan revisions
    *   Accommodates flow-of-consciousness expression while creating clarity
    *   Supports the natural refinement of objectives through dialogue
    *   Balances conversational exploration with structured outcomes
    *   Uses reflective questioning and active listening
    *   Progressively refines ideas into actionable plans
    *   Periodically summarizes to validate understanding
    *   The workflow structure is:
        1.  **Discovery & Exploration**: Listen to initial ideas, reflect concepts, identify objectives
        2.  **Refinement & Structure**: Guide toward specific deliverables, prioritize features, offer structure
        3.  **Plan Documentation**: Formalize the plan with clear steps, milestones, and criteria
        4.  **Future-Proofing**: Discuss pivot points, metrics, and triggers for plan revision
    *   Creates dated planning documents in the appropriate inbox directory
    *   Updates all relevant memory bank files (development-status.md, development-log.md, etc.)
    *   Maintains plan version history
    *   Emphasizes plan quality standards:
        *   Clear: Specific actions with defined outcomes
        *   Complete: All necessary steps included
        *   Consistent: No internal contradictions
        *   Feasible: Realistic given resources and constraints
        *   Flexible: Adaptable to reasonable changes
        *   Measurable: Progress can be tracked
*   Core principles: clarity, efficiency, actionability, and accountability for both human and AI agent together.

### Vibe-Tools Task Execution Rules

### Run Prompt Script

### Testing Commands

*Example Usage*
```bash
# Test repo (analyzes your codebase)
./run-prompt.sh repo "Explain this project" --include=README.md --include='src/**'

# Test plan (creates implementation plans)  
./run-prompt.sh plan "Add user login" --include=README.md
```

### Include/Exclude Patterns (What Files to Use)

*   When specifying include/exclude paths, use simple file and folder paths:
    *   `--include=path/to/file` to include a specific file.
    *   `--include=path/to/folder` to include an entire folder and its contents.
    *   `--exclude=path/to/file` to exclude a specific file.
    *   `--exclude=path/to/folder` to exclude an entire folder and its contents.

### Dynamic Task Configuration Discovery

*   The system uses a runtime-first fallback for task configuration discovery:
    *   It checks for task configuration files in the runtime environment first (`~/.vibe-tools-square/tasks/`).
    *   If not found, it checks in the repository environment relative to the `run_prompt.sh` file (e.g., in an `assets` folder).
    *   Runtime configurations take precedence over repository assets.

### Template Placeholders

*   `{{PLACEHOLDER_NAME}}` - Gets replaced with values from `--placeholder-name=value` flags.
*   `{{PLACEHOLDER_NAME=value}}` - Gets replaced with `value` if no `--placeholder-name` flag is provided.
*   `{{PLACEHOLDER_NAME=file:path}}` - Injects content from specified file.
*   When specifying parameters using flags in `run-prompt.sh`, tokens specified in lowercase are accepted with both dashes and underscores. The dashes will be replaced with underscores when the parameter name is expanded to uppercase to match the token.

### Task Types

*   `TASK_TYPE` - Execution type (ask, repo, plan).
*   Available tasks types: ask, repo, plan.
*   The other vibe-tools commands (`web`, `doc`, `browser`, `youtube`) are not currently implemented, but could fairly easily be added.
*   Multiple step workflows are out of scope.

### Custom Tasks

### Bug Fixes and Codebase Integrity

*   **CRITICAL:** Under no circumstances should core utilities or shared scripts like `logging_utils.sh` be modified directly to resolve issues in specific tasks. Such utilities are used by numerous scripts, and direct modifications can introduce widespread problems.
*   **Directory Creation:** Do not create directories manually outside of the designated setup scripts or utilities. The `ensure_output_directory` function must be used to create output directories before writing to log files.
*   The system must only create directories when they are needed for writing, not for reading. This applies to both the configuration directory and the logs directory.
*   The system must check if a directory exists before attempting to write to it, and create the directory if it does not exist.
*   The `ensure_log_directory` function from `#file:logging_utils.sh` must be used to ensure the log directory exists before writing to it. **NOTE:** The `ensure_output_directory` is preferred, but `ensure_log_directory` can be used if necessary.

### Correcting Operational Sequence

### Corrected Directory Creation Logic
*   The system must only create directories when they are needed for writing, not for reading. This applies to both the configuration directory and the logs directory.
*   The system must check if a directory exists before attempting to write to it, and create the directory if it does not exist.
*   The `ensure_log_directory` function from `#file:logging_utils.sh` must be used to ensure the log directory exists before writing to it.

### Displaying Configuration and Log File Usage
*   The script must display which `default.conf` file is being used (runtime or repository).
*   The script must also display which log file is being written to (runtime or repository).

### Code Refactoring Rules

*   `execute_ask_task` in `core.sh` must be refactored to use `run_vibe_command_from_runtime`.
*   All three functions (`execute_ask_task`, `execute_repo_task`, `execute_plan_task`) must use the same template path resolution logic. Create a shared function in `core.sh` for this purpose.
*   All three functions should implement detailed parameter display. Write a function and use it for all three functions.
*   Use shared functions for command display formatting in all three functions.
*   Use shared functions for execution result handling in all three functions.
*   Messaging utilities should be used for logging in all three functions, converting existing logging as needed.
*   Be extraordinarily careful not to break any existing functionality during refactoring.