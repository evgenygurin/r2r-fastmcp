---
name: r2r-workflows
description: Automated R2R workflows for common multi-step tasks
argument-hint: upload <file> [col_id] | create-collection <name> <desc> <files...> | research <query> [mode] | analyze <doc_id> | batch-upload <dir> [col_id] [pattern]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Automated Workflows

Execute multi-step automated workflows for common R2R operations.

**Workflow:** {workflow}
**Arguments:** {args}

## Instructions

Use the workflows script to automate complex operations:

```bash
.claude/scripts/workflows.sh {workflow} {args}
```

## Available Workflows

### 1. upload <file> [collection_id]
**Steps:**
1. Validate file exists
2. Upload to R2R
3. Wait for processing
4. Extract knowledge graph
5. Test searchability

**Usage:**
```bash
/r2r-workflows upload research-paper.pdf
/r2r-workflows upload document.pdf abc123
```

### 2. create-collection <name> <description> <files...>
**Steps:**
1. Create new collection
2. Upload all specified files
3. Extract knowledge graphs
4. Build community structure
5. Return collection ID

**Usage:**
```bash
/r2r-workflows create-collection "Research Papers" "AI research" paper1.pdf paper2.pdf
```

### 3. research <query> [mode]
**Steps:**
1. Start conversation with query
2. Get conversation ID
3. Interactive follow-up loop
4. Enter empty line to exit

**Usage:**
```bash
/r2r-workflows research "What is RAG?" research
/r2r-workflows research "Simple question" rag
```

### 4. analyze <document_id>
**Steps:**
1. Fetch document metadata
2. Search key topics
3. Extract knowledge graph
4. Analyze entities
5. Generate RAG summary

**Usage:**
```bash
/r2r-workflows analyze abc123-def456-document-id
```

### 5. batch-upload <directory> [collection_id] [pattern]
**Steps:**
1. Find matching files
2. Upload each file
3. Extract graphs in batch
4. Show progress and stats

**Usage:**
```bash
/r2r-workflows batch-upload ./documents
/r2r-workflows batch-upload ./papers abc123 "*.pdf"
```

## Features

- **Automation**: Multi-step processes in one command
- **Error Handling**: Validation, retry logic, clear error messages
- **Progress**: Indicators for long-running operations
- **Safety**: File validation, confirmation prompts for destructive ops

## Examples

```bash
# Quick upload with full processing
/r2r-workflows upload important-document.pdf

# Create research collection
/r2r-workflows create-collection "ML Research" "Machine learning papers" *.pdf

# Start research session
/r2r-workflows research "Explain transformer architecture"

# Analyze uploaded document
/r2r-workflows analyze <document_id>

# Batch upload directory
/r2r-workflows batch-upload ./research-papers collection123
```

## Tips

**upload**: File must exist, graph extraction ~5s, returns document ID

**create-collection**: Use glob patterns (`*.pdf`), ID saved to `/tmp/.r2r_last_collection`

**research**: Use "research" mode for complex queries, "rag" for simple factual questions

**batch-upload**: Default pattern `*.pdf`, shows upload/failure counts

## Related Commands

- `/r2r-quick` - One-line shortcuts
- `/r2r-examples` - Interactive learning
- Chain workflows: upload → analyze → research
