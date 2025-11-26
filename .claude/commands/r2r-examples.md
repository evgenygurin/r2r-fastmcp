---
name: r2r-examples
description: Interactive R2R examples and tutorials (50+ demonstrations)
argument-hint: [category]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Interactive Examples

Run interactive examples script with 50+ ready-to-use demonstrations.

**Category:** {category} (search, rag, agent, docs, collections, graph, workflows, all)

## Instructions

Use the interactive examples script to demonstrate R2R functionality:

```bash
.claude/scripts/examples.sh {category}
```

## Available Categories

| Category | Examples |
|----------|----------|
| **search** | Basic search, quiet mode, JSON output, collection-specific, graph search |
| **rag** | Basic RAG, extended responses (8K+ tokens), show sources, collection-specific |
| **agent** | Research agent, RAG mode, extended thinking, continue conversation, tool calls |
| **docs** | List, get details, upload, extract knowledge graph, delete documents |
| **collections** | List, create, get details, add/remove documents |
| **graph** | Entities, relationships, communities, create entities, pull/sync, build |
| **workflows** | Upload → extract → search, research session, collection setup |
| **all** | Run all categories interactively |

## Features

- **Interactive**: Choose which examples to run, step-by-step execution
- **Comprehensive**: 50+ examples covering all core commands
- **Educational**: Real-world use cases, best practices demonstrated
- **Safe**: Asks before running, shows commands, can skip, Ctrl+C to exit

## Examples

```bash
# Show all examples interactively
/r2r-examples

# Search examples only
/r2r-examples search

# RAG examples
/r2r-examples rag

# Agent examples
/r2r-examples agent

# Complete workflows
/r2r-examples workflows
```

## Related Commands

- `/r2r-workflows` - Automated multi-step processes
- `/r2r-quick` - One-line shortcuts
- `/r2r-search`, `/r2r-rag`, `/r2r-agent` - Core operations
