#!/bin/bash
# core.sh - Main orchestration logic for vibe-tools-square
# This is the heart of the system that coordinates all other modules

set -euo pipefail

# Dependencies are sourced by run-prompt.sh
# No need to re-source them here

# Runtime detection for task listing (simplified version)
detect_runtime_home_for_listing() {
    # Force the variable from environment first, regardless of what happened before
    if [[ -n "${ORIGINAL_VIBE_TOOLS_SQUARE_HOME:-}" ]]; then
        VIBE_TOOLS_SQUARE_HOME="$ORIGINAL_VIBE_TOOLS_SQUARE_HOME"
    elif [[ -z "${VIBE_TOOLS_SQUARE_HOME:-}" ]]; then
        VIBE_TOOLS_SQUARE_HOME="${HOME}/.vibe-tools-square"
    fi
}

# Core function: orchestrate task execution
core_main() {
    # Handle special flags
    if [[ "${1:-}" == "--list-tasks" ]]; then
        # For listing tasks, we need to detect runtime home first
        detect_runtime_home_for_listing
        list_available_tasks_detailed
        exit 0
    fi
    
    local task_name="$1"
    shift
    
    print_header "Starting vibe-tools-square execution"
    print_info "Task: $task_name"
    print_info "Arguments: $*"
    
    # Load and execute the specified task
    execute_task "$task_name" "$@"
    
    print_info "Execution completed successfully"
}

# Execute a user-defined task
execute_task() {
    local task_name="$1"
    shift
    
    print_step "Executing task: $task_name"
    
    # TODO: Phase 2 - Load task definition and execute steps
    # For Phase 1, simply acknowledge the task request
    print_info "Task: $task_name"
    print_info "Status: Phase 1 placeholder - task execution not yet implemented"
    print_info "This task will be implemented in Phase 2 when task definitions are loaded from configuration"
}

# List available tasks (brief for usage display)
list_available_tasks() {
    local tasks_dir="$VIBE_TOOLS_SQUARE_HOME/tasks"
    
    if [[ -d "$tasks_dir" ]]; then
        for task_file in "$tasks_dir"/*.conf; do
            if [[ -f "$task_file" ]]; then
                # Source the task file to get variables
                source "$task_file"
                printf "  %-20s %s\n" "$TASK_NAME" "$TASK_DESCRIPTION"
            fi
        done
    else
        print_warning "Tasks directory not found: $tasks_dir"
        print_info "Run the install script to set up the runtime environment"
    fi
}

# List available tasks (detailed for --list-tasks)
list_available_tasks_detailed() {
    print_info "Available Tasks:"
    print_info ""
    
    local tasks_dir="$VIBE_TOOLS_SQUARE_HOME/tasks"
    
    if [[ -d "$tasks_dir" ]]; then
        for task_file in "$tasks_dir"/*.conf; do
            if [[ -f "$task_file" ]]; then
                # Source the task file to get variables
                source "$task_file"
                printf "  %-20s %s\n" "$TASK_NAME" "$TASK_DESCRIPTION"
            fi
        done
    else
        print_warning "Tasks directory not found: $tasks_dir"
        print_info "Run the install script to set up the runtime environment"
    fi
    
    print_info ""
    print_info "Usage: run-prompt.sh <task-name> [options]"
    print_info "Example: run-prompt.sh analyze-codebase --template=analysis --include='src/**'"
}

# Show usage information
show_usage() {
    cat << EOF
Usage: run-prompt.sh <task-name> [options]
       run-prompt.sh --list-tasks     # Show available tasks

Options:
  --go                    Actually execute (default is dry run)
  --template=<name>       Template to use for the task
  --preset=<alias>        Provider preset (e.g., gemini-free, openrouter-cheap)
  --include=<pattern>     Include files/dirs in context (for tasks using repo/plan)
  --exclude=<pattern>     Exclude files/dirs from context (for tasks using repo/plan)
  --output-file=<path>    Save output to specific file
  --list-tasks            Show available tasks and their descriptions
  --help                  Show this help

Available Tasks:
$(list_available_tasks)

Note: Tasks are user-defined workflows that may use vibe-tools ask/repo/plan internally.
For detailed documentation, see docs/testing-commands.md
EOF
}

# Only execute core_main if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    core_main "$@"
fi
