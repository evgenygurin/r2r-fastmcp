---
name: r2r
description: Show R2R quick reference
allowed-tools: Read
denied-tools: Write, Edit, Bash
---

# R2R Quick Reference

Show R2R quick reference with modular CLI commands.

## Modular R2R CLI

**`.claude/scripts/r2r`** - Unified command interface (8 commands, 48 sub-commands)

### Core Commands (3):
- `search <query> [--limit N]` - Hybrid search (semantic + fulltext)
- `rag <query> [--max-tokens N]` - RAG query with generation
- `agent <query> [--mode research|rag]` - Multi-turn agent

### Management Commands (5):
- `docs` - Document management (14 sub-commands: list, get, upload, delete, extract, etc.)
- `collections` - Collection management (6 sub-commands: list, create, add-doc, remove-doc, etc.)
- `conversation` - Conversation management (5 sub-commands: list, create, get, add-message, delete)
- `graph` - Knowledge graph operations (20 sub-commands: entities, relationships, communities, etc.)
- `analytics` - System analytics (3 sub-commands: system, collection, document)

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

## Common Flags (GNU-style)

**Output modes:**
- `--quiet, -q` - Minimal output (one line per result)
- `--json` - Raw JSON output
- `--verbose, -v` - Full details with metadata

**Search/RAG options:**
- `--limit, -l <n>` - Number of results (default: 3)
- `--max-tokens, -t <n>` - Max tokens for generation (default: 4000)
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Filter by collection
- `--filter, -f <key=val>` - Custom filters

**Agent options:**
- `--mode, -m <mode>` - research (default) or rag
- `--conversation, -c <id>` - Continue conversation
- `--thinking` - Extended thinking (4096 token budget)
- `--show-tools` - Show tool calls
- `--show-sources` - Show citations

## Quick Examples

```bash
# Core commands
r2r search "transformers" --limit 5 -q
r2r rag "What is RAG?" --show-sources
r2r agent "Explain DeepSeek" --thinking

# Management
r2r docs list -l 10 -q
r2r collections create -n "Research Papers"
r2r graph entities <collection_id> -l 50

# Advanced
r2r search "AI" --graph --collection abc123
r2r rag "Question" --filter category=research --max-tokens 8000
r2r agent "Continue discussion" -c <conv_id> --show-tools
```

## Helper Scripts

**Quick Tasks** (`.claude/scripts/quick.sh`):
- `ask "query"` - Search + RAG answer in one command
- `status` - Show R2R system status
- `up <file>` - Quick upload with auto-extract
- `col "name"` - Create collection
- `continue "msg"` - Continue last conversation
- `batch [pattern]` - Batch upload directory
- `cleanup` - Delete failed documents

**Workflows** (`.claude/scripts/workflows.sh`):
- `upload <file>` - Upload + extract + verify
- `create-collection <name> <desc> <files...>` - Full collection setup
- `research <query>` - Interactive research session
- `analyze <doc_id>` - Comprehensive document analysis
- `batch-upload <dir>` - Mass upload with progress

**Examples** (`.claude/scripts/examples.sh`):
- `search`, `rag`, `agent` - Category-specific examples
- `docs`, `collections`, `graph` - Management examples
- `workflows` - Complete workflow demonstrations
- Interactive mode with step-by-step execution

**Aliases** (`.claude/scripts/aliases.sh`):
```bash
source .claude/scripts/aliases.sh
rs "query"        # r2r search
rr "question"     # r2r rag
ra "message"      # r2r agent
rq ask "query"    # quick.sh ask
rw upload file    # workflows.sh upload
```

## Documentation

- **Full reference:** `.claude/scripts/README.md`
- **Helper scripts:** Use `/r2r-quick`, `/r2r-workflows`, `/r2r-examples` commands
- **CLI help:** `r2r <command> help`
- **All commands:** `r2r search help`, `r2r rag help`, `r2r agent help`, etc.
