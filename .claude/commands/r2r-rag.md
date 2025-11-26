---
name: r2r-rag
description: RAG query to R2R with answer generation
argument-hint: <query> [max_tokens] [--json|--show-sources|--show-metadata]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R RAG Query

**Query:** {query}

**Options:**
- **Max Tokens:** {max_tokens} (default: 4000 tokens)
- **Flags:** --json, --show-sources, --show-metadata, --graph, --collection <id>

## Instructions

Use the modular R2R CLI to perform RAG query with hybrid search + generation.

Execute RAG command:
```bash
.claude/scripts/r2r rag "{query}" --max-tokens {max_tokens}
```

RAG combines:
1. **Retrieval** - Hybrid search (semantic + fulltext)
2. **Augmentation** - Provide context to LLM
3. **Generation** - Generate comprehensive answer

Present result:
- **Generated Answer:** [clean text response]
- **Sources:** [brief context note if relevant]
- **Length:** [token/character count if useful]

Available flags:
- `--json` - Raw JSON with metadata
- `--quiet, -q` - Minimal output
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Filter by collection
- `--show-sources` - Show retrieved chunks
- `--show-metadata` - Show metadata
- `--filter, -f <key=val>` - Custom filters

If no query provided, prompt user for a query.

## Examples

```bash
# Basic RAG query
/r2r-rag "What are the key features of FastMCP?"

# Extended response (12K tokens)
/r2r-rag "Explain transformer architecture in detail" 12000

# With sources
/r2r-rag "Claude Code subagents overview" 8000 --show-sources

# JSON output
/r2r-rag "What is R2R?" 4000 --json

# Collection-specific
/r2r-rag "Key concepts" 8000 --collection abc123
```
