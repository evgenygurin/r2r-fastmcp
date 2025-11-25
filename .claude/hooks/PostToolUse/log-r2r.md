# R2R Tool Usage Logging Hook

This hook runs after every R2R MCP tool call to log usage for monitoring and debugging.

## Configuration

**Event:** PostToolUse
**Type:** command
**Matcher:** `mcp__r2r-bridge__*`
**Description:** Log R2R tool usage

## Command

```bash
echo "[$(date +%H:%M:%S)] $CLAUDE_TOOL_NAME" >> /tmp/r2r-usage.log
```

## What It Does

1. Matches any tool from `r2r-bridge` MCP server
2. Captures timestamp (HH:MM:SS format)
3. Logs tool name with timestamp
4. Appends to `/tmp/r2r-usage.log`

## Purpose

- **Usage Tracking:** Monitor which R2R tools are used
- **Debugging:** Troubleshoot R2R integration issues
- **Performance Analysis:** Identify frequently used operations
- **Audit Trail:** Track R2R interactions over time

## Log Format

```text
[14:23:45] mcp__r2r-bridge__search_knowledge
[14:23:52] mcp__r2r-bridge__rag_query
[14:24:01] mcp__r2r-bridge__agent_chat
[14:24:15] mcp__r2r-bridge__list_collections
```

## Viewing Logs

### Real-time Monitoring

```bash
# Watch logs in real-time
tail -f /tmp/r2r-usage.log

# With context (last 20 lines)
tail -20 /tmp/r2r-usage.log
```

### Analysis

```bash
# Count tool usage
cat /tmp/r2r-usage.log | cut -d']' -f2 | sort | uniq -c | sort -rn

# Usage by hour
cat /tmp/r2r-usage.log | cut -d':' -f1 | cut -d'[' -f2 | sort | uniq -c

# Today's activity
grep "$(date +%Y-%m-%d)" /tmp/r2r-usage.log | wc -l

# Most used tools
cat /tmp/r2r-usage.log | grep -o 'mcp__r2r-bridge__[^[:space:]]*' | sort | uniq -c | sort -rn
```

## Available Tool Names

The following tools can appear in logs:

- `mcp__r2r-bridge__search_knowledge` - Semantic/hybrid search
- `mcp__r2r-bridge__rag_query` - RAG queries
- `mcp__r2r-bridge__agent_chat` - Multi-turn conversations
- `mcp__r2r-bridge__search_entities` - Knowledge graph entities
- `mcp__r2r-bridge__upload_document` - Document uploads
- `mcp__r2r-bridge__list_collections` - Collection listing

## Integration in settings.json

This hook is configured in `.claude/settings.json`:

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "mcp__r2r-bridge__*",
      "hooks": [
        {
          "type": "command",
          "command": "echo \"[$(date +%H:%M:%S)] $CLAUDE_TOOL_NAME\" >> /tmp/r2r-usage.log",
          "description": "Log R2R tool usage"
        }
      ]
    }
  ]
}
```

## Advanced Logging

### With Full Timestamp

```bash
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $CLAUDE_TOOL_NAME" >> /tmp/r2r-usage.log
```

Output: `[2025-11-25 14:23:45] mcp__r2r-bridge__search_knowledge`

### With Tool Input

To log tool parameters:

```bash
echo "[$(date +%H:%M:%S)] $CLAUDE_TOOL_NAME | Input: $CLAUDE_TOOL_INPUT" >> /tmp/r2r-usage.log
```

**Warning:** This may log sensitive information. Be careful with production use.

### With Performance Timing

Track execution time (requires PreToolUse hook):

```bash
# PreToolUse hook (save start time):
echo "[$(date +%s)] START $CLAUDE_TOOL_NAME" >> /tmp/r2r-timing.log

# PostToolUse hook (calculate duration):
START_TIME=$(grep "START $CLAUDE_TOOL_NAME" /tmp/r2r-timing.log | tail -1 | cut -d'[' -f2 | cut -d']' -f1)
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "[$(date +%H:%M:%S)] $CLAUDE_TOOL_NAME | Duration: ${DURATION}s" >> /tmp/r2r-usage.log
```

### With User Context

If available, log which user triggered the tool:

```bash
echo "[$(date +%H:%M:%S)] $CLAUDE_TOOL_NAME | User: ${USER}" >> /tmp/r2r-usage.log
```

## Log Rotation

To prevent log file growth:

```bash
# Keep only last 1000 lines
tail -1000 /tmp/r2r-usage.log > /tmp/r2r-usage.log.tmp && mv /tmp/r2r-usage.log.tmp /tmp/r2r-usage.log

# Or use logrotate (create /etc/logrotate.d/r2r-usage):
/tmp/r2r-usage.log {
    rotate 7
    daily
    compress
    missingok
    notifempty
}
```

## Privacy Considerations

**⚠️ Important:** This hook logs tool names only by default, not parameters.

If you extend it to log `$CLAUDE_TOOL_INPUT`:
- May contain sensitive queries
- May contain API keys or tokens
- May contain personal information
- Consider log file permissions: `chmod 600 /tmp/r2r-usage.log`

## Disabling This Hook

To disable R2R usage logging:

1. Remove the hook from `.claude/settings.json`, or
2. Delete this file: `.claude/hooks/PostToolUse/log-r2r.md`, or
3. Comment out the command in settings.json

## Use Cases

### Development & Debugging
```bash
# Monitor R2R calls during development
tail -f /tmp/r2r-usage.log
```

### Performance Analysis
```bash
# Identify most used operations
cat /tmp/r2r-usage.log | grep -o 'mcp__r2r-bridge__[^[:space:]]*' | sort | uniq -c | sort -rn

# Sample output:
#  45 mcp__r2r-bridge__search_knowledge
#  23 mcp__r2r-bridge__rag_query
#  12 mcp__r2r-bridge__agent_chat
#   5 mcp__r2r-bridge__list_collections
#   2 mcp__r2r-bridge__search_entities
```

### Troubleshooting
```bash
# Check when errors occurred
grep -B5 -A5 "error" /tmp/r2r-usage.log

# Verify tool was called
grep "search_knowledge" /tmp/r2r-usage.log | tail -5
```

## Related Hooks

- **SessionStart/check-r2r.md** - Checks R2R availability at session start

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_TOOL_NAME` | (auto) | Name of the tool being used |
| `CLAUDE_TOOL_INPUT` | (auto) | JSON of tool input parameters |
| `CLAUDE_TOOL_OUTPUT` | (auto) | Result of tool execution |
