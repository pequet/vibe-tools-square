#!/bin/bash
# template.sh - Template loading and placeholder processing
# Handles the core template system from the legacy script

set -euo pipefail

# Load and process template
load_template() {
    local template_name="$1"
    local template_path
    
    # Find template file
    template_path=$(find_template "$template_name")
    if [[ ! -f "$template_path" ]]; then
        print_error "Template not found: $template_name"
        exit 1
    fi
    
    cat "$template_path"
}

# Find template file in search paths
find_template() {
    local template_name="$1"
    local search_paths=(
        "$VIBE_TOOLS_SQUARE_HOME/config/templates/$template_name"
        "$VIBE_TOOLS_SQUARE_HOME/config/templates/$template_name/template.txt"
        "$(pwd)/config/templates/$template_name"
        "$(pwd)/config/templates/$template_name/template.txt"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    print_error "Template not found in any search path: $template_name"
    return 1
}

# Process placeholders in template content
# Extracted and adapted from legacy run_prompt.sh replace_placeholders() function
process_placeholders() {
    local template_content="$1"
    shift
    local params=("$@")
    
    # Replace date placeholders
    local today_date=$(date +"%Y-%m-%d")
    local today_datetime=$(date +"%Y-%m-%d %H:%M:%S")
    
    template_content=$(echo "$template_content" | sed "s/{{TODAY_DATE}}/$today_date/g")
    template_content=$(echo "$template_content" | sed "s/{{TODAY_DATETIME}}/$today_datetime/g")
    
    # Find repository root for file injection
    local repo_root
    repo_root=$(find_repo_root)
    
    # Process custom parameter placeholders
    for param in "$@"; do
        if [[ "$param" == --*=* ]]; then
            # Extract key and value
            local key="${param#--}"
            key="${key%%=*}"
            local value="${param#*=}"
            
            # Convert \n to actual newlines in the value BEFORE any other processing
            value=$(printf '%b' "$value")
            
            # Convert key to uppercase for placeholder
            local placeholder_key=$(echo "$key" | tr '[:lower:]' '[:upper:]')
            
            # Check if value starts with 'file:' prefix - if so, read the file content
            if [[ "$value" == file:* ]]; then
                local file_paths_str="${value#file:}"
                
                # Create a marker for the placeholder
                local placeholder="{{$placeholder_key}}"
                
                # Split the content at the placeholder
                local before_placeholder="${template_content%%$placeholder*}"
                local after_placeholder="${template_content#*$placeholder}"
                
                # Initialize an empty string for all file contents
                local all_file_contents=""
                
                # Split on unescaped commas only
                IFS=',' read -ra file_paths <<< "$file_paths_str"
                
                for file_path in "${file_paths[@]}"; do
                    # Convert to absolute path if it's a relative path
                    if [[ "$file_path" != /* ]]; then
                        file_path="${repo_root}/${file_path}"
                    fi
                    
                    if [ -f "$file_path" ]; then
                        print_info "Reading file: $file_path"
                        
                        # Read the file content and concatenate
                        if [ -n "$all_file_contents" ]; then
                            # Add a newline between file contents
                            all_file_contents+=$'\n\n'
                        fi
                        all_file_contents+=$(cat "$file_path")
                    else
                        print_error "File '$file_path' not found."
                        print_error "Paths should be relative to the repository root: ${repo_root}"
                        print_error "Current directory: $(pwd)"
                        exit 1
                    fi
                done
                
                # Reassemble the content with the combined file content in place of the placeholder
                template_content="${before_placeholder}${all_file_contents}${after_placeholder}"
                
            else
                # Direct parameter substitution that preserves content exactly as provided
                if [[ "$template_content" == *"{{$placeholder_key}}"* ]]; then
                    # Use direct parameter expansion to avoid any escaping or interpretation
                    template_content=${template_content//\{\{$placeholder_key\}\}/$value}
                fi
            fi
        fi
    done
    
    echo "$template_content"
}

# Find repository root (where .git directory exists)
find_repo_root() {
    local current_dir="$PWD"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.git" ]]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    echo "$PWD"  # Fallback to current directory if no .git found
    return 1
}

# Initialize template system
init_template() {
    # TODO: Copy templates from development repo if needed
    return 0
}
