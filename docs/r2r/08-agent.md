# R2R Agent

## Overview

The R2R Agent is an intelligent, RAG-powered conversational system that combines retrieval capabilities with advanced language models to provide deep, context-aware responses. The agent supports multi-turn conversations, query decomposition, and various specialized tools for complex information retrieval and analysis.

## Core Features

- **Multi-Turn Conversations**: Maintain context across multiple interactions
- **Query Decomposition**: Break complex queries into manageable sub-queries
- **Context Maintenance**: Track conversation history and branches
- **Tool Integration**: Use specialized tools for search, reasoning, and execution
- **Web Search**: Augment knowledge base with real-time web information
- **Streaming Support**: Real-time token generation for better UX

## Agent Modes

### 1. RAG Mode (Default)
Standard retrieval-augmented generation using your knowledge base.

**Capabilities:**
- Search file knowledge base
- Search file descriptions
- Get file content
- Web search (optional)
- Web scraping (optional)

### 2. Research Mode
Advanced mode with reasoning and analytical capabilities.

**Capabilities:**
- All RAG mode tools
- Dedicated reasoning system
- Critique capabilities
- Python code execution
- Multi-step reasoning

## API Endpoint

**Endpoint:** `POST /v3/retrieval/agent`

Engage with the RAG-powered conversational agent.

### Request Parameters

- **message** (object, required): User's message
  - **role** (string): Message role (`user`, `assistant`, `system`)
  - **content** (string): Message content
  - **name** (string, optional): Sender name

- **conversation_id** (string, optional): ID for continuing a conversation
- **branch_id** (string, optional): ID for a specific conversation branch
- **search_mode** (string, optional): `basic`, `advanced`, or `custom`
- **search_settings** (object, optional): Configuration for retrieval
- **rag_generation_config** (object, optional): LLM generation configuration
- **research_generation_config** (object, optional): Research mode LLM config
- **mode** (string, optional): `rag` or `research` (default: `rag`)
- **rag_tools** (array, optional): Tools to enable in RAG mode
- **research_tools** (array, optional): Tools to enable in research mode
- **use_system_context** (boolean, optional): Use extended prompt (default: `true`)
- **needs_initial_conversation_name** (boolean, optional): Auto-assign conversation name
- **max_tool_context_length** (integer, optional): Max tool context length (default: 32768)

## RAG Mode

### Basic Usage

```python
from r2r import R2RClient

client = R2RClient()

# Simple query
response = client.retrieval.agent(
    message={"role": "user", "content": "What is DeepSeek R1?"}
)

print(response)
```

### With Search Settings

```python
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "Can you summarize the latest AI research?"
    },
    search_mode="advanced",
    search_settings={
        "use_semantic_search": True,
        "use_fulltext_search": True,
        "filters": {"publication_year": {"$gte": 2023}},
        "limit": 3
    }
)
```

### Available RAG Tools

Specify which tools the agent can use:

```python
response = client.retrieval.agent(
    message={"role": "user", "content": "Query"},
    rag_tools=[
        "search_file_knowledge",   # Search document chunks
        "search_file_descriptions", # Search document summaries
        "get_file_content",         # Retrieve full documents
        "web_search",               # Search the web
        "web_scrape"                # Extract web content
    ]
)
```

### Example: RAG with Web Search

```python
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "Compare historical and modern interpretations"
    },
    search_settings={
        "limit": 5,
        "filters": {},
        "use_web_search": True  # Requires Serper API key
    }
)
```

## Research Mode

### Basic Usage

```python
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "What does DeepSeek R1 imply? Think about market, societal implications, and more."
    },
    mode="research",
    rag_generation_config={
        "model": "anthropic/claude-3-7-sonnet-20250219",
        "extended_thinking": True,
        "thinking_budget": 4096,
        "temperature": 1,
        "max_tokens_to_sample": 16000,
    }
)
```

### Available Research Tools

```python
response = client.retrieval.agent(
    message={"role": "user", "content": "Deep analysis query"},
    mode="research",
    research_tools=[
        "rag",              # Use underlying RAG agent
        "reasoning",        # Dedicated reasoning model
        "critique",         # Analyze for biases/flaws
        "python_executor"   # Execute Python code
    ]
)
```

### Extended Thinking

Enable extended thinking for complex reasoning:

```python
rag_generation_config = {
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "extended_thinking": True,
    "thinking_budget": 4096,  # Token budget for reasoning
    "temperature": 1,
    "max_tokens_to_sample": 16000
}
```

