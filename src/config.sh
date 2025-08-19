#!/bin/bash
# config.sh - Configuration management for vibe-tools-square
# Handles loading and managing configuration from multiple sources

set -euo pipefail

# Utility functions (since utils are sourced by run-prompt.sh)
setup_vibe_tools_logging() {
    # Set log file path based on whether runtime logs directory exists
    if [[ -d "$VIBE_TOOLS_SQUARE_HOME/logs" ]]; then
        export LOG_FILE_PATH="$VIBE_TOOLS_SQUARE_HOME/logs/run-prompt.log"
        echo "Using runtime logs: $LOG_FILE_PATH"
    else
        # No runtime logs directory - log to repo logs directory
        export LOG_FILE_PATH="$SCRIPT_DIR/logs/run-prompt.log"
        echo "Using repo logs: $LOG_FILE_PATH"
    fi
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
        
    # Default fallback
    VIBE_TOOLS_SQUARE_HOME="${HOME}/.vibe-tools-square"
}

# CONFIG_FILE will be set in init_config after runtime detection
CONFIG_FILE=""
USING_RUNTIME_CONFIG=false

# Load configuration from file
load_config() {
    # Check for config file with runtime-first fallback
    local config_to_load=""
    
    if [[ -f "$CONFIG_FILE" ]]; then
        # Found in runtime
        config_to_load="$CONFIG_FILE"
        USING_RUNTIME_CONFIG=true
    else
        # Check in assets folder
        local assets_config="$SCRIPT_DIR/assets/.vibe-tools-square/config/default.conf"
        if [[ -f "$assets_config" ]]; then
            config_to_load="$assets_config"
            USING_RUNTIME_CONFIG=false
        else
            print_error "Configuration file not found in runtime ($CONFIG_FILE) or assets ($assets_config)"
            print_error "Script execution halted"
            exit 1
        fi
    fi
    
    # Source the config file in a safe way
    set -a  # Export all variables
    source "$config_to_load"
    set +a  # Stop exporting
    
    # Show which config was loaded
    if [[ "$USING_RUNTIME_CONFIG" == "true" ]]; then
        echo "Using runtime config: $config_to_load"
    else
        echo "Using repo config: $config_to_load"
    fi
}

# Create specific directory only when needed for writing
ensure_log_directory() {
    if [[ "$USING_RUNTIME_CONFIG" == "true" ]]; then
        mkdir -p "$VIBE_TOOLS_SQUARE_HOME/logs"
    fi
}

ensure_output_directory() {
    mkdir -p "$VIBE_TOOLS_SQUARE_HOME/output"
}

ensure_content_directory() {
    if [[ "$USING_RUNTIME_CONFIG" == "true" ]]; then
        mkdir -p "$VIBE_TOOLS_SQUARE_HOME/content"
    fi
}

ensure_config_directory() {
    if [[ "$USING_RUNTIME_CONFIG" == "true" ]]; then
        mkdir -p "$VIBE_TOOLS_SQUARE_HOME/config"
    fi
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
    
    # Set config file path
    CONFIG_FILE="$VIBE_TOOLS_SQUARE_HOME/config/default.conf"
    
    # Load the config first to determine which config we're using
    load_config
    
    # Now setup logging with the correct path
    setup_vibe_tools_logging
    # Configuration system initialized
}
