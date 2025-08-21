# Testing Commands for Vibe-Tools Square

This document provides commands you can use to test the functionality of `vibe-tools-square` at each development phase.

## Configuration File Organization

### Project Structure
```
assets/.vibe-tools-square/
├── config/                           # Template configs (copied during install)
│   ├── default.conf                  # Environment variables and settings
│   ├── providers.conf.example       # AI provider presets template
│   └── templates/                    # Template collection
```

### Runtime Environment Structure  
```
~/.vibe-tools-square/
├── config/                          # User's runtime configs (customizable)
│   ├── default.conf                 # Copied from assets
│   ├── providers.conf.example       # Copied from assets  
│   ├── providers.conf               # USER CREATES with their preferences
│   └── templates/                   # Copied from assets
├── tasks/                           # User's custom task configs (optional)
│   ├── ask.conf                     # Overrides repo version if present
│   ├── repo.conf                    # Overrides repo version if present
│   └── my-custom-task.conf          # User-defined tasks (must use existing TASK_TYPE: ask, repo, or plan)
├── content/                         # ICE workspace
├── output/                          # Generated outputs
└── logs/                           # Execution logs
```

### Task Configuration Discovery
The system uses a **runtime-first, repo-fallback** discovery pattern:

1. **Runtime First**: Checks `~/.vibe-tools-square/tasks/${task_name}.conf`
2. **Repo Fallback**: If not found, uses `assets/.vibe-tools-square/tasks/${task_name}.conf`
3. **Dynamic Loading**: Task behavior is determined by `TASK_TYPE` field in .conf files

**Important**: 
- If no runtime tasks directory exists, system automatically uses repo assets
- Runtime configs take precedence and allow development without reinstalling
- Task names are no longer hardcoded - system is fully dynamic

**Important**: 
- `default.conf` contains system defaults and gets copied during install
- `providers.conf.example` is a template - users copy it to `providers.conf` and customize with their AI provider preferences

## Installation Tests

### 1. Install to Default Location
```bash
./scripts/install.sh
# Expected: Creates ~/.vibe-tools-square/ with all files and global run-prompt.sh symlink
```

### 2. Install to Custom Location  
```bash
./scripts/install.sh --target=~/custom-vibe-tools
# Expected: Creates ~/custom-vibe-tools/ and global wrapper script with correct path
```

### 2b. Test Multiple Installations (Overwrites)
```bash
# Install to default (creates symlink)
./scripts/install.sh

# Install to custom (should remove symlink, create wrapper)
./scripts/install.sh --target=~/custom-location

# Install back to default (should remove wrapper, create symlink)
./scripts/install.sh

# Expected: Each install cleanly replaces the previous global command
```

### 3. Verify Installation Structure
```bash
ls -la ~/.vibe-tools-square/
# Expected: config/, content/, logs/, output/, tasks/, README.md

ls -la ~/.vibe-tools-square/tasks/
# Expected: analyze-codebase.conf, ask.conf, code-review.conf, feature-planning.conf
```

## Phase 1 Tests (Current Status)

### Basic Functionality Tests

**Test 1: Usage Display**
```bash
./run-prompt.sh
# Expected: Shows usage information and exits with code 1
```

**Test 2: List Available Tasks**
```bash
./run-prompt.sh --list-tasks
# Expected: Shows dynamic list of tasks from runtime environment first, then repo assets
```

**Test 2B: Task Configuration Discovery Priority**
```bash
# Verify system uses repo assets when no runtime tasks exist
ls ~/.vibe-tools-square/tasks/ 2>/dev/null || echo "No runtime tasks - will use repo assets"
./run-prompt.sh --list-tasks
# Expected: Shows tasks from assets/.vibe-tools-square/tasks/ (ask, repo, plan, etc.)

# Test runtime precedence (if runtime tasks existed)
# mkdir -p ~/.vibe-tools-square/tasks/
# cp assets/.vibe-tools-square/tasks/ask.conf ~/.vibe-tools-square/tasks/
# ./run-prompt.sh ask --prompt="test" --model=gemini/gemini-2.0-flash
# Expected: Would show "Using runtime task config: ~/.vibe-tools-square/tasks/ask.conf"
```

**Test 3: Task Execution (Phase 1 Placeholder)**
```bash
./run-prompt.sh analyze-codebase  
./run-prompt.sh code-review
./run-prompt.sh feature-planning
# Expected: Shows Phase 1 placeholder message for each task
```