## Multi-Turn Conversations

### Create and Continue Conversation

```python
# First message - creates conversation
response1 = client.retrieval.agent(
    message={"role": "user", "content": "What is machine learning?"}
)

conversation_id = response1["conversation_id"]

# Follow-up message
response2 = client.retrieval.agent(
    message={"role": "user", "content": "Can you give me an example?"},
    conversation_id=conversation_id
)
```

### Conversation Management

```python
# Create a new conversation
conversation = client.conversations.create("Research Session")
conversation_id = conversation["id"]

# Add system message
client.conversations.add_message(
    conversation_id=conversation_id,
    role="system",
    content="You are an AI research assistant."
)

# Query with conversation context
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "Explain neural networks"
    },
    conversation_id=conversation_id
)
```

### Contextualizing with Files

```python
# Create conversation
conversation = client.conversations.create("Document Analysis")

# Inform agent about available files
client.conversations.add_message(
    conversation_id=conversation["id"],
    role="system",
    content=f"You have access to the following file: {document_info['title']}"
)

# Query with file context
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "Summarize the main points of the document"
    },
    search_settings={"limit": 5, "filters": {}},
    conversation_id=conversation["id"]
)
```

## Configuration

### RAG Generation Config

```python
rag_generation_config = {
    "model": "openai/gpt-4.1",
    "temperature": 0.7,
    "max_tokens_to_sample": 2000,
    "stream": True,
    "top_p": 1.0
}
```

### Search Settings

```python
search_settings = {
    "use_semantic_search": True,
    "use_fulltext_search": False,
    "use_hybrid_search": False,
    "limit": 10,
    "filters": {},
    "search_strategy": "vanilla"
}
```

### Custom Agent Settings

```python
response = client.retrieval.agent(
    message={"role": "user", "content": "Query"},
    search_settings={
        "limit": 5,
        "filters": {
            "date": "2023",
            "category": "technology"
        }
    },
    max_tool_context_length=16384
)
```

## Response Format

### Standard Response

```json
{
  "results": {
    "messages": [
      {
        "role": "assistant",
        "content": "The agent's response...",
        "name": "Assistant",
        "conversation_id": "conversation_id",
        "branch_id": "branch_id"
      }
    ]
  }
}
```

### Streaming Response

When streaming is enabled, events include:
- **thinking**: Agent's reasoning process (if extended thinking enabled)
- **tool_call**: When agent invokes a tool
- **tool_result**: Result of tool invocation
- **citation**: Citation metadata
- **message**: Partial response tokens
- **final_answer**: Complete answer with citations

## Python SDK Examples

### Example 1: Basic Query

```python
from r2r import R2RClient

client = R2RClient(base_url="http://localhost:7272")

# Basic search
results = client.retrieval.search(query="What is DeepSeek R1?")

# RAG with citations
response = client.retrieval.rag(query="What is DeepSeek R1?")

# Agent interaction
agent_response = client.retrieval.agent(
    message={"role": "user", "content": "Explain DeepSeek R1"}
)
```

### Example 2: Deep Research

```python
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "What does DeepSeek R1 imply? Think about market, societal implications, and more."
    },
    rag_generation_config={
        "model": "anthropic/claude-3-7-sonnet-20250219",
        "extended_thinking": True,
        "thinking_budget": 4096,
        "temperature": 1,
        "top_p": None,
        "max_tokens_to_sample": 16000,
    }
)
```

### Example 3: Conversation with Context

```python
# Create conversation
conversation = client.conversations.create("Analysis")

# Add context
client.conversations.add_message(
    conversation_id=conversation["id"],
    role="system",
    content="Focus on technical details and provide code examples."
)

# Multi-turn interaction
response1 = client.retrieval.agent(
    message={"role": "user", "content": "Explain transformers"},
    conversation_id=conversation["id"]
)

response2 = client.retrieval.agent(
    message={"role": "user", "content": "Show me a code example"},
    conversation_id=conversation["id"]
)
```

## JavaScript Examples

### Basic Agent Query

```javascript
const response = await client.agent({
    message: {
        role: "user",
        content: "What are the key features of R2R?"
    },
    search_mode: "advanced"
});

console.log(response.results.messages[0].content);
```

### With Custom Settings

