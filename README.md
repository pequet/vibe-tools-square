# Vibe-Tools Square

**A query template engine that transforms AI interactions into reusable, parameterized workflows.**

Instead of retyping similar vibe-tools commands, create template-driven tasks with variable substitution and execution controls.

## Core Value Proposition

Transform this repetitive workflow:
```bash
# Processing different content with similar analysis patterns
vibe-tools ask "Summarize this meeting transcript: [paste long transcript]"
vibe-tools repo "Review this new feature for security vulnerabilities" --subdir="src/auth/"  
vibe-tools plan "Create deployment strategy for this service" --subdir="config/,deploy/"
```

Into this structured approach:
```bash
# Template-driven with variable content injection
./run-prompt.sh meeting-summary --transcript="file:transcripts/standup-2025-08-21.txt" --go
./run-prompt.sh security-review --feature="auth" --include="src/auth/" --go
./run-prompt.sh deploy-strategy --service="user-service" --env="production" --include="config/,deploy/" --go
```

## The Three Modes of Thinking: Ask vs. Repo vs. Plan

Each vibe-tools command serves a distinct purpose - understanding these differences is crucial:

| Command | Purpose | Useful Automation Example |
|---------|---------|---------------------------|
| **ask** (The Interrogator) | General programming questions requiring no codebase context | "Summarize this meeting transcript: {{TRANSCRIPT}}" |
| **repo** (The Code Archaeologist) | Repository-specific analysis, search, and code review | "Review {{MODULE}} for security vulnerabilities" |
| **plan** (The Project Architect) | Strategic planning and refactoring based on codebase analysis | "Create deployment plan for {{SERVICE}} to {{ENVIRONMENT}}" |

## Prerequisites

- **vibe-tools** installed globally with API keys configured
- **rsync** command (required for repo/plan context management)
- Basic familiarity with vibe-tools commands

## Installation

```bash
git clone https://github.com/pequet/vibe-tools-square.git
cd vibe-tools-square
./scripts/install.sh
```

## Quick Start: Learn from Three Demo Tasks

The repository includes three demo tasks that show template-driven workflows:

- **`ask-demo`** - See how to create templates for processing variable content (project briefings, document analysis, etc.)
- **`repo-demo`** - Learn codebase analysis patterns with parameterized focus areas
- **`plan-demo`** - Understand feature planning workflows with variable complexity and scope

Each demo task includes configuration files showing template structure and placeholder usage.

**To explore the demos:**
1. Run `./run-prompt.sh --list-tasks` to see all available tasks
2. Check demo configurations in `assets/.vibe-tools-square/tasks/` 
3. View templates in `assets/.vibe-tools-square/config/templates/`
4. Test with custom variables: `./run-prompt.sh <demo-name> --variable-name="value" --go` (defaults are set, but variables let you inject specific content into placeholders)

## What We're Building (Wrapper Layer Only)

- **Simple CLI API**: Flexible command-line interface for atomic AI operations via vibe-tools
- **Template + Placeholder Engine**: Token replacement system for reusable workflows
- **Config-Driven Everything**: No hardcoded values, all settings from config files
- **Modular Architecture**: Clean separation of concerns while preserving functionality
- **Provider Agnostic**: Seamless AI provider switching via config presets
- **Curated Context Engine**: For `repo` and `plan` commands, builds temporary Isolated Context Environment with only explicitly required files to control context size and cost
- **Atomic Operations**: Supports `ask`, `repo`, and `plan` commands only

## Context Management for Repo/Plan Commands

A key innovation is the dynamic file inclusion/exclusion system using `rsync`. Instead of editing `.repomixignore` for each command:

- **`--include=` parameter**: Comma-delimited list of files/folders to include
- **`--exclude=` parameter**: Comma-delimited list of files/folders to exclude  
- **Isolated Context Environment**: Copies only relevant files to temporary folder
- **Cost Control**: Reduces context size, tokens, and API costs

Example:
```bash
./run-prompt.sh security-review --include="src/auth/,tests/auth/" --exclude="*.log,node_modules/" --go
```

Use `./run-prompt.sh --list-tasks` to see all available tasks:

- `ask` - General AI questions (no codebase context)
- `repo` - Repository analysis with file context  
- `plan` - Implementation planning with codebase awareness
- `ask-demo` - Template demonstration with variable injection
- `repo-demo` - Advanced codebase analysis workflow
- `plan-demo` - Feature planning workflow demonstration

## Available Tasks

## Creating Custom Tasks

1. Create a task configuration in `~/.vibe-tools-square/tasks/`:

```bash
# my-task.conf
TASK_NAME="my-task"
TASK_DESCRIPTION="Custom workflow description"
TASK_TYPE="ask"  # or "repo" or "plan"
PROMPT="Analyze {{TOPIC=general programming}} concepts"
PARAM_MAX_TOKENS="4000"
```

2. Run your custom task:

```bash
./run-prompt.sh my-task --topic="React hooks" --go
```

## Documentation

- **[Testing Commands](docs/100-Testing-Commands.md)** - Complete command reference
- **[Special Characters Guide](docs/110-Special-Characters-Guide.md)** - Handling special characters in prompts  
- **[Using Placeholders](docs/120-Using-Placeholders.md)** - Template variable system

## License

This project is licensed under the MIT License.

## Support the Project

If you find this project useful:

- [Buy Me a Coffee](https://buymeacoffee.com/pequet)
- [Sponsor on GitHub](https://github.com/sponsors/pequet)

Your support helps maintain and improve this project. Thank you! 

