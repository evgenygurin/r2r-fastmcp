---
name: r2r-search
description: Search R2R knowledge base with semantic/hybrid search
argument-hint: <query> [limit] [--verbose|--json|--quiet|--graph]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Knowledge Base Search

**Query:** {query}

**Options:**
- **Limit:** {limit} (default: 3 results)
- **Flags:** --verbose, --json, --quiet, --graph, --collection <id>

## Instructions

Use the modular R2R CLI to perform hybrid search (semantic + fulltext).

Execute search command:
```bash
.claude/scripts/r2r search "{query}" --limit {limit}
```

Present results in clear format:
1. **Score:** X.XX
2. **Document:** Title [chunk_id]
3. **Text excerpt**

Available flags:
- `--quiet, -q` - Minimal output (one line per result)
- `--json` - Raw JSON output
- `--verbose, -v` - Full metadata
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Filter by collection
- `--filter, -f <key=val>` - Custom filters

If no query provided, prompt user for a search query.

## Examples

```bash
# Basic search
/r2r-search "machine learning algorithms"

# With custom limit
/r2r-search "neural networks" 10

# Verbose output
/r2r-search "transformer architecture" 5 --verbose

# JSON output
/r2r-search "deep learning" 3 --json

# Collection-specific search
/r2r-search "RAG systems" 5 --collection abc123
```
