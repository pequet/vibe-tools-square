#!/bin/bash
# providers.sh - AI provider preset handling
# Manages different AI provider configurations and presets

set -euo pipefail

# Load provider presets
load_provider_presets() {
    local presets_file="$VIBE_TOOLS_SQUARE_HOME/config/providers.conf"
    
    # Loading provider presets from: $presets_file
    
    if [[ -f "$presets_file" ]]; then
        source "$presets_file"
        # Provider presets loaded
    else
        # Provider presets file not found - this is OK, will use direct values
        return 0
    fi
}

# Convert kebab-case to SNAKE_CASE for variable lookup
kebab_to_snake() {
    local input="$1"
    echo "$input" | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'
}

# Get provider configuration
get_provider_config() {
    local provider="$1"
    local config_key="$2"
    
    # Getting $config_key for provider: $provider
    
    # Convert to SNAKE_CASE variable name
    local var_name="${config_key}_$(kebab_to_snake "$provider")"
    
    # Get the value of the variable
    local value="${!var_name:-}"
    
    if [[ -n "$value" ]]; then
        echo "$value"
    else
        # Provider config not found: $var_name
        echo "ERROR: Provider mapping not found for $var_name" >&2
        return 1
    fi
}

# Resolve provider/model mapping from kebab-case input
resolve_provider_model() {
    local input_model="$1"
    local provider=""
    local model=""
    
    # Split provider/model at /
    if [[ "$input_model" == */* ]]; then
        provider="${input_model%%/*}"
        model="${input_model#*/}"
    else
        model="$input_model"
    fi
    
    # Get original provider name for model variable construction
    local original_provider="${input_model%%/*}"
    local provider_snake=$(kebab_to_snake "$original_provider")
    local has_errors=false
    
    # Look up actual provider value from config
    if [[ -n "$provider" ]]; then
        local provider_var="PROVIDER_${provider_snake}"
        local provider_value="${!provider_var:-}"
        if [[ -n "$provider_value" ]]; then
            provider="$provider_value"
        else
            echo "ERROR: Provider mapping not found for $provider_var" >&2
            has_errors=true
        fi
    fi
    
    # Look up actual model value from config
    if [[ -n "$model" ]]; then
        local model_snake=$(kebab_to_snake "$model")
        local model_var="MODEL_${provider_snake}_${model_snake}"
        local resolved_model="${!model_var:-}"
        
        if [[ -n "$resolved_model" ]]; then
            model="$resolved_model"
        else
            echo "ERROR: Model mapping not found for $model_var" >&2
            has_errors=true
        fi
    fi
    
    # Return error only after checking both
    if [[ "$has_errors" == true ]]; then
        return 1
    fi
    
    echo "$provider|$model"
}

# Validate provider is available
validate_provider() {
    local provider="$1"
    
    # TODO: Phase 2 - Implement provider validation
    # Validating provider: $provider
    return 0
}

# Initialize provider system
init_providers() {
    # Initializing provider system
    load_provider_presets
    # Provider system initialized
}