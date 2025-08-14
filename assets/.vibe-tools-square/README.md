# Vibe-Tools Square Runtime Environment

This directory contains the isolated runtime environment for the `vibe-tools-square` command-line tool.

## Purpose

This is an **Isolated Context Environment** (ICE) for running AI queries with controlled context and configuration, separate from your main development codebase.

## Directory Structure

- `config/` - Runtime configuration files and templates
- `content/` - **ICE**: Dynamically populated with curated files for `repo`/`plan` commands
- `output/` - Default output directory for command results
- `logs/` - Execution logs and debugging information
- `node_modules/` - Isolated installation modules (created during setup)

## Installation

This directory is automatically created when you install `vibe-tools-square`. To reinstall or update:

```bash
# From the development repository
./scripts/install.sh
```

## Usage

The `run-prompt` command operates from this environment, allowing:

1. **Isolated execution** - No interference with your main codebase
2. **Controlled context** - Only explicitly included files are sent to AI models
3. **Cost control** - Precise control over context size reduces API costs
4. **Independent configuration** - Separate API keys and settings

## Related Documentation

- Main repository: `vibe-tools-square/`
- Framework concept: `Core/Models/2. Knowledge/Framework/Terminology/Isolated Context Environment.md`
