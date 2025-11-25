---
name: r2r-collections
description: List and manage R2R collections
allowed-tools: Read, Grep, Glob
denied-tools: Write, Edit, Bash
---

# R2R Collections Management

## Instructions

Use the R2R bridge MCP server to list all available collections in the knowledge base.

Present collections in a clear table format:

| Collection ID | Name | Documents | Description |
|---------------|------|-----------|-------------|
| col_abc123 | Research Papers | 45 | AI research collection |
| col_def456 | Technical Docs | 23 | Product documentation |

For each collection, provide:
- **Collection ID:** For use in other commands
- **Name:** Human-readable name
- **Document count:** Number of documents
- **Description:** Purpose or content type

## Next Steps

After listing collections, suggest:
1. Search within a specific collection
2. View documents in a collection
3. Add documents to a collection
4. Create a new collection

## Examples

```text
/r2r-collections
```

## Related Commands

```bash
# Search in specific collection
/r2r-search "query" 10

# View collection documents
# Use resource: knowledge://collections/{collection_id}/documents

# Upload to collection
/r2r-upload ./doc.pdf collection_id
```

## Collection Features

Collections allow you to:
- Organize documents by topic/project
- Apply per-collection permissions
- Filter search results by collection
- Build collection-specific knowledge graphs
