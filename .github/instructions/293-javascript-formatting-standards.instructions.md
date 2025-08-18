---
description: 
applyTo: "*.js,**/*.js"
---

# 293: JavaScript Formatting Standards

**Ensure consistent formatting and organization for all JavaScript scripts.**

## Script Structure

ALL JavaScript scripts SHOULD follow this organizational structure where applicable:

```javascript
/*
 * Attribution header (per 292-javascript-attribution-standards.instructions.md)
 */

// --- Constants & Global Variables ---
const GLOBAL_CONSTANT = 'value';
let globalVariable = null;

// --- Class Definitions ---
class MyClass {
    constructor() {
        // ...
    }

    // --- Public Methods ---
    myPublicMethod() {
        // ...
    }

    // --- Helper Methods ---
    _myHelperMethod() {
        // ...
    }
}

// --- Function Definitions ---

/**
 * JSDoc comment explaining the function's purpose.
 * @param {string} param1 - Description of parameter 1.
 * @returns {boolean} - Description of what the function returns.
 */
function myFunctionName(param1) {
    // Function implementation
}


// --- Script Entrypoint / Main Logic ---
// (If applicable, for scripts that are not purely defining classes/modules)
function main() {
    // ... main execution logic
}

main();
```

## Formatting Rules

### Section Headers
- Use `// --- Section Name ---` for major sections within a file.
- Use JSDoc blocks `/** ... */` to document all public functions and classes.

### Code Organization
1. **Constants and Globals first:** All module-level variables at the top.
2. **Classes and Functions second:** Grouped logically. Use classes to encapsulate related state and behavior.
3. **Execution last:** A single entrypoint if the script performs direct actions.

### Spacing and Indentation
- **Consistent indentation:** Use 4 spaces.
- **Blank lines:** One blank line between methods/functions, two between major sections (classes, etc.).
- **Comments:** Inline comments (`//`) should be concise and helpful.

### Naming Conventions
- **Classes:** `PascalCase`
- **Functions & Variables:** `camelCase`
- **Constants:** `UPPER_SNAKE_CASE`
- **Private/Internal Helpers:** Prefix with an underscore `_myHelper`.

# 293: JavaScript Formatting Standards

**Ensure consistent formatting and organization for all JavaScript scripts.**

## Script Structure

ALL JavaScript scripts SHOULD follow this organizational structure where applicable:

```javascript
/*
 * Attribution header (per 292-javascript-attribution-standards.instructions.md)
 */

// --- Constants & Global Variables ---
const GLOBAL_CONSTANT = 'value';
let globalVariable = null;

// --- Class Definitions ---
class MyClass {
    constructor() {
        // ...
    }

    // --- Public Methods ---
    myPublicMethod() {
        // ...
    }

    // --- Helper Methods ---
    _myHelperMethod() {
        // ...
    }
}

// --- Function Definitions ---

/**
 * JSDoc comment explaining the function's purpose.
 * @param {string} param1 - Description of parameter 1.
 * @returns {boolean} - Description of what the function returns.
 */
function myFunctionName(param1) {
    // Function implementation
}


// --- Script Entrypoint / Main Logic ---
// (If applicable, for scripts that are not purely defining classes/modules)
function main() {
    // ... main execution logic
}

main();
```

## Formatting Rules

### Section Headers
- Use `// --- Section Name ---` for major sections within a file.
- Use JSDoc blocks `/** ... */` to document all public functions and classes.

### Code Organization
1. **Constants and Globals first:** All module-level variables at the top.
2. **Classes and Functions second:** Grouped logically. Use classes to encapsulate related state and behavior.
3. **Execution last:** A single entrypoint if the script performs direct actions.

### Spacing and Indentation
- **Consistent indentation:** Use 4 spaces.
- **Blank lines:** One blank line between methods/functions, two between major sections (classes, etc.).
- **Comments:** Inline comments (`//`) should be concise and helpful.

### Naming Conventions
- **Classes:** `PascalCase`
- **Functions & Variables:** `camelCase`
- **Constants:** `UPPER_SNAKE_CASE`
- **Private/Internal Helpers:** Prefix with an underscore `_myHelper`.

