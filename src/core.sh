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
    
    # Look for task definition - runtime first, then repo assets
    local task_file=""
    local runtime_task_file="$VIBE_TOOLS_SQUARE_HOME/tasks/${task_name}.conf"
    local repo_task_file="$SCRIPT_DIR/assets/.vibe-tools-square/tasks/${task_name}.conf"
    
    if [[ -f "$runtime_task_file" ]]; then
        task_file="$runtime_task_file"
        print_info "Using runtime task config: $task_file"
    elif [[ -f "$repo_task_file" ]]; then
        task_file="$repo_task_file"
        print_info "Using repo task config: $task_file"
    else
        print_error "Task '$task_name' not found in runtime ($VIBE_TOOLS_SQUARE_HOME/tasks/) or repo (assets/.vibe-tools-square/tasks/)"
        print_info "Available tasks:"
        list_available_tasks
        exit 1
    fi
    
    # Source the task configuration
    source "$task_file"
    
    # Parse TASK_DEFAULT_PARAMS if it exists
    local default_params=()
    if [[ -n "${TASK_DEFAULT_PARAMS:-}" ]]; then
        # Simple approach: use eval with array assignment to handle quoted parameters properly
        # This expands command substitutions like $(date ...) and preserves quoted strings
        eval "default_params=($TASK_DEFAULT_PARAMS)"
    fi
    
    # Combine default params with user-provided params
    # User params come after to override defaults
    local all_params=()
    if [[ ${#default_params[@]} -gt 0 ]]; then
        all_params+=("${default_params[@]}")
    fi
    if [[ $# -gt 0 ]]; then
        all_params+=("$@")
    fi
    
    # Handle different task types based on their configuration
    case "$TASK_TYPE" in
        "ask")
            execute_ask_task "${all_params[@]+"${all_params[@]}"}"
            ;;
        "repo")
            execute_repo_task "${all_params[@]+"${all_params[@]}"}"
            ;;
        "plan")
            execute_plan_task "${all_params[@]+"${all_params[@]}"}"
            ;;
        *)
            # Generic task handler - for now just show that the task exists
            print_info "Task '$TASK_NAME' loaded: $TASK_DESCRIPTION"
            print_info "Task type '$TASK_TYPE' not recognized"
            print_info "Supported task types: ask, repo, plan"
            exit 1
            ;;
    esac
}

### ARE THE execute_ask_task, execute_plan_task, execute_repo_task DIFFERENT ENOUGH TO JUSTIFY HAVING 3 COMPLETELY HARDCODED FUNCTIONS ###

