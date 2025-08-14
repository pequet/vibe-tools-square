# Default Output Directory

This directory contains output from `vibe-tools-square` commands when no specific output file is specified.

## File Naming Convention

Output files are automatically timestamped:
- `YYYY-MM-DD_HHMM-command-template.md`

## Examples

```
2025-08-14_1430-repo-analysis.md
2025-08-14_1445-ask-metacognitive.md
2025-08-14_1500-plan-feature-implementation.md
```

## Organization

Files are organized by date for easy browsing. Older files can be safely archived or deleted as needed.

## Custom Output

To save to a specific location instead of this directory, use the `--output-file` flag:

```bash
run-prompt ask --template=analysis --output-file=/path/to/specific/file.md
```
