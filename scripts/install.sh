#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

#  █████  Vibe-Tools Square: Query Template Engine
#  █   █  Version: 1.0.0
#  █   █  Author: Benjamin Pequet
#  █████  GitHub: https://github.com/pequet/vibe-tools-square/
#
# Purpose:
#   Installs the Vibe-Tools Square utility by performing these steps:
#   1. Creates runtime directory structure at target location
#   2. Copies configuration files, templates, and task definitions
#   3. Installs documentation (README files for each directory)
#   4. Optionally creates global command in /usr/local/bin (user prompted)
#
# Installation Steps Explained:
#   • Runtime Environment: Creates ~/.vibe-tools-square/ (or custom path) with subdirectories
#   • Configuration: Copies default.conf, providers.conf.example, and templates
#   • Task Definitions: Copies predefined task configurations
#   • Documentation: Installs README files explaining each directory
#   • Global Access: Prompts user to create global 'run-prompt.sh' command
#
# Update Mode (--update):
#   • Updates existing installation without touching global command
#   • Refreshes configuration files, templates, and task definitions
#   • Preserves user's custom configurations where safe
#
# Usage:
#   ./scripts/install.sh [OPTIONS]
#   
# Options:
#   --target=PATH   Install to specified path (default: ~/.vibe-tools-square)
#   --update        Update existing installation (no global command changes)
#   --help      Show this help message and exit
#
# Dependencies:
#   - rsync (for context management in repo/plan commands)
#   - vibe-tools (for AI interactions, must be installed globally)
#
# Changelog:
#   1.0.0 - 2025-08-22 - Initial release with modular architecture
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

# --- Global Variables ---
INSTALL_SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_ROOT="$(dirname "$INSTALL_SCRIPT_DIR")"
RUNTIME_HOME="$HOME/.vibe-tools-square"
UPDATE_MODE=false
GLOBAL_COMMAND_PREFIX=""  # Will be loaded from config

# --- Source Utilities ---
# Source the proper utility libraries from src/utils/
source "${PROJECT_ROOT}/src/utils/logging_utils.sh"
source "${PROJECT_ROOT}/src/utils/messaging_utils.sh"   
source "${PROJECT_ROOT}/src/utils/input_utils.sh"

# Set up logging for the installer
LOG_FILE_PATH="${INSTALL_SCRIPT_DIR}/../logs/install.log"
ensure_log_directory

# *
# * Configuration Loading
# *

load_configuration() {
    print_step "Loading configuration..."
    
    local default_conf_path="$PROJECT_ROOT/assets/.vibe-tools-square/config/default.conf"
    
    if [[ -f "$default_conf_path" ]]; then
        # Source the configuration file to load variables
        if source "$default_conf_path"; then
            print_info "Loaded configuration from default.conf"
            # Validate that GLOBAL_COMMAND_PREFIX was loaded
            if [[ -n "$GLOBAL_COMMAND_PREFIX" ]]; then
                print_info "Global command prefix: $GLOBAL_COMMAND_PREFIX"
            else
                print_error "GLOBAL_COMMAND_PREFIX not found in default.conf"
                print_error "Please add GLOBAL_COMMAND_PREFIX=\"your-prefix\" to default.conf"
                exit 1
            fi
        else
            print_error "Failed to source default.conf"
            exit 1
        fi
    else
        print_error "default.conf not found at: $default_conf_path"
        print_error "Configuration file is required for installation"
        exit 1
    fi
}

# *
# * Installation Logic
# *

verify_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v rsync >/dev/null 2>&1; then
        missing_deps+=("rsync")
    fi
    
    if ! command -v vibe-tools >/dev/null 2>&1; then
        missing_deps+=("vibe-tools")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        if [[ " ${missing_deps[*]} " =~ " vibe-tools " ]]; then
            print_error "Install vibe-tools: npm install -g vibe-tools"
        fi
        if [[ " ${missing_deps[*]} " =~ " rsync " ]]; then
            print_error "rsync is required for repo/plan context management"
        fi
        exit 1
    fi
    
    # print_success "All dependencies found"
}

