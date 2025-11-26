---
name: cc-mcp
description: Model Context Protocol (MCP) integration guide
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# MCP Integration Guide

Comprehensive MCP integration documentation at @docs/claude_code/07-mcp-integration.md

## What is MCP?

Model Context Protocol (MCP) - open standard for connecting AI applications to external data sources and tools.

## Key Concepts

**MCP Servers** - Lightweight services that provide:
- Tools - Actions Claude can perform
- Resources - Data Claude can access
- Prompts - Pre-built prompt templates

**Configuration** - `settings.json` with server definitions
**OAuth Support** - Secure authentication for APIs
**Transport** - stdio or SSE connections

## Official MCP Servers

### GitHub (Official)
- Repositories, PRs, issues, commits
- OAuth authentication
- Full GitHub API access

### Filesystem (Official)
- Read/write local files
- Directory operations
- File search and manipulation

### Database (Official)
- PostgreSQL, MySQL, SQLite
- Query execution
- Schema introspection

## Instructions

1. Read the full MCP documentation:
```text
Read docs/claude_code/07-mcp-integration.md
```

2. Focus on explaining:
   - MCP architecture and concepts
   - Configuration in `settings.json`
   - OAuth authentication flow
   - Official servers (GitHub, Filesystem, Database)
   - Creating custom MCP servers
   - Enterprise security (allowlists)
   - Troubleshooting

3. Show configuration examples:
   - Basic server setup
   - OAuth configuration
   - Environment variables
   - Security settings

## Example Configuration

**settings.json:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed"]
    }
  }
}
```

## MCP Servers in This Project

Check if MCP servers are configured in `.claude/settings.json`.

Common use cases:
- GitHub integration for PR reviews
- Filesystem access for codebase operations
- Custom R2R MCP server (previously used, now replaced with bash CLI)

## Creating Custom MCP Server

Use FastMCP framework (documented in `docs/fastmcp/`):

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool()
def my_tool(param: str) -> str:
    """Tool description"""
    return f"Result: {param}"

if __name__ == "__main__":
    mcp.run()
```

See `docs/fastmcp/` for full FastMCP documentation.

## Security Considerations

**Allowlists** - Restrict which servers can be used:
```json
{
  "security": {
    "allowedMcpServers": ["github", "filesystem"]
  }
}
```

**Environment Variables** - Never hardcode secrets
**OAuth** - Use for API authentication
**Least Privilege** - Grant minimal permissions needed

## Next Steps

- Read full MCP documentation
- Check current MCP configuration in `.claude/settings.json`
- Install official MCP servers: `npx -y @modelcontextprotocol/server-github`
- Explore FastMCP for custom servers: `docs/fastmcp/`
- Use `/cc` for other Claude Code topics
