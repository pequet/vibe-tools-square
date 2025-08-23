#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Author: Benjamin Pequet
# Purpose: Main orchestration logic that coordinates all system modules and handles task execution.
# Project: https://github.com/pequet/vibe-tools-square/ 
# Refer to main project for detailed docs.

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
    
    # Handle help flags
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    # Handle context display flag
    if [[ "${1:-}" == "--show-context" ]]; then
        show_context
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

# *
# * Helper Functions for Task Execution
# *

# Parse parameters for ask task - sets global PARSED_* variables
parse_ask_task_parameters() {
    local task_template="$1"
    shift
    
    # Initialize parsed values
    PARSED_TEMPLATE_NAME=""
    PARSED_PROMPT_CONTENT=""
    PARSED_MODEL=""
    PARSED_PROVIDER=""
    PARSED_OUTPUT_FILE=""
    PARSED_GO_FLAG=false
    PARSED_MAX_TOKENS=""
    PARSED_PARAMS=()
    
    # Set template_name from TASK_TEMPLATE if available
    if [[ -n "$task_template" ]]; then
        print_info "Using template from task configuration: $task_template"
        PARSED_TEMPLATE_NAME="$task_template"
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*)
                PARSED_TEMPLATE_NAME="${1#*=}"
                ;;
            --prompt=*)
                PARSED_PROMPT_CONTENT="${1#*=}"
                ;;
            --model=*)
                PARSED_MODEL="${1#*=}"
                ;;
            --provider=*)
                PARSED_PROVIDER="${1#*=}"
                ;;
            --output-file=*)
                PARSED_OUTPUT_FILE="${1#*=}"
                # Remove surrounding quotes if present
                if [[ $PARSED_OUTPUT_FILE == \"*\" ]]; then
                    PARSED_OUTPUT_FILE="${PARSED_OUTPUT_FILE%\"}"
                    PARSED_OUTPUT_FILE="${PARSED_OUTPUT_FILE#\"}"
                fi
                ;;
            --max-tokens=*)
                PARSED_MAX_TOKENS="${1#*=}"
                ;;
            --go)
                PARSED_GO_FLAG=true
                ;;
            --*=*)
                # Collect custom parameters for template processing
                PARSED_PARAMS+=("$1")
                ;;
            *)
                print_error "Unknown parameter: $1"
                print_info "Usage: run-prompt.sh ask --template=<name> OR --prompt=<text|file:path> --model=<provider/model> [--param=value] [--go]"
            exit 1
            ;;
    esac
        shift
    done
}

# Parse parameters for repo task - extends ask task parameters with repo-specific ones
parse_repo_task_parameters() {
    local task_template="$1"
    shift
    
    # Initialize all parsed values (ask task ones + repo-specific ones)
    PARSED_TEMPLATE_NAME=""
    PARSED_PROMPT_CONTENT=""
    PARSED_MODEL=""
    PARSED_PROVIDER=""
    PARSED_OUTPUT_FILE=""
    PARSED_GO_FLAG=false
    PARSED_MAX_TOKENS=""
    PARSED_PARAMS=()
    PARSED_INCLUDES=()
    PARSED_EXCLUDES=()
    PARSED_QUESTION=""
    
    # Set template_name from TASK_TEMPLATE if available
    if [[ -n "$task_template" ]]; then
        print_info "Using template from task configuration: $task_template"
        PARSED_TEMPLATE_NAME="$task_template"
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*)
                PARSED_TEMPLATE_NAME="${1#*=}"
                ;;
            --prompt=*)
                PARSED_PROMPT_CONTENT="${1#*=}"
                ;;
            --model=*)
                PARSED_MODEL="${1#*=}"
                ;;
            --provider=*)
                PARSED_PROVIDER="${1#*=}"
                ;;
            --output-file=*)
                PARSED_OUTPUT_FILE="${1#*=}"
                # Remove surrounding quotes if present
                if [[ $PARSED_OUTPUT_FILE == \"*\" ]]; then
                    PARSED_OUTPUT_FILE="${PARSED_OUTPUT_FILE%\"}"
                    PARSED_OUTPUT_FILE="${PARSED_OUTPUT_FILE#\"}"
                fi
                ;;
            --max-tokens=*)
                PARSED_MAX_TOKENS="${1#*=}"
                ;;
            --include=*)
                PARSED_INCLUDES+=("${1#*=}")
                ;;
            --exclude=*)
                PARSED_EXCLUDES+=("${1#*=}")
                ;;
            --show-context)
                show_context
                exit 0
                ;;
            --go)
                PARSED_GO_FLAG=true
                ;;
            --*=*)
                # Collect custom parameters for template processing
                PARSED_PARAMS+=("$1")
                ;;
            *)
                # First non-flag is the question string if provided as bare arg
                if [[ -z "$PARSED_QUESTION" ]]; then
                    PARSED_QUESTION="$1"
                else
                print_error "Unknown parameter: $1"
                    print_info "Usage: run-prompt.sh repo --prompt=<text|file:path> --include=<files> [--param=value] [--go]"
            exit 1
                fi
            ;;
    esac
        shift
    done
}

