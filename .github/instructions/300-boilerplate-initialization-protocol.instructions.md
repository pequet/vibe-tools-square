---
description: 
applyTo: "*,**/*"
---

# 300: Boilerplate Initialization Protocol

## Primary Directive
**NEVER DELETE OR OVERWRITE BOILERPLATE FILES UNLESS EXPLICITLY INSTRUCTED.**

When beginning a project that is cloned or copied from a boilerplate template, you MUST assume that all files in the boilerplate are critical for the project's setup, tooling, and context.

## Protocol
1.  **IDENTIFY AS BOILERPLATE:** At the start of the session, determine if the project is based on a boilerplate. Look for signs like a `README.md` describing a boilerplate, configuration files (`vibe-tools.config.json`, `repomix.config.json`), and context directories (`memory-bank/`).
2.  **ANALYZE, DO NOT DELETE:** Your first priority is to analyze and understand the purpose of the existing files. Read the `README.md` and any documentation in `docs/` or `memory-bank/` to learn the intended workflow.
3.  **PRESERVE CONFIGURATION:** All configuration files (e.g., for `vibe-tools`, `repomix`, `.gitignore`, IDE settings) MUST be preserved.
4.  **PRESERVE CONTEXT:** The `memory-bank/` directory and its contents are CRITICAL and must not be touched unless the user instructs you to update them.
5.  **ADAPT, DON'T REPLACE:** When asked to create new files (like scripts or documentation), you must ADAPT them to the existing standards, rules, and file structures, rather than replacing or ignoring them.
6.  **SEEK CLARIFICATION:** If you are in any doubt about whether a file is part of the boilerplate and should be kept, you MUST ask the user for clarification before taking any action.

5.  **ADAPT, DON'T REPLACE:** When asked to create new files (like scripts or documentation), you must ADAPT them to the existing standards, rules, and file structures, rather than replacing or ignoring them.
6.  **SEEK CLARIFICATION:** If you are in any doubt about whether a file is part of the boilerplate and should be kept, you MUST ask the user for clarification before taking any action.
