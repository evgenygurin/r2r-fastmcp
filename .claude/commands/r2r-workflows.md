---
name: r2r-workflows
description: Automated R2R workflows for common tasks
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Automated Workflows

Execute multi-step automated workflows for common R2R operations.

## Usage

Workflow: **$1** (upload, create-collection, research, analyze, batch-upload)

Arguments: **$2**, **$3**, **$4**...

## Instructions

Use the workflows script `.claude/scripts/workflows.sh` to automate complex operations.

Execute workflow:
```bash
.claude/scripts/workflows.sh "$1" "${@:2}"
```

## Available Workflows

### upload <file> [collection_id]
Upload document with automatic processing:
1. Validate file exists
2. Upload to R2R
3. Wait for processing
4. Extract knowledge graph
5. Test searchability

**Example:**
```bash
/r2r-workflows upload research-paper.pdf
/r2r-workflows upload document.pdf abc123-collection-id
```

### create-collection <name> <description> <files...>
Create and populate collection:
1. Create new collection
2. Upload all specified files
3. Extract knowledge graphs
4. Build community structure
5. Return collection ID

**Example:**
```bash
/r2r-workflows create-collection "Research Papers" "AI research" paper1.pdf paper2.pdf
```

### research <query> [mode]
Interactive research session:
1. Start conversation with query
2. Get conversation ID
3. Interactive follow-up loop
4. Enter empty line to exit

**Example:**
```bash
/r2r-workflows research "What is RAG?" research
/r2r-workflows research "Simple question" rag
```

### analyze <document_id>
Comprehensive document analysis:
1. Fetch document metadata
2. Search key topics
3. Extract knowledge graph
4. Analyze entities
5. Generate RAG summary

**Example:**
```bash
/r2r-workflows analyze abc123-def456-document-id
```

### batch-upload <directory> [collection_id] [pattern]
Mass upload directory:
1. Find matching files
2. Upload each file
3. Extract graphs in batch
4. Show progress and stats

**Example:**
```bash
/r2r-workflows batch-upload ./documents
/r2r-workflows batch-upload ./papers abc123 "*.pdf"
```

## Workflow Features

**Automation:**
- Multi-step processes in one command
- Error handling and validation
- Progress indicators
- Success/failure reporting

**Smart Defaults:**
- Wait times for processing
- Retry logic
- Batch operations
- Clean output

**Safety:**
- File validation before upload
- Confirmation prompts for destructive ops
- Error messages with context
- Non-zero exit codes on failure

## Examples

```bash
# Quick upload with full processing
/r2r-workflows upload important-document.pdf

# Create research collection
/r2r-workflows create-collection "ML Research" "Machine learning papers" *.pdf

# Start research session
/r2r-workflows research "Explain transformer architecture"

# Analyze uploaded document
/r2r-workflows analyze <document_id_from_upload>

# Batch upload directory
/r2r-workflows batch-upload ./research-papers collection123
```

## Tips

**For upload workflow:**
- File must exist and be accessible
- Knowledge graph extraction takes ~5 seconds
- Returns document ID for further use

**For create-collection:**
- Can pass multiple files as arguments
- Use glob patterns: `*.pdf`, `papers/*.md`
- Collection ID saved to `/tmp/.r2r_last_collection`

**For research:**
- Use "research" mode for complex queries
- Use "rag" mode for simple factual questions
- Conversation ID auto-saved to `/tmp/.r2r_conversation_id`

**For batch-upload:**
- Processes files in current directory
- Default pattern: `*.pdf`
- Shows upload/failure counts

## Next Steps

- Use `/r2r-quick` for one-line shortcuts
- Use `/r2r-examples` for interactive learning
- Chain workflows: upload → analyze → research
- Customize workflows for your use case
