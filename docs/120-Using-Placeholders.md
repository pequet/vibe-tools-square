# Using Placeholders

Guide for template and configuration placeholder usage in `vibe-tools-square`.

## Placeholder System

Placeholders use `{{PLACEHOLDER_NAME}}` format and are replaced with user-provided values at runtime.

### Basic Example

Configuration file (`code-review.conf`):
```bash
TASK_DEFAULT_PARAMS="--reviewer=\"{{REVIEWER_NAME=Jane Doe}}\" --project=\"{{PROJECT_NAME=Current Project}}\" --focus=\"{{REVIEW_FOCUS=security and performance}}\""
```

Command:
```bash
./run-prompt.sh code-review --reviewer-name="Jane Doe" --project-name="Payment API"
```

Result: `{{REVIEWER_NAME}}` becomes "Jane Doe", `{{PROJECT_NAME}}` becomes "Payment API", `{{REVIEW_FOCUS}}` keeps default "security and performance".

## Built-in Placeholders

Always available:
- `{{TODAY_DATE}}` - Current date (YYYY-MM-DD)
- `{{TODAY_DATETIME}}` - Current date and time (YYYY-MM-DD HH:MM:SS)

## Default Values

Specify defaults using `{{PLACEHOLDER=default value}}` syntax:

```bash
TASK_DEFAULT_PARAMS="--developer=\"{{DEVELOPER_NAME=Team Lead}}\" --project=\"{{PROJECT_NAME=Main Application}}\" --priority=\"{{PRIORITY=medium}}\" --deadline=\"{{DEADLINE=end of sprint}}\""
```

## File Content Injection

Include file content using `file:` prefix:

```bash
TASK_DEFAULT_PARAMS="--requirements=\"file:docs/requirements.md\" --architecture=\"file:docs/architecture.md\" --current-status=\"file:CHANGELOG.md\""
```

Reads file content and injects it as parameter values. Supports multiple files and relative/absolute paths.

## Command Substitution

Dynamic values using shell command substitution:

```bash
TASK_DEFAULT_PARAMS="--output-file=\"reports/$(date +%Y-%m-%d_%H%M)-analysis.md\" --build-number=\"$(git rev-parse --short HEAD)\" --branch=\"$(git branch --show-current)\""
```

## Template Usage

Placeholders work in both configuration files and template files with identical substitution rules.

## Usage Example

```bash
./run-prompt.sh feature-analysis --developer-name="Jane Doe" --project-name="E-commerce Platform" --feature="payment processing" --priority="critical"
```

Substitutes `{{DEVELOPER_NAME}}` → "Jane Doe", `{{PROJECT_NAME}}` → "E-commerce Platform", `{{FEATURE}}` → "payment processing", and `{{PRIORITY}}` → "critical" before execution.

## Advanced Examples

### Multiple File Injection
```bash
TASK_DEFAULT_PARAMS="--context=\"file:docs/requirements.md,docs/technical-specs.md,CHANGELOG.md\""
```

### Combined Placeholders and File Injection
```bash
TASK_DEFAULT_PARAMS="--developer=\"{{DEVELOPER_NAME=Jane Doe}}\" --specs=\"file:{{SPEC_FILE=docs/specs.md}}\" --deadline=\"{{DEADLINE=end of sprint}}\""
```

### Dynamic Output Paths
```bash
TASK_DEFAULT_PARAMS="--output-file=\"reports/{{PROJECT_NAME}}/$(date +%Y-%m-%d_%H%M)-analysis.md\""
```

## Best Practices

- **Descriptive Names**: Use clear placeholder names (`PROJECT_DESCRIPTION` not `VAR1`)
- **Provide Defaults**: Include default values for optional parameters
- **File Path Safety**: Verify file paths exist before using `file:` injection
- **Escape Special Characters**: Follow special character guidelines for parameter values
- **Test Templates**: Use dry-run mode to verify placeholder replacement works correctly