```javascript
const response = await client.agent({
    message: {
        role: "user",
        content: "Analyze the document"
    },
    search_settings: {
        use_semantic_search: true,
        limit: 5,
        filters: { category: "research" }
    },
    rag_generation_config: {
        model: "openai/gpt-4.1",
        temperature: 0.7,
        stream: false
    }
});
```

## cURL Examples

### Basic Request

```bash
curl -X POST "http://localhost:7272/v3/retrieval/agent" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "message": {
      "role": "user",
      "content": "What is R2R?"
    },
    "search_mode": "advanced"
  }'
```

### With Conversation

```bash
curl -X POST "http://localhost:7272/v3/retrieval/agent" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "message": {
      "role": "user",
      "content": "Can you summarize the latest AI research?"
    },
    "search_settings": {
      "use_semantic_search": true,
      "use_fulltext_search": true,
      "filters": { "publication_year": { "$gte": 2023 } },
      "limit": 3
    },
    "conversation_id": "your-conversation-id"
  }'
```

## Agent Configuration in `r2r.toml`

```toml
[agent]
rag_agent_static_prompt = "rag_agent"
tools = ["search_file_knowledge"]

  [agent.generation_config]
  model = "openai/gpt-4.1"
  temperature = 0.7
  max_tokens_to_sample = 2000
```

## Best Practices

### 1. Choose the Right Mode

- **RAG Mode**: For information retrieval and Q&A
- **Research Mode**: For deep analysis and complex reasoning

### 2. Use Conversations for Context

```python
# Create conversation for related queries
conversation = client.conversations.create("Research Session")

# All queries within conversation share context
for query in queries:
    response = client.retrieval.agent(
        message={"role": "user", "content": query},
        conversation_id=conversation["id"]
    )
```

### 3. Filter Appropriately

```python
search_settings = {
    "filters": {
        "collection_ids": {"$overlap": [collection_id]},
        "date": {"$gte": "2023-01-01"}
    }
}
```

### 4. Enable Streaming for Long Responses

```python
rag_generation_config = {
    "stream": True,
    "max_tokens_to_sample": 4000
}
```

### 5. Provide System Context

```python
client.conversations.add_message(
    conversation_id=conversation_id,
    role="system",
    content="You are an expert in AI and machine learning. Provide detailed technical explanations."
)
```

### 6. Use Extended Thinking for Complex Queries

```python
rag_generation_config = {
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "extended_thinking": True,
    "thinking_budget": 4096
}
```

## Common Workflows

### Workflow 1: Document Q&A

```python
# 1. Ingest documents
client.documents.create(file_path="document.pdf")

# 2. Ask questions
response = client.retrieval.agent(
    message={"role": "user", "content": "What are the main findings?"}
)

# 3. Follow up
response = client.retrieval.agent(
    message={"role": "user", "content": "Can you elaborate?"},
    conversation_id=response["conversation_id"]
)
```

### Workflow 2: Research Analysis

```python
# 1. Create research conversation
conversation = client.conversations.create("Research Project")

# 2. Set research context
client.conversations.add_message(
    conversation_id=conversation["id"],
    role="system",
    content="Provide comprehensive analysis with citations."
)

# 3. Perform deep research
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "Analyze the impact of AI on healthcare"
    },
    mode="research",
    conversation_id=conversation["id"]
)
```

### Workflow 3: Multi-Source Analysis

```python
# 1. Enable web search
response = client.retrieval.agent(
    message={
        "role": "user",
        "content": "Compare current trends with historical data"
    },
    rag_tools=[
        "search_file_knowledge",
        "web_search"
    ],
    search_settings={
        "use_web_search": True
    }
)
```

## Troubleshooting

### Agent Not Using Tools

Verify:
1. Tools are included in `rag_tools` or `research_tools`
2. Required API keys are configured (e.g., Serper for web search)
3. Query is clear about information needs

### Context Not Maintained

Check:
1. Conversation ID is passed correctly
2. Conversation exists
3. Messages are added in order

### Poor Response Quality

Solutions:
1. Use better model (e.g., GPT-4)
2. Adjust temperature (lower for focused, higher for creative)
3. Provide system context
4. Enable extended thinking
5. Increase search limit

## Resources

- [R2R Agent API Reference](https://r2r-docs.sciphi.ai/api/agent)
- [Conversation Management](https://r2r-docs.sciphi.ai/features/conversations)
- [Tool Configuration](https://r2r-docs.sciphi.ai/features/tools)
- [Extended Thinking Guide](https://r2r-docs.sciphi.ai/features/reasoning)
