# Output Directory

Default location for command outputs when no specific output file is specified.

## Structure

Outputs are organized by date:
```
output/
├── 2025-01-15/
│   ├── 2025-01-15_1430-template-name-result.md
│   └── 2025-01-15_1445-another-result.md
└── 2025-01-16/
    └── 2025-01-16_0900-morning-result.md
```

## File Naming

Files are automatically timestamped using the format:
`YYYY-MM-DD_HHMM-description.md`

The description is derived from the template name and command context.