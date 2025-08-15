# Special Characters Guide - Vibe-Tools Square

## Template Placeholders

**Templates use UPPERCASE placeholders**: `{{STRING1}}`, `{{STRING2}}`, etc.
**Parameters use lowercase names**: `--string1=value`, `--string2=value`, etc.

The system automatically converts parameter names to uppercase when matching placeholders.

## Passing Special Characters in Parameters

### Double Quotes in Parameters
```bash
# ✅ CORRECT: Use single quotes to wrap parameters containing double quotes
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string1='"hey"'

# ❌ INCORRECT: Will break shell parsing
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string1=""hey""
```

### Single Quotes in Parameters  
```bash
# ✅ CORRECT: Use double quotes to wrap parameters containing single quotes
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string2="'hey'"

# ❌ INCORRECT: Will break shell parsing
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string2=''hey''
```

### Backticks in Parameters
```bash
# ✅ CORRECT: Escape backticks with backslash OR use quotes
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string3="\`hey\`"
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string3='`hey`'

# ❌ INCORRECT: Unescaped backticks will execute as commands
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string3=`hey`
```

### Dollar Signs in Parameters
```bash
# ✅ CORRECT: Use single quotes to prevent variable expansion
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string4='$HOME and $USER'

# ❌ INCORRECT: Will expand variables
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash --string4=$HOME and $USER
```

### Complex Mixed Characters
```bash
# ✅ CORRECT: Mix of all special characters properly quoted
./run-prompt.sh ask --template=hi --model=gemini/gemini-2.0-flash \
  --string1='"hey"' \
  --string2="'hey'" \
  --string3="\`hey\`" \
  --string4='$VARS'
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
- Double quotes: {{STRING1}}
- Single quotes: {{STRING2}}  
- Backticks: {{STRING3}}
- Dollar signs: {{STRING4}}

All characters are preserved exactly.
```

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
