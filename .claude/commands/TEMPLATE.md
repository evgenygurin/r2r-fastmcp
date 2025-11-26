---
name: command-name                    # lowercase-with-hyphens
description: Brief, natural-language trigger phrase for when this command should be invoked
argument-hint: <required> [optional] [--flags]
allowed-tools: Bash, Read, Glob       # Whitelist: tools this command is allowed to use
denied-tools: Write, Edit             # Blacklist: explicitly denied tools
---

# Command Title

Brief description of what this command does and when to use it.

## Context

Additional context about:
- When this command should be invoked
- What problem it solves
- Prerequisites or requirements

## Arguments

- **$1** - Description of first required argument
- **$2** - Description of second argument (optional, default: value)
- **$ARGUMENTS** - All remaining arguments as string
- **Flags:**
  - `--flag1, -f` - Description of flag1
  - `--flag2` - Description of flag2
  - `--json` - Output in JSON format
  - `--verbose, -v` - Verbose output
  - `--quiet, -q` - Minimal output

## Instructions

Clear, step-by-step instructions for Claude on how to execute this command.

### Execute Command

```bash
# Execute the main script/command
.claude/scripts/script.sh "$1" "${2:-default_value}" $ARGUMENTS
```

### Process Results

Present results in clear format:
- **Primary output:** Main result to show user
- **Status:** Success/failure indication
- **Additional info:** Relevant metadata or context

### Error Handling

If errors occur:
1. Show clear error message
2. Suggest troubleshooting steps
3. Provide related commands that might help

## Examples

```bash
# Example 1: Basic usage
/command-name "value1"
# Expected output: ...

# Example 2: With optional parameter
/command-name "value1" "value2"
# Expected output: ...

# Example 3: With flags
/command-name "value1" --flag1 --verbose
# Expected output: ...

# Example 4: Advanced usage
/command-name "complex query" 10 --json --filter key=value
# Expected output: ...
```

## Related Commands

- `/related-command-1` - Brief description of related command
- `/related-command-2` - Another related command
- `/help` - Show all available commands

## Notes

- **Performance:** Any performance considerations
- **Limitations:** Known limitations or constraints
- **Best practices:** Recommended usage patterns

## Troubleshooting

**Problem:** Common issue users might encounter
**Solution:** How to resolve it

**Problem:** Another common issue
**Solution:** Resolution steps

<!-- CI/CD Pipeline Test -->
<!-- Test update: 15:24:06 -->
<!-- Test push #3: 15:34:00 -->
