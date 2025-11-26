---
name: cc-subagents
description: Claude Code subagents and parallel execution
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# Subagents Guide

Comprehensive subagents documentation at @docs/claude_code/06-subagents.md

## What are Subagents?

Subagents are specialized Claude instances that run autonomously to complete specific tasks in parallel.

## Built-in Subagent Types

### Code Analysis
- **Explore** - Fast codebase exploration and search
- **Code Explorer** - Deep dive into code structure
- **Plan** - Design implementation approach

### Code Quality
- **Code Reviewer** - Review code for quality and issues
- **Silent Failure Hunter** - Find bugs that fail silently
- **PR Test Analyzer** - Analyze test coverage in PRs

### Architecture
- **Code Architect** - Design system architecture
- **general-purpose** - Multi-step complex tasks

## Key Features

**Parallel Execution** - Multiple subagents run simultaneously
**Autonomy** - Subagents work independently with their own tools
**Specialization** - Each type optimized for specific tasks
**Context Sharing** - Results returned to main Claude

## Instructions

1. Read the full subagents documentation:
```text
Read docs/claude_code/06-subagents.md
```

2. Focus on explaining:
   - Subagent types and their capabilities
   - When to use each subagent
   - Parallel execution patterns
   - Creating custom subagents
   - Tool access per subagent
   - Best practices and workflows

3. Show practical examples:
   - Codebase exploration
   - Code review workflow
   - Architecture design
   - Parallel task execution

## When to Use Subagents

**Use Explore:**
- "Find all API endpoints"
- "Understand authentication flow"
- Quick codebase searches

**Use Plan:**
- "Design database schema for users"
- "Plan refactoring approach"
- Architecture decisions

**Use Code Reviewer:**
- After completing features
- Before commits/PRs
- Quality checks

**Use Silent Failure Hunter:**
- Debug mysterious issues
- Find edge cases
- Audit error handling

## Parallel Execution

Launch multiple subagents simultaneously:

```python
# Claude will create multiple Task tool calls in one message:
Task(subagent_type="explore", prompt="Find auth code")
Task(subagent_type="code-reviewer", prompt="Review security")
Task(subagent_type="plan", prompt="Design API")
```

All three run in parallel and report back.

## Creating Custom Subagents

Custom agent definitions in `.claude/agents/`:

```markdown
---
name: my-agent
description: Custom agent for specific task
tools: [Read, Grep, Glob]
---

# Agent Instructions

Your custom agent prompt and instructions...
```

See `.claude/agents/` for examples:
- research-assistant.md
- doc-analyst.md
- knowledge-explorer.md

## Subagent vs Agent vs Skill

**Subagent** - Autonomous subprocess with own tools (via Task tool)
**Agent** - Persistent definitions in `.claude/agents/`
**Skill** - Lightweight capability without subprocess

**Hooks** - Different! Hooks run shell commands at lifecycle events.
**Commands** - Different! Commands are slash shortcuts for prompts.

## Next Steps

- Read full subagents documentation
- Check `.claude/agents/` for custom agents
- Practice parallel execution
- Create custom agents for your workflows
- Use `/cc-commands` for slash commands
- Use `/cc-hooks` for lifecycle automation