### Phase 1 Ask Implementation Tests ✅ COMPLETED

**Test 3A: Basic Ask with String Parameters (Dry Run)**
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --project="My Project" --description="Testing the system"
# Expected: Shows processed template content and vibe-tools command without executing
```

**Test 3A-2: Ask with Universal --prompt Flag (Dry Run)**
```bash
./run-prompt.sh ask --prompt="What is this project about?" --model=gemini/gemini-2.0-flash
# Expected: Shows direct prompt text and vibe-tools command without executing
```

**Test 3A-3: Ask with --prompt File Loading (Dry Run)**
```bash
echo "Analyze this codebase structure" > /tmp/test-prompt.txt
./run-prompt.sh ask --prompt="file:/tmp/test-prompt.txt" --model=gemini/gemini-2.0-flash
# Expected: Loads prompt from file and shows command without executing
```

**Test 3B: Ask with File Content Injection (Dry Run)**
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --documentation=file:README.md
# Expected: Shows template with README.md content injected, command preview without executing
```

**Test 3C: Ask with Custom Output File (Dry Run)**
```bash
./run-prompt.sh ask --template=metacognitive --model=gemini/gemini-2.0-flash --project="Test Project" --context="Testing output" --domain="testing" --output-file=custom-output.md
# Expected: Shows command with --save-to=custom-output.md
```

**Test 3D: Ask with Provider Parameter (Dry Run)**
```bash
./run-prompt.sh ask --template=hello --model=claude-3-sonnet --provider=anthropic --name="Test" --project="Test"
# Expected: Shows command with --provider=anthropic
```

**Test 3E: Ask Actual Execution**
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --project="My Project" --go
# Expected: Actually executes vibe-tools ask command, saves to timestamped file in ~/.vibe-tools-square/output/
```

**Test 3F: Ask with Multiple File Injection**
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --documentation=file:README.md,docs/testing-commands.md
# Expected: Shows template with both files injected separated by newlines
```

**Test 3G: Template Discovery Test**
```bash
./run-prompt.sh ask --template=nonexistent --model=gemini/gemini-2.0-flash
# Expected: Error message about template not found in search paths
```

### Phase 1 Repo Implementation Tests ✅ COMPLETED

**Test 4A: Basic Repo with Context Validation**
```bash
./run-prompt.sh repo "Explain the overall structure of this codebase"
# Expected: ERROR - Repository analysis requires context files. Use --include to specify files/folders to analyze.
```

**Test 4A-2: Repo with Universal --prompt Flag (Dry Run)**
```bash
./run-prompt.sh repo --prompt="Analyze the README file" --include=README.md
# Expected: Uses direct prompt text with context validation, shows curated context, dry run mode
```

**Test 4B: Repo with Include Files (Dry Run)**
```bash
./run-prompt.sh repo "What is in the README and source code?" --include=README.md --include=src
# Expected: Includes README.md file and everything in src/ folder, shows count of curated files
```

**Test 4C: Repo with Include and Exclude (Dry Run)**
```bash
./run-prompt.sh repo "Analyze the source code but ignore utility files" --include=src --exclude=src/utils
# Expected: Includes src/ folder but excludes src/utils/ folder, shows file count
```

**Test 4D: Repo with Specific Model (Dry Run)**
```bash
./run-prompt.sh repo "Quick analysis" --include=README.md --model=openrouter/gemini-2.0-flash
# Expected: Uses specified model instead of default, shows resolved provider/model in command
```

**Test 4E: Repo Live Execution**
```bash
./run-prompt.sh repo "Explain this project" --include=README.md --include=src --go
# Expected: Actually runs vibe-tools repo command from ~/.vibe-tools-square/content with --subdir=public
```

**Test 4F: Show Current Context**
```bash
./run-prompt.sh repo --show-context
# Expected: Lists all files currently in the curated context (ICE public folder)
```

### Phase 1 Plan Implementation Tests ✅ COMPLETED

**Test 5A: Basic Plan with Context Validation**
```bash
./run-prompt.sh plan "Add user authentication to this project"
# Expected: ERROR - Planning requires context files. Use --include to specify files/folders to base the plan on.
```

