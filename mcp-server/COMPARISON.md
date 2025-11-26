# Bash Scripts vs MCP Tools Comparison

Complete mapping of slash commands to MCP tools with 1-to-1 correspondence.

## Overview

| Component | Bash Implementation | MCP Implementation |
|-----------|-------------------|-------------------|
| **Architecture** | Slash commands → Bash scripts → curl | MCP tools → FastMCP → httpx |
| **Interface** | CLI with text output | Python async functions |
| **Data Format** | Text parsing required | Structured JSON |
| **Error Handling** | Exit codes | Python exceptions |
| **Type Safety** | None | Type hints + validation |
| **Testing** | Shell scripts | Unit tests |
| **Integration** | Shell execution | Native tool calling |

## 1-to-1 Command Mapping

### 1. Search Command

#### Bash Implementation
```bash
# Slash command
/r2r-search "machine learning" 5 --verbose

# Bash script
.claude/scripts/r2r search "machine learning" --limit 5 --verbose

# Implementation
curl -X POST "${R2R_BASE_URL}/v3/retrieval/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "query": "machine learning",
    "limit": 5,
    "search_settings": {
      "use_hybrid_search": true,
      "search_strategy": "vanilla"
    }
  }'
```

#### MCP Tool
```python
# Tool call
result = await r2r_search(
    query="machine learning",
    limit=5,
    strategy="vanilla"
)

# Returns structured dict:
{
  "results": {
    "chunk_search_results": [
      {
        "id": "abc123",
        "score": 0.95,
        "text": "...",
        "metadata": {...}
      }
    ]
  }
}
```

**Key Differences:**
- ✅ MCP: Type-safe parameters
- ✅ MCP: Structured JSON response
- ✅ MCP: Async/await support
- ✅ MCP: Automatic validation

---

### 2. RAG Command

#### Bash Implementation
```bash
# Slash command
/r2r-rag "What is FastMCP?" 8000 --show-sources

# Bash script
.claude/scripts/r2r rag "What is FastMCP?" --max-tokens 8000 --show-sources

# Text output with parsing
💬 RAG | tokens:8000

FastMCP is a Python framework...

📚 Sources:
  [1] Unknown [abc123] (score: 0.02)
```

#### MCP Tool
```python
# Tool call
result = await r2r_rag(
    query="What is FastMCP?",
    max_tokens=8000
)

# Returns structured dict:
{
  "results": {
    "generated_answer": "FastMCP is a Python framework...",
    "citations": [...],
    "search_results": {
      "chunk_search_results": [...]
    }
  }
}
```

**Benefits:**
- ✅ No text parsing needed
- ✅ Access to raw citations data
- ✅ Programmatic access to sources
- ✅ Easy to extract specific fields

---

### 3. Agent Command

#### Bash Implementation
```bash
# Slash command
/r2r-agent "Research AI safety" research "" --thinking

# Bash script
.claude/scripts/r2r agent "Research AI safety" \
  --mode research \
  --thinking \
  --new

# Stores conversation_id in /tmp/.r2r_conversation_id
```

#### MCP Tool
```python
# Initial query
response = await r2r_agent(
    message="Research AI safety",
    mode="research",
    enable_thinking=True
)

# Follow-up (automatic conversation tracking)
response2 = await r2r_agent(
    message="Tell me more",
    conversation_id=response["results"]["conversation_id"],
    mode="research"
)
```

**Advantages:**
- ✅ Conversation state in memory
- ✅ No temp files needed
- ✅ Multi-turn support built-in
- ✅ Extended thinking parameter

---

### 4. Collections Command

#### Bash Implementation
```bash
# List collections
/r2r-collections list

.claude/scripts/r2r collections list --limit 10 --quiet

# Create collection
/r2r-collections create "AI Research" "Papers about AI"

.claude/scripts/r2r collections create \
  --name "AI Research" \
  --description "Papers about AI"
```

#### MCP Tools (3 separate tools)
```python
# List collections
collections = await r2r_collections_list(limit=10)

# Create collection
new_col = await r2r_collections_create(
    name="AI Research",
    description="Papers about AI"
)

# Get collection details
details = await r2r_collections_get(
    collection_id="col_abc123"
)
```

**Improvements:**
- ✅ Separate tools for clarity
- ✅ Type-safe collection IDs
- ✅ Direct dict access
- ✅ No sub-command parsing

---

### 5. Upload Command

#### Bash Implementation
```bash
# Slash command
/r2r-upload ./document.pdf "col1,col2" --title "Research Paper"

# Bash script
.claude/scripts/r2r docs upload "./document.pdf" \
  --collections "col1,col2" \
  --title "Research Paper" \
  --mode hi-res
```

