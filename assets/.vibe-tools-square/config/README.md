# Configuration Directory

This directory contains configuration files and templates for Vibe-Tools Square.

## Files

- `default.conf` - Default environment variables and settings
- `providers.conf.example` - Example provider configurations (copy to `providers.conf` to use)
- `templates/` - Template collection for various use cases

## Configuration Hierarchy

1. Command-line arguments (highest priority)
2. Environment variables
3. `providers.conf` (if exists)
4. `default.conf` (fallback)

## Templates

Templates support placeholder replacement with `{{TOKEN}}` syntax:
- `{{TODAY_DATE}}` - Current date
- `{{TODAY_DATETIME}}` - Current date and time  
- `{{PARAM_NAME}}` - Custom parameters from command line
- `file:path/to/file.txt` - File content injection