---
name: r2r-agent
description: Multi-turn conversation with R2R agent
allowed-tools: Read, Grep, Glob
denied-tools: Write, Edit, Bash
---

# R2R Agent Conversation

Message: **$1**

Options:
- Mode: **$2** (rag/research, default: rag)
  - `rag`: Standard RAG mode
  - `research`: Deep analysis with extended thinking
- Conversation ID: **$3** (optional, for follow-ups)

## Instructions

Use the R2R bridge MCP server to start or continue an agent conversation.

**First message:** The agent will create a new conversation and return a conversation_id.
**Follow-ups:** Use the conversation_id from previous response to continue the conversation.

### Modes:

**RAG Mode:**
- Best for: Direct questions, fact retrieval
- Tools: search_file_knowledge, get_file_content, web_search

**Research Mode:**
- Best for: Complex analysis, multi-step reasoning
- Tools: RAG tools + reasoning, critique, python_executor
- Features: Extended thinking, deeper analysis

Present the agent response with:
- **Response:** Agent's answer
- **Conversation ID:** For follow-ups
- **Mode:** Current mode
- **Next steps:** Suggested follow-up questions

If no message provided, prompt user for a message.

## Examples

```bash
# Start new conversation
/r2r-agent "What is DeepSeek R1?" rag

# Continue conversation (use returned conversation_id)
/r2r-agent "How does it compare to GPT-4?" rag conv_123abc

# Research mode for complex analysis
/r2r-agent "Analyze the impact of AI on society" research
```

## Multi-turn Tips

- Save conversation_id from each response
- Use research mode for complex topics
- RAG mode is faster for simple queries
- Conversations maintain context across turns
