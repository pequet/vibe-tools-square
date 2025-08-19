# Using Placeholders in Configuration Files

This guide explains how to use the placeholder substitution system in task configuration files.

## Basic Usage

You can use placeholders in your task configuration files that will be replaced with values provided by the user at runtime.

Placeholders use the format `{{PLACEHOLDER_NAME}}` and can be included in any parameter value in your configuration file.

Example in a task configuration file (`hello.conf`):

```bash
# Task configuration with placeholders
TASK_DEFAULT_PARAMS="--name=\"{{USER_NAME=Hello User}}\" --project=\"{{PROJECT_NAME=Hello World}}\""
```

When a user runs the command:

```bash
./run-prompt.sh hello --user-name="John"
```

The placeholder `{{USER_NAME}}` will be replaced with "John", while `{{PROJECT_NAME}}` will keep its default value.

## Special Placeholders

The system includes some built-in placeholders that are always available:

- `{{TODAY_DATE}}`: Current date in YYYY-MM-DD format
- `{{TODAY_DATETIME}}`: Current date and time in YYYY-MM-DD HH:MM:SS format

## File Content Injection

You can also include file content as a parameter value using the `file:` prefix:

```bash
# Including file content
TASK_DEFAULT_PARAMS="--documentation=file:README.md"
```

This will read the content of README.md and use it as the value for the `--documentation` parameter.

## Default Values in Placeholders

You can specify default values for placeholders that will be used if no override is provided:

```bash
# Using default values
TASK_DEFAULT_PARAMS="--name=\"{{USER_NAME=Hello User}}\" --project=\"{{PROJECT_NAME=Hello World}}\""
```

## Command Substitution

The configuration system still supports command substitution for dynamic values:

```bash
# Using command substitution
TASK_DEFAULT_PARAMS="--output-file=\"output/$(date +%Y-%m-%d_%H%M)-report.md\""
```

## Usage in Templates

Placeholders can also be used in template files, not just in configuration parameters. The same substitution rules apply.

## Example Command

```bash
./run-prompt.sh hello --user-name="John" --project-name="MK-Ultra"
```

This will substitute `{{USER_NAME}}` with "John" and `{{PROJECT_NAME}}` with "MK-Ultra" in the task configuration before execution.
