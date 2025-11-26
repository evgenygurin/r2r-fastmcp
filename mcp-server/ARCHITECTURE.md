# Two-Layer FastMCP Architecture

Intelligent MCP server architecture with automatic OpenAPI tool generation and smart composite workflows.

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                      Claude Code Client                      │
│                  (Uses MCP Protocol)                         │
└───────────────┬──────────────────────┬──────────────────────┘
                │                      │
       ┌────────▼──────────┐  ┌────────▼──────────┐
       │   Layer 2 Smart   │  │   Layer 1 OpenAPI │
       │  Composite Tools  │──▶│   Basic Tools     │
       │  (layer2_smart.py)│  │(layer1_openapi.py)│
       └────────┬──────────┘  └────────┬───────────┘
                │                      │
                │         ┌────────────▼───────────┐
                └────────▶│    R2R API (HTTP)      │
                          │http://136.119.36.216:  │
                          │7272/openapi.json       │
                          └────────────────────────┘
```

## Layer 1: OpenAPI Basic Tools

### Purpose
- Auto-generate MCP tools from R2R OpenAPI specification
- Provide 1-to-1 mapping of all 81 R2R endpoints
- Handle authentication and request/response formatting
- Expose low-level API access

### Features
- ✅ Automatic tool generation from OpenAPI spec
- ✅ Type-safe parameter handling
- ✅ Authentication via Bearer token
- ✅ Error handling with proper exceptions
- ✅ MCP resources for config and spec

### Example Tools (Layer 1)
```python
# Direct API mapping
await r2r_search(query="test", limit=3)
await r2r_rag(query="What is X?", max_tokens=4000)
await r2r_agent(message="Research Y", conversation_id=None)
await collections_create(name="Test", description="Desc")
await graph_entities(collection_id="col123", limit=50)
```

### OpenAPI Integration
```python
# Fetch OpenAPI spec
spec = await fetch_openapi_spec()

# Auto-generate tools from endpoints
for path, methods in spec["paths"].items():
    for method, definition in methods.items():
        # Create @mcp.tool dynamically
        create_tool_from_openapi(path, method, definition)
```

---

## Layer 2: Smart Composite Tools

### Purpose
- Wrap Layer 1 tools with intelligence
- Provide high-level workflows
- Implement multi-step operations
- Expose smart prompts and resources

### Features
- ✅ Intelligent search with filtering and re-ranking
- ✅ Multi-step deep research workflows
- ✅ Multi-source synthesis
- ✅ Parallel collection processing
- ✅ Smart prompts as MCP resources
- ✅ Automatic error recovery
- ✅ Context-aware operations

### Example Tools (Layer 2)
```python
# Smart operations
await smart_search(
    query="AI safety",
    max_results=10,
    min_score=0.7
)

await deep_research(
    query="Quantum computing implications",
    num_iterations=3
)

await synthesize_sources(
    query="Transformer architecture",
    num_sources=10
)

await knowledge_graph_query(
    collection_id="col123",
    entity_name="neural networks"
)
```

### Smart Workflows
```python
# Multi-step pipeline
result = await document_upload_pipeline(
    file_path="paper.pdf",
    collection_name="Research Papers",
    extract_entities=True
)

