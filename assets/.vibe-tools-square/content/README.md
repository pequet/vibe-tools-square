# Isolated Context Environment (ICE)

This directory serves as the **Isolated Context Environment** for `repo` and `plan` commands.

## Purpose

When you run `run-prompt repo` or `run-prompt plan`, this directory is dynamically populated with a curated subset of your codebase before the AI query is executed.

## How It Works

1. **Before execution**: The `context.sh` script copies only the files you specify using `--include` and `--exclude` patterns
2. **During execution**: `vibe-tools` runs from this directory, seeing only the curated context
3. **After execution**: The directory can be inspected or cleaned for the next run

## Benefits

- **Cost Control**: Only relevant files are sent to the AI, reducing token usage
- **Precision**: Eliminate noise from irrelevant code
- **Safety**: Your main codebase is never modified
- **Debugging**: You can inspect exactly what context was provided

## Usage

```bash
# Example: Include specific directories, exclude logs
run-prompt repo --template=analysis \
  --include="src/***" \
  --include="docs/important.md" \
  --exclude="*.log" \
  --exclude="node_modules/**"
```

## Note

This directory is temporary and gets recreated for each context-dependent command. Do not store permanent files here.
