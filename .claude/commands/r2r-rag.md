---
name: r2r-rag
argument-hint: "<question> [max_tokens]"
description: RAG query to R2R with answer generation
allowed-tools: Bash
---

# R2R RAG Query

Query: **$1**

Options:
- Max tokens: **$2** (default: 8000 tokens for extended responses)
- Flags: **--json** (raw JSON output)

## Instructions

Use the modular R2R CLI `.claude/scripts/r2r` to perform RAG query with hybrid search.

Execute the RAG command:
```bash
.claude/scripts/r2r rag "$1" --max-tokens ${2:-8000}
```

RAG combines:
1. **Retrieval** - Hybrid search (semantic + fulltext)
2. **Augmentation** - Provide context to LLM
3. **Generation** - Generate comprehensive answer

Present result with:
- **Generated Answer:** The LLM's response (clean text)
- **Context:** Brief note on sources used
- **Length:** Token/character count if relevant

Additional flags:
- `--json` - Output raw JSON with metadata
- `--quiet, -q` - Minimal output
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Search in specific collection
- `--filter, -f <key=val>` - Filter results
- `--show-sources` - Show retrieved chunks
- `--show-metadata` - Show metadata

If no query provided, prompt user for a query.

## Examples

```bash
# Basic RAG query
/r2r-rag "What are the key features of FastMCP?"

# Extended response (12K tokens)
/r2r-rag "Explain transformer architecture in detail" 12000

# JSON output with metadata
/r2r-rag "Claude Code subagents overview" --json
```