#### MCP Tool
```python
# Upload document
result = await r2r_upload(
    file_path="./document.pdf",
    collection_ids=["col1", "col2"],
    title="Research Paper",
    mode="hi-res"
)

# Returns document_id
document_id = result["results"]["document_id"]
```

**Benefits:**
- ✅ List instead of comma-separated string
- ✅ Direct file path handling
- ✅ Structured response
- ✅ Easy to chain operations

---

### 6. Examples Command

#### Bash Implementation
```bash
# Show examples
/r2r-examples search

# Interactive menu
.claude/scripts/examples.sh search

# Outputs formatted text with code snippets
```

#### MCP Tool
```python
# Get examples programmatically
examples = await r2r_examples(category="search")

# Returns structured catalog:
{
  "category": "search",
  "examples": [
    {
      "name": "Basic Search",
      "description": "Simple search with 3 results",
      "code": "r2r_search('query', limit=3)"
    }
  ]
}
```

**Advantages:**
- ✅ Programmatic access
- ✅ Filter by category
- ✅ Structured code snippets
- ✅ Easy to display/execute

---

### 7. Workflows Command

#### Bash Implementation
```bash
# Research workflow
/r2r-workflows research "Complex query"

# Multiple bash commands chained
.claude/scripts/workflows.sh research "Complex query"

# Executes: search → rag → agent
```

#### MCP Tool
```python
# Research workflow (single call)
result = await r2r_workflows(
    workflow="research",
    query="Complex query"
)

# Create collection workflow
result = await r2r_workflows(
    workflow="create-collection",
    name="New Collection",
    description="Description"
)
```

**Improvements:**
- ✅ Atomic operations
- ✅ Transaction-like behavior
- ✅ Better error handling
- ✅ Composable workflows

---

### 8. Quick Command

#### Bash Implementation
```bash
# Quick ask
/r2r-quick ask "What is RAG?"

# Quick status
/r2r-quick status

# Bash implementation
.claude/scripts/quick.sh ask "What is RAG?"
```

#### MCP Tool
```python
# Quick ask (search + RAG in one call)
result = await r2r_quick(
    task="ask",
    query="What is RAG?"
)

# Quick status check
status = await r2r_quick(task="status")

# Quick collection create
col = await r2r_quick(
    task="col",
    name="Test",
    description="Test collection"
)
```

**Benefits:**
- ✅ Combined operations
- ✅ Single tool call
- ✅ Structured shortcuts
- ✅ Kwargs for flexibility

---

## Performance Comparison

| Aspect | Bash Scripts | MCP Tools |
|--------|-------------|-----------|
| **Latency** | Process spawn overhead (~50-100ms) | Direct async call (~5-10ms) |
| **Memory** | New process per command | Shared server process |
| **Concurrency** | Sequential execution | Parallel async calls |
| **Error Recovery** | Exit codes, text parsing | Structured exceptions |
| **Data Parsing** | Regex, jq, text manipulation | Native JSON deserialization |

## Testing Comparison

### Bash Tests
```bash
# Integration tests only
./test_search.sh
./test_rag.sh

# Limited mocking capabilities
# Requires actual API running
```

### MCP Tests
```python
# Unit tests with mocking
@pytest.mark.asyncio
async def test_r2r_search(mock_request):
    mock_request.return_value = {...}
    result = await r2r_search("test")
    assert result["results"]

# Integration tests
# API can be mocked or real
```

## Integration Examples

### Bash Integration (Current)
```bash
# Claude Code slash command
User: /r2r-search "test"
→ Execute: .claude/scripts/r2r search "test"
→ Parse: Text output
→ Display: Formatted text
```

### MCP Integration (New)
```python
# Claude Code tool call
User: Use r2r_search for "test"
→ Call: await r2r_search("test")
→ Receive: JSON dict
→ Display: Native formatting
```

## Migration Path

### Phase 1: Parallel Operation
- Keep bash scripts for backward compatibility
- Add MCP server as optional feature
- Users can choose preferred interface

### Phase 2: Gradual Adoption
- Encourage MCP for new features
- Document benefits
- Provide migration guide

### Phase 3: Full Migration
- Deprecate bash scripts
- MCP as primary interface
- Bash scripts as thin wrappers (optional)

## Conclusion

### Bash Scripts Strengths
- ✅ Simple to understand
- ✅ No dependencies
- ✅ CLI-first design
- ✅ Easy to debug with curl

### MCP Tools Strengths
- ✅ Type safety
- ✅ Structured data
- ✅ Better integration
- ✅ Testability
- ✅ Async performance
- ✅ Native tool calling
- ✅ Composability
- ✅ Error handling

**Recommendation:** Use MCP tools for programmatic access, keep bash scripts for manual CLI usage.
