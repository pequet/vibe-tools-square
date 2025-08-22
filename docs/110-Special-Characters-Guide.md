# Special Characters Guide

Quick reference for handling special characters in `vibe-tools-square` parameters and templates.

## Template Placeholder System

- **Templates**: Use `{{UPPERCASE}}` placeholders (`{{STRING1}}`, `{{STRING2}}`)
- **Parameters**: Use `--lowercase` names (`--string1=value`, `--string2=value`)
- **Conversion**: System automatically converts parameter names to uppercase for matching



## Quick Reference Table

| Character | Context | Wrap With | Example | Result | Notes |
|-----------|---------|-----------|---------|--------|-------|
| `"` (double quote) | Parameter | Single quotes `'` | `--param='"hello"'` | `"hello"` | Preserves spaces, prevents expansion |
| `"` (double quote) | Template | N/A | `{{PARAM="hello"}}` | `"hello"` | No wrapping needed in templates |
| `'` (single quote) | Parameter | Double quotes `"` | `--param="'hello'"` | `'hello'` | Prevents variable expansion |
| `'` (single quote) | Template | N/A | `{{PARAM='hello'}}` | `'hello'` | No wrapping needed in templates |
| `` ` `` (backtick) | Parameter | Single quotes `'` | `--param='`cmd`'` | `` `cmd` `` | Prevents command execution |
| `` ` `` (backtick) | Template | N/A | `{{PARAM=`cmd`}}` | `` `cmd` `` | No wrapping needed in templates |
| `$` (literal) | Parameter | Single quotes `'` | `--param='$50'` | `$50` | Prevents variable expansion |
| `$` (expand) | Parameter | Double quotes `"` | `--param="$USER"` | `john` | Expands environment variables |
| `$` (literal) | Template | N/A | `{{PARAM=$50}}` | `$50` | No wrapping needed in templates |
| `\` (backslash) | Parameter | N/A | `--param="value\\path"` | `value\path` | Used to escape special characters |
| ` ` (space) | Parameter | Quotes `"` or `'` | `--param="multi word value"` | `multi word value` | Required for multi-word parameters |

## Detailed Examples

### Double Quotes in Parameters
```bash
# ✅ CORRECT: Use single quotes to wrap
--param='"hey"'                   # → "hey"
--param='"hello world"'           # → "hello world"
--param='"$USER says hello"'      # → "john says hello" (expanded)
--param='"$1,234.56"'             # → "$1,234.56" (literal)

# ❌ INCORRECT: Will break shell parsing
--param=""hello world""
```

### Single Quotes in Parameters  
```bash
# ✅ CORRECT: Use double quotes to wrap
--param="'hey'"                   # → 'hey'
--param="'hello world'"           # → 'hello world'
--param="'\$10 bill'"             # → '$10 bill' (literal $)
--param="'Don'\''t do this'"      # → 'Don't do this' (complex)

# ❌ INCORRECT: Will break shell parsing
--param=''hello world''
```

### Backticks in Parameters
```bash
# ✅ CORRECT: Escape or quote backticks
--param="\`hey\`"                 # → `hey` (escaped)
--param='`hey`'                   # → `hey` (quoted)
--param='`console.log("Hello");`' # → `console.log("Hello");`
--param='`$100 bill`'             # → `$100 bill` (literal)

# ❌ INCORRECT: Will execute as command
--param=`hello`
```

### Dollar Signs (Variables)
```bash
# ✅ EXPAND variables (use double quotes)
--param='"$USER logged in"'       # → "john logged in"
--param='"$HOME/file"'            # → "/home/john/file"

# ✅ LITERAL dollar signs (use single quotes)
--param="'\$10 bill'"             # → '$10 bill'
--param='$50'                     # → $50 (literal)
--param='"$1,234.56"'             # → "$1,234.56" (literal, $1 empty)

# ❌ INCORRECT: Unquoted variables
--param=$HOME                     # May break on spaces
```

### Complex Examples
```bash
# Financial data
--amount='"$1,234.56"'            # → "$1,234.56" (literal)
--price="'\$99.99'"               # → '$99.99' (literal)

# Code snippets
--code='`console.log("Hello");`'  # → `console.log("Hello");`
--bash='"echo '\''hello'\''"'     # → "echo 'hello'" (nested)

# Mixed content
--text='"User $USER said '\''Hi'\'' and ran `pwd`"'
# → "User john said 'Hi' and ran /current/path"
```

## Processing Flow

1. **Shell processing**: Expands variables, handles quote escaping, processes backticks
2. **Script processing**: Direct string replacement in templates, safe shell escaping
3. **Final output**: All special characters preserved using proven escaping techniques

## Wrapping Strategy

| Content | Wrap With | Example |
|---------|-----------|---------|
| Double quotes `"` | Single quotes `'` | `--param='"hello"'` |
| Single quotes `'` | Double quotes `"` | `--param="'hello'"` |
| Backticks `` ` `` | Either + escape | `--param="\`hello\`"` |
| Dollar signs `$` (literal) | Single quotes `'` | `--param='$50'` |
| Dollar signs `$` (expand) | Double quotes `"` | `--param="$USER"` |

## Debugging

### Test Parameter Quoting
```bash
# Test your quoting before using in commands
echo --param='"your value"'  # Should output: --param="your value"
echo --param="'single quoted'"  # Should output: --param='single quoted'
echo --param='`backtick value`'  # Should output: --param=`backtick value`
```

### Check Parameter Processing
```bash
# Use dry-run mode to see how parameters are processed
./run-prompt.sh ask --template=hello --model=gemini/gemini-2.0-flash --test-param="your value"
# Look for "Parameters: X custom parameters" in output

# Check what command gets constructed
./run-prompt.sh ask --prompt="test" --model=gemini/gemini-2.0-flash --special-chars='"quotes and $vars"'
```

### Verify Template Replacement
```bash
# Check execution logs for template processing
cat ~/.vibe-tools-square/output/[timestamp]_execution.log
# Look for "=== PROCESSED TEMPLATE CONTENT ===" section

# Check logs directory for detailed output
ls -la ~/.vibe-tools-square/logs/
```

## Character Handling

- **Templates**: All special characters preserved exactly
- **Parameters**: Shell processes first, then passed to script
- **Replacement**: Direct string replacement preserves all characters  
- **Execution**: Automatic shell escaping using proven `'\''` technique

## Common Mistakes

1. Wrong placeholder case: Use `{{STRING1}}`, not `{{string1}}`
2. Unquoted special characters: Always quote parameters with special characters
3. Wrong quote type: Use single quotes for double quotes, double quotes for single quotes
4. Unescaped backticks: Always escape or quote backticks to prevent command execution
5. Variable expansion confusion: Know when you want `$USER` expanded vs literal `$USER`