# Parse parameters for plan task - extends repo task parameters with dual model/provider support
parse_plan_task_parameters() {
    local task_template="$1"
    shift
    
    # Initialize all parsed values (repo task ones + plan-specific dual models)
    PARSED_TEMPLATE_NAME=""
    PARSED_PROMPT_CONTENT=""
    PARSED_FILE_MODEL=""
    PARSED_THINKING_MODEL=""
    PARSED_FILE_PROVIDER=""
    PARSED_THINKING_PROVIDER=""
    PARSED_OUTPUT_FILE=""
    PARSED_GO_FLAG=false
    PARSED_PARAMS=()
    PARSED_INCLUDES=()
    PARSED_EXCLUDES=()
    PARSED_QUESTION=""
    
    # Set template_name from TASK_TEMPLATE if available
    if [[ -n "$task_template" ]]; then
        print_info "Using template from task configuration: $task_template"
        PARSED_TEMPLATE_NAME="$task_template"
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*)
                PARSED_TEMPLATE_NAME="${1#*=}"
                ;;
            --prompt=*)
                PARSED_PROMPT_CONTENT="${1#*=}"
                ;;
            --file-model=*)
                PARSED_FILE_MODEL="${1#*=}"
                ;;
            --thinking-model=*)
                PARSED_THINKING_MODEL="${1#*=}"
                ;;
            --file-provider=*)
                PARSED_FILE_PROVIDER="${1#*=}"
                ;;
            --thinking-provider=*)
                PARSED_THINKING_PROVIDER="${1#*=}"
                ;;
            --output-file=*)
                PARSED_OUTPUT_FILE="${1#*=}"
                # Remove surrounding quotes if present
                if [[ $PARSED_OUTPUT_FILE == \"*\" ]]; then
                    PARSED_OUTPUT_FILE="${PARSED_OUTPUT_FILE%\"}"
                    PARSED_OUTPUT_FILE="${PARSED_OUTPUT_FILE#\"}"
                fi
                ;;
            --include=*)
                PARSED_INCLUDES+=("${1#*=}")
                ;;
            --exclude=*)
                PARSED_EXCLUDES+=("${1#*=}")
                ;;
            --show-context)
                show_context
                exit 0
                ;;
            --go)
                PARSED_GO_FLAG=true
                ;;
            --*=*)
                # Collect custom parameters for template processing
                PARSED_PARAMS+=("$1")
                ;;
            *)
                # First non-flag is the question string if provided as bare arg
                if [[ -z "$PARSED_QUESTION" ]]; then
                    PARSED_QUESTION="$1"
                else
                print_error "Unknown parameter: $1"
                    print_info "Usage: run-prompt.sh plan --prompt=<text|file:path> --include=<files> [--param=value] [--go]"
                exit 1
                fi
                ;;
        esac
        shift
    done
}

# Validate task inputs and apply config defaults
validate_task_inputs() {
    local template_name="$1"
    local prompt_content="$2"
    local model="$3"
    local provider="$4"
    
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
    
    # Return the potentially updated model and provider values via global variables
    VALIDATED_MODEL="$model"
    VALIDATED_PROVIDER="$provider"
}

