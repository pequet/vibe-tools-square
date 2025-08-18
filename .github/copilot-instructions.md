---
description: AI rules derived by SpecStory from the project AI interaction history
globs: *
---

## HEADERS

## TECH STACK

## PROJECT DOCUMENTATION & CONTEXT SYSTEM

## CODING STANDARDS

### Script Standards

*   All scripts must include a standard error handling section: `set -e`, `set -u`, `set -o pipefail`.
*   All scripts must include a header block with the following information:
    *   Tool Name
    *   Version
    *   Author
    *   GitHub Repository URL
    *   Purpose
    *   Usage
    *   Options
    *   Dependencies
    *   Changelog
*   Scripts must require a mandatory project root path as an argument and exit gracefully if the specified path does not contain the expected directory structure (e.g., a `.cursor/rules` directory). If the specified path does not contain the expected directory structure, the script must halt with a helpful message. All file paths within the script must be adjusted to work from the provided root directory.

## DEBUGGING

*   When modifying files, especially during automated processes, always back up existing files before overwriting them. Use a timestamped `.bak` extension (e.g., `.bak-YYYY-MM-DD_HHMMSS`).
*   **CRITICAL:** During testing, only use `gemini` and `gemini-2.0-flash` models to avoid incurring excessive costs.

## WORKFLOW & RELEASE RULES

### Git Submodules

*   When a new tool or script emerges that is expected to be used across multiple projects, it should be placed in a dedicated git submodule.
*   The exact steps for setting up the submodule should be documented.
*   Example submodule setup:
    1.  Create a dedicated repository for the tool (e.g., `pequet/cursor-to-copilot`).
    2.  Add the script and a README to the tool's repository.
    3.  Add the tool as a submodule to the main project using:
        ```bash
        git submodule add <repository_url> <path_in_project>
        git commit -m "Add <tool_name> submodule"
        ```
        For example:
        ```bash
        git submodule add https://github.com/pequet/cursor-to-copilot.git scripts/IDE/Cursor-to-Copilot/cursor-to-copilot
        git commit -m "Add cursor-to-copilot submodule"
        ```
    4.  To use the tool from the main project:
        ```bash
        <path_in_project>/<tool_name>/<script_name> <arguments>
        ```
        For example:
        ```bash
        scripts/IDE/Cursor-to-Copilot/cursor-to-copilot/convert-cursor-rules.sh .
        ```
    5.  Submodule maintenance:
        ```bash
        git submodule update --init --recursive
        git submodule foreach git pull origin main
        ```
*   Consider simplifying submodule paths for new tools. For example, instead of `Core/Controllers/Methods/Operations/Scripts/IDE/Convert Rules to Instructions/cursor-rules-to-instructions/`, use `scripts/IDE/<tool_name>/`.

## REFERENCES

### Extensive Chat Mode Rules
* The extensive chat mode should not duplicate or contradict the rules defined in the GitHub instructions folder. This applies to all topics addressed in the GitHub instructions, not just memory-bank related rules. All concepts treated in the GitHub instructions should not be duplicated, contradicted, or have conflicting rules in the extensive chat mode.
* When updating the extensive chat mode or `copilot-instructions.md`, ensure adherence to the following principles:
    1.  **No Duplication**: Replace detailed instructions with references to canonical rules in the GitHub instructions folder.
    2.  **No Contradiction**: Ensure all instruction sources are aligned.
    3.  **Explicit References**: Add clear references to relevant GitHub instruction files.
    4.  **Preserve Uniqueness**: Maintain the unique aspects of each instruction file.
    5.  **Comprehensive Coverage**: Address all topics from GitHub instructions.
* When updating `Extensive.chatmode.md`:
    *   Use the extended implementation plan.
    *   Make each section explicitly reference relevant instruction files in `#file:2025-08-17_2145-extended-extensive-chatmode-plan.md`
    *   Make each section explicitly reference relevant instruction files in `#file:instructions` rather than duplicating content.
    *   Maintain the unique purpose of the chatmode (action-oriented, autonomous task completion).
    *   Ensure no contradictions with GitHub instructions.
    *   Follow the section-by-section approach in the extended plan as defined in #file:2025-08-17_2145-extended-extensive-chatmode-plan.md
    *   Use relative links in the format `[Rule Name (Number)](../instructions/xxx-rule-name.instructions.md)`.
    *   Ensure that `Extensive.chatmode.md` explicitly references relevant GitHub instruction files rather than duplicating content. This maintains the unique purpose of the chatmode (action-oriented, autonomous task completion) while ensuring no contradictions with the GitHub instructions. The updated file now serves as a directive for extensive, autonomous task completion that works in concert with, rather than in parallel to, the established instruction rules.
    *   All changes must be made with careful attention to preserve the action-oriented nature of the chatmode while providing clear references to canonical rules for each aspect of behavior.
    *   **IMPORTANT**: When updating `Extensive.chatmode.md`, remove any references to specific frameworks or technologies (e.g., Next.js) that are not universally applicable. Also, remove any references to third-party systems or concepts that are not relevant to the current project or memory bank structure. Ensure the document is streamlined and free of redundancy.
    *   **CRITICAL**: The `Extensive.chatmode.md` file must not contain outdated or incorrect information about the memory system or file structure. Ensure that all references to memory storage locations and content structure align with the current project's memory bank rules. Remove any sections that duplicate or contradict the project's memory bank structure.
