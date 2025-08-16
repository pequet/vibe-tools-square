# Special Characters Guide - Vibe-Tools Square

## Template Placeholders

**Templates use UPPERCASE placeholders**: `{{STRING1}}`, `{{STRING2}}`, etc.
**Parameters use lowercase names**: `--string1=value`, `--string2=value`, etc.

The system automatically converts parameter names to uppercase when matching placeholders.



## Complete Special Characters Reference

### Double Quotes in Parameters
```bash
# ✅ CORRECT: Use single quotes to wrap (simple)
--param='"hey"'                   # Results in: "hey"
--param='"hello world"'           # Results in: "hello world"

# ✅ CORRECT: With variable expansion
--param='"$USER says hello"'      # Results in: "username says hello" (variable expanded)
--param='"$5 bill"'               # Results in: "$5 bill" (shell expands $5)

# ✅ CORRECT: Literal dollar signs
--param='"$1,234.56"'             # Results in: "$1,234.56" (literal, $1 usually empty)

# ❌ INCORRECT: Will break shell parsing
--param=""hello world""
```

### Single Quotes in Parameters  
```bash
# ✅ CORRECT: Use double quotes to wrap (simple)
--param="'hey'"                   # Results in: 'hey'
--param="'hello world'"           # Results in: 'hello world'

# ✅ CORRECT: With literal dollar signs
--param="'\$10 bill'"             # Results in: '$10 bill' (literal $10)
--param="'\$99.99'"               # Results in: '$99.99' (literal dollar sign)

# ✅ CORRECT: Complex escaping (advanced)
--param="'Don'\''t do this'"      # Results in: 'Don't do this' (complex escaping)

# ❌ INCORRECT: Will break shell parsing
--param=''hello world''
```

### Backticks in Parameters
```bash
# ✅ CORRECT: Simple backticks (two ways)
--param="\`hey\`"                 # Results in: `hey` (escaped)
--param='`hey`'                   # Results in: `hey` (quoted)

# ✅ CORRECT: Variables preserved literally in single quotes
--param='`$100 bill`'             # Results in: `$100 bill` (literal, no expansion in single quotes)

# ✅ CORRECT: Code snippets
--param='`console.log("Hello");`' # Results in: `console.log("Hello");`

# ❌ INCORRECT: Unescaped backticks execute as commands
--param=`hello`                   # Will try to execute 'hello' command
```

### Dollar Signs (Variables)
```bash
# ✅ To EXPAND variables (shell processes them):
--param='"$USER logged in"'       # Results in: "john logged in"
--param='"$5 bill"'               # Results in: "$5 bill" (shell expands $5)
--param='`$HOME/file`'            # Results in: `/home/john/file`

# ✅ To PREVENT expansion (literal $ signs):
--param="'\$10 bill'"             # Results in: '$10 bill' (literal $10)
--param="'\$50 bill'"             # Results in: '$50 bill' (literal)
--param="'\$99.99'"               # Results in: '$99.99' (literal dollar sign)

# ✅ Mixed scenarios:
--param='$50'                     # Results in: whatever $50 expands to (usually empty)
--param='"$1,234.56"'             # Results in: "$1,234.56" (literal, $1 usually empty)

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

## How Special Characters Are Handled

1. **In Templates**: All special characters are preserved exactly as written
2. **In Parameters**: Characters are processed by the shell first, then passed to our script
3. **During Replacement**: Our script uses direct string replacement, preserving all characters
4. **During Execution**: Our script uses proven shell escaping (`'\''` technique for single quotes)

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

## Shell Escaping Summary

The system handles shell escaping automatically using the proven legacy technique:
- Single quotes in content are escaped as `'\''`
- All other characters are protected by single quote wrapping
- No additional escaping needed by the user

## Common Mistakes

1. **Wrong placeholder case**: Use `{{STRING1}}` in templates, not `{{string1}}`
2. **Unquoted special characters**: Always quote parameters containing special characters
3. **Wrong quote type**: Use single quotes for double quotes, double quotes for single quotes
4. **Unescaped backticks**: Always escape or quote backticks to prevent command execution
5. **Variable expansion confusion**: Know when you want `$USER` expanded vs literal `$USER`