# Validate repo task inputs and apply config defaults (extends ask task validation)
validate_repo_task_inputs() {
    local template_name="$1"
    local prompt_content="$2"  # This maps to prompt_text in repo task
    local model="$3"
    local provider="$4"
    local question="$5"
    shift 5
    local includes=("$@")
    
    # Use the standard ask task validation for common logic
    validate_task_inputs "$template_name" "$prompt_content" "$model" "$provider"
    
    # Use the validated model and provider from the ask validation
    model="$VALIDATED_MODEL"
    provider="$VALIDATED_PROVIDER"
    
    # Additional validation for repo task: handle prompt input conversion to question
    if [[ -n "$prompt_content" ]]; then
        if [[ "$prompt_content" == file:* ]]; then
            local prompt_file="${prompt_content#file:}"
            if [[ ! -f "$prompt_file" ]]; then
                print_error "Prompt file not found: $prompt_file"
                exit 1
            fi
            question=$(cat "$prompt_file")
        else
            question="$prompt_content"
        fi
    fi
    
    # Validate that we have a question (either from prompt or template will be processed later)
    if [[ -z "$question" && -z "$template_name" ]]; then
        print_error "Question text is required (e.g., run-prompt.sh repo \"Explain...\") or use --template/--prompt"
        exit 1
    fi
    
    # Repo-specific validation: context files are required
    if [[ ${#includes[@]} -eq 0 ]]; then
        print_error "Repository analysis requires context files. Use --include to specify files/folders to analyze."
        print_info "Examples:"
        print_info "  --include=README.md                 # Analyze just the README"
        print_info "  --include=src                       # Analyze the src/ folder"
        print_info "  --include=README.md --include=src   # Analyze README and src/"
        exit 1
    fi
    
    # Return validated values via global variables
    VALIDATED_MODEL="$model"
    VALIDATED_PROVIDER="$provider"
    VALIDATED_QUESTION="$question"
}

# Validate plan task inputs and apply config defaults (extends repo task validation with dual models)
validate_plan_task_inputs() {
    local template_name="$1"
    local prompt_content="$2"  # This maps to prompt_text in plan task
    local file_model="$3"
    local thinking_model="$4"
    local file_provider="$5"
    local thinking_provider="$6"
    local question="$7"
    shift 7
    local includes=("$@")
    
    # Handle prompt input conversion to question (same as repo task)
    if [[ -n "$prompt_content" ]]; then
        if [[ "$prompt_content" == file:* ]]; then
            local prompt_file="${prompt_content#file:}"
            if [[ ! -f "$prompt_file" ]]; then
                print_error "Prompt file not found: $prompt_file"
                exit 1
            fi
            question=$(cat "$prompt_file")
        else
            question="$prompt_content"
        fi
    fi
    
    # Validate that we have a question (either from prompt or template will be processed later)
    if [[ -z "$question" && -z "$template_name" ]]; then
        print_error "Question text is required (e.g., run-prompt.sh plan \"Add auth...\") or use --template/--prompt"
        exit 1
    fi
    
    # Plan-specific validation: context files are required
    if [[ ${#includes[@]} -eq 0 ]]; then
        print_error "Planning requires context files. Use --include to specify files/folders to base the plan on."
        print_info "Examples:"
        print_info "  --include=README.md                 # Plan based on project overview"
        print_info "  --include=src                       # Plan based on existing code"
        print_info "  --include=README.md --include=src   # Plan with full context"
        exit 1
    fi
    
    # Return validated values via global variables
    VALIDATED_FILE_MODEL="$file_model"
    VALIDATED_THINKING_MODEL="$thinking_model"
    VALIDATED_FILE_PROVIDER="$file_provider"
    VALIDATED_THINKING_PROVIDER="$thinking_provider"
    VALIDATED_QUESTION="$question"
}

# Find template file in runtime and repo locations
find_template_file() {
    local template_name="$1"
    local extension="${2:-txt}"  # Default to .txt for ask tasks, can specify .md for repo tasks
    
    # Find template file in search paths (runtime first, then repo)
        local template_path=""
    local search_paths=()
    
    if [[ "$extension" == "txt" ]]; then
        # Ask task template search paths
        search_paths=(
            "$VIBE_TOOLS_SQUARE_HOME/config/templates/$template_name.txt"
            "$VIBE_TOOLS_SQUARE_HOME/config/templates/$template_name/template.txt"
            "$(pwd)/assets/.vibe-tools-square/config/templates/$template_name.txt"
            "$(pwd)/assets/.vibe-tools-square/config/templates/$template_name/template.txt"
        )
    elif [[ "$extension" == "md" ]]; then
        # Repo/Plan task template search paths (same as txt templates)
        search_paths=(
            "$VIBE_TOOLS_SQUARE_HOME/config/templates/$template_name.txt"
            "$VIBE_TOOLS_SQUARE_HOME/config/templates/$template_name/template.txt"
            "$(pwd)/assets/.vibe-tools-square/config/templates/$template_name.txt"
            "$(pwd)/assets/.vibe-tools-square/config/templates/$template_name/template.txt"
        )
    fi
        
        for path in "${search_paths[@]}"; do
            if [[ -f "$path" ]]; then
                template_path="$path"
                break
            fi
        done
        
        if [[ ! -f "$template_path" ]]; then
            print_error "Template not found: $template_name"
            exit 1
        fi
        
    # Return the found template path via global variable
    FOUND_TEMPLATE_PATH="$template_path"
}

# Load and process content (template or direct prompt)
load_and_process_content() {
    local template_name="$1"
    local prompt_content="$2"
    shift 2
    local params=("$@")
    
    local processed_content=""
    local content_source=""
    
    if [[ -n "$template_name" ]]; then
        # Template mode - load and process template
        print_step "Loading template: $template_name"
        
        # Find template file using helper function
        find_template_file "$template_name"
        local template_path="$FOUND_TEMPLATE_PATH"
        
        # Load template content
        local template_content
        template_content=$(cat "$template_path")
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
    
    # Return values via global variables
    PROCESSED_CONTENT="$processed_content"
    CONTENT_SOURCE="$content_source"
}

# Resolve provider and model using mapping system
resolve_task_model() {
    local model="$1"
    local provider="$2"
    
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
            print_error "Provider/model mapping failed for: $provider/$model"
            print_error "See the list of available aliases in providers.conf."
            print_error "Use format: --model=provider_alias/model_alias (e.g., --model=gemini/free)"
            exit 1
        fi
    elif [[ -z "$provider" ]]; then
        # No provider specified, use model as-is
        model="$model"
    fi
    
    # Return resolved values via global variables
    RESOLVED_MODEL="$model"
    RESOLVED_PROVIDER="$provider"
}

# Resolve dual models for plan task (file and thinking)
resolve_plan_task_models() {
    local file_model="$1"
    local file_provider="$2"
    local thinking_model="$3"
    local thinking_provider="$4"
    
    # Default models if not specified
    [[ -z "$file_model" ]] && file_model="gemini/gemini-2-0-flash"
    [[ -z "$thinking_model" ]] && thinking_model="gemini/gemini-2-0-flash"
    
    # Convert bare model names to provider/model format for resolution
    [[ "$file_model" != */* && -n "$file_provider" ]] && file_model="$file_provider/$file_model"
    [[ "$file_model" != */* && -z "$file_provider" ]] && file_model="gemini/$file_model"
    [[ "$thinking_model" != */* && -n "$thinking_provider" ]] && thinking_model="$thinking_provider/$thinking_model"
    [[ "$thinking_model" != */* && -z "$thinking_provider" ]] && thinking_model="gemini/$thinking_model"
    
    # Resolve file model
    if [[ "$file_model" == */* ]]; then
        local resolved
        if ! resolved=$(resolve_provider_model "$file_model"); then
            print_error "File model/provider mapping failed for: $file_model"
            print_error "Available aliases in providers.conf: anthropic/claude-3-5-sonnet, gemini/gemini-2-0-flash, openai/o3-mini, etc."
            exit 1
        fi
        file_provider="${resolved%%|*}"
        file_model="${resolved#*|}"
        print_info "Resolved file model $1 to provider='$file_provider' model='$file_model'"
    fi
    
    # Resolve thinking model
    if [[ "$thinking_model" == */* ]]; then
        local resolved2
        if ! resolved2=$(resolve_provider_model "$thinking_model"); then
            print_error "Thinking model/provider mapping failed for: $thinking_model"
            print_error "Available aliases in providers.conf: anthropic/claude-3-5-sonnet, gemini/gemini-2-0-flash, openai/o3-mini, etc."
            exit 1
        fi
        thinking_provider="${resolved2%%|*}"
        thinking_model="${resolved2#*|}"
        print_info "Resolved thinking model $3 to provider='$thinking_provider' model='$thinking_model'"
    fi
    
    # Return resolved values via global variables
    RESOLVED_FILE_MODEL="$file_model"
    RESOLVED_FILE_PROVIDER="$file_provider"
    RESOLVED_THINKING_MODEL="$thinking_model"
    RESOLVED_THINKING_PROVIDER="$thinking_provider"
}

# Build vibe-tools command arguments and handle output file setup
build_vibe_command_args() {
    local vibe_cmd="$1"
    local model="$2"
    local provider="$3"
    local max_tokens="$4"
    local go_flag="$5"
    local output_file="$6"
    local template_name="$7"
    
    local vibe_args=()
    
    # Add model and provider
    vibe_args+=("--model=$model")
    [[ -n "$provider" ]] && vibe_args+=("--provider=$provider")
    
    # Add max-tokens if specified
    [[ -n "$max_tokens" ]] && vibe_args+=("--max-tokens=$max_tokens")
    
    # Add task-specific arguments
    if [[ "$vibe_cmd" == "repo" ]]; then
        print_info "DEBUG: Analyzing entire content directory (no --subdir)"
    elif [[ "$vibe_cmd" == "plan" ]]; then
        print_info "DEBUG: Plan analyzing entire content directory (no --subdir)"
        # Plan task uses dual models via additional parameters passed after basic ones
        # These will be added by the caller: --fileProvider, --thinkingProvider, --fileModel, --thinkingModel
    fi
    
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
        local task_type=""
        
        # Determine task type based on template and TASK_OUTPUT_PREFIX
        if [[ -n "$template_name" && "$template_name" != "repo-prompt" && "$template_name" != "plan-prompt" ]]; then
            # Template-based task: use TASK_OUTPUT_PREFIX if available, otherwise template name
            if [[ -n "${TASK_OUTPUT_PREFIX:-}" ]]; then
                task_type="$TASK_OUTPUT_PREFIX"
            else
                task_type="$template_name"
            fi
        else
            # Basic task: use [task]_prompt pattern - extract task name from vibe_cmd
            local basic_task="${vibe_cmd##* }"  # Extract last word (e.g., "ask" from "vibe-tools ask")
            task_type="${basic_task}_prompt"
        fi
        
        local default_output="$VIBE_TOOLS_SQUARE_HOME/output/${timestamp}_${task_type}.md"
        ensure_output_directory
        vibe_args+=("--save-to=$default_output")
        output_file="$default_output"  # Set for later reference
    fi
    
    # Return values via global variables
    BUILT_VIBE_ARGS=("${vibe_args[@]}")
    FINAL_OUTPUT_FILE="$output_file"
}

# Build vibe-tools plan command arguments (specialized for dual model system)
build_plan_command_args() {
    local file_model="$1"
    local file_provider="$2"
    local thinking_model="$3"
    local thinking_provider="$4"
    local output_file="$5"
    
    # Build plan-specific vibe-tools arguments
    local vibe_args=()
    print_info "DEBUG: Plan analyzing entire content directory (no --subdir)"
    
    # Add dual model arguments
    [[ -n "$file_provider" ]] && vibe_args+=("--fileProvider=$file_provider")
    [[ -n "$thinking_provider" ]] && vibe_args+=("--thinkingProvider=$thinking_provider")
    [[ -n "$file_model" ]] && vibe_args+=("--fileModel=$file_model")
    [[ -n "$thinking_model" ]] && vibe_args+=("--thinkingModel=$thinking_model")
        
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
        local task_type=""
        
        # Determine task type - for plan, check if we have TASK_OUTPUT_PREFIX (template-based) or not (basic)
        if [[ -n "${TASK_OUTPUT_PREFIX:-}" ]]; then
            task_type="$TASK_OUTPUT_PREFIX"
        else
            task_type="plan_prompt"
        fi
        
        local default_output="$VIBE_TOOLS_SQUARE_HOME/output/${timestamp}_${task_type}.md"
        ensure_output_directory
        vibe_args+=("--save-to=$default_output")
        output_file="$default_output"  # Set for later reference
    fi
    
    # Return values via global variables
    BUILT_PLAN_ARGS=("${vibe_args[@]}")
    FINAL_PLAN_OUTPUT_FILE="$output_file"
}

# Create comprehensive execution log
create_execution_log() {
    local template_name="$1"
    local content_source="$2"
    local model="$3"
    local provider="$4"
    local max_tokens="$5"
    local output_file="$6"
    local go_flag="$7"
    local processed_content="$8"
    local vibe_cmd="$9"
    local ice_context_info="${10:-}"  # Optional ICE context info
    shift 10
    local params=("$@")
    local vibe_args=("${BUILT_VIBE_ARGS[@]}")  # Use the global from build_vibe_command_args
    
    # Create execution log file
    local log_timestamp=$(date +%Y-%m-%d_%H%M%S)
    local log_task_type=""
    
    # Determine log task type based on template and TASK_OUTPUT_PREFIX
    if [[ -n "$template_name" && "$template_name" != "repo-prompt" && "$template_name" != "plan-prompt" ]]; then
        # Template-based task: use TASK_OUTPUT_PREFIX if available, otherwise template name
        if [[ -n "${TASK_OUTPUT_PREFIX:-}" ]]; then
            log_task_type="$TASK_OUTPUT_PREFIX"
        else
            log_task_type="$template_name"
        fi
    else
        # Basic task: use [task]_prompt pattern - extract task name from vibe command
        local basic_task="${vibe_cmd##* }"  # Extract last word (e.g., "ask" from "vibe-tools ask")
        log_task_type="${basic_task}_prompt"
    fi
    local log_file="$VIBE_TOOLS_SQUARE_HOME/output/${log_timestamp}_${log_task_type}_execution.log"
    
    # Ensure output directory exists before writing
    ensure_output_directory
    
    # Log all execution details
    {
        echo "=== VIBE-TOOLS SQUARE EXECUTION LOG ==="
        echo "Timestamp: $(date)"
        echo "Mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
        echo ""
        echo "=== ORIGINAL COMMAND ==="
        echo "Command: ${ORIGINAL_COMMAND_LINE:-./run-prompt.sh [parameters not captured]}"
        echo ""
        echo "=== EXECUTION PLAN DETAILS ==="
        if [[ -n "$template_name" ]]; then
            echo "Template: $template_name"
            echo "Content source: $content_source"
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
        # Build clean display command without excessive quoting
        local display_cmd="$vibe_cmd '$safe_content_for_log'"
        for a in "${vibe_args[@]}"; do
            # Only add quotes if the argument contains spaces or special characters
            if [[ "$a" == *" "* ]] || [[ "$a" == *"'"* ]]; then
                local q=${a//\'/\'\\\'\'}
                display_cmd+=" '${q}'"
            else
                display_cmd+=" ${a}"
            fi
        done
        echo "$display_cmd"
        echo ""
        
        # Add ICE context information for repo and plan tasks
        if [[ -n "$ice_context_info" ]]; then
            echo "=== CONTEXT FILES ==="
            echo "$ice_context_info"
            echo ""
        fi
        
        echo "=== PROCESSED TEMPLATE CONTENT ==="
        echo "$processed_content"
        echo ""
    } > "$log_file"
    
    # Return log file path via global variable
    EXECUTION_LOG_FILE="$log_file"
}

# Execute vibe-tools command (or dry run)
execute_vibe_command() {
    local go_flag="$1"
    local processed_content="$2"
    local vibe_cmd="$3"
    local output_file="$4"
    local log_file="$5"
    local vibe_args=("${BUILT_VIBE_ARGS[@]}")  # Use the global from build_vibe_command_args
    
    if $go_flag; then
        print_step "Executing $vibe_cmd command from runtime content directory"
        
        # Log the execution attempt
        echo "=== EXECUTION ATTEMPT ===" >> "$log_file"
        echo "Started at: $(date)" >> "$log_file"
        
        # DEBUG: Log working directory BEFORE cd
        echo "Working directory before cd: $(pwd)" >> "$log_file"
        
        # Escape single quotes correctly for bash using the proven legacy technique
        # Replace each ' with '\''
        local safe_content=${processed_content//\'/\'\\\'\'}
        
        # Build the execution command string properly (separate from display)
        local exec_cmd="$vibe_cmd '$safe_content'"
        for a in "${vibe_args[@]}"; do
            local escaped_arg=${a//\'/\'\\\'\'}
            exec_cmd+=" '$escaped_arg'"
        done
        
        # DEBUG: Log the exact command being executed
        echo "=== EXACT VIBE-TOOLS EXECUTION COMMAND ===" >> "$log_file"
        echo "Command: $exec_cmd" >> "$log_file"
        echo "Arguments breakdown:" >> "$log_file"
        for a in "${vibe_args[@]}"; do
            echo "  $a" >> "$log_file"
        done
        echo "" >> "$log_file"
        
        # Execute from ICE content directory for deterministic environment
        local prev_dir="$(pwd)"
        cd "$VIBE_TOOLS_SQUARE_HOME/content"
        
        # DEBUG: Log actual execution directory
        echo "ACTUAL vibe-tools execution directory: $(pwd)" >> "$log_file"
        echo "" >> "$log_file"
        
        local command_output
        command_output=$(eval "$exec_cmd" 2>&1)
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
    
    # Collect PARAM_* variables and build parameters from them
    local collected_params=""
    local param_vars_raw
    param_vars_raw=$(compgen -v | grep "^PARAM_" 2>/dev/null || true)
    
    if [[ -n "$param_vars_raw" ]]; then
        local param_vars=($param_vars_raw)
        for param_var in "${param_vars[@]}"; do
            local param_name="${param_var#PARAM_}"  # Remove PARAM_ prefix
            local param_value="${!param_var}"       # Get the value
            
            # Convert PARAM_MAX_TOKENS to --max-tokens format
            local flag_name=$(echo "$param_name" | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g')
            collected_params+=" --${flag_name}=\"${param_value}\""
        done
    fi
    
    # If we have PARAM_* variables, use them; otherwise fall back to TASK_DEFAULT_PARAMS
    local effective_params=""
    if [[ -n "$collected_params" ]]; then
        effective_params="$collected_params"
    elif [[ -n "${TASK_DEFAULT_PARAMS:-}" ]]; then
        effective_params="$TASK_DEFAULT_PARAMS"
    fi
    
    # Parse and process the effective parameters
    local default_params=()
    if [[ -n "$effective_params" ]]; then
        # Process any placeholders in the parameters string
        local processed_params="$effective_params"
        
        # Process placeholders using the remaining command line arguments
        processed_params=$(process_placeholders "$processed_params" "$@")
        
        # Simple approach: use eval with array assignment to handle quoted parameters properly
        eval "default_params=($processed_params)"
    fi
    
    # Handle PROMPT variable if defined and no --prompt provided in command line
    local prompt_found=false
    for arg in "$@"; do
        if [[ "$arg" == --prompt=* ]]; then
            prompt_found=true
            break
        fi
    done
    
    # If no --prompt in command line but PROMPT variable is defined, add it to default_params
    if [[ "$prompt_found" == false && -n "${PROMPT:-}" ]]; then
        default_params+=("--prompt=$PROMPT")
    fi
    
    # Start with processed default params
    local all_params=()
    if [[ ${#default_params[@]} -gt 0 ]]; then
        all_params+=("${default_params[@]}")
    fi
    
    # Add ALL command line parameters (allow overrides for core system parameters)
    for arg in "$@"; do
        # Remove any existing parameter of the same type to allow overrides
        case "$arg" in
            --prompt=*)
                # Remove existing --prompt parameter
                local filtered_params=()
                for param in "${all_params[@]}"; do
                    [[ "$param" != --prompt=* ]] && filtered_params+=("$param")
                done
                all_params=("${filtered_params[@]}")
                all_params+=("$arg")
                ;;
            --provider=*)
                # Remove existing --provider parameter
                local filtered_params=()
                for param in "${all_params[@]}"; do
                    [[ "$param" != --provider=* ]] && filtered_params+=("$param")
                done
                all_params=("${filtered_params[@]}")
                all_params+=("$arg")
                ;;
            --model=*)
                # Remove existing --model parameter
                local filtered_params=()
                for param in "${all_params[@]}"; do
                    [[ "$param" != --model=* ]] && filtered_params+=("$param")
                done
                all_params=("${filtered_params[@]}")
                all_params+=("$arg")
                ;;
            --go)
                all_params+=("$arg")
                ;;
            --*=*)
                # For all other parameters, allow them through (template variables, etc.)
                # Remove existing parameter of the same type first
                local param_prefix="${arg%%=*}="
                local filtered_params=()
                for param in "${all_params[@]}"; do
                    [[ "$param" != $param_prefix* ]] && filtered_params+=("$param")
                done
                all_params=("${filtered_params[@]}")
                all_params+=("$arg")
                ;;
        esac
    done
    
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

# Execute the ask task 
execute_ask_task() {
    # Parse parameters using helper function
    parse_ask_task_parameters "${TASK_TEMPLATE:-}" "$@"
    
    # Use parsed values (for readability, assign to local variables)
    local template_name="$PARSED_TEMPLATE_NAME"
    local prompt_content="$PARSED_PROMPT_CONTENT"
    local model="$PARSED_MODEL"
    local provider="$PARSED_PROVIDER"
    local output_file="$PARSED_OUTPUT_FILE"
    local go_flag="$PARSED_GO_FLAG"
    local max_tokens="$PARSED_MAX_TOKENS"
    local params=("${PARSED_PARAMS[@]+"${PARSED_PARAMS[@]}"}")
    
    # Validate inputs and apply task config defaults
    validate_task_inputs "$template_name" "$prompt_content" "$model" "$provider"
    
    # Use validated values
    model="$VALIDATED_MODEL"
    provider="$VALIDATED_PROVIDER"
    
    print_info "Execute mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
    
    # Load and process content using helper function
    load_and_process_content "$template_name" "$prompt_content" "${params[@]+"${params[@]}"}"
    local processed_content="$PROCESSED_CONTENT"
    local content_source="$CONTENT_SOURCE"
    
    # Build vibe-tools command
    local vibe_cmd="vibe-tools ask"
    
    # Resolve provider and model using helper function
    resolve_task_model "$model" "$provider"
    model="$RESOLVED_MODEL"
    provider="$RESOLVED_PROVIDER"
    
    # Build command arguments and handle output file setup
    build_vibe_command_args "$vibe_cmd" "$model" "$provider" "$max_tokens" "$go_flag" "$output_file" "$template_name"
    local vibe_args=("${BUILT_VIBE_ARGS[@]}")
    output_file="$FINAL_OUTPUT_FILE"
    
    # Build full command
    local full_command="$vibe_cmd \"$processed_content\" ${vibe_args[*]}"
    
    # Create comprehensive execution log using helper function
    create_execution_log "$template_name" "$content_source" "$model" "$provider" "$max_tokens" "$output_file" "$go_flag" "$processed_content" "$vibe_cmd" "" "${params[@]+"${params[@]}"}"
    local log_file="$EXECUTION_LOG_FILE"
    
    # Show execution plan for both dry run and live execution
    print_info ""
    print_info "=== EXECUTION PLAN DETAILS ==="
    if [[ -n "$template_name" ]]; then
        print_info "$content_source"
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
    
    # Execute command (or dry run) using helper function
    execute_vibe_command "$go_flag" "$processed_content" "$vibe_cmd" "$output_file" "$log_file"
}

# Execute the repo task (adds ICE curation and runs from runtime)
execute_repo_task() {
    # Parse parameters using helper function
    parse_repo_task_parameters "${TASK_TEMPLATE:-}" "$@"
    
    # Use parsed values (for readability, assign to local variables)
    local template_name="$PARSED_TEMPLATE_NAME"
    local prompt_text="$PARSED_PROMPT_CONTENT"
    local model="$PARSED_MODEL"
    local provider="$PARSED_PROVIDER"
    local output_file="$PARSED_OUTPUT_FILE"
    local go_flag="$PARSED_GO_FLAG"
    local max_tokens="$PARSED_MAX_TOKENS"
    local params=("${PARSED_PARAMS[@]+"${PARSED_PARAMS[@]}"}")
    local includes=("${PARSED_INCLUDES[@]+"${PARSED_INCLUDES[@]}"}")
    local excludes=("${PARSED_EXCLUDES[@]+"${PARSED_EXCLUDES[@]}"}")
    local question="$PARSED_QUESTION"
    
    # Validate inputs and apply task config defaults using helper function
    validate_repo_task_inputs "$template_name" "$prompt_text" "$model" "$provider" "$question" "${includes[@]+"${includes[@]}"}"
    
    # Use validated values
    model="$VALIDATED_MODEL"
    provider="$VALIDATED_PROVIDER"
    question="$VALIDATED_QUESTION"
    
    # Handle template processing if template is specified
    if [[ -n "$template_name" ]]; then
        # Find template file using helper function (with .md extension for repo tasks)
        find_template_file "$template_name" "md"
        local template_file="$FOUND_TEMPLATE_PATH"
        
        # Load and process template
        question=$(cat "$template_file")
        question=$(process_placeholders "$question")
    fi
    
    # Default to free Gemini for testing if not specified
    if [[ -z "$model" ]]; then
        model="gemini/gemini-2-0-flash"
    fi
    
    print_info "Execute mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
    
    # Resolve provider and model using helper function
    resolve_task_model "$model" "$provider"
    model="$RESOLVED_MODEL"
    provider="$RESOLVED_PROVIDER"
    
    # Prepare ICE using include/exclude
    init_context
    prepare_ice "${includes[@]/#/--include=}" "${excludes[@]/#/--exclude=}"
    
    # Capture ICE context information for logging
    capture_ice_context
    local ice_context="$ICE_CONTEXT_INFO"
    
    # Build vibe-tools command using helper function
    # Use template name for template-based tasks, otherwise use "repo-prompt"
    local vibe_template_name="repo-prompt"
    if [[ -n "$template_name" && "$template_name" != "repo-prompt" ]]; then
        vibe_template_name="$template_name"
    fi
    build_vibe_command_args "repo" "$model" "$provider" "$max_tokens" "$go_flag" "$output_file" "$vibe_template_name"
    
    # Create comprehensive execution log using helper function
    create_execution_log "$vibe_template_name" "prompt: $question" "$model" "$provider" "$max_tokens" "$output_file" "$go_flag" "$question" "vibe-tools repo" "$ice_context" "${params[@]+"${params[@]}"}"
    
    # Add ICE context debug info to log before execution
    {
        echo "ICE content directory: $VIBE_TOOLS_SQUARE_HOME/content"
        echo "=== ICE CONTEXT DEBUG ==="
        echo "$ice_context"
        echo ""
    } >> "$EXECUTION_LOG_FILE"
    
    # Execute command using helper function
    execute_vibe_command "$go_flag" "$question" "vibe-tools repo" "$output_file" "$EXECUTION_LOG_FILE"
}

# Execute the plan task (supports separate file/thinking models)
execute_plan_task() {
    # Parse parameters using helper function
    parse_plan_task_parameters "${TASK_TEMPLATE:-}" "$@"
    
    # Use parsed values (for readability, assign to local variables)
    local template_name="$PARSED_TEMPLATE_NAME"
    local prompt_text="$PARSED_PROMPT_CONTENT"
    local file_model="$PARSED_FILE_MODEL"
    local thinking_model="$PARSED_THINKING_MODEL"
    local file_provider="$PARSED_FILE_PROVIDER"
    local thinking_provider="$PARSED_THINKING_PROVIDER"
    local output_file="$PARSED_OUTPUT_FILE"
    local go_flag="$PARSED_GO_FLAG"
    local params=("${PARSED_PARAMS[@]+"${PARSED_PARAMS[@]}"}")
    local includes=("${PARSED_INCLUDES[@]+"${PARSED_INCLUDES[@]}"}")
    local excludes=("${PARSED_EXCLUDES[@]+"${PARSED_EXCLUDES[@]}"}")
    local question="$PARSED_QUESTION"
    
    # Validate inputs and apply task config defaults using helper function
    validate_plan_task_inputs "$template_name" "$prompt_text" "$file_model" "$thinking_model" "$file_provider" "$thinking_provider" "$question" "${includes[@]+"${includes[@]}"}"
    
    # Use validated values
    file_model="$VALIDATED_FILE_MODEL"
    thinking_model="$VALIDATED_THINKING_MODEL"
    file_provider="$VALIDATED_FILE_PROVIDER"
    thinking_provider="$VALIDATED_THINKING_PROVIDER"
    question="$VALIDATED_QUESTION"
    
    # Handle template processing if template is specified
    if [[ -n "$template_name" ]]; then
        # Find template file using helper function (with .md extension for plan tasks)
        find_template_file "$template_name" "md"
        local template_file="$FOUND_TEMPLATE_PATH"
        
        # Load and process template
        question=$(cat "$template_file")
        question=$(process_placeholders "$question")
    fi
    
    print_info "Execute mode: $(if $go_flag; then echo "EXECUTE"; else echo "DRY RUN"; fi)"
    
    # Resolve dual models using helper function
    resolve_plan_task_models "$file_model" "$file_provider" "$thinking_model" "$thinking_provider"
    file_model="$RESOLVED_FILE_MODEL"
    file_provider="$RESOLVED_FILE_PROVIDER"
    thinking_model="$RESOLVED_THINKING_MODEL"
    thinking_provider="$RESOLVED_THINKING_PROVIDER"
    
    # Prepare ICE using include/exclude
    init_context
    prepare_ice "${includes[@]/#/--include=}" "${excludes[@]/#/--exclude=}"
    
    # Capture ICE context information for logging
    capture_ice_context
    local ice_context="$ICE_CONTEXT_INFO"
    
    # Build vibe-tools plan command using helper function
    build_plan_command_args "$file_model" "$file_provider" "$thinking_model" "$thinking_provider" "$output_file"
    
    # Set BUILT_VIBE_ARGS for create_execution_log compatibility
    BUILT_VIBE_ARGS=("${BUILT_PLAN_ARGS[@]}")
    
    # Create comprehensive execution log using helper function
    # Use template name for template-based tasks, otherwise use "plan-prompt"
    local log_template_name="plan-prompt"
    if [[ -n "$template_name" && "$template_name" != "plan-prompt" ]]; then
        log_template_name="$template_name"
    fi
    create_execution_log "$log_template_name" "prompt: $question" "$file_model" "$file_provider" "" "$output_file" "$go_flag" "$question" "vibe-tools plan" "$ice_context" "${params[@]+"${params[@]}"}"
    
    # Add ICE context debug info to log before execution
    {
        echo "ICE content directory: $VIBE_TOOLS_SQUARE_HOME/content"
        echo "=== ICE CONTEXT DEBUG ==="
        echo "$ice_context"
        echo ""
    } >> "$EXECUTION_LOG_FILE"
    
    # Execute command using helper function
    execute_vibe_command "$go_flag" "$question" "vibe-tools plan" "$FINAL_PLAN_OUTPUT_FILE" "$EXECUTION_LOG_FILE"
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
    # Ensure output directory exists before writing
    ensure_output_directory
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
  --prompt=<text|file:path>  Direct prompt text or file reference
  
  Model Selection (only aliases from providers.conf allowed):
    --model=<alias>              Model for ask/repo tasks (e.g., gemini/gemini-2-0-flash)
    --file-model=<alias>         File analysis model for plan tasks (default: gemini/gemini-2-0-flash)
    --thinking-model=<alias>     Plan generation model for plan tasks (default: gemini/gemini-5-0-flash)
  
  Context Control (for repo/plan tasks):
    --include=<pattern>     Include files/dirs in context analysis  
    --exclude=<pattern>     Exclude files/dirs from context analysis
    --show-context          Show what files are currently in the curated context
  
  Output Options:
    --output-file=<path>    Save output to specific file (default: timestamped in ~/.vibe-tools-square/output/)
    --max-tokens=<num>      Set maximum response tokens
  
  System:
    --list-tasks            Show available tasks and their descriptions
    --help                  Show this help

Example Model Aliases (from providers.conf):
  anthropic/claude-3-5-sonnet    # Anthropic Claude 3.5 Sonnet  
  gemini/free                    # Google Gemini 2.0 Flash (free)
  gemini/gemini-2-0-flash        # Google Gemini 2.0 Flash (free)
  gemini/gemini-2-5-flash        # Google Gemini 2.5 Flash
  gemini/gemini-2-5-pro          # Google Gemini 2.5 Pro  
  openai/o3-mini                 # OpenAI o3-mini
  openrouter/gemini-2-5-flash    # Gemini 2.5 Flash via OpenRouter
  perplexity/sonar               # Perplexity Sonar Pro

Plan Task Dual Models:
  Plan tasks use TWO models:
  1. --file-model: Analyzes repository files and context
  2. --thinking-model: Generates the actual implementation plan
  
  Example: run-prompt.sh plan-demo --file-model=gemini/gemini-2-0-flash --thinking-model=openai/o3-mini --include=src

Available Tasks:
$(list_available_tasks)

Note: Only aliases from providers.conf are allowed to prevent accidental expensive model usage.
For detailed documentation, see docs/100-Testing-Commands.md
EOF
}

# Only execute core_main if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    core_main "$@"
fi
