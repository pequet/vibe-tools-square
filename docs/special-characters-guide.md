# Special Characters Guide - Vibe-Tools Square

## Template Placeholders

**Templates use UPPERCASE placeholders**: `{{STRING1}}`, `{{STRING2}}`, etc.
**Parameters use lowercase names**: `--string1=value`, `--string2=value`, etc.

The system automatically converts parameter names to uppercase when matching placeholders.

## Working Examples (TESTED AND VERIFIED)

### Example 1: Mixed Special Characters with Dollar Signs
```bash
# ✅ TESTED AND WORKING:
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash \
  --string1='"$0 bill"' \
  --string2="'\$10 bill'" \
  --string3='`$75 bill`'

# Results in template:
# - STRING1: "$0 bill" (double quotes preserved, $0 expanded by shell)
# - STRING2: '$10 bill' (single quotes preserved, $ escaped so literal $10)
# - STRING3: `$75 bill` (backticks preserved, $75 expanded by shell)
```

### Example 2: Simple Quote Escaping
```bash
# ✅ TESTED AND WORKING:
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash \
  --string1='"hey"' \
  --string2="'hey'" \
  --string3="\`hey\`" \
  --string4='`hey`'

# Results in template:
# - STRING1: "hey" (double quotes preserved)
# - STRING2: 'hey' (single quotes preserved)
# - STRING3: `hey` (backticks preserved, escaped)
# - STRING4: `hey` (backticks preserved, unescaped)
```

## Complete Special Characters Reference

### Double Quotes in Parameters
```bash
# ✅ CORRECT: Use single quotes to wrap
--param='"hello world"'           # Results in: "hello world"
--param='"$USER says hello"'      # Results in: "username says hello" (variable expanded)

# ❌ INCORRECT: Will break shell parsing
--param=""hello world""
```

### Single Quotes in Parameters  
```bash
# ✅ CORRECT: Use double quotes to wrap
--param="'hello world'"           # Results in: 'hello world'
--param="'Don'\''t do this'"      # Results in: 'Don't do this' (complex escaping)

# ❌ INCORRECT: Will break shell parsing
--param=''hello world''
```

### Backticks in Parameters
```bash
# ✅ CORRECT: Two ways to handle backticks
--param="\`hello\`"               # Results in: `hello` (escaped)
--param='`hello`'                 # Results in: `hello` (quoted)
--param='`$USER`'                 # Results in: `username` (variable expanded)

# ❌ INCORRECT: Unescaped backticks execute as commands
--param=`hello`                   # Will try to execute 'hello' command
```

### Dollar Signs (Variables)
```bash
# ✅ To EXPAND variables (shell processes them):
--param='"$USER logged in"'       # Results in: "john logged in"
--param='`$HOME/file`'            # Results in: `/home/john/file`

# ✅ To PREVENT expansion (literal $ signs):
--param="'\$50 bill'"             # Results in: '$50 bill' (literal)
--param='$50'                     # Results in: whatever $50 expands to (usually empty)

# ❌ INCORRECT: Unquoted variables
--param=$HOME                     # Will expand to path, may break on spaces
```

### Complex Real-World Examples
```bash
# ✅ FINANCIAL DATA:
--amount='"$1,234.56"'            # Results in: "$1,234.56" (literal dollar sign)
--price="'\$99.99'"               # Results in: '$99.99' (literal dollar sign)

# ✅ CODE SNIPPETS:
--code='`console.log("Hello");`'  # Results in: `console.log("Hello");`
--bash='"echo '\''hello'\''"'     # Results in: "echo 'hello'" (nested quotes)

# ✅ MIXED CONTENT:
--text='"User $USER said '\''Hi'\'' and ran `pwd`"'
# Results in: "User john said 'Hi' and ran /current/path"
```

## Shell Processing Order

1. **Shell processes the command line first**:
   - Expands variables like `$USER`, `$HOME`
   - Processes quote escaping
   - Handles command substitution (backticks)

2. **Our script receives the processed values**:
   - Performs direct string replacement in templates
   - Uses proven shell escaping for execution

3. **Final execution**:
   - Content is safely escaped using legacy `'\''` technique
   - All special characters preserved in final output

## Quote Wrapping Strategy

| Content Contains | Wrap With | Example |
|------------------|-----------|---------|
| Double quotes `"` | Single quotes `'` | `--param='"hello"'` |
| Single quotes `'` | Double quotes `"` | `--param="'hello'"` |
| Backticks `` ` `` | Either + escape | `--param="\`hello\`"` or `--param='`hello`'` |
| Dollar signs `$` | Single quotes `'` (literal) | `--param='$50'` |
| Dollar signs `$` | Double quotes `"` (expand) | `--param="$USER"` |
| Mixed characters | Plan carefully | See examples above |

## Debugging Tips

1. **Test your quoting first**:
   ```bash
   echo --param='"your value"'
   # Should output exactly: --param="your value"
   ```

2. **Check parameter parsing**:
   ```bash
   ./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --your-param
   # Look at "Parameters: X custom parameters" in output
   ```

3. **Check template replacement**:
   ```bash
   # Look at "=== PROCESSED TEMPLATE CONTENT ===" in execution log
   cat ~/.vibe-tools-square/output/[timestamp]_execution.log
   ```

## Common Mistakes

1. **Wrong placeholder case**: Use `{{STRING1}}` in templates, not `{{string1}}`
2. **Unquoted special characters**: Always quote parameters containing special characters
3. **Wrong quote type**: Use single quotes for double quotes, double quotes for single quotes
4. **Unescaped backticks**: Always escape or quote backticks to prevent command execution
5. **Variable expansion confusion**: Know when you want `$USER` expanded vs literal `$USER`

## Template Example

```
Hi this is a template for testing special characters.

Variables:
- STRING1: {{STRING1}}
- STRING2: {{STRING2}}  
- STRING3: {{STRING3}}
- STRING4: {{STRING4}}

All characters are preserved exactly.
```

Use this template with the working examples above to test your parameter escaping.