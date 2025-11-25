# R2R Documentation

## Overview

R2R (RAG to Riches) is a production-ready AI retrieval system offering cutting-edge search capabilities including hybrid search, knowledge graphs, and agentic RAG. This documentation provides comprehensive guides for installing, configuring, and using R2R.

## What is R2R?

R2R is an advanced retrieval-augmented generation (RAG) platform that combines:
- **Vector Search**: Semantic similarity search using embeddings
- **Full-Text Search**: Traditional keyword-based search
- **Knowledge Graphs**: Entity and relationship extraction
- **Agentic RAG**: Intelligent conversational agents
- **Multi-User Support**: Collections, authentication, and access control

## Documentation Structure

### 1. [Installation and Setup](./01-installation-and-setup.md)
Get R2R up and running quickly with various installation methods:
- Docker installation (recommended)
- Python SDK installation
- JavaScript SDK installation
- GCP deployment
- Environment configuration

**Key Topics:**
- Prerequisites and requirements
- Docker Compose setup
- Python and JavaScript SDKs
- Environment variables
- Verification and troubleshooting

### 2. [Document Management](./02-document-management.md)
Learn how to ingest, manage, and organize documents:
- Document ingestion from files, text, or URLs
- Metadata management
- Document lifecycle operations
- Ingestion modes (hi-res, fast, custom)
- Export and deletion

**Key Topics:**
- Creating and uploading documents
- Ingestion configuration
- Updating and deleting documents
- Checking ingestion status
- Knowledge graph extraction from documents

### 3. [Search and RAG](./03-search-and-rag.md)
Master search and retrieval-augmented generation:
- Vector, full-text, and hybrid search
- RAG queries with citations
- Search modes and strategies
- Filtering and pagination
- Streaming responses

**Key Topics:**
- Basic and advanced search
- Hybrid search configuration
- RAG generation settings
- Knowledge graph-enhanced search
- Search strategies (RAG-Fusion, HyDE)
- Model configuration

### 4. [Knowledge Graphs](./04-knowledge-graphs.md)
Understand entity and relationship management:
- Automatic extraction from documents
- Manual entity and relationship creation
- Community detection
- Graph synchronization
- Graph-enhanced retrieval

**Key Topics:**
- Entity extraction and management
- Relationship creation
- Community building
- Graph operations (pull, reset)
- Export functions
- Deduplication

### 5. [Collections](./05-collections.md)
Organize documents and control access:
- Creating and managing collections
- Document-to-collection associations
- User access control
- Collection-level knowledge graphs
- Multi-collection workflows

**Key Topics:**
- Collection creation and updates
- Adding/removing documents
- User permissions
- Collection-scoped search
- Graph management per collection

### 6. [Authentication and Users](./06-authentication-and-users.md)
Secure your R2R instance with user management:
- User registration and verification
- Authentication methods (JWT, API keys)
- Password management
- Role-based access control
- API key management

**Key Topics:**
- User registration and login
- Email verification
- Password reset flows
- API key creation
- Superuser privileges
- Collection membership

### 7. [Configuration](./07-configuration.md)
Customize R2R behavior through configuration:
- `r2r.toml` configuration file
- Environment variables
- Runtime overrides
- Component-specific settings
- Performance tuning

**Key Topics:**
- Application settings
- Authentication configuration
- LLM and embedding settings
- Ingestion configuration
- Knowledge graph settings
- Rate limiting
- Database configuration

### 8. [Agent](./08-agent.md)
Use the intelligent conversational agent:
- RAG mode for information retrieval
- Research mode for deep analysis
- Multi-turn conversations
- Tool integration
- Web search capabilities

**Key Topics:**
- Agent modes (RAG vs Research)
- Conversation management
- Tool configuration
- Extended thinking
- Context maintenance
- Streaming responses

## Quick Start

### Installation

```bash
# Clone repository
git clone git@github.com:SciPhi-AI/R2R.git && cd R2R

# Set API key
export OPENAI_API_KEY=sk-...

# Start with Docker
docker compose up
```

### Basic Usage (Python)

