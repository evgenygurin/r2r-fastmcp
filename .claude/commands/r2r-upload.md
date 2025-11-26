---
name: r2r-upload
argument-hint: "<file> [collection_id]"
description: Upload document to R2R with automatic processing
allowed-tools: Bash, Read, Glob
---

# Upload Document to R2R

File path: **$1**

Options:
- Collection IDs: **$2** (optional, comma-separated collection IDs)
- Metadata: **$3** (optional, JSON string)

## Instructions

Use the modular R2R CLI `.claude/scripts/r2r` to upload a document.

**IMPORTANT:** This command is potentially destructive. Confirm with user before uploading.

Execute upload command:
```bash
.claude/scripts/r2r docs upload "$1" ${2:+--collections "$2"}
```

Supported file types:
- PDF (.pdf)
- Markdown (.md)
- Text (.txt)
- Word (.docx)
- HTML (.html)
- JSON (.json)
- CSV (.csv)

Additional flags:
- `--collections, -c <ids>` - Comma-separated collection IDs
- `--title, -t <title>` - Document title
- `--mode, -m <mode>` - Ingestion mode (hi-res/fast, default: hi-res)
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON output

After successful upload:
1. Extract `document_id` from response
2. Confirm successful upload with status
3. Suggest next steps:
   - Extract knowledge graph: `.claude/scripts/r2r docs extract <document_id>`
   - Search the document content
   - Add to more collections
   - Build knowledge graph communities

If file path not provided, list available documents in current directory using Glob.

## Examples

```bash
# Upload single document
/r2r-upload ./research.pdf

# Upload to specific collections
/r2r-upload ./paper.pdf "col1,col2,col3"

# Upload with metadata
/r2r-upload ./document.md "" '{"category": "research", "year": 2024, "author": "John Doe"}'

# Upload and extract knowledge graph
/r2r-upload ./technical-doc.pdf "collection_id"
# Then run: .claude/scripts/r2r_advanced.sh docs extract <returned_document_id>
```

## Security Notes

- File must exist and be accessible
- Upload requires appropriate permissions
- Large files may take time to process
- R2R will automatically:
  - Chunk the document
  - Generate embeddings
  - Index for search
  - Extract entities (if requested)
