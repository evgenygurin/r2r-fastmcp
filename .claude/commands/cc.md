---
name: cc
description: Claude Code quick reference and command overview
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# Claude Code Quick Reference

Comprehensive Claude Code documentation available at @docs/claude_code/README.md

## Documentation Structure

**Full documentation:** @docs/claude_code/

### Getting Started (1-3)
1. @docs/claude_code/01-overview-and-getting-started.md
2. @docs/claude_code/02-installation-and-setup.md
3. @docs/claude_code/03-core-features.md

### Usage (4-6)
4. @docs/claude_code/04-commands-and-usage.md
5. @docs/claude_code/05-hooks-and-customization.md
6. @docs/claude_code/06-subagents.md

### Integrations (7-9)
7. @docs/claude_code/07-mcp-integration.md
8. @docs/claude_code/08-skills-and-agents.md
9. @docs/claude_code/09-plugins-and-marketplaces.md

### Configuration (10-13)
10. @docs/claude_code/10-settings-and-configuration.md
11. @docs/claude_code/11-github-integration.md
12. @docs/claude_code/12-security-and-permissions.md
13. @docs/claude_code/13-troubleshooting-and-debugging.md

## Documentation Commands

- `/cc` - This quick reference
- `/cc-hooks` - Hooks and lifecycle automation
- `/cc-commands` - Custom slash commands guide
- `/cc-mcp` - MCP integration guide
- `/cc-subagents` - Subagents and parallel execution
- `/cc-setup` - Installation and configuration

## Core Capabilities

**Build** - Create functions, generate files, scaffold projects
**Debug** - Analyze errors, fix bugs, optimize performance
**Navigate** - Understand codebases, find code, explain patterns
**Automate** - Custom commands, hooks, subagents

## Key Features

- **CLAUDE.md** - Project memory system
- **Hooks** - Lifecycle automation (SessionStart, PreToolUse, etc.)
- **Slash Commands** - Custom workflows (30+ built-in)
- **Subagents** - Parallel task execution
- **MCP Integration** - Connect external tools
- **GitHub Integration** - PR reviews, commits, actions

## Project Custom Commands

This project has 15 slash commands:
- **R2R Commands (9):** /r2r-*, operations for R2R API
- **CC Documentation (6):** /cc-*, Claude Code documentation

Use `/help` to see all available commands.

## Next Steps

1. Read @docs/claude_code/01-overview-and-getting-started.md for introduction
2. Check @docs/claude_code/02-installation-and-setup.md for setup
3. Explore @docs/claude_code/03-core-features.md for capabilities
4. Use `/cc-hooks` for automation guide
5. Use `/cc-commands` for custom workflows