```python
from r2r import R2RClient

client = R2RClient("http://localhost:7272")

# Ingest a document
client.documents.create(file_path="document.pdf")

# Search
results = client.retrieval.search(query="What is machine learning?")

# RAG query
response = client.retrieval.rag(query="Explain neural networks")

# Agent interaction
agent_response = client.retrieval.agent(
    message={"role": "user", "content": "What are transformers?"}
)
```

### Basic Usage (JavaScript)

```javascript
import { R2RClient } from 'r2r-js';

const client = new R2RClient('http://localhost:7272');

// Ingest a document
await client.documents.create({ 
    file: { path: 'document.pdf', name: 'document.pdf' }
});

// Search
const results = await client.retrieval.search({
    query: 'What is machine learning?'
});

// RAG query
const response = await client.retrieval.rag({
    query: 'Explain neural networks'
});
```

## Core Concepts

### Documents
The primary unit of content in R2R. Documents can be:
- Uploaded from files (PDF, DOCX, TXT, etc.)
- Created from raw text
- Pre-processed as chunks
- Associated with metadata and collections

### Collections
Logical groupings of documents that:
- Organize related content
- Control user access
- Maintain separate knowledge graphs
- Enable isolated search and retrieval

### Knowledge Graphs
Structured representations of information with:
- **Entities**: Concepts, people, organizations, etc.
- **Relationships**: Connections between entities
- **Communities**: Groups of related entities

### Users and Authentication
Multi-user support with:
- Email/password authentication
- API key management
- Role-based access control
- Collection-level permissions

### Agent
An intelligent conversational system that:
- Maintains conversation context
- Uses multiple tools for information retrieval
- Supports reasoning and analysis
- Integrates web search

## Architecture

### Components

1. **API Layer**: RESTful API endpoints for all operations
2. **Ingestion Pipeline**: Document processing and chunking
3. **Vector Store**: PostgreSQL with pgvector extension
4. **Knowledge Graph**: Entity and relationship storage
5. **LLM Integration**: Via LiteLLM (100+ providers)
6. **Agent System**: Conversational AI with tool use

### Data Flow

```
Document Upload → Parsing → Chunking → Embedding → Vector Store
                                    ↓
                              Knowledge Graph ← Entity Extraction
                                    ↓
Query → Search → Context Retrieval → LLM Generation → Response
```

## Common Workflows

### 1. Document Ingestion and Search

```python
# 1. Ingest documents
for file_path in document_paths:
    client.documents.create(file_path=file_path)

# 2. Search
results = client.retrieval.search("your query")

# 3. RAG query
response = client.retrieval.rag("your question")
```

### 2. Knowledge Graph Construction

```python
# 1. Ingest documents
client.documents.create(file_path="document.pdf")

# 2. Extract entities and relationships
client.documents.extract(document_id)

# 3. Build communities
client.graphs.build_communities(collection_id)

# 4. Search with graph enhancement
results = client.retrieval.search(
    query="query",
    graph_search_settings={"use_graph_search": True}
)
```

### 3. Multi-User Collaboration

```python
# 1. Create collection
collection = client.collections.create("Team Project")

# 2. Add team members
for user_id in team_members:
    client.collections.add_user(user_id, collection["id"])

# 3. Add documents
client.documents.create(
    file_path="document.pdf",
    collection_ids=[collection["id"]]
)

# 4. Team members search within collection
results = client.retrieval.search(
    query="query",
    search_settings={
        "filters": {"collection_ids": {"$overlap": [collection["id"]]}}
    }
)
```

## API Overview

### Document Operations
- `POST /v3/documents` - Create document
- `GET /v3/documents` - List documents
- `GET /v3/documents/{id}` - Get document
- `PUT /v3/documents/{id}` - Update document
- `DELETE /v3/documents/{id}` - Delete document
- `POST /v3/documents/{id}/extract` - Extract knowledge graph

### Search and RAG
- `POST /v3/retrieval/search` - Search documents
- `POST /v3/retrieval/rag` - RAG query
- `POST /v3/retrieval/agent` - Agent interaction
- `POST /v3/documents/search` - Search document summaries

