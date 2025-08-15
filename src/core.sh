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
    
    # Phase 1: Handle specific task implementations
    case "$task_name" in
        "ask")
            execute_ask_task "$@"
            ;;
        *)
            # TODO: Phase 2 - Load task definition from configuration files
            print_info "Status: Phase 1 placeholder - task '$task_name' not yet implemented"
            print_info "Available Phase 1 tasks: ask"
            print_info "Other tasks will be implemented in Phase 2 when task definitions are loaded from configuration"
            exit 1
            ;;
    esac
}

# Execute the ask task (Phase 1 implementation)
execute_ask_task() {
    local template_name=""
    local model=""
    local provider=""
    local output_file=""
    local go_flag=false
    local max_tokens=""
    local params=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*)
                template_name="${1#*=}"
                ;;
            --model=*)
                model="${1#*=}"
                ;;
            --provider=*)
                provider="${1#*=}"
                ;;
            --output-file=*)
                output_file="${1#*=}"
                ;;
            --max-tokens=*)
                max_tokens="${1#*=}"
                ;;
            --go)
                go_flag=true
                ;;
            --*=*)
                # Collect custom parameters for template processing
                params+=("$1")
                ;;
            *)
                print_error "Unknown parameter: $1"
                print_info "Usage: run-prompt.sh ask --template=<name> --model=<provider/model> [--param=value] [--go]"
                exit 1
                ;;
        esac
        shift
    done
    
    # Validate required parameters
    if [[ -z "$template_name" ]]; then
        print_error "Template name is required (--template=<name>)"
        exit 1
    fi
    
    if [[ -z "$model" ]]; then
        print_error "Model is required (--model=<provider/model>)"
        exit 1
    fi
    
    print_info "Execute mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
    
    # Load and process template
    print_step "Loading template: $template_name"
    local template_content
    local template_path
    template_path=$(find_template "$template_name")
    template_content=$(load_template "$template_name")
    
    print_step "Processing placeholders"
    local processed_content
    processed_content=$(process_placeholders "$template_content" "${params[@]}")
    
    # Build vibe-tools command
    local vibe_cmd="vibe-tools ask"
    local vibe_args=()
    
    # Parse provider from model if not explicitly set
    if [[ -z "$provider" ]] && [[ "$model" == */* ]]; then
        provider="${model%%/*}"
        model="${model#*/}"
    fi
    
    # Add model and provider
    vibe_args+=("--model=$model")
    [[ -n "$provider" ]] && vibe_args+=("--provider=$provider")
    
    # Add max-tokens if specified
    [[ -n "$max_tokens" ]] && vibe_args+=("--max-tokens=$max_tokens")
    
    # Handle output file - default to timestamped file in output directory
    if [[ -n "$output_file" ]]; then
        # Convert to absolute path if relative
        if [[ "$output_file" != /* ]]; then
            output_file="$(pwd)/$output_file"
        fi
        vibe_args+=("--save-to=$output_file")
    else
        # Default output to ~/.vibe-tools-square/output/ with timestamp
        local timestamp=$(date +%Y-%m-%d_%H%M%S)
        local default_output="$VIBE_TOOLS_SQUARE_HOME/output/${timestamp}_ask_${template_name}.md"
        mkdir -p "$VIBE_TOOLS_SQUARE_HOME/output"
        vibe_args+=("--save-to=$default_output")
        output_file="$default_output"  # Set for later reference
    fi
    
    # Build full command
    local full_command="$vibe_cmd \"$processed_content\" ${vibe_args[*]}"
    
    # Create execution log file
    local log_timestamp=$(date +%Y-%m-%d_%H%M%S)
    local log_file="$VIBE_TOOLS_SQUARE_HOME/output/${log_timestamp}_ask_${template_name}_execution.log"
    
    # Log all execution details
    {
        echo "=== VIBE-TOOLS SQUARE EXECUTION LOG ==="
        echo "Timestamp: $(date)"
        echo "Mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
        echo ""
        echo "=== EXECUTION PLAN DETAILS ==="
        echo "Template: $template_name"
        echo "Template source: $template_path"
        echo "Model: $model"
        [[ -n "$provider" ]] && echo "Provider: $provider" || echo "Provider: (using vibe-tools default)"
        [[ -n "$max_tokens" ]] && echo "Max tokens: $max_tokens" || echo "Max tokens: (using vibe-tools default)"
        echo "Working directory: $(pwd)"
        echo "Output destination: $output_file"
        echo "Parameters: ${#params[@]} custom parameters"
        if [[ ${#params[@]} -gt 0 ]]; then
            echo "Parameter details:"
            for param in "${params[@]}"; do
                if [[ "$param" == --*=file:* ]]; then
                    local param_name="${param%%=*}"
                    local file_path="${param#*=file:}"
                    echo "  $param_name: FILE INJECTION from '$file_path' (resolved from current directory: $(pwd))"
                else
                    echo "  $param"
                fi
            done
        fi
        echo ""
        echo "=== VIBE-TOOLS COMMAND ==="
        # Show the properly escaped command that will actually be executed using legacy technique
        local safe_content_for_log=${processed_content//\'/\'\\\'\'}
        echo "$vibe_cmd '$safe_content_for_log' ${vibe_args[*]}"
        echo ""
        echo "=== PROCESSED TEMPLATE CONTENT ==="
        echo "$processed_content"
        echo ""
    } > "$log_file"
    
    # Show execution plan for both dry run and live execution
    print_info ""
    print_info "=== EXECUTION PLAN DETAILS ==="
    print_info "Template: $template_name (from $template_path)"
    print_info "Model: $model"
    [[ -n "$provider" ]] && print_info "Provider: $provider" || print_info "Provider: (using vibe-tools default)"
    [[ -n "$max_tokens" ]] && print_info "Max tokens: $max_tokens" || print_info "Max tokens: (using vibe-tools default)"
    print_info "Output: $output_file"
    print_info "Execution log: $log_file"
    if [[ ${#params[@]} -gt 0 ]]; then
        print_info "Parameters: ${#params[@]} custom parameters"
        for param in "${params[@]}"; do
            if [[ "$param" == --*=file:* ]]; then
                local param_name="${param%%=*}"
                local file_path="${param#*=file:}"
                print_info "  $param_name: FILE INJECTION from '$file_path'"
            else
                print_info "  $param"
            fi
        done
    fi
    
    if $go_flag; then
        print_step "Executing vibe-tools ask command"
        
        # Log the execution attempt
        echo "=== EXECUTION ATTEMPT ===" >> "$log_file"
        echo "Started at: $(date)" >> "$log_file"
        
        # Escape single quotes correctly for bash using the proven legacy technique
        # Replace each ' with '\''
        local safe_content=${processed_content//\'/\'\\\'\'}
        
        # Build the command string with proper quoting
        local cmd_string="$vibe_cmd '$safe_content' ${vibe_args[*]}"
        
        # Execute the command and capture all output
        local command_output
        command_output=$(eval "$cmd_string" 2>&1)
        local exit_code=$?
        
        # Log the results
        {
            echo "Exit code: $exit_code"
            echo "Command output:"
            echo "$command_output"
            echo "Completed at: $(date)"
        } >> "$log_file"
        
        if [[ $exit_code -eq 0 ]]; then
            print_info "✓ Command executed successfully"
            print_info "✓ Response saved to: $output_file"
            print_info "✓ Execution log saved to: $log_file"
        else
            print_error "✗ Command failed with exit code: $exit_code"
            print_error "✗ Error output:"
            echo "$command_output"
            print_info "✓ Execution log saved to: $log_file"
            exit $exit_code
        fi
    else
        print_info ""
        print_info "🚫 DRY RUN MODE - Command not executed"
        print_info "💡 Use --go flag to actually execute the command"
        print_info "✓ Execution plan logged to: $log_file"
    fi
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
