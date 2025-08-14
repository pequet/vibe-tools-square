#!/bin/bash
# context.sh - Isolated Context Environment (ICE) management
# Handles preparation of curated working directory for repo/plan commands

set -euo pipefail

# Prepare ICE for context-dependent commands
prepare_ice() {
    local include_patterns=()
    local exclude_patterns=()
    local source_dir="${PWD}"
    local target_dir="$VIBE_TOOLS_SQUARE_HOME/content"
    
    log_info "Preparing Isolated Context Environment"
    log_debug "Source: $source_dir"
    log_debug "Target: $target_dir"
    
    # Parse include/exclude patterns from arguments
    parse_context_args include_patterns exclude_patterns "$@"
    
    # Clean target directory
    clean_ice "$target_dir"
    
    # Copy files using rsync with patterns
    sync_context "$source_dir" "$target_dir" include_patterns exclude_patterns
    
    log_info "ICE preparation completed"
    log_info "Context directory: $target_dir"
}

# Parse include/exclude arguments
parse_context_args() {
    local -n inc_ref=$1
    local -n exc_ref=$2
    shift 2
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --include=*)
                inc_ref+=("${1#--include=}")
                ;;
            --exclude=*)
                exc_ref+=("${1#--exclude=}")
                ;;
        esac
        shift
    done
    
    log_debug "Include patterns: ${inc_ref[*]:-none}"
    log_debug "Exclude patterns: ${exc_ref[*]:-none}"
}

# Clean the ICE directory
clean_ice() {
    local target_dir="$1"
    
    if [[ -d "$target_dir" ]]; then
        log_debug "Cleaning ICE directory: $target_dir"
        rm -rf "$target_dir"/*
    fi
    
    ensure_directory "$target_dir"
}

# Sync context using rsync
sync_context() {
    local source_dir="$1"
    local target_dir="$2"
    local -n inc_patterns=$3
    local -n exc_patterns=$4
    
    local rsync_cmd=(
        "rsync"
        "--archive"
        "--verbose"
        "--human-readable"
    )
    
    # Add include patterns
    for pattern in "${inc_patterns[@]}"; do
        rsync_cmd+=(--include="$pattern")
    done
    
    # Add exclude patterns
    for pattern in "${exc_patterns[@]}"; do
        rsync_cmd+=(--exclude="$pattern")
    done
    
    # Add source and target
    rsync_cmd+=("$source_dir/" "$target_dir/")
    
    log_debug "Rsync command: ${rsync_cmd[*]}"
    
    # TODO: Phase 2 - Execute the rsync command
    log_info "Context sync placeholder - Phase 2 implementation pending"
}

# Show what would be copied (dry run)
show_context_dry_run() {
    log_info "DRY RUN: Context curation"
    # TODO: Phase 2 - Implement dry run showing what files would be copied
    echo "Dry run placeholder - would show files to be copied"
}

# Initialize context system
init_context() {
    log_debug "Initializing context system"
    ensure_directory "$VIBE_TOOLS_SQUARE_HOME/content"
    log_debug "Context system initialized"
}
