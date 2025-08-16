#!/bin/bash
# run-prompt.sh - Main executable for vibe-tools-square
# Entry point that initializes all systems and delegates to core.sh

set -euo pipefail

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

# Source all modules
source "$SCRIPT_DIR/src/config.sh"
source "$SCRIPT_DIR/src/template.sh"
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

    # Initialize configuration and logging early so that
    # VIBE_TOOLS_SQUARE_HOME is available even when showing usage
    init_system
    init_logging
    check_dependencies

    # Show usage if no arguments
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi

    print_header "Vibe-Tools Square Started"
    print_info "Version: Phase 1 Development"
    print_info "Arguments: $*"

    # Delegate to core
    core_main "$@"

    print_footer
}

# Execute main function
main "$@"