verify_source_files() {
    print_step "Verifying source files..."
    
    local required_files=(
        "$PROJECT_ROOT/run-prompt.sh"
        "$PROJECT_ROOT/src/core.sh"
        "$PROJECT_ROOT/src/config.sh"
        "$PROJECT_ROOT/src/context.sh"
        "$PROJECT_ROOT/src/providers.sh"
        "$PROJECT_ROOT/src/utils/template_utils.sh"
        "$PROJECT_ROOT/assets/.vibe-tools-square/config/default.conf"
        "$PROJECT_ROOT/assets/.vibe-tools-square/content/vibe-tools.config.json"
        "$PROJECT_ROOT/assets/.vibe-tools-square/content/repomix.config.json"
        "$PROJECT_ROOT/assets/.vibe-tools-square/content/.repomixignore"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required source file not found: $file"
            exit 1
        fi
    done
    
    # print_success "All source files found"
}

create_runtime_environment() {
    if [[ "$UPDATE_MODE" == true ]]; then
        print_step "Verifying runtime environment at $RUNTIME_HOME"
        
        # In update mode, check if the target exists
        if [[ ! -d "$RUNTIME_HOME" ]]; then
            print_info "Target directory does not exist: $RUNTIME_HOME"
            response=$(get_input "Would you like to create it? (y/N)")
            if [[ "$response" =~ ^[Yy]$ ]]; then
                print_step "Creating new runtime environment at $RUNTIME_HOME"
            else
                print_error "Cannot update non-existent installation"
                exit 1
            fi
        else
            print_step "Updating runtime environment at $RUNTIME_HOME"
        fi
    else
        print_step "Creating runtime environment at $RUNTIME_HOME"
    fi
    
    # Create directory structure
    mkdir -p "$RUNTIME_HOME"/{config,content,output,logs}
    
    # Copy README files from assets
    if [[ -d "$PROJECT_ROOT/assets/.vibe-tools-square" ]]; then
        print_step "Installing documentation..."
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/README.md" "$RUNTIME_HOME/"
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/config/README.md" "$RUNTIME_HOME/config/"
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/content/README.md" "$RUNTIME_HOME/content/"
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/output/README.md" "$RUNTIME_HOME/output/"
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/logs/README.md" "$RUNTIME_HOME/logs/"
    else
        print_error "Assets directory not found. Please ensure you're running from the project root."
        exit 1
    fi
    
    if [[ "$UPDATE_MODE" == true ]]; then
        print_success "Runtime environment updated"
    else
        print_success "Runtime environment created"
    fi
}

setup_content_directory() {
    print_step "Setting up Isolated Context Environment (ICE)..."
    
    # Create the public subdirectory in content
    mkdir -p "$RUNTIME_HOME/content/public"
    
    # Copy vibe-tools.config.json to content directory
    if [[ -f "$PROJECT_ROOT/assets/.vibe-tools-square/content/vibe-tools.config.json" ]]; then
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/content/vibe-tools.config.json" "$RUNTIME_HOME/content/"
    else
        print_error "vibe-tools.config.json not found in assets"
        exit 1
    fi
    
    # Copy repomix configuration files for content directory
    if [[ -f "$PROJECT_ROOT/assets/.vibe-tools-square/content/repomix.config.json" ]]; then
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/content/repomix.config.json" "$RUNTIME_HOME/content/"
        print_info "Copied repomix.config.json for content directory"
    else
        print_warning "repomix.config.json not found in assets for content directory"
    fi
    
    if [[ -f "$PROJECT_ROOT/assets/.vibe-tools-square/content/.repomixignore" ]]; then
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/content/.repomixignore" "$RUNTIME_HOME/content/"
        print_info "Copied .repomixignore for content directory"
    else
        print_warning ".repomixignore not found in assets for content directory"
    fi
    
    # Optionally install vibe-tools in the content directory
    if [[ "$UPDATE_MODE" == true ]]; then
        print_info "Skipping vibe-tools installation (update mode)"
    else
        print_info ""
        
        response=$(get_input "Install vibe-tools locally in content directory? (y/N)")
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_step "Installing vibe-tools in content directory..."
            if command -v vibe-tools >/dev/null 2>&1; then
                cd "$RUNTIME_HOME/content"
                print_info "Running: vibe-tools install ."
                if ! vibe-tools install .; then
                    print_error "Failed to install vibe-tools in content directory"
                    print_error "Make sure vibe-tools is installed globally and working"
                    cd - 
                    exit 1
                fi
                cd - 
                # print_success "vibe-tools installed in content directory"
            else
                print_error "vibe-tools command not found"
                print_error "Please install vibe-tools globally first: npm install -g vibe-tools"
                exit 1
            fi
        else
            print_info "Skipping local vibe-tools installation - using global installation"
        fi
    fi
    
    # print_success "Isolated Context Environment setup complete"
}

install_configuration() {
    print_step "Setting up configuration structure..."

    # Copy essential configuration files
    print_info ".conf files will be discovered dynamically from assets (runtime precedence)"

    # Create task directory structure with README only (dynamic discovery handles assets)
    print_step "Creating task directory structure..."
    mkdir -p "$RUNTIME_HOME/tasks"
    if [[ -f "$PROJECT_ROOT/assets/.vibe-tools-square/tasks/README.md" ]]; then
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/tasks/README.md" "$RUNTIME_HOME/tasks/"
        print_info "Tasks will be discovered dynamically from assets (runtime precedence)"
    else
        print_error "Task README not found in assets"
        exit 1
    fi
    
    # Create templates directory structure with README only (dynamic discovery handles assets)
    print_step "Creating templates directory structure..."
    mkdir -p "$RUNTIME_HOME/config/templates"
    if [[ -f "$PROJECT_ROOT/assets/.vibe-tools-square/config/templates/README.md" ]]; then
        cp "$PROJECT_ROOT/assets/.vibe-tools-square/config/templates/README.md" "$RUNTIME_HOME/config/templates/"
        print_info "Templates will be discovered dynamically from assets (runtime precedence)"
    else
        print_warning "Templates README not found in assets"
    fi
    
    # print_success "Configuration structure setup complete"
}

prompt_global_installation() {
    if [[ "$UPDATE_MODE" == true ]]; then
        print_info "Skipping global command setup (update mode)"
        return 0
    fi
    
    print_info ""
    response=$(get_input "Would you like to make 'run-prompt.sh' available globally? (y/N)")
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Prompt for prefix customization
        print_info ""
        print_info "Global command will be installed as: ${GLOBAL_COMMAND_PREFIX}-run-prompt.sh"
        prefix_response=$(get_input "Enter custom prefix (or press Enter for '${GLOBAL_COMMAND_PREFIX}')")
        if [[ -n "$prefix_response" ]]; then
            GLOBAL_COMMAND_PREFIX="$prefix_response"
            print_info "Using custom prefix: $GLOBAL_COMMAND_PREFIX"
        fi
        
        install_global_script
    else
        print_info "Global installation skipped. You can install globally later by re-running this script."
    fi
}

install_global_script() {
    print_step "Installing global command..."
    
    local dest_dir="/usr/local/bin"
    local global_command_name="${GLOBAL_COMMAND_PREFIX}-run-prompt.sh"
    local dest_path="$dest_dir/$global_command_name"
    
    if [[ ! -d "$dest_dir" ]]; then
        print_error "Global install directory not found: $dest_dir"
        print_error "You can still use the script locally: $PROJECT_ROOT/run-prompt.sh"
        return 1
    fi
    
    # Remove any existing global command first (symlink or wrapper script)
    if [[ -e "$dest_path" ]]; then
        print_step "Removing existing global command (may require sudo password)..."
        if ! sudo rm "$dest_path"; then
            print_error "Failed to remove existing global command"
            return 1
        fi
    fi
    
    # Check if we're using the default location or a custom target
    if [[ "$RUNTIME_HOME" == "$HOME/.vibe-tools-square" ]]; then
        # Default location - use simple symlink
        print_step "Creating global symlink (may require sudo password)..."
        if ! sudo ln -sf "$PROJECT_ROOT/run-prompt.sh" "$dest_path"; then
            print_error "Failed to create global symlink"
            print_error "You can still use the script locally: $PROJECT_ROOT/run-prompt.sh"
            return 1
        fi
        # print_success "Global command '$global_command_name' available (symlink)"
    else
        # Custom location - create wrapper script
        print_step "Creating global wrapper script for custom location (may require sudo password)..."
        
        local wrapper_content="#!/bin/bash
# Global wrapper for run-prompt.sh
# Auto-generated by vibe-tools-square installer
# Custom runtime location: $RUNTIME_HOME

export VIBE_TOOLS_SQUARE_HOME=\"$RUNTIME_HOME\"
exec \"$PROJECT_ROOT/run-prompt.sh\" \"\$@\"
"
        
        if ! echo "$wrapper_content" | sudo tee "$dest_path" > /dev/null; then
            print_error "Failed to create global wrapper script"
            print_error "You can still use the script locally: $PROJECT_ROOT/run-prompt.sh"
            return 1
        fi
        
        if ! sudo chmod +x "$dest_path"; then
            print_error "Failed to make global script executable"
            return 1
        fi
        
        # print_success "Global command '$global_command_name' available (wrapper script)"
    fi
    
    print_step "You can now use: $global_command_name <task-name> --template=..."
}

# *
# * Argument Parsing
# *

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --target=*)
                RUNTIME_HOME="${1#--target=}"
                # Expand ~ to full path if needed
                RUNTIME_HOME="${RUNTIME_HOME/#\~/$HOME}"
                shift
                ;;
            --update)
                UPDATE_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    print_info "Vibe-Tools Square Installer"
    print_info ""
    print_info "Usage: $0 [OPTIONS]"
    print_info ""
    print_info "Options:"
    print_info "  --target=PATH   Install to specified path (default: ~/.vibe-tools-square)"
    print_info "  --update        Update existing installation (no global command changes)"
    print_info "  -h, --help      Show this help message and exit"
    print_info ""
    print_info "Examples:"
    print_info "  $0                                          # Fresh install to ~/.vibe-tools-square"
    print_info "  $0 --target=/custom/path                    # Install to custom location"
    print_info "  $0 --update                                 # Update default installation"
    print_info "  $0 --update --target=/custom/path          # Update custom installation"
    print_info ""
    print_info "Installation vs Update:"
    print_info "  • Install: Full setup + prompts for global command"
    print_info "  • Update:  Refresh files only, skip global command setup"
}

