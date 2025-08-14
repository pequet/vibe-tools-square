# Configuration Directory

This directory contains runtime configuration for `vibe-tools-square`.

## Files

- `default.conf` - Environment variables and default settings
- `providers.conf` - AI provider presets with aliases
- `vibe-tools.config.json` - Vibe-tools specific configuration
- `templates/` - Template collection (copied from development repo)

## Configuration Hierarchy

1. Environment variables in `default.conf`
2. Provider presets from `providers.conf`
3. Command-line flags (override everything)
4. Vibe-tools configuration from `vibe-tools.config.json`

## Provider Presets

Use aliases to define provider+model combinations:

```bash
# Example usage with preset aliases
run-prompt ask --template=analysis --preset=gemini-free
run-prompt repo --template=review --preset=openrouter-cheap
```

## Template Management

Templates are automatically synced from the development repository during installation. To add custom templates, place them in `templates/` - they will be preserved during updates.
