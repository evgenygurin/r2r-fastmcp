---
name: r2r-examples
argument-hint: "[category]"
description: Interactive R2R examples (search/rag/agent/docs/collections/graph)
allowed-tools: Bash
---

# R2R Interactive Examples

Run interactive examples script with 50+ ready-to-use demonstrations.

## Usage

Category: **$1** (search, rag, agent, docs, collections, graph, workflows, all)

## Instructions

Use the interactive examples script `.claude/scripts/examples.sh` to demonstrate R2R functionality.

Execute examples:
```bash
.claude/scripts/examples.sh ${1:-all}
```

## Available Categories

### search
- Basic search with limits
- Quiet mode search
- JSON output
- Collection-specific search
- Graph search

### rag
- Basic RAG queries
- Extended responses (8K+ tokens)
- Show sources
- Collection-specific RAG
- Quiet mode RAG

### agent
- Research agent (default)
- RAG agent mode
- Extended thinking
- Continue conversation
- Show tool calls

### docs
- List documents
- Get document details
- Upload documents
- Extract knowledge graph
- Delete documents

### collections
- List collections
- Create collections
- Get collection details
- Add/remove documents

### graph
- List entities
- List relationships
- List communities
- Create entities
- Pull/sync graph
- Build communities

### workflows
- Complete upload → extract → search workflow
- Research session workflow
- Collection setup workflow

## Features

**Interactive Mode:**
- Choose which examples to run
- Step-by-step execution
- Clear explanations for each example
- Press Enter to continue

**50+ Examples:**
- All core commands covered
- Real-world use cases
- Best practices demonstrated
- Common workflows

**Safe Execution:**
- Asks before running each example
- Shows command before execution
- Can skip examples
- Ctrl+C to exit anytime

## Examples

```bash
# Show all examples interactively
/r2r-examples

# Search examples only
/r2r-examples search

# RAG examples
/r2r-examples rag

# Agent examples
/r2r-examples agent

# Complete workflows
/r2r-examples workflows
```

## Next Steps

After exploring examples:
- Use `/r2r-workflows` for automated multi-step processes
- Use `/r2r-quick` for one-line shortcuts
- Try examples with your own data
- Customize commands for your workflow
