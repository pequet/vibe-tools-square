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

### Runtime Structure  
```
~/.vibe-tools-square/
├── config/                          # User's runtime configs (customizable)
│   ├── default.conf                 # Copied from assets
│   ├── providers.conf.example       # Copied from assets  
│   ├── providers.conf               # USER CREATES with their preferences
│   └── templates/                   # Copied from assets
```

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
# Expected: Shows dynamic list of tasks from runtime environment
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

### Phase 2 (Next): Context Curation Engine
- Template processing
- ICE (Isolated Context Environment) 
- Include/exclude patterns
- Dry run functionality

### Phase 3 (Future): Full Integration
- Actual vibe-tools command execution
- Multi-step workflows
- Advanced template features