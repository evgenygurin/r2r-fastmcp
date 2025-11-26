---
name: r2r-quick
description: Quick one-line R2R tasks and shortcuts
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Quick Tasks

One-line shortcuts for the most common R2R operations.

## Usage

Task: **$1** (ask, status, up, col, col-search, continue, graph, batch, find, cleanup)

Arguments: **$2**, **$3**...

## Instructions

Use the quick tasks script `.claude/scripts/quick.sh` for instant operations.

Execute quick task:
```bash
.claude/scripts/quick.sh "$1" "${@:2}"
```

## Available Tasks

### ask <query>
Quick search + RAG answer in one command:
- Searches knowledge base (3 results)
- Generates comprehensive answer
- Shows both search results and RAG response

**Example:**
```bash
/r2r-quick ask "What is RAG?"
/r2r-quick ask "Explain transformers"
```

### status
Show R2R system status:
- Total documents count
- List collections (5 recent)
- Recent uploads (5 documents)

**Example:**
```bash
/r2r-quick status
```

### up <file> [collection_id]
Quick upload with auto-extract:
- Uploads document
- Waits for processing (3 seconds)
- Extracts knowledge graph
- Returns document ID
- Shows search command hint

**Example:**
```bash
/r2r-quick up paper.pdf
/r2r-quick up document.pdf abc123-collection-id
```

### col <name> [description]
Quick create collection:
- Creates new collection
- Returns collection ID
- Saves to `/tmp/.r2r_last_collection`
- Shows usage hints

**Example:**
```bash
/r2r-quick col "Research Papers"
/r2r-quick col "AI Research" "Machine learning papers"
```

### col-search <query>
Search in last created collection:
- Uses collection ID from `/tmp/.r2r_last_collection`
- Returns 5 results
- Faster than full corpus search

**Example:**
```bash
/r2r-quick col-search "transformers"
```

### continue <message>
Continue last agent conversation:
- Uses conversation ID from `/tmp/.r2r_conversation_id`
- Maintains context across turns
- Auto-starts new conversation if none exists

**Example:**
```bash
/r2r-quick continue "Tell me more"
/r2r-quick continue "Give me examples"
```

### graph <collection_id>
Quick knowledge graph overview:
- Lists entities (10)
- Lists relationships (10)
- Lists communities (5)
- Compact one-line format

**Example:**
```bash
/r2r-quick graph abc123-def456-collection-id
```

### batch [pattern]
Batch upload current directory:
- Finds matching files (default: `*.pdf`)
- Asks for confirmation
- Uploads all files
- Shows progress and stats

**Example:**
```bash
/r2r-quick batch
/r2r-quick batch "*.md"
/r2r-quick batch "papers/*.pdf"
```

### find <search_term>
Find documents by title:
- Searches document titles (case-insensitive)
- Shows document ID, title, status
- Returns up to 50 matches

**Example:**
```bash
/r2r-quick find "machine learning"
/r2r-quick find "research"
```

### cleanup
Delete failed documents:
- Finds all documents with `ingestion_status: failed`
- Shows count
- Asks for confirmation
- Deletes failed documents

**Example:**
```bash
/r2r-quick cleanup
```

## Quick Task Features

**Speed:**
- One command, multiple operations
- Minimal output by default
- No configuration needed

**Smart Defaults:**
- Auto-saves important IDs
- Reuses last collection/conversation
- Reasonable limits and waits

**User-Friendly:**
- Clear confirmations for destructive ops
- Helpful hints after operations
- Progress indicators
- Error messages with context

## Common Workflows

**Quick Q&A:**
```bash
/r2r-quick ask "What is DeepSeek R1?"
```

**Upload and Search:**
```bash
/r2r-quick up paper.pdf
/r2r-quick ask "key concepts from paper"
```

**Collection Workflow:**
```bash
/r2r-quick col "Research"
/r2r-quick up paper1.pdf
/r2r-quick up paper2.pdf
/r2r-quick col-search "transformers"
```

**Conversation:**
```bash
/r2r-quick ask "Explain RAG systems"
/r2r-quick continue "Show me examples"
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
# Search + answer
/r2r-quick ask "What is R2R?"

# Check status
/r2r-quick status

# Upload document
/r2r-quick up research.pdf

# Create collection
/r2r-quick col "ML Papers"

# Continue conversation
/r2r-quick continue "Elaborate on that"

# Batch upload
/r2r-quick batch "*.pdf"

# Find documents
/r2r-quick find "transformer"

# Cleanup failed
/r2r-quick cleanup
```

## Aliases

If you source `.claude/scripts/aliases.sh`:

```bash
# Ultra-short form
rq ask "query"           # /r2r-quick ask
rq up file.pdf           # /r2r-quick up
rq status                # /r2r-quick status

# Helper functions
r2r-ask "query"          # Quick ask
r2r-up file.pdf          # Quick upload
r2r-cont "message"       # Continue conversation
```

## Next Steps

- Use `/r2r-workflows` for multi-step automation
- Use `/r2r-examples` for learning
- Combine quick tasks in shell scripts
- Source `aliases.sh` for even faster access