*   When referencing product context, tech context and project brief in the chat mode, explicitly reference the specific files in the memory bank: `product-context.md`, `tech-context.md`, and `project-brief.md`.
*   State files should explicitly reference the `development-log.md` and `development-status.md` files, as well as the `project-journey.md` file.
*   **Continuity Protocol**: If the user says "resume" or "continue", check the memory bank, particularly the state files (`development-log.md`, `development-status.md`) for the last incomplete step and inform the user which step you're continuing from. Note that state files may not always be up-to-date.

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
*   The `Planning.chatmode.md` file has been superseded by the `Collaborative.chatmode.md` file and is now obsolete.
*   Core principles: clarity, efficiency, actionability, and accountability for both human and AI agent together.

### Vibe Tools Task Execution Rules

*   Vibe Tools commands must be executed from the runtime environment to ensure the correct configuration and preferences are applied.
*   The following commands must be implemented:
    *   `vibe-tools ask "question....."`
    *   `vibe-tools repo "question....."`
    *   `vibe-tools plan "question....."`
*   For the `repo` and `plan` commands, the following options must be implemented to provide context:
    *   `--include="path/to/file"`
    *   `--include="path/to/folder"`
    *   `--exclude="path/to/file"`
    *   `--exclude="path/to/folder"`
*   Files and folders specified with `--include` must be copied into the ICE folder for use as context.
*   The `.repomixignore` file should be used to filter context for the `repo` and `plan` commands.
*   **IMPORTANT:** When executing `vibe-tools repo` and `vibe-tools plan`, ensure that the command line syntax is correct, specifically that strings are enclosed in quotes.
*   **MANDATORY:** Ensure that files are correctly synced to the `content/public` directory within the ICE folder when using `--include` and `--exclude` options.
*   When a `plan` or `repo` command is executed without including any files, the command must not run. A helpful message should be displayed instead.

### Run Prompt Script

*   The `run_prompt.sh` script must support specifying a provider and model for each command:
    *   `run_prompt.sh ask a question with a specific provider/model`
    *   `run_prompt.sh repo a question with a specific provider/model`
    *   `run_prompt.sh plan a question with a specific provider/model for file and a specific provider/model for thinking`
*   A flag must be implemented to specify a prompt string directly, similar to loading a template:
    *   `--prompt="your prompt here"`
    *   The `--template` flag should be an alias for `--prompt=file:path/to/template`.
*   Task configuration files must be located dynamically:
    1.  Check for configuration files in the runtime environment first.
    2.  If not found, check in the repository environment relative to the `run_prompt.sh` file (e.g., in an `assets` folder).
    3.  The local runtime environment takes precedence.
*   The system uses a runtime-first fallback for task configuration discovery:
    *   It checks for task configuration files in the runtime environment first (`~/.vibe-tools-square/tasks/`).
    *   If not found, it checks in the repository environment relative to the `run_prompt.sh` file (e.g., in an `assets` folder).
    *   Runtime configurations take precedence over repository assets.
*   The install script should create the folder structure for tasks and config in the runtime environment but not move the task templates or configs from assets. It should create READMEs in both the templates and tasks folders explaining the discovery process.

### Testing Commands