# Execute the ask task (Phase 1 implementation)
execute_ask_task() {
    local template_name=""
    local prompt_content=""
    local model=""
    local provider=""
    local output_file=""
    local go_flag=false
    local max_tokens=""
    local params=()
    
    # Set template_name from TASK_TEMPLATE if available
    if [[ -n "${TASK_TEMPLATE:-}" ]]; then
        print_info "Using template from task configuration: $TASK_TEMPLATE"
        template_name="$TASK_TEMPLATE"
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*)
                template_name="${1#*=}"
                ;;
            --prompt=*)
                prompt_content="${1#*=}"
                ;;
            --model=*)
                model="${1#*=}"
                ;;
            --provider=*)
                provider="${1#*=}"
                ;;
            --output-file=*)
                output_file="${1#*=}"
                # Remove surrounding quotes if present
                if [[ $output_file == \"*\" ]]; then
                    output_file="${output_file%\"}"
                    output_file="${output_file#\"}"
                fi
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
                print_info "Usage: run-prompt.sh ask --template=<name> OR --prompt=<text|file:path> --model=<provider/model> [--param=value] [--go]"
                exit 1
                ;;
        esac
        shift
    done
    
    # Validate that either template or prompt is provided, but not both
    if [[ -n "$template_name" && -n "$prompt_content" ]]; then
        print_error "Cannot specify both --template and --prompt. Use one or the other."
        exit 1
    fi
    
    if [[ -z "$template_name" && -z "$prompt_content" ]]; then
        print_error "Either --template=<name> or --prompt=<text|file:path> is required"
        exit 1
    fi
    
    # Use model from task config if not specified in command
    if [[ -z "$model" && -n "${TASK_MODEL:-}" ]]; then
        print_info "Using model from task configuration: $TASK_MODEL"
        model="$TASK_MODEL"
    fi

    # Use provider from task config if not specified in command
    if [[ -z "$provider" && -n "${TASK_PROVIDER:-}" ]]; then
        print_info "Using provider from task configuration: $TASK_PROVIDER"
        provider="$TASK_PROVIDER"
    fi

    if [[ -z "$model" ]]; then
        print_error "Model is required (--model=<model-name> or TASK_MODEL in config)"
        exit 1
    fi
    
    print_info "Execute mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
    
    # Process prompt content (template or direct)
    local processed_content=""
    local content_source=""
    
    if [[ -n "$template_name" ]]; then
        # Template mode - load and process template
        print_step "Loading template: $template_name"
        local template_path
        template_path=$(find_template "$template_name")
        local template_content
        template_content=$(load_template "$template_name")
        content_source="template: $template_name (from $template_path)"
        
        print_step "Processing placeholders"
        processed_content=$(process_placeholders "$template_content" "${params[@]+"${params[@]}"}")
    else
        # Prompt mode - handle direct text or file
        if [[ "$prompt_content" == file:* ]]; then
            # File mode: load content from file
            local file_path="${prompt_content#file:}"
            if [[ ! -f "$file_path" ]]; then
                print_error "Prompt file not found: $file_path"
                exit 1
            fi
            processed_content=$(cat "$file_path")
            content_source="file: $file_path"
            print_step "Loading prompt from file: $file_path"
        else
            # Direct text mode
            processed_content="$prompt_content"
            content_source="direct text"
            print_step "Using direct prompt text"
        fi
        
        # Process placeholders even for direct prompts (in case user includes them)
        if [[ ${#params[@]} -gt 0 ]]; then
            print_step "Processing placeholders in prompt"
            processed_content=$(process_placeholders "$processed_content" "${params[@]+"${params[@]}"}")
        fi
    fi
    
    # Build vibe-tools command
    local vibe_cmd="vibe-tools ask"
    local vibe_args=()
    
    # Resolve provider/model using providers.conf mapping
    if [[ "$model" == */* ]]; then
        # Model contains slash - use the provider mapping system
        local resolved
        if ! resolved=$(resolve_provider_model "$model"); then
            print_error "Provider/model mapping failed for: $model"
            exit 1
        fi
        provider="${resolved%%|*}"
        model="${resolved#*|}"
    elif [[ -n "$provider" ]]; then
        # Separate provider and model specified - try to resolve using provider/model combination
        local combined_model="${provider}/${model}"
        local resolved
        if resolved=$(resolve_provider_model "$combined_model" 2>/dev/null); then
            provider="${resolved%%|*}"
            model="${resolved#*|}"
            print_info "Resolved $provider/$model to provider='$provider' model='$model'"
        else
            # No mapping found - use values as-is
            print_info "No provider mapping found for $provider/$model - using direct values"
        fi
    elif [[ -z "$provider" ]]; then
        # No provider specified, use model as-is
        model="$model"
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
        local task_type="ask"
        if [[ -n "$template_name" ]]; then
            task_type="ask_${template_name}"
        fi
        local default_output="$VIBE_TOOLS_SQUARE_HOME/output/${timestamp}_${task_type}.md"
        mkdir -p "$VIBE_TOOLS_SQUARE_HOME/output"
        vibe_args+=("--save-to=$default_output")
        output_file="$default_output"  # Set for later reference
    fi
    
    # Build full command
    local full_command="$vibe_cmd \"$processed_content\" ${vibe_args[*]}"
    
    # Create execution log file
    local log_timestamp=$(date +%Y-%m-%d_%H%M%S)
    local log_task_type="ask"
    if [[ -n "$template_name" ]]; then
        log_task_type="ask_${template_name}"
    fi
    local log_file="$VIBE_TOOLS_SQUARE_HOME/output/${log_timestamp}_${log_task_type}_execution.log"
    
    # Log all execution details
    {
        echo "=== VIBE-TOOLS SQUARE EXECUTION LOG ==="
        echo "Timestamp: $(date)"
        echo "Mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
        echo ""
        echo "=== EXECUTION PLAN DETAILS ==="
        if [[ -n "$template_name" ]]; then
            echo "Template: $template_name"
            echo "Template source: $template_path"
        else
            echo "Prompt: Direct text input"
        fi
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
        # Quote args for display
        local display_cmd="$vibe_cmd '$safe_content_for_log'"
        for a in "${vibe_args[@]}"; do
            local q=${a//\'/\'\\\'\'}
            display_cmd+=" '${q}'"
        done
        echo "$display_cmd"
        echo ""
        echo "=== PROCESSED TEMPLATE CONTENT ==="
        echo "$processed_content"
        echo ""
    } > "$log_file"
    
    # Show execution plan for both dry run and live execution
    print_info ""
    print_info "=== EXECUTION PLAN DETAILS ==="
    if [[ -n "$template_name" ]]; then
        print_info "Template: $template_name (from $template_path)"
    else
        print_info "Prompt: Direct text input"
    fi
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
        print_step "Executing vibe-tools ask command from runtime content directory"
        
        # Log the execution attempt
        echo "=== EXECUTION ATTEMPT ===" >> "$log_file"
        echo "Started at: $(date)" >> "$log_file"
        
        # Escape single quotes correctly for bash using the proven legacy technique
        # Replace each ' with '\''
        local safe_content=${processed_content//\'/\'\\\'\'}
        
        # Build the command string with proper quoting
        local cmd_string="$display_cmd"
        
        # Execute from ICE content directory for deterministic environment
        local prev_dir="$(pwd)"
        cd "$VIBE_TOOLS_SQUARE_HOME/content"
        local command_output
        command_output=$(eval "$cmd_string" 2>&1)
        local exit_code=$?
        cd "$prev_dir"
        
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
        # Log dry run completion
        {
            echo "=== DRY RUN COMPLETION ==="
            echo "Status: Command prepared but not executed (no --go flag)"
            echo "To execute: Add --go flag to the command"
            echo "Log completed at: $(date)"
        } >> "$log_file"
        
        print_info ""
        print_info "🚫 DRY RUN MODE - Command not executed"
        print_info "💡 Use --go flag to actually execute the command"
        print_info "✓ Execution plan logged to: $log_file"
    fi
}

# Execute the repo task (adds ICE curation and runs from runtime)
execute_repo_task() {
    local template_name=""
    local prompt_text=""
    local model=""
    local provider=""
    local output_file=""
    local go_flag=false
    local max_tokens=""
    local includes=()
    local excludes=()
    local question=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*) template_name="${1#*=}" ;;
            --prompt=*) prompt_text="${1#*=}" ;;
            --model=*) model="${1#*=}" ;;
            --provider=*) provider="${1#*=}" ;;
            --output-file=*) output_file="${1#*=}" ;;
            --max-tokens=*) max_tokens="${1#*=}" ;;
            --include=*) includes+=("${1#*=}") ;;
            --exclude=*) excludes+=("${1#*=}") ;;
            --show-context) show_context; exit 0 ;;
            --go) go_flag=true ;;
            *)
                # First non-flag is the question string if provided as bare arg
                if [[ -z "$question" ]]; then
                    question="$1"
                else
                    print_error "Unknown parameter: $1"
                    exit 1
                fi
                ;;
        esac
        shift
    done
    
    # Check for mutual exclusivity between template and prompt
    if [[ -n "$template_name" && -n "$prompt_text" ]]; then
        print_error "Cannot use both --template and --prompt flags. Use one or the other."
        exit 1
    fi
    
    # Handle prompt input (direct text or file: prefix)
    if [[ -n "$prompt_text" ]]; then
        if [[ "$prompt_text" == file:* ]]; then
            local prompt_file="${prompt_text#file:}"
            if [[ ! -f "$prompt_file" ]]; then
                print_error "Prompt file not found: $prompt_file"
                exit 1
            fi
            question=$(cat "$prompt_file")
        else
            question="$prompt_text"
        fi
    fi
    
    if [[ -z "$question" && -z "$template_name" ]]; then
        print_error "Question text is required (e.g., run-prompt.sh repo \"Explain...\") or use --template/--prompt"
        exit 1
    fi
    
    # Validate that context files are provided for repo analysis
    if [[ ${#includes[@]} -eq 0 ]]; then
        print_error "Repository analysis requires context files. Use --include to specify files/folders to analyze."
        print_info "Examples:"
        print_info "  --include=README.md                 # Analyze just the README"
        print_info "  --include=src                       # Analyze the src/ folder"
        print_info "  --include=README.md --include=src   # Analyze README and src/"
        exit 1
    fi
    
    # Handle template processing if template is specified
    if [[ -n "$template_name" ]]; then
        # Look for template in runtime environment first, then repo assets
        local template_file=""
        if [[ -f "$VIBE_TOOLS_SQUARE_HOME/assets/templates/${template_name}.md" ]]; then
            template_file="$VIBE_TOOLS_SQUARE_HOME/assets/templates/${template_name}.md"
        elif [[ -f "${SCRIPT_DIR}/../assets/templates/${template_name}.md" ]]; then
            template_file="${SCRIPT_DIR}/../assets/templates/${template_name}.md"
        else
            print_error "Template '$template_name' not found"
            exit 1
        fi
        
        # Load and process template
        question=$(cat "$template_file")
        question=$(process_placeholders "$question")
    fi
    
    # Default to free Gemini for testing if not specified
    if [[ -z "$model" ]]; then
        model="gemini/gemini-2-0-flash"
    fi
    
    print_info "Execute mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
    
    # Provider/model resolution
    if [[ "$model" == */* ]]; then
        local resolved
        if ! resolved=$(resolve_provider_model "$model"); then
            # Fallback: pass through provider/model as-is
            provider="${model%%/*}"
            model="${model#*/}"
            print_warning "Provider/model mapping not found. Using pass-through: provider='$provider' model='$model'"
        else
            provider="${resolved%%|*}"
            model="${resolved#*|}"
        fi
    fi
    
    # Prepare ICE using include/exclude
    init_context
    prepare_ice "${includes[@]/#/--include=}" "${excludes[@]/#/--exclude=}"
    
    # Build command
    local vibe_cmd="vibe-tools repo"
    local vibe_args=("$question")
    vibe_args+=("--subdir=public")
    vibe_args+=("--save-to=$(default_output_path repo)")
    [[ -n "$provider" ]] && vibe_args+=("--provider=$provider")
    [[ -n "$model" ]] && vibe_args+=("--model=$model")
    [[ -n "$max_tokens" ]] && vibe_args+=("--max-tokens=$max_tokens")
    
    # Replace save-to if user specified output_file
    if [[ -n "$output_file" ]]; then
        local abs
        abs=$(absolute_path "$output_file")
        for i in "${!vibe_args[@]}"; do
            [[ "${vibe_args[$i]}" == --save-to=* ]] && vibe_args[$i]="--save-to=$abs"
        done
    fi
    
    # Log + dry run / execute
    run_vibe_command_from_runtime "$vibe_cmd" vibe_args $go_flag "repo"
}

# Execute the plan task (supports separate file/thinking models)
execute_plan_task() {
    local question=""
    local template_name=""
    local prompt_text=""
    local file_model=""
    local thinking_model=""
    local file_provider=""
    local thinking_provider=""
    local output_file=""
    local go_flag=false
    local includes=()
    local excludes=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*) template_name="${1#*=}" ;;
            --prompt=*) prompt_text="${1#*=}" ;;
            --file-model=*) file_model="${1#*=}" ;;
            --thinking-model=*) thinking_model="${1#*=}" ;;
            --file-provider=*) file_provider="${1#*=}" ;;
            --thinking-provider=*) thinking_provider="${1#*=}" ;;
            --output-file=*) output_file="${1#*=}" ;;
            --include=*) includes+=("${1#*=}") ;;
            --exclude=*) excludes+=("${1#*=}") ;;
            --show-context) show_context; exit 0 ;;
            --go) go_flag=true ;;
            *)
                if [[ -z "$question" ]]; then
                    question="$1"
                else
                    print_error "Unknown parameter: $1"
                    exit 1
                fi
                ;;
        esac
        shift
    done
    
    # Check for mutual exclusivity between template and prompt
    if [[ -n "$template_name" && -n "$prompt_text" ]]; then
        print_error "Cannot use both --template and --prompt flags. Use one or the other."
        exit 1
    fi
    
    # Handle prompt input (direct text or file: prefix)
    if [[ -n "$prompt_text" ]]; then
        if [[ "$prompt_text" == file:* ]]; then
            local prompt_file="${prompt_text#file:}"
            if [[ ! -f "$prompt_file" ]]; then
                print_error "Prompt file not found: $prompt_file"
                exit 1
            fi
            question=$(cat "$prompt_file")
        else
            question="$prompt_text"
        fi
    fi
    
    if [[ -z "$question" && -z "$template_name" ]]; then
        print_error "Question text is required (e.g., run-prompt.sh plan \"Add auth...\") or use --template/--prompt"
        exit 1
    fi
    
    # Validate that context files are provided for planning
    if [[ ${#includes[@]} -eq 0 ]]; then
        print_error "Planning requires context files. Use --include to specify files/folders to base the plan on."
        print_info "Examples:"
        print_info "  --include=README.md                 # Plan based on project overview"
        print_info "  --include=src                       # Plan based on existing code"
        print_info "  --include=README.md --include=src   # Plan with full context"
        exit 1
    fi
    
    # Handle template processing if template is specified
    if [[ -n "$template_name" ]]; then
        # Look for template in runtime environment first, then repo assets
        local template_file=""
        if [[ -f "$VIBE_TOOLS_SQUARE_HOME/assets/templates/${template_name}.md" ]]; then
            template_file="$VIBE_TOOLS_SQUARE_HOME/assets/templates/${template_name}.md"
        elif [[ -f "${SCRIPT_DIR}/../assets/templates/${template_name}.md" ]]; then
            template_file="${SCRIPT_DIR}/../assets/templates/${template_name}.md"
        else
            print_error "Template '$template_name' not found"
            exit 1
        fi
        
        # Load and process template
        question=$(cat "$template_file")
        question=$(process_placeholders "$question")
    fi
    # Default to free Gemini for testing if not specified
    if [[ -z "$file_model" ]]; then file_model="gemini/gemini-2-0-flash"; fi
    if [[ -z "$thinking_model" ]]; then thinking_model="gemini/gemini-2-0-flash"; fi
    
    # Resolve models
    if [[ "$file_model" == */* ]]; then
        local resolved
        if ! resolved=$(resolve_provider_model "$file_model"); then
            file_provider="${file_model%%/*}"; file_model="${file_model#*/}"
            print_warning "File provider/model mapping not found. Using pass-through: provider='$file_provider' model='$file_model'"
        else
            file_provider="${resolved%%|*}"; file_model="${resolved#*|}"
        fi
    fi
    if [[ "$thinking_model" == */* ]]; then
        local resolved2
        if ! resolved2=$(resolve_provider_model "$thinking_model"); then
            thinking_provider="${thinking_model%%/*}"; thinking_model="${thinking_model#*/}"
            print_warning "Thinking provider/model mapping not found. Using pass-through: provider='$thinking_provider' model='$thinking_model'"
        else
            thinking_provider="${resolved2%%|*}"; thinking_model="${resolved2#*|}"
        fi
    fi
    
    init_context
    prepare_ice "${includes[@]/#/--include=}" "${excludes[@]/#/--exclude=}"
    
    local vibe_cmd="vibe-tools plan"
    local vibe_args=("$question")
    vibe_args+=("--subdir=public")
    vibe_args+=("--save-to=$(default_output_path plan)")
    [[ -n "$file_provider" ]] && vibe_args+=("--fileProvider=$file_provider")
    [[ -n "$thinking_provider" ]] && vibe_args+=("--thinkingProvider=$thinking_provider")
    [[ -n "$file_model" ]] && vibe_args+=("--fileModel=$file_model")
    [[ -n "$thinking_model" ]] && vibe_args+=("--thinkingModel=$thinking_model")
    
    if [[ -n "$output_file" ]]; then
        local abs
        abs=$(absolute_path "$output_file")
        for i in "${!vibe_args[@]}"; do
            [[ "${vibe_args[$i]}" == --save-to=* ]] && vibe_args[$i]="--save-to=$abs"
        done
    fi
    
    run_vibe_command_from_runtime "$vibe_cmd" vibe_args $go_flag "plan"
}

# Helpers used by repo/plan
default_output_path() {
    local kind="$1" # ask|repo|plan
    local ts=$(date +%Y-%m-%d_%H%M%S)
    mkdir -p "$VIBE_TOOLS_SQUARE_HOME/output"
    echo "$VIBE_TOOLS_SQUARE_HOME/output/${ts}_${kind}.md"
}

absolute_path() {
    local p="$1"
    if [[ "$p" != /* ]]; then
        echo "$(pwd)/$p"
    else
        echo "$p"
    fi
}

run_vibe_command_from_runtime() {
    local cmd="$1"; shift
    # Bash 3 compatible: copy the referenced array into a local array
    local ref_name="$1"; shift
    eval "local args_ref=( \"\${${ref_name}[@]}\" )"
    local go_flag=$1; shift
    local kind="$1"; shift || true
    
    local log_timestamp=$(date +%Y-%m-%d_%H%M%S)
    local log_file="$VIBE_TOOLS_SQUARE_HOME/output/${log_timestamp}_${kind}_execution.log"
    # Build safely quoted command string
    local quoted_cmd="$cmd"
    local arg
    for arg in "${args_ref[@]}"; do
        # Single-quote each arg, safely escaping inner single quotes
        local safe=${arg//\'/\'\\\'\'}
        quoted_cmd+=" '${safe}'"
    done

    print_info "=== VIBE-TOOLS COMMAND ==="
    print_info "$quoted_cmd"
    print_info "Working directory (runtime): $VIBE_TOOLS_SQUARE_HOME/content"
    print_info "Execution log: $log_file"
    
    {
        print_info "=== VIBE-TOOLS SQUARE EXECUTION LOG ==="
        print_info "Timestamp: $(date)"
        print_info "Mode: $(if $go_flag; then echo EXECUTE; else echo DRY RUN; fi)"
        print_info "Command: $quoted_cmd"
        print_info "Runtime: $VIBE_TOOLS_SQUARE_HOME/content"
    } > "$log_file"
    
    if $go_flag; then
        local prev_dir="$(pwd)"
        cd "$VIBE_TOOLS_SQUARE_HOME/content"
        local output
        output=$(eval "$quoted_cmd" 2>&1)
        local code=$?
        cd "$prev_dir"
        {
            echo "Exit code: $code"
            echo "Output:"; echo "$output"
        } >> "$log_file"
        if [[ $code -ne 0 ]]; then
            print_error "Command failed ($code)"
            echo "$output"
            exit $code
        fi
        print_success "Command executed"
    else
        print_info "🚫 DRY RUN MODE - Command not executed"
        print_info "💡 Use --go to execute"
    fi
}

# List available tasks (brief for usage display)
list_available_tasks() {
    local runtime_tasks_dir="$VIBE_TOOLS_SQUARE_HOME/tasks"
    local repo_tasks_dir="$SCRIPT_DIR/assets/.vibe-tools-square/tasks"
    
    # Track seen tasks to avoid duplicates (runtime takes precedence)
    local seen_tasks=""
    
    # Runtime tasks first
    if [[ -d "$runtime_tasks_dir" ]]; then
        for task_file in "$runtime_tasks_dir"/*.conf; do
            if [[ -f "$task_file" ]]; then
                source "$task_file"
                printf "  %-20s %s\n" "$TASK_NAME" "$TASK_DESCRIPTION"
                seen_tasks="$seen_tasks $TASK_NAME "
            fi
        done
    fi
    
    # Repo tasks (only if not already seen)
    if [[ -d "$repo_tasks_dir" ]]; then
        for task_file in "$repo_tasks_dir"/*.conf; do
            if [[ -f "$task_file" ]]; then
                source "$task_file"
                # Check if we've already seen this task name
                if [[ "$seen_tasks" != *" $TASK_NAME "* ]]; then
                    printf "  %-20s %s\n" "$TASK_NAME" "$TASK_DESCRIPTION"
                fi
            fi
        done
    fi
    
    if [[ ! -d "$runtime_tasks_dir" && ! -d "$repo_tasks_dir" ]]; then
        print_warning "No task directories found"
        print_info "Runtime: $runtime_tasks_dir"
        print_info "Repo: $repo_tasks_dir"
    fi
}

list_available_tasks_detailed() {
    print_info "Available Tasks:"
    print_info ""
    
    local runtime_tasks_dir="$VIBE_TOOLS_SQUARE_HOME/tasks"
    local repo_tasks_dir="$SCRIPT_DIR/assets/.vibe-tools-square/tasks"
    
    # Track seen tasks to avoid duplicates (runtime takes precedence)
    local seen_tasks=""
    
    # Runtime tasks first
    if [[ -d "$runtime_tasks_dir" ]]; then
        for task_file in "$runtime_tasks_dir"/*.conf; do
            if [[ -f "$task_file" ]]; then
                source "$task_file"
                printf "  %-20s %s\n" "$TASK_NAME" "$TASK_DESCRIPTION"
                seen_tasks="$seen_tasks $TASK_NAME "
            fi
        done
    fi
    
    # Repo tasks (only if not already seen)
    if [[ -d "$repo_tasks_dir" ]]; then
        for task_file in "$repo_tasks_dir"/*.conf; do
            if [[ -f "$task_file" ]]; then
                source "$task_file"
                # Check if we've already seen this task name
                if [[ "$seen_tasks" != *" $TASK_NAME "* ]]; then
                    printf "  %-20s %s\n" "$TASK_NAME" "$TASK_DESCRIPTION"
                fi
            fi
        done
    fi
    
    if [[ ! -d "$runtime_tasks_dir" && ! -d "$repo_tasks_dir" ]]; then
        print_warning "No task directories found"
        print_info "Runtime: $runtime_tasks_dir"
        print_info "Repo: $repo_tasks_dir"
    fi
    
    print_info ""
    print_info "Usage: run-prompt.sh <task-name> [options]"
    print_info "Example: run-prompt.sh analyze-codebase --template=analysis --include=src"
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
    --model=<provider/model>   Model for ask/repo (e.g., gemini/gemini-2-0-flash)
    --file-model=<provider/model>      Model for file analysis (plan only)
    --thinking-model=<provider/model>  Model for plan generation (plan only)
  --include=<pattern>     Include files/dirs in context (for tasks using repo/plan)
  --exclude=<pattern>     Exclude files/dirs from context (for tasks using repo/plan)
  --show-context          Show what files are currently in the curated context
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
