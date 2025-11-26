---
name: r2r-search
argument-hint: "<query> [limit]"
description: Search R2R knowledge base with semantic/hybrid search
allowed-tools: Bash
---

# R2R Knowledge Base Search

Search query: **$1**

Options:
- Limit: **$2** (default: 3 results)
- Flags: **--verbose** (show full metadata), **--json** (raw JSON output)

## Instructions

Use the modular R2R CLI `.claude/scripts/r2r` to perform hybrid search (semantic + fulltext).

Execute the search command:
```bash
.claude/scripts/r2r search "$1" --limit ${2:-3}
```

Additional flags:
- `--quiet, -q` - Minimal output (one line per result)
- `--json` - Output raw JSON for further processing
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Search in specific collection
- `--filter, -f <key=val>` - Filter results
- `--strategy, -s <name>` - Search strategy (vanilla, rag_fusion, hyde)

Present results in clear format:
1. **Score:** X.XX
2. **Document:** Title [chunk_id]
3. **Text excerpt**

If no query provided, prompt user for a search query.

## Examples

```bash
# Basic search
/r2r-search "machine learning algorithms"

# With custom limit
/r2r-search "neural networks" 10

# Verbose output with metadata
/r2r-search "transformer architecture" 5 --verbose

# JSON output for processing
/r2r-search "deep learning" --json
```
