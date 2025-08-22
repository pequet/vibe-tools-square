# Tasks Directory

This directory is for your custom task configurations. Task files use the `.conf` extension and define how tasks are executed.

## How Tasks Work

Task configuration files define:

- `TASK_NAME` - The name of the task (matches filename without .conf)
- `TASK_DESCRIPTION` - Description shown in `--list-tasks`
- `TASK_TYPE` - Execution type (currently only: ask, repo, or plan)

## Task Discovery

The system searches for tasks in this order:

1. **Runtime tasks**: `~/.vibe-tools-square/tasks/` (this directory when copied to runtime)
2. **Repo tasks**: `assets/.vibe-tools-square/tasks/` (fallback)

This allows you to:
- Override default tasks by placing custom versions in your runtime directory
- Add completely new tasks
- Develop without reinstalling the system

## Default Tasks

The core task types provided in the repo assets:

- **ask** - Direct AI queries with template processing and universal --prompt flag  
- **repo** - Repository analysis with context curation (requires --include)
- **plan** - Implementation planning with dual AI models (requires --include)

Additional example tasks are also provided to demonstrate various configurations and use cases.

*Note: Additional vibe-tools commands (web, doc, browser, youtube) are not yet implemented as tasks but could be added fairly easily in future versions.*

## Current Scope and Limitations

**Currently Supported:**
- Single-step task execution with preset configurations
- Template and parameter presets
- Model and provider presets  
- Context curation presets (include/exclude patterns)
- Template variable injection
- Only `ask`, `repo`, `plan` are implemented (`web`, `doc`, `browser`, `youtube` could be added fairly easily down the line)

**Out of Scope:**
- **Multi-step workflows** - Tasks execute single vibe-tools commands only

## Creating Custom Tasks

1. Create a `.conf` file in `~/.vibe-tools-square/tasks/` (e.g., `my-task.conf`)
2. Study the example task configurations in this assets directory for reference
3. Define your task using the same parameter structure as the examples
4. Use with: `./run-prompt.sh my-task [additional-options]`

See the various `.conf` files in this directory for examples of different task types and parameter configurations.

## Task Types

- **ask** - Uses `execute_ask_task()` - for direct AI queries with template processing
- **repo** - Uses `execute_repo_task()` - for repository analysis with ICE context curation
- **plan** - Uses `execute_plan_task()` - for implementation planning with dual AI models

*Note: All task types ultimately call vibe-tools commands with different parameters and context handling.*

## Runtime Override Example

To override the default "ask" task:

1. Copy: `cp assets/.vibe-tools-square/tasks/ask-demo.conf ~/.vibe-tools-square/tasks/`
2. Edit: Modify `~/.vibe-tools-square/tasks/ask-demo.conf` with your customizations
3. Use: Your version will take precedence over the repo version

## Development Workflow

1. Develop tasks in your runtime environment
2. Test with local overrides
3. Promote successful tasks back to repo assets if desired
4. Runtime configs always take precedence for seamless development