*Example Usage*
```bash
# Test repo (analyzes your codebase)
./run-prompt.sh repo "Explain this project" --include=README.md --include='src/**'

# Test plan (creates implementation plans)  
./run-prompt.sh plan "Add user login" --include=README.md

# See what files are currently curated
./run-prompt.sh repo --show-context
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
*   The install script should create the folder structure for tasks and config in the runtime environment but not move the task templates or configs from assets. It should create READMEs in both the templates and tasks folders explaining the discovery process.

### Template Placeholders

*   `{{PLACEHOLDER_NAME}}` - Gets replaced with values from `--PLACEHOLDER_NAME=value` flags.
*   `{{PLACEHOLDER_NAME=file:path}}` - Injects content from specified file.

### Task Types

*   `TASK_TYPE` - Execution type (ask, repo, plan).
    *   `TASK_TYPE="ask"`  # or "repo", "plan"
*   Available tasks types: ask, repo, plan.
*   The other Vibe tools commands (`web`, `doc`, `browser`, `youtube`) are not currently implemented, but could fairly easily be added down the line.
*   Multiple step workflows are out of scope.
*   The other Modes for Vibe tools, Doc, Web, YouTube, etc. are also out of scope, but could fairly easily be added down the line.

### Custom Tasks

If we wanted custom tasks, they would work like this:

**Example: `my-web-search.conf`**
```bash
TASK_NAME="my-web-search"
TASK_DESCRIPTION="Search the web for current information"
TASK_TYPE="ask"  # Uses existing ask handler
```

Then you'd use: `./run-prompt.sh my-web-search --prompt="What's the latest on AI developments?"`

It would just call `execute_ask_task()` but with your custom task name and description. The "custom" part is just having a different name/description, not different code.

Real Custom Tasks Would Need:

### 1. **Preset Templates/Prompts**
A custom task should come with a pre-configured template and specific parameters:

```bash
# code-review-security.conf
TASK_NAME="code-review-security"
TASK_DESCRIPTION="Security-focused code review with predefined checklist"
TASK_TYPE="repo"
TASK_TEMPLATE="security-review"  # Uses specific template
TASK_DEFAULT_PARAMS="--focus=security --checklist=owasp"
```

### 2. **Pre-configured Workflows**
```bash
# api-documentation.conf
TASK_NAME="api-documentation"
TASK_DESCRIPTION="Generate API docs with specific format and structure"
TASK_TYPE="doc"  # When we implement doc
TASK_TEMPLATE="api-docs"
TASK_DEFAULT_PARAMS="--format=openapi --include-examples"
```

### 3. **Domain-Specific Analysis**
```bash
# frontend-performance.conf
TASK_NAME="frontend-performance"
TASK_DESCRIPTION="Analyze frontend code for performance issues"
TASK_TYPE="repo"
TASK_TEMPLATE="performance-analysis"
TASK_INCLUDE_PATTERNS="src/components,src/pages,public"
TASK_EXCLUDE_PATTERNS="node_modules,dist"
```

### Enhanced Task Configuration

Custom tasks should support:

- **TASK_TEMPLATE**: Pre-configured template to use
- **TASK_DEFAULT_PARAMS**: Default flags/parameters
- **TASK_INCLUDE_PATTERNS**: Default include patterns
- **TASK_EXCLUDE_PATTERNS**: Default exclude patterns
- **TASK_MODEL**: Default model to use
- **TASK_PROVIDER**: Default provider

### Additional Rules

## Creating Custom Tasks

1.  Create a `.conf` file in `~/.vibe-tools-square/tasks/` (e.g., `my-task.conf`)
2.  Define the task configuration with available parameters:

```bash
# Task Definition: my-custom-task
TASK_NAME="my-custom-task"
TASK_DESCRIPTION="My custom task description"
TASK_TYPE="ask"  # Currently supported: "ask", "repo", "plan"

# Template Configuration
TASK_TEMPLATE="my-template"           # Optional: Use specific template

# Model and Provider Configuration
TASK_MODEL="claude-3.5-sonnet"        # Optional: Default model
TASK_PROVIDER="anthropic"             # Optional: Default provider

# For PLAN tasks - Dual Model Support
TASK_FILE_MODEL="gemini-2.0-flash"    # Optional: Model for file identification
TASK_FILE_PROVIDER="gemini"           # Optional: Provider for file identification
TASK_THINKING_MODEL="o3-mini"         # Optional: Model for plan generation
TASK_THINKING_PROVIDER="openai"       # Optional: Provider for plan generation

# Context Curation (for REPO and PLAN tasks)
TASK_INCLUDE_PATTERNS="src/,docs/"    # Optional: Default include patterns
TASK_EXCLUDE_PATTERNS="test/,tmp/"    # Optional: Default exclude patterns

# Default Parameters
TASK_DEFAULT_PARAMS="--max-tokens=4000 --reasoning-effort=high"  # Optional

# Template Variables (automatically applied)
TASK_FOCUS="your focus area"          # Optional: Sets {{FOCUS}} in templates
TASK_CONTEXT="file:context.md"        # Optional: Sets {{CONTEXT}} in templates
# ... any other variables your template uses

# Output Configuration
TASK_OUTPUT_PREFIX="custom-output"    # Optional: Prefix for output files
```

3.  Use with: `./run-prompt.sh my-custom-task [additional-options]`

The following tasks are provided in the repo assets:

*   **ask** - Direct AI queries with template processing and universal --prompt flag
*   **repo** - Repository analysis with context curation (requires --include)
*   **plan** - Implementation planning with dual AI models (requires --include)
*   **analyze-codebase** - Code structure analysis
*   **code-review** - Code review assistance
*   **feature-planning** - New feature planning