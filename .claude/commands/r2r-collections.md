---
name: r2r-collections
description: List and manage R2R collections
argument-hint: list | create <name> <desc> | add-doc <col_id> <doc_id> | get <id> | delete <id>
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Collections Management

**Action:** {action} (list, create, add-doc, remove-doc, add-user, get, delete)

## Instructions

Use the modular R2R CLI to manage collections.

### Available Commands

**List collections:**
```bash
.claude/scripts/r2r collections list --limit {limit}
```

**Create collection:**
```bash
.claude/scripts/r2r collections create --name "{name}" --description "{description}"
```

**Add document:**
```bash
.claude/scripts/r2r collections add-doc --collection {collection_id} --document {document_id}
```

**Remove document:**
```bash
.claude/scripts/r2r collections remove-doc --collection {collection_id} --document {document_id}
```

**Get details:**
```bash
.claude/scripts/r2r collections get {collection_id}
```

**Delete collection:**
```bash
.claude/scripts/r2r collections delete {collection_id}
```

### Presentation

Present collections:
- **Collection ID:** [UUID]
- **Name:** [human-readable]
- **Description:** [purpose/content]
- **Documents:** [count if available]

### Available Flags

- `--limit, -l <n>` - Number of results (default: 10)
- `--offset, -o <n>` - Skip first N results
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON output

## Examples

```bash
# List all collections
/r2r-collections list

# Create new collection
/r2r-collections create "AI Research" "Papers about artificial intelligence"

# Add document to collection
/r2r-collections add-doc <collection_id> <document_id>

# Get collection details
/r2r-collections get <collection_id>

# Delete collection
/r2r-collections delete <collection_id>
```

## Collection Features

- **Organize** documents by topic/project
- **Permissions** per-collection access control
- **Filter** search results by collection
- **Knowledge graphs** collection-specific graphs
- **Share** access with specific users

## Next Steps

After managing collections:
1. Search within specific collection
2. Add documents to collection
3. Build knowledge graph
4. Extract entities and relationships
