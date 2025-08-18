#!/bin/bash
# config.sh - Configuration management for vibe-tools-square
# Handles loading and managing configuration from multiple sources

set -euo pipefail

# Utility functions (since utils are sourced by run-prompt.sh)
setup_vibe_tools_logging() {
    # Create log directory first
    mkdir -p "$VIBE_TOOLS_SQUARE_HOME/logs"
    
    # Set log file path for the logging utilities AFTER ensuring directory exists
    export LOG_FILE_PATH="$VIBE_TOOLS_SQUARE_HOME/logs/run-prompt.log"
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

# Load configuration from file
load_config() {
    # Make sure basic directories exist first
    mkdir -p "$(dirname "$CONFIG_FILE")"
    mkdir -p "$VIBE_TOOLS_SQUARE_HOME/logs"
    
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
    
    # Ensure all required directories exist
    ensure_directories_exist
}

# Set up default configuration if file doesn't exist
setup_default_config() {
    # Create required directories first
    mkdir -p "$(dirname "$CONFIG_FILE")"
    mkdir -p "$VIBE_TOOLS_SQUARE_HOME/logs"
    
    # Check for template file
    local template_file="$SCRIPT_DIR/src/default.conf.template"
    if [[ -f "$template_file" ]]; then
        # Use template to create config file
        cp "$template_file" "$CONFIG_FILE"
    else
        # Create a minimal config file
        echo "# Default configuration" > "$CONFIG_FILE"
        echo "LOG_FILE_PATH=\"$VIBE_TOOLS_SQUARE_HOME/logs/run-prompt.log\"" >> "$CONFIG_FILE"
    fi
    
    print_warning "Created default configuration at $CONFIG_FILE"
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
    
    # Set config file path
    CONFIG_FILE="$VIBE_TOOLS_SQUARE_HOME/config/default.conf"
    
    # Ensure basic directories exist before trying to use them
    mkdir -p "$VIBE_TOOLS_SQUARE_HOME/config"
    mkdir -p "$VIBE_TOOLS_SQUARE_HOME/logs"
    
    # Now we can safely load the config
    load_config
    # Configuration system initialized
}
