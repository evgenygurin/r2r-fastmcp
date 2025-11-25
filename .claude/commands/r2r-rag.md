---
name: r2r-rag
description: RAG query to R2R with answer generation
allowed-tools: Read, Grep, Glob
denied-tools: Write, Edit, Bash
---

# R2R RAG Query

Question: **$1**

Options:
- Temperature: **$2** (default: 0.1 - more deterministic)
- Model: **$3** (default: openai/gpt-4.1-mini)

## Instructions

Use the R2R bridge MCP server to perform a RAG query.

The system will:
1. Search relevant documents in the knowledge base
2. Generate an answer based on retrieved context
3. Provide citations to source documents

Present the response with:
- **Answer:** Generated response
- **Sources:** List of documents used with citations
- **Confidence:** If available

For complex questions, consider using higher temperature (0.3-0.7).

If no question provided, prompt user for a question.

## Examples

```text
/r2r-rag "What is the transformer architecture?"
/r2r-rag "Explain quantum computing" 0.3
/r2r-rag "Summarize recent AI research" 0.5 "anthropic/claude-3-haiku-20240307"
```
