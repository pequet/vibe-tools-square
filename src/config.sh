#!/bin/bash
# config.sh - Configuration management for vibe-tools-square
# Handles loading and managing configuration from multiple sources

set -euo pipefail

# Utility functions (since utils are sourced by run-prompt.sh)
setup_vibe_tools_logging() {
    # Set log file path for the logging utilities
    LOG_FILE_PATH="$VIBE_TOOLS_SQUARE_HOME/logs/run-prompt.log"
    
    # Ensure log directory exists
    ensure_log_directory
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate required commands are available
check_dependencies() {
    local missing_deps=()
    
    if ! command_exists "rsync"; then
        missing_deps+=("rsync")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Please install the missing dependencies and try again"
        exit 1
    fi
}

# Detect runtime environment location
detect_runtime_home() {
    # Check for environment variable override
    if [[ -n "${VIBE_TOOLS_SQUARE_HOME:-}" ]]; then
        return 0
    fi
    
    # No additional detection needed - wrapper script handles this
    
    # Default fallback
    VIBE_TOOLS_SQUARE_HOME="${HOME}/.vibe-tools-square"
}

# CONFIG_FILE will be set in init_config after runtime detection
CONFIG_FILE=""

# Load configuration from file
load_config() {
    # Debug: Loading configuration
    
    if [[ -f "$CONFIG_FILE" ]]; then
        # Source the config file in a safe way
        set -a  # Export all variables
        source "$CONFIG_FILE"
        set +a  # Stop exporting
        # Configuration loaded successfully
    else
        print_warning "Configuration file not found: $CONFIG_FILE"
        print_warning "Using default settings"
        setup_default_config
    fi
    
    # Validate required directories exist
    ensure_directories_exist
}

# Set up default configuration if file doesn't exist
setup_default_config() {
    print_error "Configuration file not found and no default config available"
    print_error "Please run the install script to set up the runtime environment"
    print_error "Example: ./scripts/install.sh"
    exit 1
}

# Ensure required directories exist
ensure_directories_exist() {
    local dirs=(
        "$VIBE_TOOLS_SQUARE_HOME"
        "$VIBE_TOOLS_SQUARE_HOME/config"
        "$VIBE_TOOLS_SQUARE_HOME/content"
        "$VIBE_TOOLS_SQUARE_HOME/output"
        "$VIBE_TOOLS_SQUARE_HOME/logs"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            # Creating directory
            mkdir -p "$dir"
        fi
    done
}

# Get configuration value with fallback
get_config() {
    local key="$1"
    local default="${2:-}"
    
    # Return the value of the variable named by $key, or default if unset
    echo "${!key:-$default}"
}

# Initialize configuration system
init_config() {
    # Initializing configuration system
    detect_runtime_home
    CONFIG_FILE="$VIBE_TOOLS_SQUARE_HOME/config/default.conf"
    load_config
    # Configuration system initialized
}
