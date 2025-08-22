#!/bin/bash

set -euo pipefail

# Template placeholder Utilities
# Version: 1.0.0
# Author: Benjamin Pequet
# Projects: https://github.com/pequet/ 
# Purpose: Provides template placeholder processing utility functions.
# Refer to main project for detailed docs.

# --- Guard against direct execution ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script provides utility functions and is not meant to be executed directly." >&2
    echo "Please source it from another DLS script." >&2
    exit 1
fi

# --- Function Definitions ---

# *
# * Template Placeholder Processing
# *

# Returns the processed template content with all placeholders substituted.
# 
# Usage:
#   process_placeholders "content with {{PLACEHOLDERS}}" --param1="value1" --param2="value2" --file_param=file:path/to/file.md
#
# Parameters (named parameters):
#   $1 - Template content with placeholders in the format {{PLACEHOLDER_NAME}} or {{PLACEHOLDER_NAME=DEFAULT_VALUE}}
#   $@ - Named parameters to substitute, format: --parameter_name="value"
#
# Special placeholders:
#   {{TODAY_DATE}} - Replaced with current date (YYYY-MM-DD)
#   {{TODAY_DATETIME}} - Replaced with current date and time (YYYY-MM-DD HH:MM:SS)
#   {{PLACEHOLDER_NAME=DEFAULT_VALUE}} - If no matching parameter is provided, DEFAULT_VALUE will be used
#
# Special parameter values:
#   file:path/to/file - Reads the content of the specified file and uses it as the value
#                       Multiple files can be specified with commas: file:file1.md,file2.md
#                       Paths are relative to the current directory (PWD) by default
process_placeholders() {
    local template_content="$1"
    shift
    
    # Replace date placeholders
    local today_date=$(date +"%Y-%m-%d")
    local today_datetime=$(date +"%Y-%m-%d %H:%M:%S")
    
    template_content=$(echo "$template_content" | sed "s/{{TODAY_DATE}}/$today_date/g")
    template_content=$(echo "$template_content" | sed "s/{{TODAY_DATETIME}}/$today_datetime/g")
    
    # Process parameters - collect them into an associative structure
    local param_keys=""
    local param_values=""
    
    for param in "$@"; do
        if [[ "$param" == --*=* ]]; then
            # Extract key and value
            local key="${param#--}"
            key="${key%%=*}"
            local value="${param#*=}"
            
            # Convert key to uppercase for placeholder, replacing dashes with underscores
            local placeholder_key=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
            
            # Store key-value pairs (simple approach without associative arrays)
            if [[ -z "$param_keys" ]]; then
                param_keys="$placeholder_key"
                param_values="$value"
            else
                param_keys="$param_keys|$placeholder_key"
                param_values="$param_values|$value"
            fi
        fi
    done
    
    # First pass: Handle placeholders with default values {{KEY=DEFAULT}}
    while [[ "$template_content" =~ \{\{([A-Z0-9_]+)=([^}]*)\}\} ]]; do
        local full_match="${BASH_REMATCH[0]}"
        local key="${BASH_REMATCH[1]}"
        local default_value="${BASH_REMATCH[2]}"
        
        # Check if we have a provided value for this key
        local provided_value=""
        if [[ -n "$param_keys" ]]; then
            # Split and search for the key
            IFS='|' read -ra keys <<< "$param_keys"
            IFS='|' read -ra values <<< "$param_values"
            
            for i in "${!keys[@]}"; do
                if [[ "${keys[i]}" == "$key" ]]; then
                    provided_value="${values[i]}"
                    break
                fi
            done
        fi
        
        if [[ -n "$provided_value" ]]; then
            # Use provided value - check if it's a file injection
            if [[ "$provided_value" == file:* ]]; then
                local file_path="${provided_value#file:}"
                if [[ "$file_path" != /* ]]; then
                    file_path="$PWD/$file_path"
                fi
                
                if [[ -f "$file_path" ]]; then
                    local file_content
                    file_content=$(cat "$file_path")
                    template_content="${template_content//$full_match/$file_content}"
                else
                    echo "Error: File '$file_path' not found." >&2
                    exit 1
                fi
            else
                template_content="${template_content//$full_match/$provided_value}"
            fi
        else
            # Use default value
            template_content="${template_content//$full_match/$default_value}"
        fi
    done
    
    # Second pass: Handle regular placeholders {{KEY}}
    while [[ "$template_content" =~ \{\{([A-Z0-9_]+)\}\} ]]; do
        local full_match="${BASH_REMATCH[0]}"
        local key="${BASH_REMATCH[1]}"
        
        # Check if we have a provided value for this key
        local provided_value=""
        if [[ -n "$param_keys" ]]; then
            # Split and search for the key
            IFS='|' read -ra keys <<< "$param_keys"
            IFS='|' read -ra values <<< "$param_values"
            
            for i in "${!keys[@]}"; do
                if [[ "${keys[i]}" == "$key" ]]; then
                    provided_value="${values[i]}"
                    break
                fi
            done
        fi
        
        if [[ -n "$provided_value" ]]; then
            # Check if it's a file injection
            if [[ "$provided_value" == file:* ]]; then
                local file_path="${provided_value#file:}"
                if [[ "$file_path" != /* ]]; then
                    file_path="$PWD/$file_path"
                fi
                
                if [[ -f "$file_path" ]]; then
                    local file_content
                    file_content=$(cat "$file_path")
                    template_content="${template_content//$full_match/$file_content}"
                else
                    echo "Error: File '$file_path' not found." >&2
                    exit 1
                fi
            else
                template_content="${template_content//$full_match/$provided_value}"
            fi
        else
            # No replacement - leave as is
            break
        fi
    done
    
    echo "$template_content"
}
