# Content Directory - Isolated Context Environment (ICE)

This directory serves as the Isolated Context Environment for `repo` and `plan` commands.

## Purpose

When running `repo` or `plan` commands, the system:
1. Copies specified files here using `--include` and `--exclude` patterns
2. Installs vibe-tools in this directory
3. Runs the vibe-tools command from within this curated context
4. Maintains its own `vibe-tools.config.json` configuration

## Subdirectories

- `public/` - Public content area for curated files (ONLY files here are included in repomix processing)
- `vibe-tools.config.json` - Vibe-tools configuration for this context

## Repomix Configuration

This directory includes:
- `repomix.config.json` - Configured to only include files from the `public/` subdirectory
- `.repomixignore` - Excludes everything except the `public/` directory

This ensures that when vibe-tools processes this context, only the specifically curated files are included in the analysis, providing precise token control and context isolation.

## Usage

This directory is automatically managed by the run-prompt.sh script. You typically don't need to interact with it directly, but you can inspect its contents for debugging context curation.