---
name: r2r
description: Show R2R quick reference with modular CLI commands
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# R2R Quick Reference

Comprehensive reference for R2R modular CLI commands.

For complete documentation, see @.claude/scripts/README.md

## Modular R2R CLI

Unified command interface: `.claude/scripts/r2r`

**8 commands, 48 sub-commands**

### Core Commands (3)

- `search <query> [--limit N]` - Hybrid search (semantic + fulltext)
- `rag <query> [--max-tokens N]` - RAG query with generation  
- `agent <query> [--mode research|rag]` - Multi-turn agent

### Management Commands (5)

- `docs` - Document management (14 sub-commands)
- `collections` - Collection management (6 sub-commands)
- `conversation` - Conversation management (5 sub-commands)
- `graph` - Knowledge graph operations (20 sub-commands)
- `analytics` - System analytics (3 sub-commands)

For details, see @.claude/scripts/commands/

## Slash Commands

**Core Operations:**
- `/r2r-search "query" [limit]` - Quick search
- `/r2r-rag "query" [max_tokens]` - RAG query
- `/r2r-agent "message" [mode]` - Agent conversation
- `/r2r-collections [action]` - Manage collections
- `/r2r-upload <file> [collection_ids]` - Upload document

**Helper Scripts:**
- `/r2r-quick <task> [args]` - One-line shortcuts (ask, status, up, col, continue, etc.)
- `/r2r-workflows <workflow> [args]` - Automated workflows (upload, create-collection, research, etc.)
- `/r2r-examples [category]` - Interactive examples (50+ demos)

## Common Flags

**Output:**
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON output
- `--verbose, -v` - Full metadata

**Search/RAG:**
- `--limit, -l <n>` - Results count (default: 3)
- `--max-tokens, -t <n>` - Max tokens (default: 4000)
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Filter by collection

**Agent:**
- `--mode, -m <mode>` - research (default) or rag
- `--conversation, -c <id>` - Continue conversation
- `--thinking` - Extended thinking (4096 tokens)
- `--show-tools` - Show tool calls

## Examples

```bash
# Core commands
r2r search "transformers" --limit 5
r2r rag "What is RAG?" --show-sources
r2r agent "Explain DeepSeek" --thinking

# Management
r2r docs list -l 10 -q
r2r collections create -n "Research Papers"
r2r graph entities <collection_id> -l 50
```

## Helper Scripts

For details, see @.claude/scripts/

**Quick Tasks** (`quick.sh`): ask, status, up, col, continue, batch, find, cleanup

**Workflows** (`workflows.sh`): upload, create-collection, research, analyze, batch-upload

**Examples** (`examples.sh`): Interactive demos by category (50+ examples)

**Aliases** (`aliases.sh`):
```bash
source .claude/scripts/aliases.sh
rs "query"      # r2r search
rr "question"   # r2r rag  
ra "message"    # r2r agent
```

## Related Commands

- `/r2r-search` - Quick search
- `/r2r-rag` - RAG query
- `/r2r-agent` - Agent conversation
- `/r2r-collections` - Manage collections
- `/r2r-upload` - Upload documents
- `/r2r-quick` - One-line shortcuts
- `/r2r-workflows` - Automated workflows
- `/r2r-examples` - Interactive examples

## Documentation

- Full reference: @.claude/scripts/README.md
- CLI help: `r2r <command> help`
