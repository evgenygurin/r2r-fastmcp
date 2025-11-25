---
name: r2r-upload
description: Upload document to R2R knowledge base
allowed-tools: Read, Glob
denied-tools: Write, Edit, Bash
---

# Upload Document to R2R

File path: **$1**

Options:
- Collection ID: **$2** (optional, add to specific collection)
- Metadata: **$3** (optional, JSON string)

## Instructions

Use the R2R bridge MCP server to upload a document to the knowledge base.

**IMPORTANT:** This command is potentially destructive. Confirm with user before uploading.

Supported file types:
- PDF (.pdf)
- Markdown (.md)
- Text (.txt)
- Word (.docx)
- HTML (.html)

After upload:
1. Extract document_id from response
2. Confirm successful upload
3. Suggest next steps:
   - Search the uploaded document
   - Add to a collection
   - Extract knowledge graph

If file path not provided, list available documents in current directory.

## Examples

```text
/r2r-upload ./research.pdf
/r2r-upload ./paper.pdf collection_123
/r2r-upload ./document.md collection_456 '{"category": "research", "year": 2024}'
```

## Security Notes

- File must exist and be accessible
- Upload requires appropriate permissions
- Large files may take time to process
- R2R will automatically chunk and embed the document
