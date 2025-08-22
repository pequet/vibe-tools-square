---
type: guide
domain: methods
subject: Vibe-Tools Square
status: active
summary: Practical examples demonstrating the power and utility of each vibe-tools command type
tags: [notes-active]
---

# Testing Commands - Practical Examples

This guide provides **useful, real-world examples** that demonstrate the power of vibe-tools-square. E


## Quick Reference

```bash
# List all available tasks
./run-prompt.sh --list-tasks

# See what each task does (check the .conf file)
cat ~/.vibe-tools-square/tasks/ask.conf  # (or assets/.vibe-tools-square/tasks/ask.conf)
```

## Ask Commands - General Programming Questions (No Codebase Context)

**ask** is for general questions that don't need your codebase context. It relies solely on the prompt you provide.

```bash
# Get programming advice
./run-prompt.sh ask --prompt="What are the best practices for error handling in Bash scripts?" --model=gemini/gemini-2.0-flash --go

# Explain concepts
./run-prompt.sh ask --prompt="Explain the difference between synchronous and asynchronous programming with examples" --model=gemini/gemini-2.0-flash --go

# General architectural guidance (no codebase context)
./run-prompt.sh ask --prompt="What are the pros and cons of microservices vs monolithic architecture?" --model=gemini/gemini-2.0-flash --go
```

## Repo Commands - Analyze Your Codebase (With Codebase Context)

**repo** analyzes YOUR code and provides insights about your specific project. It includes codebase context.

```bash
# Get project overview
./run-prompt.sh repo --prompt="What is this project about and how is it structured?" --include="README.md,src/" --model=gemini/gemini-2.0-flash --go

# Code quality analysis  
./run-prompt.sh repo --prompt="Analyze the code quality and suggest improvements" --include="src/" --exclude="src/utils" --model=gemini/gemini-2.0-flash --go

# Documentation review
./run-prompt.sh repo --prompt="Is the documentation complete and accurate? What's missing?" --include="README.md,docs" --model=gemini/gemini-2.0-flash --go

# Find functions related to a specific feature
./run-prompt.sh repo --prompt="List and explain the function names in src/config.sh" --include="src/config.sh" --model=gemini/gemini-2.0-flash --go
```

## Plan Commands - Strategic Planning (With Codebase Context)

**plan** creates implementation strategies based on your codebase analysis. It includes codebase context and typically involves more complex, multi-step reasoning. Plan commands use a dual-model approach with separate models for file identification and thinking/planning.

```bash
# Feature planning (using default models)
./run-prompt.sh plan --prompt="Create a plan to add user authentication with JWT tokens" --include="src" --go

# Refactoring strategy (overriding the thinking model only)
./run-prompt.sh plan --prompt="Design a plan to modularize this bash script for better maintainability" --include="src/core.sh" --thinking-model="gemini/gemini-2.5-pro" --go

# Migration planning (overriding the file model only)
./run-prompt.sh plan --prompt="Plan the migration from this bash implementation to a Python CLI tool" --include="src,README.md" --thinking-model="gemini/gemini-2.5-flash" --go

# Testing strategy (overriding both models)
./run-prompt.sh plan --prompt="Design a comprehensive testing strategy for this CLI tool" --include="src" --file-model="gemini/gemini-2.5-flash" --thinking-model="gemini/gemini-2.5-pro" --go
```

## Demo Commands - See Templates in Action

These demonstrate the template system with pre-configured examples. Check the referenced configuration files to see the pre-defined prompts.

```bash
# Ask demo - project briefing template
./run-prompt.sh ask-demo --project-name="My Web App" --user-role="Lead Developer" --go
# To see the task configuration:
cat ~/.vibe-tools-square/tasks/ask-demo.conf 2>/dev/null || cat assets/.vibe-tools-square/tasks/ask-demo.conf

# Repo demo - code quality analysis template  
./run-prompt.sh repo-demo --go
# To see the task configuration:
cat ~/.vibe-tools-square/tasks/repo-demo.conf 2>/dev/null || cat assets/.vibe-tools-square/tasks/repo-demo.conf

# Plan demo - feature planning template
./run-prompt.sh plan-demo --go
# To see the task configuration:
cat ~/.vibe-tools-square/tasks/plan-demo.conf 2>/dev/null || cat assets/.vibe-tools-square/tasks/plan-demo.conf
```

## Provider Configuration

```bash
# Test your API keys and provider setup
./run-prompt.sh ask --prompt="Hello, are you working correctly?" --model=gemini/gemini-2.0-flash --go
```

## File Inclusion Examples

```bash
# Analyze specific files
./run-prompt.sh repo --prompt="Review the main script for potential improvements" --include="run-prompt.sh" --model=gemini/gemini-2.0-flash --go

# Analyze files in a directory
./run-prompt.sh repo --prompt="Review the utility functions for code quality" --include="src/utils" --model=gemini/gemini-2.0-flash --go
```

## Practical Workflow Examples

```bash
# 1. Understand a new codebase
./run-prompt.sh repo --prompt="Explain this project's purpose, architecture, and main components" --include="README.md,src" --model=gemini/gemini-2.0-flash --go

# 2. Plan a new feature
./run-prompt.sh plan --prompt="Create a plan to add configuration file support with validation" --include="src" --model=gemini/gemini-2.0-flash --go

# 3. Review your work
./run-prompt.sh repo --prompt="Review recent changes for potential issues" --include="src/core.sh" --model=gemini/gemini-2.0-flash --go
```

## File Selection Guide

```bash
# Single file
--include=README.md

# Multiple files (comma-separated, no spaces)
--include=README.md,src/core.sh,docs/guide.md

# Single directory (includes all contents)
--include=src

# Multiple directories (comma-separated, no spaces)
--include=src,docs,assets

# Mix files and directories (comma-separated, no spaces)
--include=README.md,src,docs/guide.md

# Exclude patterns
--exclude=src/utils,logs,archives

# Include everything except specific paths
--include=. --exclude=node_modules,logs,archives,.git
```

## Output Management

All commands save results to `~/.vibe-tools-square/output/` with timestamps. Use `--go` to execute (otherwise it runs in dry-run mode).