**Test 5A-2: Plan with Universal --prompt Flag (Dry Run)**
```bash
./run-prompt.sh plan --prompt="Create a plan to improve the documentation" --include=README.md --include=docs
# Expected: Uses direct prompt text with context validation, shows curated context, dry run mode
```

**Test 5B: Plan with Context Files (Dry Run)**
```bash
./run-prompt.sh plan "Refactor the core module" --include=src/core.sh --include=README.md
# Expected: Curates specified files, shows file count, displays plan command with --subdir=public
```

**Test 5C: Plan with Different Models (Dry Run)**
```bash
./run-prompt.sh plan "Design a new feature" --file-model=gemini/gemini-2.0-flash --thinking-model=openrouter/claude-3.5-sonnet --include=src
# Expected: Shows command with separate fileProvider/fileModel and thinkingProvider/thinkingModel flags
```

**Test 5D: Plan with Full Context (Dry Run)**
```bash
./run-prompt.sh plan "Complete project analysis" --include=. --exclude=.git --exclude=node_modules
# Expected: Includes current directory except specified exclusions, shows large file count
```

**Test 5E: Plan Live Execution**
```bash
./run-prompt.sh plan "Create implementation steps" --include=README.md --go
# Expected: Actually executes vibe-tools plan command with curated context
```

**Test 5F: Show Context After Planning**
```bash
./run-prompt.sh plan "Test" --include=src --show-context
# Expected: Shows all files that would be used as context for planning
```

### Context Management Tests ✅ COMPLETED

**Test 6A: Context Patterns**
```bash
# Include single file
./run-prompt.sh repo "Analyze README" --include=README.md

# Include entire directory
./run-prompt.sh repo "Analyze source" --include=src

# Include multiple files and folders  
./run-prompt.sh repo "Full analysis" --include=README.md --include=src --include=docs

# Include with exclusions
./run-prompt.sh repo "Source without tests" --include=src --exclude=src/test
```

**Test 6B: Check What's Actually Copied**
```bash
# Run with includes then check context
./run-prompt.sh repo "Test" --include=README.md --include=src
./run-prompt.sh repo --show-context

# Expected: First command shows "Curated files copied: X", second shows detailed file list
```

**Test 6C: Simple Usage Examples**
```bash
# Include specific files:
--include=README.md          # Include just the README.md file
--include=src/core.sh        # Include just the src/core.sh file

# Include entire folders:
--include=src               # Include everything in src/ folder
--include=docs              # Include everything in docs/ folder

# Exclude from what you included:
--exclude=src/test          # Exclude the src/test/ folder
--exclude=README.md.bak     # Exclude specific backup file
```

**Test 4: Global Command (if installed)**
```bash
run-prompt.sh --list-tasks
run-prompt.sh ask
# Expected: Same behavior as local script
```

### Configuration Tests

**Test 5: Custom Runtime Environment**
```bash
VIBE_TOOLS_SQUARE_HOME=~/custom-vibe-tools ./run-prompt.sh --list-tasks
# Expected: Lists tasks from custom location
```

**Test 6: Configuration File Validation**
```bash
cat ~/.vibe-tools-square/config/default.conf
cat ~/.vibe-tools-square/config/providers.conf.example
# Expected: default.conf and providers.conf.example exist

# User should create their own providers.conf:
cp ~/.vibe-tools-square/config/providers.conf.example ~/.vibe-tools-square/config/providers.conf
# Then customize providers.conf with their API keys and preferred models

# This should NOT exist:
ls ~/.vibe-tools-square/config/vibe-tools.config.json 2>/dev/null || echo "✅ vibe-tools.config.json correctly absent"
```

### Logging Tests

**Test 7: Log File Creation**
```bash
./run-prompt.sh ask
cat ~/.vibe-tools-square/logs/run-prompt.log
# Expected: Log file created with timestamped entries
```

**Test 8: Multiple Runtime Environments**
```bash
# Install to custom location
./scripts/install.sh --target=/tmp/test-vibe-tools

# Test with custom environment
VIBE_TOOLS_SQUARE_HOME=/tmp/test-vibe-tools ./run-prompt.sh --list-tasks

# Test with default environment  
./run-prompt.sh --list-tasks

# Expected: Each shows tasks from respective locations
```

## Architecture Validation

**Test 9: Module Sourcing**
```bash
./run-prompt.sh ask 2>&1 | head -5
# Expected: No "file not found" errors, clean execution
```