# *
# * Main Installation
# *

main() {
    parse_arguments "$@"
    
    if [[ "$UPDATE_MODE" == true ]]; then
        print_header "Update Starting"
    else
        print_header "Installation Starting"
    fi
    
    # Step 0: Load configuration
    load_configuration
    
    # Step 1: Verify dependencies
    verify_dependencies
    
    # Step 2: Verify source files
    verify_source_files
    
    # Step 3: Create/update runtime environment
    create_runtime_environment
    
    # Step 4: Setup content directory (ICE)
    setup_content_directory
    
    # Step 5: Install/update configuration
    install_configuration
    
    # Step 6: Handle global script (install mode only, with prompt)
    prompt_global_installation
    
    if [[ "$UPDATE_MODE" == true ]]; then
        # print_success "Update completed successfully!"
        print_info ""
        print_info "Updated:"
        print_info "• Configuration files in: $RUNTIME_HOME/config/"
        print_info "• Task definitions and templates"
        print_info "• Documentation files"
        print_info ""
        print_info "Note: Global command setup was not changed (update mode)"
    else
        # print_success "Installation completed successfully!"
        print_info ""
        print_info "The run-prompt.sh script is available locally at:"
        print_info "  $PROJECT_ROOT/run-prompt.sh"
        print_info ""
        print_info "Next steps:"
        print_info "1. Review configuration in: $RUNTIME_HOME/config/"
        print_info "2. Test the installation with: $PROJECT_ROOT/run-prompt.sh --list-tasks"
        local global_command_name="${GLOBAL_COMMAND_PREFIX}-run-prompt.sh"
        if command -v "$global_command_name" >/dev/null 2>&1; then
            print_info "3. Or use globally: $global_command_name --list-tasks"
        fi
        print_info ""
        print_info "For testing commands, see: docs/100-Testing-Commands.md"
    fi
}

# --- Script Entrypoint ---
main "$@"