### Collections
- `POST /v3/collections` - Create collection
- `GET /v3/collections` - List collections
- `PUT /v3/collections/{id}` - Update collection
- `DELETE /v3/collections/{id}` - Delete collection

### Knowledge Graphs
- `POST /v3/graphs/{collection_id}/entities` - Create entity
- `GET /v3/graphs/{collection_id}/entities` - List entities
- `POST /v3/graphs/{collection_id}/relationships` - Create relationship
- `GET /v3/graphs/{collection_id}/relationships` - List relationships
- `POST /v3/graphs/{collection_id}/communities/build` - Build communities
- `POST /v3/graphs/{collection_id}/pull` - Sync graph

### Users and Auth
- `POST /v3/users` - Register user
- `POST /v3/users/login` - Login
- `POST /v3/users/logout` - Logout
- `GET /v3/users/me` - Get current user
- `POST /v3/users/{id}/api_keys` - Create API key

## SDKs

### Python SDK

```bash
pip install r2r
```

```python
from r2r import R2RClient

client = R2RClient("http://localhost:7272")
```

### JavaScript SDK

```bash
npm install r2r-js
```

```javascript
import { R2RClient } from 'r2r-js';

const client = new R2RClient('http://localhost:7272');
```

## Configuration

### Environment Variables

```bash
# LLM Provider
export OPENAI_API_KEY=sk-...

# Configuration
export R2R_CONFIG_PATH=/path/to/r2r.toml
export R2R_CONFIG_NAME=full

# Database
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
```

### Configuration File (`r2r.toml`)

```toml
[completion]
provider = "litellm"

  [completion.generation_config]
  model = "openai/gpt-4.1"
  temperature = 0.1

[embedding]
provider = "litellm"
base_model = "openai/text-embedding-3-small"

[ingestion]
chunk_size = 1024
chunk_overlap = 512
```

## Best Practices

1. **Use Collections**: Organize documents logically for better access control and search
2. **Enable Authentication**: Secure your instance with user authentication
3. **Tune Chunk Size**: Adjust based on your content type and use case
4. **Build Knowledge Graphs**: Extract entities for enhanced retrieval
5. **Use Hybrid Search**: Combine semantic and keyword search for best results
6. **Stream Long Responses**: Enable streaming for better user experience
7. **Monitor Rate Limits**: Configure appropriate limits for your workload
8. **Backup Configurations**: Keep backups of your `r2r.toml` file

## Troubleshooting

### Common Issues

1. **Installation Problems**: Check Docker installation and permissions
2. **API Connection**: Verify R2R is running and accessible
3. **Authentication Errors**: Check API keys and tokens
4. **Empty Search Results**: Verify documents are ingested and indexed
5. **Performance Issues**: Tune batch sizes and concurrency limits

### Getting Help

- **GitHub Issues**: [R2R GitHub Repository](https://github.com/sciphi-ai/r2r/issues)
- **Documentation**: [R2R Official Docs](https://r2r-docs.sciphi.ai)
- **Community**: Join R2R community discussions

## Resources

### Official Links
- [R2R GitHub](https://github.com/sciphi-ai/r2r)
- [R2R Documentation](https://r2r-docs.sciphi.ai)
- [Python SDK](https://github.com/sciphi-ai/r2r/tree/main/py/sdk)
- [JavaScript SDK](https://github.com/sciphi-ai/r2r/tree/main/js)

### Additional Resources
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [PostgreSQL pgvector](https://github.com/pgvector/pgvector)
- [Docker Documentation](https://docs.docker.com/)

## Contributing

R2R is open source! Contributions are welcome:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

R2R is licensed under the MIT License. See the [LICENSE](https://github.com/sciphi-ai/r2r/blob/main/LICENSE) file for details.

## Support

For questions, issues, or feature requests:
- Open an issue on [GitHub](https://github.com/sciphi-ai/r2r/issues)
- Check the [documentation](https://r2r-docs.sciphi.ai)
- Join community discussions

---

**Last Updated**: 2024
**Version**: Based on R2R v3.x API

For the most up-to-date information, visit the [official R2R documentation](https://r2r-docs.sciphi.ai).
