> **Vibe-Tools Square?** It's a compact toolkit for automating common vibe-tools workflows, a "Vibe-Tools Tool", hence the squared notation. The template-driven automation promises to accelerate development and system evolution exponentially. This meta-tool approach aligns perfectly with our framework's meta-system thinking principles. 

# Vibe-Tools Square

Template-driven AI workflow automation. Transform repetitive vibe-tools commands into reusable, parameterized tasks.

**Before:** Manual command repetition

```bash
vibe-tools ask "Summarize this meeting transcript: [paste long transcript]"
vibe-tools repo "Review this feature for security vulnerabilities" --subdir="src/auth/"  
vibe-tools plan "Create deployment strategy for this service" --subdir="deploy/"
```

**After:** Automated template workflows

```bash
./run-prompt.sh ask-meeting-summary --transcript="file:transcripts/standup.txt" --go
./run-prompt.sh repo-security-review --include="src/auth/,tests/auth/" --exclude="*.log" --go
./run-prompt.sh plan-deploy-strategy --service="user-service" --include="config/,deploy/" --go
```

## Core Features

- **Template Engine**: Token replacement system with variable substitution
- **Curated Context Engine**: For `repo` and `plan` -based commands, builds temporary Isolated Context Environment with only explicitly required files for cost optimization
- **Provider Agnostic**: Switch AI providers via configuration and parameters
- **Atomic Operations**: `ask` (general questions), `repo` (codebase analysis), `plan` (strategic planning)

## Smart Context Management

Control exactly which files are analyzed to reduce costs and improve focus:

```bash
# Include specific directories only
./run-prompt.sh repo-code-review --include="src/components/,tests/unit/" --go

# Include files but exclude patterns within them
./run-prompt.sh repo-security-scan --include="src/" --exclude="*.test.js,*.spec.ts" --go

# Complex filtering
./run-prompt.sh repo-api-review --include="api/,docs/" --exclude="*.log,temp/" --go
```

**How it works:**
- Creates temporary isolated environment with only specified files
- Uses `rsync` filters for precise file selection
- Reduces token usage and API costs
- Wildcards supported: `*.test.js`, `*.spec.ts`, `*.log`, etc.

## Command Types

Each vibe-tools command type serves a distinct purpose, and understanding these differences is crucial:

| Command | Purpose | Example Use Case |
|---------|---------|------------------|
| **ask** | General questions (no codebase context) | "Summarize this meeting transcript: {{TRANSCRIPT}}" |
| **repo** | Codebase analysis and code review | "Review {{MODULE}} for security vulnerabilities" |
| **plan** | Strategic planning with codebase context | "Create deployment plan for {{SERVICE}} to {{ENVIRONMENT}}" |

## Installation

**Prerequisites:** vibe-tools installed globally with API keys configured, rsync command

```bash
git clone https://github.com/pequet/vibe-tools-square.git
cd vibe-tools-square
./scripts/install.sh
```

## Quick Start

**Basic command:**
```bash
./run-prompt.sh ask --prompt="Explain the difference between a bug and a feature, with examples" --go
```

**Explore demo tasks:**
1. List available tasks: `./run-prompt.sh --list-tasks`
2. Try demos: `ask-demo`, `repo-demo`, `plan-demo`
3. Run with variables: `./run-prompt.sh ask-demo --topic="authentication" --go`

Demo configurations: `assets/.vibe-tools-square/tasks/`  
Templates: `assets/.vibe-tools-square/config/templates/`

## Creating Custom Tasks

We suggest prefacing the task name with the task type, e.g. `ask-task`, `repo-task`, `plan-task`.

**1. Create task configuration:** `~/.vibe-tools-square/tasks/ask-task.conf`

```bash
TASK_NAME="ask-task"
TASK_DESCRIPTION="Custom workflow description"  
TASK_TYPE="ask"  
PROMPT="Analyze {{TOPIC=general programming}} concepts"
PARAM_MAX_TOKENS="4000"
```

**2. Execute task:**
```bash
./run-prompt.sh ask-task --topic="React hooks" --go
```

## Documentation

- [Testing Commands](docs/100-Testing-Commands.md) - Complete command reference
- [Special Characters Guide](docs/110-Special-Characters-Guide.md) - Handling special characters
- [Using Placeholders](docs/120-Using-Placeholders.md) - Template variable system

## License

This project is licensed under the MIT License.

## Support the Project

If you find this project useful:

- [Buy Me a Coffee](https://buymeacoffee.com/pequet)
- [Sponsor on GitHub](https://github.com/sponsors/pequet)

Your support helps maintain and improve this project. Thank you!

