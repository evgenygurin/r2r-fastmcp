---
name: cc-commands
description: Claude Code custom slash commands guide
allowed-tools: Read, Glob
model: claude-3-5-haiku-20241022
---

# Claude Code Custom Commands Guide

Read and explain custom slash commands documentation from `docs/claude_code/04-commands-and-usage.md`.

## What are Slash Commands?

Slash commands are shortcuts for common workflows. When executed, they expand to full prompts that guide Claude.

## Built-in Commands (30+)

### Session Management
- `/help` - Show available commands
- `/resume` - Continue previous conversation
- `/clear` - Clear session context
- `/exit` - End session

### Context Management
- `/context` - Show current context
- `/add <path>` - Add files to context
- `/remove <path>` - Remove from context

### Configuration
- `/config` - View/edit settings
- `/permissions` - Manage tool permissions
- `/model` - Switch models

### Debugging
- `/debug` - Toggle debug mode
- `/logs` - View logs
- `/health` - System health check

## Creating Custom Commands

### Structure

Location: `.claude/commands/<command-name>.md`

Format:
```markdown
---
name: command-name
description: Brief description
allowed-tools: Bash, Read, Glob
model: claude-3-5-haiku-20241022
---

# Command Title

Instructions for Claude when this command is invoked.

You can use parameters: **$1**, **$2**, etc.

## Instructions

Execute:
\`\`\`bash
# Your bash commands here
your-script.sh "$1" "$2"
\`\`\`

Present results...
```

## Instructions

1. Read the full commands documentation:
```text
Read docs/claude_code/04-commands-and-usage.md
```

2. Focus on explaining:
   - Built-in slash commands and their usage
   - Creating custom commands (structure, parameters, tools)
   - YAML frontmatter (name, description, permissions)
   - SlashCommand tool for execution
   - Namespacing for organization
   - Best practices

3. Show practical examples:
   - Code review command
   - Component generator
   - Test runner
   - Deploy automation

## Example Custom Commands

**Code Review:**
```markdown
---
name: review
description: Review code for quality and best practices
allowed-tools: Read, Grep, Glob
model: claude-3-5-haiku-20241022
---

# Code Review

Review the specified file or directory for:
- Code quality
- Best practices
- Potential bugs
- Performance issues

File/directory: **$1**
```

**Component Generator:**
```markdown
---
name: component
description: Generate React component with tests
allowed-tools: Write, Bash
model: claude-3-5-haiku-20241022
---

# Component Generator

Generate React component: **$1**

Create:
1. Component file (src/components/$1.tsx)
2. Test file (src/components/$1.test.tsx)
3. Storybook story (src/components/$1.stories.tsx)
```

## Existing Commands in This Project

Check `.claude/commands/` for R2R commands:
- `/r2r-search` - Search R2R knowledge base
- `/r2r-rag` - RAG query with generation
- `/r2r-agent` - Multi-turn agent conversation
- `/r2r-collections` - Manage collections
- `/r2r-upload` - Upload documents

## Next Steps

- Read full documentation for detailed guide
- Explore existing commands in `.claude/commands/`
- Create custom commands for your workflow
- Use `/cc-hooks` for lifecycle automation (different from commands)
