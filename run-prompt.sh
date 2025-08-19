#!/bin/bash

# Standard Error Handling
set -e  # Exit immediately if a command exits with a non-zero status.
set -u  # Treat unset variables as an error when substituting.
set -o pipefail  # Causes a pipeline to return the exit status of the last command in the pipe that failed.

# █████  Vibe-Tools Square: Query Template Engine
# █   █  Version: 1.0.0
# █   █  Author: Benjamin Pequet
# █████  GitHub: https://github.com/pequet/vibe-tools-square/
# 
# Purpose:
#   Main executable for vibe-tools-square that serves as the entry point for all operations.
#   This script initializes all system components and delegates tasks to the appropriate modules.
#   It handles command-line argument parsing, configuration loading, and execution flow.
#
# Usage:
#   ./run-prompt.sh <task> [options] [arguments]
#   ./run-prompt.sh ask --template=question "What is the capital of France?"
#   ./run-prompt.sh plan --template=strategy "Build a user authentication system"
#
# Options:
#   --template=<name>   Specify template to use for prompt construction
#   --model=<provider/model>   Specify AI model to use
#   --include=<pattern>  Include file pattern for context
#   --exclude=<pattern>  Exclude file pattern from context
#   -h, --help          Show help message and exit
#
# Dependencies:
#   - vibe-tools CLI (for AI model access)
#   - bash 4.0+ (for associative arrays)
#
# Changelog:
# 1.0.0 - 2025-08-14 - Initial release with modular architecture
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

# Get script directory (resolve symlinks)
SCRIPT_PATH="${BASH_SOURCE[0]}"
# Resolve symlinks
while [[ -L "$SCRIPT_PATH" ]]; do
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# Source utility libraries first
source "$SCRIPT_DIR/src/utils/logging_utils.sh"
source "$SCRIPT_DIR/src/utils/messaging_utils.sh"
source "$SCRIPT_DIR/src/utils/template_utils.sh"

# Source all modules
source "$SCRIPT_DIR/src/config.sh"
source "$SCRIPT_DIR/src/context.sh"
source "$SCRIPT_DIR/src/providers.sh"
source "$SCRIPT_DIR/src/core.sh"

# Initialize logging to file
init_logging() {
    # Set up the logging system using the proper utilities
    setup_vibe_tools_logging
}

# Initialize configuration and providers
init_system() {
    init_config
    init_providers
}

# Main entry point
main() {
    # Preserve original environment variable before any processing
    ORIGINAL_VIBE_TOOLS_SQUARE_HOME="${VIBE_TOOLS_SQUARE_HOME:-}"
    
    # Capture original command line for debugging logs
    export ORIGINAL_COMMAND_LINE="./run-prompt.sh $*"

    # Initialize configuration and logging
    init_system
    
    check_dependencies

    # Show usage if no arguments
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi

    print_header "Vibe-Tools Square Started"
    print_info "Arguments: $*"

    # Delegate to core
    core_main "$@"

    print_footer
}

# Execute main function
main "$@"