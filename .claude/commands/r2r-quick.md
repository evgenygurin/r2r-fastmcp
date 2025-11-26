---
name: r2r-quick
description: Quick one-line R2R tasks and shortcuts
argument-hint: ask <query> | status | up <file> [col_id] | col <name> [desc] | col-search <query> | continue <msg> | graph <col_id> | batch [pattern] | find <term> | cleanup
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Quick Tasks

One-line shortcuts for the most common R2R operations.

**Task:** {task}
**Arguments:** {args}

## Instructions

Use the quick tasks script for instant operations:

```bash
.claude/scripts/quick.sh {task} {args}
```

## Available Tasks

| Task | Description | Usage |
|------|-------------|-------|
| `ask <query>` | Search + RAG answer | `ask "What is RAG?"` |
| `status` | System status | `status` |
| `up <file> [col]` | Upload + extract | `up paper.pdf` |
| `col <name> [desc]` | Create collection | `col "Research"` |
| `col-search <q>` | Search last collection | `col-search "transformers"` |
| `continue <msg>` | Continue conversation | `continue "Tell more"` |
| `graph <col_id>` | Graph overview | `graph <id>` |
| `batch [pattern]` | Batch upload | `batch "*.pdf"` |
| `find <term>` | Find by title | `find "machine"` |
| `cleanup` | Delete failed docs | `cleanup` |

### Task Details

**ask**: Searches knowledge base (3 results) + generates comprehensive RAG answer

**status**: Shows total documents, recent collections (5), recent uploads (5)

**up**: Uploads document, waits for processing (3s), extracts knowledge graph, returns document ID

**col**: Creates collection, returns ID, saves to `/tmp/.r2r_last_collection`

**col-search**: Uses collection ID from `/tmp/.r2r_last_collection`, returns 5 results

**continue**: Uses conversation ID from `/tmp/.r2r_conversation_id`, maintains context

**graph**: Lists entities (10), relationships (10), communities (5) in compact format

**batch**: Finds matching files (default: `*.pdf`), asks confirmation, uploads with progress

**find**: Searches document titles (case-insensitive), returns up to 50 matches

**cleanup**: Finds documents with `ingestion_status: failed`, asks confirmation, deletes

## Features

- **Speed**: One command, multiple operations, minimal output
- **Smart Defaults**: Auto-saves IDs, reuses last collection/conversation
- **User-Friendly**: Clear confirmations, helpful hints, progress indicators

## Workflows

**Quick Q&A:**
```bash
/r2r-quick ask "What is DeepSeek R1?"
```

**Upload → Search:**
```bash
/r2r-quick up paper.pdf
/r2r-quick ask "key concepts from paper"
```

**Collection Setup:**
```bash
/r2r-quick col "Research"
/r2r-quick up paper1.pdf
/r2r-quick up paper2.pdf
/r2r-quick col-search "transformers"
```

**Conversation:**
```bash
/r2r-quick ask "Explain RAG systems"
/r2r-quick continue "Show examples"
/r2r-quick continue "Compare approaches"
```

**Maintenance:**
```bash
/r2r-quick status
/r2r-quick find "failed"
/r2r-quick cleanup
```

## Examples

```bash
/r2r-quick ask "What is R2R?"
/r2r-quick status
/r2r-quick up research.pdf
/r2r-quick col "ML Papers"
/r2r-quick continue "Elaborate"
/r2r-quick batch "*.pdf"
/r2r-quick find "transformer"
/r2r-quick cleanup
```

## Aliases

Source `.claude/scripts/aliases.sh` for ultra-short commands:

```bash
rq ask "query"       # /r2r-quick ask
rq up file.pdf       # /r2r-quick up
rq status            # /r2r-quick status
r2r-ask "query"      # Quick ask
r2r-up file.pdf      # Quick upload
r2r-cont "message"   # Continue conversation
```

## Related Commands

- `/r2r-workflows` - Multi-step automation
- `/r2r-examples` - Interactive learning
- `/r2r-search`, `/r2r-rag`, `/r2r-agent` - Core operations
