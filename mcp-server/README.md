# R2R FastMCP Server

FastMCP server providing tools for R2R API integration. Maps 1-to-1 with slash commands in `.claude/commands/`.

## Features

### 8 MCP Tools

1. **r2r_search** - Hybrid search (semantic + fulltext)
2. **r2r_rag** - RAG query with generation
3. **r2r_agent** - Multi-turn agent conversation
4. **r2r_collections_list/create/get** - Collection management
5. **r2r_upload** - Document upload
6. **r2r_examples** - Interactive examples catalog
7. **r2r_workflows** - Automated workflows
8. **r2r_quick** - Quick one-line tasks

## Installation

```bash
# Install dependencies with uv (recommended)
uv pip install -e .

# Or with pip
pip install -e .
```

## Configuration

Create `.env` file:

```bash
R2R_BASE_URL=http://localhost:7272  # Your R2R instance URL
API_KEY=your_api_key_here            # R2R API key
```

## Usage

### Run MCP Server

```bash
# Stdio transport (for Claude Code)
python server.py

# Or with fastmcp CLI
fastmcp run server.py
```

### Configure in Claude Code

Add to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "r2r": {
      "command": "python",
      "args": ["/Users/laptop/dev/r2r-fastmcp/mcp-server/server.py"],
      "env": {
        "R2R_BASE_URL": "http://localhost:7272",
        "API_KEY": "your_api_key"
      }
    }
  }
}
```

## Tool Examples

### Search

```python
# Basic search
result = await r2r_search("machine learning", limit=3)

# Collection-specific search
result = await r2r_search(
    "neural networks",
    limit=5,
    collection_id="col_abc123"
)
```

### RAG Query

```python
# Simple question
answer = await r2r_rag("What is FastMCP?", max_tokens=1000)

# Detailed analysis
answer = await r2r_rag(
    "Explain transformer architecture in detail",
    max_tokens=8000
)
```

### Agent Conversation

```python
# Initial query
response = await r2r_agent(
    "Research AI safety implications",
    mode="research"
)

# Follow-up
response = await r2r_agent(
    "Tell me more about alignment",
    conversation_id=response["conversation_id"]
)

# With extended thinking
response = await r2r_agent(
    "Deep analysis required",
    mode="research",
    enable_thinking=True
)
```

### Collections

```python
# List collections
collections = await r2r_collections_list(limit=10)

# Create collection
collection = await r2r_collections_create(
    "AI Research",
    "Papers about artificial intelligence"
)

# Get collection details
details = await r2r_collections_get("col_abc123")
```

### Quick Tasks

```python
# Quick search + RAG answer
result = await r2r_quick("ask", query="What is RAG?")

# System status
status = await r2r_quick("status")

# Quick collection create
col = await r2r_quick("col", name="Test", description="Test collection")
```

### Workflows

```python
# Research workflow with extended thinking
result = await r2r_workflows(
    "research",
    query="Analyze quantum computing implications"
)

# Create collection workflow
result = await r2r_workflows(
    "create-collection",
    name="Research Papers",
    description="Academic papers"
)
```

## Mapping to Slash Commands

| MCP Tool | Slash Command | Bash Script |
|----------|---------------|-------------|
| `r2r_search` | `/r2r-search` | `.claude/scripts/r2r search` |
| `r2r_rag` | `/r2r-rag` | `.claude/scripts/r2r rag` |
| `r2r_agent` | `/r2r-agent` | `.claude/scripts/r2r agent` |
| `r2r_collections_*` | `/r2r-collections` | `.claude/scripts/r2r collections` |
| `r2r_upload` | `/r2r-upload` | `.claude/scripts/r2r docs upload` |
| `r2r_examples` | `/r2r-examples` | `.claude/scripts/examples.sh` |
| `r2r_workflows` | `/r2r-workflows` | `.claude/scripts/workflows.sh` |
| `r2r_quick` | `/r2r-quick` | `.claude/scripts/quick.sh` |

## API Endpoints Used

- **Search:** `POST /v3/retrieval/search`
- **RAG:** `POST /v3/retrieval/rag`
- **Agent:** `POST /v3/retrieval/agent`
- **Collections List:** `GET /v3/collections`
- **Collections Create:** `POST /v3/collections`
- **Collections Get:** `GET /v3/collections/{id}`
- **Documents Create:** `POST /v3/documents/create`

## Development

### Run Tests

```bash
pytest
```

### Lint & Format

```bash
ruff check .
ruff format .
```

## Architecture

```text
┌─────────────────┐
│  Claude Code    │  Uses MCP tools
│   (Client)      │  via MCP protocol
└────────┬────────┘
         │ MCP stdio
┌────────▼────────┐
│  FastMCP Server │  8 @mcp.tool decorators
│  (server.py)    │  Map to R2R API
└────────┬────────┘
         │ HTTP + JSON
┌────────▼────────┐
│      R2R        │  v3 API endpoints
│   (Backend)     │  /v3/retrieval/*
└─────────────────┘
```

## Comparison: Bash vs MCP

### Before (Bash Scripts)

```bash
# Requires shell execution
.claude/scripts/r2r search "query" --limit 3

# Output: text parsing needed
```

### After (MCP Tools)

```python
# Native function call
result = await r2r_search("query", limit=3)

# Output: structured JSON
```

### Benefits of MCP

1. **Type Safety:** Python type hints, JSON schemas
2. **Error Handling:** Proper exceptions, validation
3. **Integration:** Native tool calling in Claude
4. **Async Support:** Non-blocking I/O
5. **Composability:** Tools can call other tools
6. **Testing:** Unit tests for each tool
7. **Documentation:** Auto-generated from docstrings

## License

MIT
