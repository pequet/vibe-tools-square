# Testing Commands - Vibe-Tools Square

This document provides commands to test the functionality of `vibe-tools-square` at each development phase.

## Phase 1 Ask Implementation Tests ✅ COMPLETED

The `ask` task is fully implemented with template processing, parameter replacement, and proper shell escaping.

### Basic Ask with String Parameters (Dry Run)
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --project="My Project" --description="Testing basic parameters"
```

### Ask with File Content Injection (Dry Run)
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --documentation=file:README.md
```

### Ask with Custom Output File (Dry Run)
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --output-file=test-output.md
```

### Ask with Provider Parameter (Dry Run)
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --provider=gemini
```

### Ask Actual Execution (`--go` flag)
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --project="Real Test" --go
```

### Ask with Multiple File Injection
```bash
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test User" --documentation=file:README.md,docs/special-characters-guide.md
```

### Template Discovery Test (for nonexistent templates)
```bash
./run-prompt.sh ask --template=nonexistent --model=gemini/gemini-2.0-flash --name="Test User"
# Should show error: Template not found
```

### Special Characters Testing ✅ VERIFIED WORKING

Test the documented special character handling:

```bash
# Test 1: Mixed special characters with dollar signs
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash \
  --string1='"$0 bill"' \
  --string2="'\$10 bill'" \
  --string3='`$75 bill`'

# Test 2: Simple quote escaping
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash \
  --string1='"hey"' \
  --string2="'hey'" \
  --string3="\`hey\`" \
  --string4='`hey`'

# Test 3: Complex nested quotes
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash \
  --string1='"Complex \"nested\" quotes"' \
  --string2="'Don'\''t break this'" \
  --string3="\`echo 'hello'\`"

# Test 4: Variable expansion vs literal
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash \
  --string1='"User: $USER"' \
  --string2="'Literal: \$USER'" \
  --string3='`pwd`'
```

## Phase 1 (Current): ✅ Foundation Complete

**Completed Features:**
- ✅ **Core CLI**: `run-prompt.sh ask --template=<name> --model=<provider/model>`
- ✅ **Dry Run Default**: Shows execution plan without contacting AI
- ✅ **`--go` Flag**: Explicit execution mode
- ✅ **Template System**: Placeholder replacement with `{{PARAM_NAME}}`
- ✅ **File Injection**: `--param=file:path/to/file.txt` syntax
- ✅ **Special Character Handling**: Proven shell escaping for all edge cases
- ✅ **Multiple Templates**: Template discovery in `assets/.vibe-tools-square/config/templates/`
- ✅ **Template Content Preview**: Shows processed content in dry run
- ✅ **Proper Output Handling**: Default timestamped files in `~/.vibe-tools-square/output/`
- ✅ **Provider/Model Parsing**: Automatic extraction from `provider/model` format
- ✅ **Comprehensive Logging**: Complete execution details logged for both dry run and live execution
- ✅ **Cost Control**: `--max-tokens` parameter support

**Templates Available:**
- `hello`: Basic parameter demonstration template
- `hi`: Special characters testing template

## Phase 2: Isolated Context Environment (ICE) - PLANNED

Phase 2 will add context curation for `repo` and `plan` commands.

### Expected Phase 2 Tests (Not Yet Implemented)
```bash
# Repo command with context curation
./run-prompt.sh repo --template=code-review --model=gemini/gemini-2.0-flash --context-filter="*.js,*.ts" --go

# Plan command with curated context
./run-prompt.sh plan --template=feature-plan --model=gemini/gemini-2.0-flash --include-dirs="src/,docs/" --go

# Context preview (dry run)
./run-prompt.sh repo --template=analyze --model=gemini/gemini-2.0-flash --show-context-only
```

## Testing Strategy

### 1. Feature Testing
- Test each parameter type individually
- Test combinations of parameters
- Test edge cases (empty values, special characters)
- Test error conditions (missing templates, invalid models)

### 2. Special Characters Testing
- Follow examples in `docs/special-characters-guide.md`
- Test all combinations of quotes, backticks, dollar signs
- Verify both shell processing and template replacement

### 3. Integration Testing
- Test with different AI providers (gemini, openai, anthropic)
- Test with different models
- Test actual AI responses end-to-end
- Verify output file creation and logging

### 4. Performance Testing
- Test with large templates
- Test with large file injections
- Test with high token limits
- Monitor execution times and log file sizes

## Common Test Patterns

### Dry Run First, Then Execute
```bash
# 1. Test dry run first
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test"

# 2. If dry run looks good, execute
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --name="Test" --go
```

### Check Logs for Debugging
```bash
# View latest execution log
ls -la ~/.vibe-tools-square/output/*.log | tail -1
cat $(ls -la ~/.vibe-tools-square/output/*.log | tail -1 | awk '{print $NF}')
```

### Test Parameter Parsing
```bash
# Look for "Parameters: X custom parameters" in output
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --test1=value1 --test2=value2 | grep "Parameters:"
```

## Error Testing

### Invalid Templates
```bash
./run-prompt.sh ask --template=invalid --model=gemini/gemini-2.0-flash
# Should show: Template not found error
```

### Invalid Models
```bash
./run-prompt.sh ask --template=hello --model=invalid/model --go
# Should show: Model not found error from vibe-tools
```

### Missing Required Parameters
```bash
./run-prompt.sh ask --model=gemini/gemini-2.0-flash
# Should show: Template is required error
```

## Verification Checklist

For each test, verify:
- [ ] Dry run shows complete execution plan
- [ ] Parameters are parsed correctly
- [ ] Template content is processed properly
- [ ] Special characters are handled safely
- [ ] Output file paths are correct
- [ ] Execution logs contain all details
- [ ] AI responses are saved (for `--go` tests)
- [ ] No shell injection vulnerabilities
