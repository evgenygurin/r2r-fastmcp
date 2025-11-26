---
name: cc-subagents
description: Claude Code subagents for specialized task execution
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# Claude Code Subagents Guide

Comprehensive subagents documentation at @docs/claude_code/06-subagents.md

## What are Subagents?

Subagents are specialized AI assistants that Claude Code can delegate tasks to. Each subagent:
- Has a specific purpose and expertise area
- Uses its own context window (separate from main conversation)
- Can be configured with specific tools it's allowed to use
- Includes a custom system prompt that guides its behavior

## Built-in Subagents

### Plan Subagent
**Purpose:** Research and planning in plan mode
**Model:** Sonnet (more capable analysis)
**Tools:** Read, Glob, Grep, Bash
**Activation:** Automatic when in plan mode

Key characteristics:
- Searches files and analyzes code structure
- Gathers context before presenting plans
- Prevents infinite nesting (subagents can't spawn subagents)

### Explore Subagent
**Purpose:** Codebase exploration and discovery
**Tools:** Read, Grep, Glob, SemanticSearch
**Use cases:**
- Finding relevant files in large codebases
- Understanding project structure
- Locating specific functionality

### Code Explorer/Architect
**Purpose:** Architectural analysis and design
**Tools:** Read, Glob, SemanticSearch
**Use cases:**
- Analyzing system architecture
- Identifying design patterns
- Suggesting architectural improvements

### Code Reviewer
**Purpose:** Code quality and security review
**Tools:** Read, Grep, Glob, Bash
**Activation:** "Use code-reviewer to check my changes"

Review checklist:
- Code quality and readability
- Security vulnerabilities
- Performance considerations
- Test coverage
- Best practices compliance

## Instructions

1. Read the full subagents documentation:
```text
Read docs/claude_code/06-subagents.md
```

2. Explain key concepts:
   - What subagents are and how they work
   - Built-in vs custom subagents
   - Automatic vs explicit invocation
   - Context separation benefits
   - Tool permission configuration

3. Show examples of:
   - Creating custom subagents
   - Using `/agents` command for management
   - Subagent file structure (.claude/agents/)
   - YAML frontmatter configuration

4. Demonstrate practical use cases:
   - Test runner automation
   - Code review workflows
   - Debugging specialists
   - Data analysis agents

## Creating Custom Subagents

### Quick Start with `/agents`

```bash
# Open interactive subagent manager
/agents

# Then:
# 1. Select "Create New Agent"
# 2. Choose project-level or user-level
# 3. Generate with Claude (recommended) or create manually
# 4. Select tools to grant access
# 5. Save and use
```

### File Structure

**Location:** `.claude/agents/<name>.md`

**Format:**
```markdown
---
name: your-subagent-name
description: When to invoke this subagent (proactive usage)
tools: Read, Bash, Grep, Glob  # Optional - inherits all if omitted
model: sonnet                   # Optional - sonnet/opus/haiku/inherit
permissionMode: default         # Optional
skills: skill1, skill2          # Optional - auto-load skills
---

# Subagent System Prompt

Your detailed instructions for the subagent's behavior, role, and approach.

Include:
- Specific responsibilities
- Decision-making guidelines
- Best practices to follow
- Output format preferences
```

## Subagent Invocation

### Automatic Delegation

Claude proactively delegates based on:
- Task description in your request
- `description` field in subagent config
- Current context and available tools

**Tip:** Use phrases like "use PROACTIVELY" or "MUST BE USED" in description field.

### Explicit Invocation

```text
> Use the test-runner subagent to fix failing tests
> Have the code-reviewer subagent look at my recent changes
> Ask the debugger subagent to investigate this error
```

## Example Subagents

### Test Runner

```markdown
---
name: test-runner
description: Use proactively to run tests and fix failures
tools: Bash, Read, Edit
---

You are a test automation expert. When you see code changes:
1. Identify affected tests
2. Run appropriate test suites
3. If tests fail, analyze failures
4. Fix issues while preserving test intent
```

### Debugger

```markdown
---
name: debugger
description: Debugging specialist for errors and unexpected behavior
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate failure location
4. Implement minimal fix
5. Verify solution works
```

### Data Scientist

```markdown
---
name: data-scientist
description: Data analysis expert for SQL queries and insights
tools: Bash, Read, Write
model: sonnet
---

You are a data scientist specializing in SQL and BigQuery.

When invoked:
1. Understand data analysis requirement
2. Write efficient SQL queries
3. Use BigQuery CLI tools (bq) when appropriate
4. Analyze and summarize results
5. Present findings clearly
```

## Key Benefits

### Context Preservation
Each subagent operates in its own context, keeping main conversation focused on high-level objectives.

### Specialized Expertise
Subagents can be fine-tuned with detailed instructions for specific domains.

### Reusability
Once created, subagents work across projects and can be shared with teams.

### Flexible Permissions
Each subagent can have different tool access levels.

## Best Practices

1. **Start with Claude-generated agents** - Generate initial subagent with Claude, then customize
2. **Design focused subagents** - Single, clear responsibilities
3. **Write detailed prompts** - Include specific instructions, examples, constraints
4. **Limit tool access** - Only grant necessary tools
5. **Version control** - Check project subagents into git

## Advanced Usage

### Chaining Subagents

```text
> First use the code-analyzer subagent to find performance issues,
  then use the optimizer subagent to fix them
```

### Dynamic Selection

Claude intelligently selects subagents based on context. Make your `description` fields specific and action-oriented.

## Configuration Options

### Model Selection

```yaml
model: sonnet     # Use Sonnet model
model: opus       # Use Opus model  
model: haiku      # Use Haiku model
model: inherit    # Use same model as main conversation
```

### Permission Modes

```yaml
permissionMode: default          # Standard permission checks
permissionMode: acceptEdits      # Auto-accept file edits
permissionMode: bypassPermissions # Skip permission checks
permissionMode: plan             # Plan mode behavior
```

### Tool Configuration

```yaml
# Option 1: Inherit all tools (omit tools field)
# Option 2: Specify explicit list
tools: Read, Bash, Grep, Glob

# Option 3: Include MCP tools
tools: Read, Bash, custom-mcp-tool
```

## Subagent Locations

| Type | Location | Scope | Priority |
|------|----------|-------|----------|
| **Project subagents** | `.claude/agents/` | Current project | Highest |
| **User subagents** | `~/.claude/agents/` | All projects | Lower |
| **Plugin agents** | Plugin `agents/` dir | Per plugin | Configurable |

When names conflict, project-level takes precedence.

## Related Commands

- `/agents` - Interactive subagent management UI
- `/cc-hooks` - Lifecycle automation with hooks
- `/cc-commands` - Custom slash commands
- `/cc` - Claude Code quick reference

## Troubleshooting

**Problem:** Subagent not activating automatically
**Solution:** 
- Make description more specific and action-oriented
- Include keywords like "proactively", "automatically"
- Check tool permissions are sufficient

**Problem:** Wrong subagent being selected
**Solution:**
- Review description fields for clarity
- Use explicit invocation: "Use the X subagent..."
- Check for conflicting descriptions

**Problem:** Subagent exceeds context window
**Solution:**
- Break task into smaller subtasks
- Use multiple subagent invocations
- Reduce tool output verbosity

## Next Steps

1. Read full documentation for detailed examples
2. Try `/agents` command to explore subagents
3. Create a custom subagent for your workflow
4. Check `.claude/agents/` for existing project subagents
5. Use `/cc-commands` for slash commands (different from subagents)
