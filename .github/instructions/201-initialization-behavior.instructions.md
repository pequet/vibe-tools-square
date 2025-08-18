---
description:  Conversation initialization protocol for identifying context and reviewing status
applyTo: "*,**/*"
---

# Initialization Behavior

ON session start ("hello", "hi", "start", "begin", "where did we left off"), ALWAYS prompt to review current state by responding with:
"Let's review [development-status.md](mdc:memory-bank/development-status.md)"

