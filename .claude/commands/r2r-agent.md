---
name: r2r-agent
description: Multi-turn conversation with R2R agent
argument-hint: <message> [mode] [conversation_id] [--thinking|--json|--show-tools]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Agent Conversation

**Message:** {message}

**Options:**
- **Mode:** {mode} (rag/research, default: **research**)
  - `rag`: Standard RAG with knowledge base tools
  - `research`: Advanced mode with reasoning, critique, code execution
- **Conversation ID:** {conversation_id} (optional, auto-reused from /tmp/.r2r_conversation_id)
- **Flags:** --thinking (4096 token budget), --json, --show-tools, --show-sources

## Instructions

Use the modular R2R CLI to interact with R2R agent.

Execute agent command:
```bash
.claude/scripts/r2r agent "{message}" --mode {mode} ${conversation_id:+--conversation {conversation_id}}
```

**First message:** Agent creates new conversation, auto-saves ID to `/tmp/.r2r_conversation_id`
**Follow-ups:** Use `--conversation <id>` or CLI auto-reuses last conversation
**Auto-reuse:** If no conversation_id provided, CLI uses saved ID from temp file

### Modes

**RAG Mode:**
- **Best for:** Direct questions, fact retrieval
- **Tools:** search_file_knowledge, search_file_descriptions, get_file_content, web_search, web_scrape

**Research Mode (DEFAULT):**
- **Best for:** Complex analysis, multi-step reasoning, deep exploration
- **Tools:** rag, reasoning, critique, python_executor
- **Features:** Advanced reasoning capabilities

### Extended Thinking

Use `--thinking` flag for complex queries:
- Enables 4096 token reasoning budget
- Best for philosophical questions, deep analysis, multi-step reasoning

### Available Flags

- `--conversation, -c <id>` - Continue specific conversation
- `--thinking` - Extended thinking (4096 tokens)
- `--show-tools` - Show tool calls
- `--show-sources` - Show citations
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON output

### Presentation

Present agent response:
- **Response:** [agent's answer as clean text]
- **Conversation ID:** [auto-saved to /tmp/.r2r_conversation_id]
- **Mode:** [current mode]
- **Thinking:** [if extended thinking used]

If no message provided, prompt user for a message.

## Examples

```bash
# Basic research query (default mode)
/r2r-agent "What is DeepSeek R1?"

# RAG mode for simple question
/r2r-agent "What are FastMCP decorators?" rag

# Continue conversation
/r2r-agent "Tell me more details" research <conversation_id>

# Extended thinking for deep analysis
/r2r-agent "Analyze philosophical implications of RAG systems" research "" --thinking

# Multi-turn with thinking
/r2r-agent "Deep question" research <conversation_id> --thinking

# Show tool calls
/r2r-agent "Complex query" research "" --show-tools

# JSON output
/r2r-agent "Query" research "" --json
```

## Tips

- **Research mode** (default) provides better reasoning
- **Extended thinking** adds deep analytical capabilities
- **Conversation ID** auto-saved for follow-ups
- **Context maintained** across turns
- **RAG mode** only for simple factual queries