# Parallel search
results = await bulk_collection_search(
    query="machine learning",
    collection_ids=["col1", "col2", "col3"]
)
```

---

## Comparison: Layer 1 vs Layer 2

| Aspect | Layer 1 (Basic) | Layer 2 (Smart) |
|--------|----------------|----------------|
| **Abstraction** | Low-level API calls | High-level workflows |
| **Complexity** | Simple, direct | Complex, composable |
| **Operations** | Single API call | Multiple API calls |
| **Intelligence** | None | Context-aware |
| **Use Case** | Direct API access | Business logic |
| **Example** | `r2r_search()` | `smart_search()` |

### Example: Search Operation

**Layer 1 (Basic):**
```python
# Simple search
result = await r2r_search(
    query="machine learning",
    limit=10
)
# Returns raw API response
```

**Layer 2 (Smart):**
```python
# Intelligent search with filtering
result = await smart_search(
    query="machine learning",
    max_results=10,
    min_score=0.7  # Auto-filter by relevance
)
# Returns filtered and ranked results
```

---

## Tool Categories

### Layer 1: Basic Tools (16 tools)

**Core Retrieval:**
- `r2r_search` - Hybrid search
- `r2r_rag` - RAG generation
- `r2r_agent` - Agent conversation

**Collections:**
- `collections_list` - List collections
- `collections_create` - Create collection
- `collections_get` - Get collection
- `collections_update` - Update collection
- `collections_delete` - Delete collection

**Documents:**
- `documents_list` - List documents
- `documents_get` - Get document
- `documents_delete` - Delete document

**Knowledge Graph:**
- `graphs_list` - List graphs
- `graph_entities` - List entities
- `graph_relationships` - List relationships
- `graph_communities` - List communities

**Resources:**
- `r2r://openapi/spec` - OpenAPI specification
- `r2r://config/base_url` - R2R base URL

### Layer 2: Smart Tools (10 tools)

**Smart Search:**
- `smart_search` - Intelligent search with filtering
- `semantic_compare` - Compare texts semantically
- `bulk_collection_search` - Parallel collection search

**Smart RAG:**
- `deep_research` - Multi-step iterative research
- `synthesize_sources` - Multi-source synthesis

**Smart Collections:**
- `create_smart_collection` - Collection with metadata
- `knowledge_graph_query` - Graph exploration

**Smart Workflows:**
- `document_upload_pipeline` - Complete upload workflow

**Resources (Prompts):**
- `prompts://research/deep_analysis` - Research prompt
- `prompts://synthesis/multi_source` - Synthesis prompt
- `workflows://available` - Available workflows

---

## Usage Examples

### Scenario 1: Simple Search (Use Layer 1)

```python
# Direct API call
result = await r2r_search(
    query="FastMCP tutorial",
    limit=5
)
```

### Scenario 2: Smart Search (Use Layer 2)

```python
# Intelligent search with auto-filtering
result = await smart_search(
    query="FastMCP tutorial",
    max_results=5,
    min_score=0.8
)
```

### Scenario 3: Deep Research (Use Layer 2)

```python
# Multi-step research workflow
report = await deep_research(
    query="Impact of quantum computing on cryptography",
    num_iterations=3,
    max_tokens_per_iteration=4000
)

# Access iterative results
for iteration in report["research_steps"]:
    print(f"Iteration {iteration['iteration']}")
    print(iteration['response'])
```

### Scenario 4: Multi-Source Synthesis (Use Layer 2)

```python
# Synthesize from 10 sources
synthesis = await synthesize_sources(
    query="Transformer architecture evolution",
    num_sources=10
)

print(synthesis["synthesized_answer"])
print(f"Sources used: {synthesis['sources_found']}")
```

### Scenario 5: Collection Management

**Layer 1 (Basic):**
```python
# Manual collection creation
col = await collections_create(
    name="Research Papers",
    description="Academic papers"
)
collection_id = col["results"]["id"]
```

**Layer 2 (Smart):**
```python
# Smart collection with metadata
col = await create_smart_collection(
    name="Research Papers",
    description="Academic papers",
    tags=["AI", "ML", "Deep Learning"]
)
# Auto-generated metadata included
print(col["metadata"])
print(col["next_steps"])
```

---

## Configuration

### Layer 1 Configuration
```bash
# .env
R2R_BASE_URL=http://136.119.36.216:7272
API_KEY=your_api_key_here
```

### Claude Code Integration

