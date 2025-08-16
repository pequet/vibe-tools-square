# Vibe-Tools Square Runtime Environment

This is your runtime environment for the Vibe-Tools Square template execution engine.

## Directory Structure

- `config/` - Configuration files and templates
- `content/` - Isolated Context Environment (ICE) for repo/plan commands  
- `output/` - Default location for command outputs
- `logs/` - Execution logs and debugging information

## Getting Started

Run commands using:
```bash
run-prompt.sh <command> --template=<name> [options]
```

Use `--go` flag to actually execute (default is dry-run mode).

For complete documentation, see the project repository.