**Test 10: Global Command Verification**
```bash
which run-prompt.sh
ls -la $(which run-prompt.sh)
# Expected: For default install: shows symlink to project script
# Expected: For custom install: shows regular file (wrapper script)

# If wrapper script:
file $(which run-prompt.sh)
head -5 $(which run-prompt.sh)
# Expected: Shows bash script with VIBE_TOOLS_SQUARE_HOME export
```

## Error Handling Tests

**Test 11: Missing Runtime Environment**
```bash
VIBE_TOOLS_SQUARE_HOME=/nonexistent ./run-prompt.sh --list-tasks
# Expected: Warning about missing tasks directory
```

**Test 12: Invalid Task Name**
```bash
./run-prompt.sh nonexistent-task
# Expected: Phase 1 placeholder message (no special error handling yet)
```

## Development Validation

**Test 13: File Organization Check**
```bash
ls -la src/
# Expected: config.sh, core.sh, template.sh, context.sh, providers.sh, logging_utils.sh, messaging_utils.sh

ls -la assets/.vibe-tools-square/
# Expected: tasks/, plus all README files
```

**Test 14: Task File Validation**
```bash
cat assets/.vibe-tools-square/tasks/ask.conf
# Expected: TASK_NAME and TASK_DESCRIPTION only (no presumptuous scaffolding)
```

---

## Expected Behaviors by Phase

### Phase 1 (Current): ✅ Foundation Complete
- ✅ Task listing works dynamically
- ✅ Basic task execution (placeholder)
- ✅ Multiple runtime environments supported
- ✅ Global command installation
- ✅ Proper logging using messaging utilities
- ✅ Configuration file management
- ✅ **Ask task implementation with template processing**
- ✅ **Template placeholder replacement (string + file injection)**
- ✅ **Dry-run default with --go flag for execution**
- ✅ **Timestamped output to ~/.vibe-tools-square/output/**
- ✅ **Repo task with ICE context curation**
- ✅ **Plan task with separate file/thinking models**
- ✅ **Include/exclude patterns for context filtering**
- ✅ **--show-context flag to list curated files**
- ✅ **Universal --prompt flag across all tasks (direct text + file: prefix)**
- ✅ **Context validation (repo/plan require --include flags)**
- ✅ **Runtime-first task configuration discovery with repo fallback**
- ✅ **Dynamic task system (no hardcoded task names)**

### Phase 2 (Next): Context Curation Engine
- Template processing
- ICE (Isolated Context Environment) 
- Include/exclude patterns
- Dry run functionality

### Phase 3 (Future): Full Integration
- Actual vibe-tools command execution
- Multi-step workflows
- Advanced template features

## Quick Testing Commands (Added 2025-08-20)

```bash
# ============================================
# TESTING PROMPT-BASED TASKS (BASIC VERSIONS)
# ============================================

# Test the basic 'ask' task
./run-prompt.sh ask --prompt="What are the main features of JavaScript ES6?" --go

# Test the basic 'repo' task
./run-prompt.sh repo --prompt="Explain the structure of this repository" --include="README.md,src/" --go

# Test the basic 'plan' task
./run-prompt.sh plan --prompt="Create a plan for adding user authentication" --include="src/,README.md" --go

# ============================================
# TESTING TEMPLATE-BASED TASKS (DEMO VERSIONS)
# ============================================

# Test the 'ask-demo' task (project briefing)
./run-prompt.sh ask-demo --project-name="Vibe Tools Square" --user-role="Lead Developer" --domain="CLI Development" --tech-stack="Bash, JavaScript" --priority="High" --context="file:README.md" --deadline="End of month" --go

# Test the 'plan-demo' task (feature planning)
./run-prompt.sh plan-demo --feature-name="OAuth Authentication" --complexity="High" --priority="Critical" --requirements-file="README.md" --architecture-file="README.md" --dependencies="Express, JWT, Passport" --timeline="3-week sprint" --team-size="2 developers" --target-audience="Enterprise users" --go

# Test the 'repo-demo' task (code analysis)
./run-prompt.sh repo-demo --include-patterns="src/,README.md" --exclude-patterns="node_modules/,test/" --focus="code maintainability" --principles="SOLID, DRY" --language="Bash" --frameworks-file="README.md" --standards-file="README.md" --architecture="CLI Tool" --go
```