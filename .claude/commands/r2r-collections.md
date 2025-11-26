---
name: r2r-collections
argument-hint: "[action]"
description: Manage R2R collections - list, create, delete, add/remove documents
allowed-tools: Bash
---

# R2R Collections Management

Action: **$1** (list, create, add-doc, add-user, optional)

## Instructions

Use the modular R2R CLI `.claude/scripts/r2r` to manage collections.

### Available Commands:

**List collections:**
```bash
.claude/scripts/r2r collections list --limit 10
```

**Create collection:**
```bash
.claude/scripts/r2r collections create --name "Collection Name" --description "Description"
```

**Add document to collection:**
```bash
.claude/scripts/r2r collections add-doc --collection <collection_id> --document <document_id>
```

**Remove document from collection:**
```bash
.claude/scripts/r2r collections remove-doc --collection <collection_id> --document <document_id>
```

**Get collection details:**
```bash
.claude/scripts/r2r collections get <collection_id>
```

**Delete collection:**
```bash
.claude/scripts/r2r collections delete <collection_id>
```

Present collections in a clear format:
- **Collection ID:** UUID for commands
- **Name:** Human-readable name
- **Description:** Purpose or content type
- **Document count:** Number of documents (if available)

Additional flags:
- `--limit, -l <n>` - Number of results (default: 10)
- `--offset, -o <n>` - Skip first N results
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON output

## Next Steps

After listing collections, suggest:
1. Search within a specific collection
2. Create a new collection
3. Add documents to collection
4. Build knowledge graph for collection

## Examples

```bash
# List all collections
/r2r-collections list

# Create new collection
/r2r-collections create "AI Research" "Papers about artificial intelligence"

# Add document to collection
/r2r-collections add-doc <collection_id> <document_id>

# Add user to collection
/r2r-collections add-user <user_id> <collection_id>
```

## Collection Features

Collections allow you to:
- Organize documents by topic/project
- Apply per-collection permissions
- Filter search results by collection
- Build collection-specific knowledge graphs
- Share access with specific users
