---
name: r2r-upload
description: Upload document to R2R knowledge base
argument-hint: <file_path> [collection_ids] [--title|--mode|--json]
allowed-tools: Bash, Read, Glob
denied-tools: Write, Edit
---

# Upload Document to R2R

**File Path:** {file_path}

**Options:**
- **Collection IDs:** {collection_ids} (optional, comma-separated)
- **Flags:** --title, --mode (hi-res/fast), --json, --quiet

## Instructions

⚠️ **IMPORTANT:** This is a potentially destructive operation. Confirm with user before uploading.

If file not provided, list available files using Glob:
```bash
# List uploadable documents in current directory
```

Execute upload command:
```bash
.claude/scripts/r2r docs upload "{file_path}" ${collection_ids:+--collections "{collection_ids}"}
```

### Supported File Types

- PDF (.pdf), Markdown (.md), Text (.txt)
- Word (.docx), HTML (.html)
- JSON (.json), CSV (.csv)

### Available Flags

- `--collections, -c <ids>` - Comma-separated collection IDs
- `--title, -t <title>` - Document title
- `--mode, -m <mode>` - Ingestion mode (hi-res/fast, default: hi-res)
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON output

### After Upload

1. Extract `document_id` from response
2. Confirm successful upload
3. Suggest next steps:
   - Extract knowledge graph: `.claude/scripts/r2r docs extract <document_id>`
   - Search document content
   - Add to more collections
   - Build communities

## Examples

```bash
# Upload single document
/r2r-upload ./research.pdf

# Upload to specific collections
/r2r-upload ./paper.pdf "col1,col2,col3"

# Fast mode upload
/r2r-upload ./document.md "" --mode fast

# With custom title
/r2r-upload ./paper.pdf "collection_id" --title "Research Paper 2024"

# JSON output
/r2r-upload ./doc.pdf "" --json
```

## Security Notes

- File must exist and be accessible
- Upload requires appropriate permissions
- Large files may take time to process

### Automatic Processing

R2R will automatically:
- Chunk the document
- Generate embeddings
- Index for search
- Extract entities (if requested)
