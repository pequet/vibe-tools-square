#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Author: Benjamin Pequet
# Purpose: Isolated Context Environment (ICE) management for preparing curated working directories.
# Project: https://github.com/pequet/vibe-tools-square/ 
# Refer to main project for detailed docs.

# Local helpers
ensure_directory() {
    local dir="$1"
    mkdir -p "$dir"
}

# Prepare ICE for context-dependent commands
prepare_ice() {
    # Workaround for Bash 3 + set -u edge cases with empty arrays
    set +u
    local include_arr=()
    local exclude_arr=()
    local source_dir="${PWD}"
    local ice_root="$VIBE_TOOLS_SQUARE_HOME/content"
    local target_public="$ice_root/public"
    
    print_info "Preparing Isolated Context Environment"
    print_info "Source: $source_dir"
    print_info "ICE Root: $ice_root"
    print_info "Target (public): $target_public"
    
    # Parse include/exclude patterns (Bash 3 compatible)
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --include=*) include_arr+=("${1#--include=}") ;;
            --exclude=*) exclude_arr+=("${1#--exclude=}") ;;
        esac
        shift
    done
    
    # Clean target public directory (preserve config files at ICE root)
    clean_ice_public "$target_public"
    
    # Copy files using rsync filters
    if [[ ${#include_arr[@]} -eq 0 ]]; then
        print_warning "No --include patterns provided; copying nothing to ICE public."
    else
        local rsync_opts=( "-a" "--prune-empty-dirs" "--human-readable" "--delete-excluded" )
        local filters=()
        # Always include directories to allow rsync to descend and evaluate deeper include rules
        filters+=("--include=*/")
        
        # Build exclude filters FIRST (rsync processes in order)
        for p in "${exclude_arr[@]}"; do
            [[ -z "$p" ]] && continue
            # If it's a directory, exclude everything inside it
            if [[ -d "$source_dir/$p" ]]; then
                filters+=("--exclude=$p/***")
            else
                # It's a file, exclude it exactly
                filters+=("--exclude=$p")
            fi
        done
        
        # Build include filters AFTER excludes
        local p
        for p in "${include_arr[@]}"; do
            [[ -z "$p" ]] && continue
            # If it's a directory, include everything inside it recursively
            if [[ -d "$source_dir/$p" ]]; then
                filters+=("--include=$p/***")
            else
                # It's a file, include it exactly
                filters+=("--include=$p")
            fi
        done
        filters+=("--exclude=*")
        print_info "Syncing curated context to ICE public via rsync filters"
        # Debug: show filters being applied
        if [[ -n "${VIBE_TOOLS_DEBUG:-}" ]]; then
            print_info "Applied rsync filters:"
            for f in "${filters[@]}"; do
                print_info "  $f"
            done
        fi
        rsync "${rsync_opts[@]}" "${filters[@]}" "$source_dir/" "$target_public/"
        print_info "Context sync complete"
        # Post-sync summary: show file count only
        if command -v find >/dev/null 2>&1; then
            local count
            count=$(find "$target_public" -type f | wc -l | tr -d ' ')
            print_info "Curated files copied: $count"
        fi
    fi
    
    print_info "ICE preparation completed"
    print_info "Context directory: $target_public"
    # Restore nounset behavior
    set -u
}

# Clean the ICE directory
clean_ice_public() {
    local target_public="$1"
    
    if [[ -d "$target_public" ]]; then
        print_info "Cleaning ICE public directory: $target_public"
        rm -rf "$target_public"/*
    fi
    
    ensure_directory "$target_public"
}

 

# Show detailed context listing
show_context() {
    local target_public="$VIBE_TOOLS_SQUARE_HOME/content/public"
    
    if [[ ! -d "$target_public" ]]; then
        print_warning "ICE public directory doesn't exist: $target_public"
        return 1
    fi
    
    print_info "=== CURATED CONTEXT LISTING ==="
    if command -v find >/dev/null 2>&1; then
        local count
        count=$(find "$target_public" -type f | wc -l | tr -d ' ')
        print_info "Total files: $count"
        print_info ""
        if [[ "$count" != "0" ]]; then
            print_info "Files in curated context:"
            find "$target_public" -type f | sed "s|^$target_public/||" | sort
        else
            print_info "No files in curated context."
        fi
    fi
}

# Initialize context system
init_context() {
    print_info "Initializing context system"
    ensure_directory "$VIBE_TOOLS_SQUARE_HOME/content"
    ensure_directory "$VIBE_TOOLS_SQUARE_HOME/content/public"
    print_info "Context system initialized"
}
