---
name: r2r-search
description: Search R2R knowledge base with semantic/hybrid search
allowed-tools: Read, Grep, Glob
denied-tools: Write, Edit, Bash
---

# R2R Knowledge Base Search

Search query: **$1**

Options:
- Limit: **$2** (default: 5 results)
- Use hybrid search: **$3** (default: true - semantic + fulltext)

## Instructions

Use the R2R bridge MCP server to perform a knowledge base search.

The search will use:
- **Semantic search** for conceptual queries
- **Full-text search** for keyword-specific queries (if hybrid=true)
- **Reciprocal Rank Fusion** to combine results

After search, present results in a clear format:
1. **Document Title** (score: X.XX)
   - Excerpt from the document
   - Source: `collection/document_id`

If no query provided, prompt user for a search query.

## Examples

```text
/r2r-search "machine learning algorithms"
/r2r-search "neural networks" 10
/r2r-search "transformer architecture" 5 false
```
