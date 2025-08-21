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
    
    # DEBUG: Show parsed include/exclude arrays
    print_info "CONTEXT DEBUG: Parsed parameters:"
    print_info "  Include patterns (${#include_arr[@]}): ${include_arr[*]:-[none]}"
    print_info "  Exclude patterns (${#exclude_arr[@]}): ${exclude_arr[*]:-[none]}"
    
    # DEBUG: Show what exists in source directory for each include pattern
    print_info "CONTEXT DEBUG: Checking source directory for include patterns:"
    for p in "${include_arr[@]}"; do
        [[ -z "$p" ]] && continue
        # Show comma-delimited items separately  
        IFS=',' read -ra include_items <<< "$p"
        for item in "${include_items[@]}"; do
            item=$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [[ -z "$item" ]] && continue
            if [[ -e "$source_dir/$item" ]]; then
                if [[ -d "$source_dir/$item" ]]; then
                    local dir_count=$(find "$source_dir/$item" -type f 2>/dev/null | wc -l | tr -d ' ')
                    print_info "  $item/ -> DIRECTORY (contains $dir_count files)"
                else
                    print_info "  $item -> FILE (exists)"
                fi
            else
                print_info "  $item -> NOT FOUND"
            fi
        done
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
            # Split comma-delimited patterns into separate filters
            IFS=',' read -ra exclude_items <<< "$p"
            for item in "${exclude_items[@]}"; do
                # Trim whitespace
                item=$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                [[ -z "$item" ]] && continue
                # If it's a directory, exclude everything inside it
                if [[ -d "$source_dir/$item" ]]; then
                    # Remove trailing slash if present, then add correct patterns
                    local clean_item="${item%/}"
                    filters+=("--exclude=$clean_item/**")
                else
                    # It's a file, exclude it exactly
                    filters+=("--exclude=$item")
                fi
            done
        done
        
        # Build include filters AFTER excludes
        local p
        for p in "${include_arr[@]}"; do
            [[ -z "$p" ]] && continue
            # Split comma-delimited patterns into separate filters
            IFS=',' read -ra include_items <<< "$p"
            for item in "${include_items[@]}"; do
                # Trim whitespace
                item=$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                [[ -z "$item" ]] && continue
                # If it's a directory, include everything inside it recursively
                if [[ -d "$source_dir/$item" ]]; then
                    # Remove trailing slash if present, then add correct patterns
                    local clean_item="${item%/}"
                    filters+=("--include=$clean_item/" "--include=$clean_item/**")
                else
                    # It's a file, include it exactly from root (add leading slash for precise matching)
                    if [[ "$item" != /* ]]; then
                        filters+=("--include=/$item")
                    else
                        filters+=("--include=$item")
                    fi
                fi
            done
        done
        filters+=("--exclude=*")
        
        # DEBUG: Always show rsync filters being applied
        print_info "CONTEXT DEBUG: Built rsync filters (${#filters[@]} total):"
        for f in "${filters[@]}"; do
            print_info "  $f"
        done
        
        # DEBUG: Show the full rsync command
        print_info "CONTEXT DEBUG: Executing rsync command:"
        print_info "  rsync ${rsync_opts[*]} [${#filters[@]} filters] $source_dir/ $target_public/"
        
        print_info "Syncing curated context to ICE public via rsync filters"
        rsync "${rsync_opts[@]}" "${filters[@]}" "$source_dir/" "$target_public/"
        print_info "Context sync complete"
        
        # DEBUG: Show detailed files that were actually copied
        if command -v find >/dev/null 2>&1; then
            local count
            count=$(find "$target_public" -type f | wc -l | tr -d ' ')
            print_info "CONTEXT DEBUG: Files actually copied to ICE public ($count total):"
            if [[ $count -gt 0 ]]; then
                find "$target_public" -type f | while read -r file; do
                    local relative_path="${file#$target_public/}"
                    local size=""
                    if command -v du >/dev/null 2>&1; then
                        size=" ($(du -h "$file" | cut -f1))"
                    fi
                    print_info "  $relative_path$size"
                done
            else
                print_info "  [no files copied]"
            fi
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