**Layer 1 Only:**
```json
{
  "mcpServers": {
    "r2r-layer1": {
      "command": "python",
      "args": ["mcp-server/layer1_openapi.py"],
      "env": {
        "R2R_BASE_URL": "http://136.119.36.216:7272",
        "API_KEY": "your_key"
      }
    }
  }
}
```

**Layer 2 (includes Layer 1):**
```json
{
  "mcpServers": {
    "r2r-smart": {
      "command": "python",
      "args": ["mcp-server/layer2_smart.py"],
      "env": {
        "R2R_BASE_URL": "http://136.119.36.216:7272",
        "API_KEY": "your_key"
      }
    }
  }
}
```

**Both Layers (recommended):**
```json
{
  "mcpServers": {
    "r2r-layer1": {
      "command": "python",
      "args": ["mcp-server/layer1_openapi.py"],
      "env": {...}
    },
    "r2r-smart": {
      "command": "python",
      "args": ["mcp-server/layer2_smart.py"],
      "env": {...}
    }
  }
}
```

---

## Benefits

### Layer 1 Benefits
- ✅ Complete API coverage (81 endpoints)
- ✅ Type-safe parameters
- ✅ Direct control
- ✅ Predictable behavior
- ✅ Easy debugging

### Layer 2 Benefits
- ✅ Higher productivity
- ✅ Complex workflows simplified
- ✅ Intelligent defaults
- ✅ Error recovery
- ✅ Context-aware operations
- ✅ Composable tools
- ✅ Smart prompts included

---

## Development Workflow

### Adding New Layer 1 Tool
```python
@mcp.tool()
async def new_endpoint(param: str) -> Dict[str, Any]:
    """Description from OpenAPI"""
    return await call_r2r_endpoint(
        "POST",
        "/v3/new/endpoint",
        body={"param": param}
    )
```

### Adding New Layer 2 Tool
```python
@mcp.tool()
async def smart_workflow(query: str) -> Dict[str, Any]:
    """Smart composite workflow"""
    # Step 1: Use Layer 1 tool
    search = await layer1.r2r_search(query, limit=10)

    # Step 2: Process results
    filtered = [r for r in search["results"]["chunk_search_results"]
                if r["score"] > 0.7]

    # Step 3: Use another Layer 1 tool
    rag = await layer1.r2r_rag(query, max_tokens=4000)

    # Step 4: Combine and return
    return {
        "search_results": filtered,
        "rag_answer": rag["results"]["generated_answer"]
    }
```

---

## Testing

### Layer 1 Tests
```python
@pytest.mark.asyncio
async def test_r2r_search():
    result = await r2r_search("test", limit=3)
    assert "results" in result
```

### Layer 2 Tests
```python
@pytest.mark.asyncio
async def test_smart_search():
    result = await smart_search("test", max_results=5, min_score=0.7)
    assert result["filtered_count"] <= result["total_found"]
    assert all(r["score"] >= 0.7 for r in result["results"])
```

---

## Deployment

### Run Layer 1
```bash
python layer1_openapi.py
```

### Run Layer 2
```bash
python layer2_smart.py
```

### Run Both (separate processes)
```bash
python layer1_openapi.py &
python layer2_smart.py &
```

---

## Future Enhancements

### Layer 1
- [ ] Full OpenAPI spec parsing
- [ ] Auto-generate all 81 tools
- [ ] Dynamic tool registration
- [ ] Streaming support

### Layer 2
- [ ] Machine learning-based ranking
- [ ] Automatic query expansion
- [ ] Caching layer
- [ ] Batch operations
- [ ] Advanced graph algorithms
- [ ] Multi-agent orchestration

---

## Summary

**Use Layer 1 when:**
- Need direct API control
- Simple single operations
- Debugging API issues
- Building custom workflows

**Use Layer 2 when:**
- Need intelligent workflows
- Multi-step operations
- High-level business logic
- Rapid development

**Use Both:**
- Maximum flexibility
- Gradual complexity
- Mix simple and smart operations
