# Templates Directory

This directory is for your custom templates. Template files use the `.txt` extension and support placeholder substitution.

## How Templates Work

Templates are Markdown files with placeholder variables that get replaced during execution:

- `{{PLACEHOLDER_NAME=value}}` - Gets replaced with values from `--PLACEHOLDER_NAME=value` flags
- `{{PLACEHOLDER_NAME=file:path}}` - Injects content from specified file (use `--PLACEHOLDER_NAME=file:path`)

## Template Discovery

The system searches for templates in this order:

1. **Runtime templates**: `~/.vibe-tools-square/config/templates/` (this directory)
2. **Repo templates**: `assets/.vibe-tools-square/config/templates/` (fallback)

## Creating Custom Templates

1. Create a `.md` file in this directory (e.g., `my-template.md`)
2. Add placeholders like `{{PROJECT_NAME}}` or `{{DOCUMENTATION=file:README.md}}`
3. Use with: `./run-prompt.sh ask --template=my-template --PROJECT_NAME="My Project"`

## Template Examples

**Simple template** (`hello.txt`):
```markdown
Hello {{NAME}}, 

Please analyze the {{PROJECT}} project and focus on {{FOCUS_AREA}}.
```

**Template with file injection** (`analysis.md`):
```markdown
Based on this documentation:

{{DOCS=file:README.md}}

Please analyze the codebase structure.
```

## Default Templates

Default templates are provided in the repo assets folder and used automatically when not overridden here.
