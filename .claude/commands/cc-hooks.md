---
name: cc-hooks
description: Claude Code hooks and lifecycle automation
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# Claude Code Hooks Guide

Comprehensive hooks documentation at @docs/claude_code/05-hooks-and-customization.md

## What are Hooks?

Hooks are shell commands that execute at specific lifecycle events in Claude Code sessions.

## Available Hook Types

### Session Hooks
- **SessionStart** - Runs when Claude Code session starts
- **SessionEnd** - Runs when session ends

### Tool Hooks
- **PreToolUse** - Before any tool execution
- **PostToolUse** - After tool completion

### Subagent Hooks
- **SubagentStart** - When subagent launches
- **SubagentStop** - When subagent completes

### Other Hooks
- **Stop** - On error or interruption

## Instructions

1. Read the full hooks documentation:
```text
Read docs/claude_code/05-hooks-and-customization.md
```

2. Focus on explaining:
   - Hook types and when they trigger
   - Creating custom hooks (`.claude/hooks/` structure)
   - Practical examples (validation, auto-format, testing, notifications)
   - Security considerations
   - Debugging hooks

3. Show relevant examples from the documentation
4. Suggest hooks configuration based on user needs

## Common Use Cases

**Validation Hooks:**
- PreToolUse/Bash - validate commands before execution
- Block dangerous operations

**Automation Hooks:**
- PostToolUse/Write - auto-format code after edits
- PostToolUse/Edit - run tests after changes

**Notification Hooks:**
- SessionStart - check environment/dependencies
- SessionEnd - cleanup, reporting

**Logging Hooks:**
- All hooks - audit trail of operations

## Hook Structure

Location: `.claude/hooks/<EventType>/<hook-name>.md`

Format:
```markdown
---
name: hook-name
description: What this hook does
---

# Hook Title

Bash commands to execute when hook triggers.

\`\`\`bash
#!/bin/bash
# Your shell commands here
\`\`\`
```

## Next Steps

- Read full documentation for detailed examples
- Check `.claude/hooks/` for existing hooks in this project
- Create custom hooks for your workflow
- Use `/cc-commands` for slash commands (different from hooks)
