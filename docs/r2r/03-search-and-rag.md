# R2R Search and RAG

## Overview

R2R provides powerful search and Retrieval-Augmented Generation (RAG) capabilities that combine vector search, full-text search, knowledge graph integration, and language model generation to deliver accurate, contextually-relevant responses.

## Core Features

- **Vector Search**: Semantic similarity search using embeddings
- **Full-Text Search**: Traditional keyword-based search
- **Hybrid Search**: Combines vector and full-text search
- **Knowledge Graph Search**: Entity and relationship-based retrieval
- **RAG Generation**: Context-aware responses with citations
- **Streaming Support**: Real-time token streaming for responses

## Search Modes

R2R offers three search modes for flexibility:

### 1. Basic Mode
Simple semantic-based search with default settings.

### 2. Advanced Mode
Hybrid search combining semantic and full-text search for comprehensive results.

### 3. Custom Mode
Complete control over search behavior through detailed `search_settings`.

## API Endpoints

### Search Endpoint

**Endpoint:** `POST /v3/retrieval/search`

Perform a semantic search query over stored chunks.

#### Request Parameters

- **query** (string, required): The search query
- **search_mode** (string, optional): `basic`, `advanced`, or `custom` (default: `custom`)
- **search_settings** (object, optional): Detailed search configuration

#### Search Settings

```json
{
  "chunk_settings": {
    "enabled": true,
    "index_measure": "cosine_distance",
    "ef_search": 40,
    "probes": 10
  },
  "graph_settings": {
    "enabled": true,
    "limits": {
      "entity": 20,
      "relationship": 20,
      "community": 20
    }
  },
  "hybrid_settings": {
    "full_text_weight": 1.0,
    "semantic_weight": 5.0,
    "full_text_limit": 200,
    "rrf_k": 50
  },
  "use_semantic_search": true,
  "use_fulltext_search": false,
  "use_hybrid_search": false,
  "filters": {},
  "limit": 10,
  "offset": 0,
  "search_strategy": "vanilla"
}
```

#### Example: Basic Search (Python)

```python
from r2r import R2RClient

client = R2RClient()

# Basic search
results = client.retrieval.search(
    query="What is DeepSeek R1?"
)

print(results)
```

#### Example: Hybrid Search (Python)

```python
from r2r import Client

client = Client()

response = client.chat(
    "What are the benefits of hybrid search?",
    collection="my_collection",
    search_mode="hybrid"
)

print(response.answer)
```

#### Example: Hybrid Search (cURL)

```bash
curl -X POST http://localhost:7272/v3/retrieval/search \
  -H "Content-Type: application/json" \
  -d '{ \
    "query": "Who is Jon Snow?", \
    "search_settings": { \
      "use_hybrid_search": true, \
      "limit": 10 \
    } \
  }'
```

### RAG Endpoint

**Endpoint:** `POST /v3/retrieval/rag`

Execute a Retrieval-Augmented Generation query combining search results with LLM generation.

#### Request Parameters

- **query** (string, required): The user's query
- **search_mode** (string, optional): `basic`, `advanced`, or `custom`
- **search_settings** (object, optional): Search configuration
- **rag_generation_config** (object, optional): LLM generation configuration
- **include_title_if_available** (boolean, optional): Include document titles (default: `false`)
- **include_web_search** (boolean, optional): Include web search results (default: `false`)
- **task_prompt** (string, optional): Custom prompt override

#### RAG Generation Config

```json
{
  "model": "openai/gpt-4.1-mini",
  "temperature": 0.7,
  "max_tokens": 1500,
  "stream": true,
  "top_p": 1.0
}
```

#### Example: Basic RAG (Python)

```python
from r2r import R2RClient

client = R2RClient()

# RAG with citations
response = client.retrieval.rag(
    query="What is DeepSeek R1?"
)

print(response["results"]["completion"])
```

#### Example: RAG with Custom Settings (Python)

```python
rag_response = client.retrieval.rag(
    query="Who is John",
    rag_generation_config={
        "model": "openai/gpt-4.1-mini",
        "temperature": 0.0
    }
)

results = rag_response["results"]

print(f"Search Results:\n{results['search_results']}")
print(f"Completion:\n{results['completion']}")
```

#### Example: RAG (JavaScript)

```javascript
console.log("Performing RAG...");
const ragResponse = await client.rag({
    query: "What does the file talk about?",
    rag_generation_config: {
        model: "openai/gpt-4.1",
        temperature: 0.0,
        stream: false,
    },
});

console.log("Search Results:");
ragResponse.results.search_results.chunk_search_results.forEach(
    (result, index) => {
        console.log(`\nResult ${index + 1}:`);
        console.log(`Text: ${result.metadata.text.substring(0, 100)}...`);
        console.log(`Score: ${result.score}`);
    },
);

console.log("\nCompletion:");
console.log(ragResponse.results.completion.choices[0].message.content);
```

#### Example: RAG with Hybrid Search (cURL)

```bash
curl -X POST http://localhost:7272/v3/retrieval/rag \
  -H "Content-Type: application/json" \
  -d '{ \
    "query": "Who is Jon Snow?", \
    "search_settings": { \
      "use_hybrid_search": true, \
      "limit": 10 \
    } \
  }'
```

#### Response Format

```json
{
  "results": {
    "chunk_search_results": [
      {
        "id": "chunk_id",
        "document_id": "document_id",
        "collection_ids": ["collection_id1"],
        "score": 0.95,
        "text": "Latest trends in AI include deep learning advancements...",
        "metadata": {
          "associated_query": "Latest trends in AI",
          "title": "ai_trends_2024.pdf"
        },
        "owner_id": "owner_id"
      }
    ],
    "graph_search_results": [
      {
        "content": {
          "name": "Deep Learning",
          "description": "A subset of machine learning involving neural networks.",
          "metadata": { "field": "Artificial Intelligence" }
        },
        "result_type": "entity",
        "chunk_ids": ["chunk_id1"],
        "metadata": {
          "associated_query": "Latest trends in AI"
        }
      }
    ],
    "generated_answer": "Recent advancements in AI include..."
  }
}
```

## Advanced Search Features

### 1. Filters

Apply complex filters to narrow search results:

```json
{
  "filters": {
    "document_id": {"$eq": "9fbe403b-..."},
    "collection_ids": {"$overlap": ["122fdf6a-..."]},
    "$and": [
      {"document_type": {"$eq": "pdf"}},
      {"metadata.year": {"$gt": 2020}}
    ]
  }
}
```

**Supported Operators:**
- `$eq`, `$neq`: Equality/Inequality
- `$gt`, `$gte`, `$lt`, `$lte`: Comparisons
- `$like`, `$ilike`: Pattern matching (case-sensitive/insensitive)
- `$in`, `$nin`: Inclusion/Exclusion
- `$overlap`: Array overlap
- `$and`, `$or`: Logical operators

### 2. Hybrid Search

Combines semantic and keyword search with configurable weights:

```python
search_settings = {
    "use_hybrid_search": True,
    "hybrid_settings": {
        "full_text_weight": 1.0,
        "semantic_weight": 5.0,
        "full_text_limit": 200,
        "rrf_k": 50
    }
}
```

### 3. Knowledge Graph Search

Leverage entity and relationship extraction:

```bash
curl -X POST http://localhost:7272/v3/retrieval/search \
  -H "Content-Type: application/json" \
  -d '{ \
    "query": "Who was Aristotle?", \
    "graph_search_settings": { \
      "use_graph_search": true, \
      "kg_search_type": "local" \
    } \
  }'
```

```python
# Python example
response = client.retrieval.search(
    query="Who was Aristotle?",
    graph_search_settings={
        "use_graph_search": True,
        "kg_search_type": "local"
    }
)
```

### 4. Search Strategies

R2R supports multiple search strategies:

#### Vanilla Search
Standard semantic search (default).

#### RAG-Fusion
Generates multiple related queries and re-ranks results using Reciprocal Rank Fusion (RRF):

```python
rag_fusion_response = client.retrieval.rag(
    "Explain the theory of relativity",
    search_settings={
        "search_strategy": "rag_fusion",
        "limit": 20
    }
)

print('rag_fusion_response = ', rag_fusion_response)
```

#### HyDE (Hypothetical Document Embeddings)
Generates hypothetical answers first, then searches using those embeddings.

### 5. Combining Settings

You can combine multiple advanced features:

```python
custom_rag_response = client.retrieval.rag(
    "Describe the impact of climate change on biodiversity",
    search_settings={
        "search_strategy": "hyde",
        "limit": 15,
        "use_hybrid_search": True
    },
    rag_generation_config={
        "model": "anthropic/claude-3-opus-20240229",
        "temperature": 0.7
    }
)
```

## Streaming Responses

When `stream: true` is set in `rag_generation_config`, the endpoint returns Server-Sent Events:

**Event Types:**
- `search_results`: Initial search results
- `message`: Partial tokens as generated
- `citation`: Citation metadata
- `final_answer`: Complete answer with citations

## Citation Management

RAG responses automatically include citations:

```json
{
  "generated_answer": "DeepSeek-R1 demonstrates impressive performance...[1]",
  "citations": [
    {
      "id": "cit.123456",
      "object": "citation",
      "payload": {
        "document_id": "...",
        "chunk_id": "...",
        "text": "..."
      }
    }
  ]
}
```

## Document-Level Search

Search over document summaries instead of chunks:

**Endpoint:** `POST /v3/documents/search`

```json
{
  "query": "What are the latest AI research trends?",
  "search_mode": "custom",
  "search_settings": {
    "use_semantic_search": true,
    "filters": { "publication_year": { "$gte": 2020 } },
    "limit": 5
  }
}
```

## Model Support

R2R supports various LLM providers:

### OpenAI (Default)
```python
rag_generation_config = {
    "model": "openai/gpt-4.1",
    "temperature": 0.7
}
```

### Anthropic Claude
```python
rag_generation_config = {
    "model": "anthropic/claude-3-haiku-20240307",
    "temperature": 0.7
}
```

### Local Models (Ollama)
Configure via server settings.

### Any LiteLLM Provider
R2R uses LiteLLM, supporting 100+ providers.

## Best Practices

### 1. Choose the Right Search Mode

- **Basic**: Quick semantic queries
- **Advanced**: When you need comprehensive results
- **Custom**: For fine-tuned control

### 2. Use Filters Effectively

Narrow search scope to improve relevance:

```python
search_settings = {
    "filters": {
        "collection_ids": {"$overlap": [my_collection_id]},
        "metadata.category": {"$eq": "technical"}
    }
}
```

### 3. Optimize Hybrid Search Weights

Adjust weights based on your use case:
- **Higher semantic weight**: For conceptual queries
- **Higher full-text weight**: For keyword-specific searches

### 4. Stream Long Responses

Enable streaming for better UX on long-form responses:

```python
rag_generation_config = {
    "stream": True,
    "max_tokens": 2000
}
```

### 5. Include Document Titles

Enhance context by including titles:

```python
client.retrieval.rag(
    query="...",
    include_title_if_available=True
)
```

## Performance Tuning

### Vector Search Parameters

- **ef_search**: Higher = better accuracy, slower search (default: 40)
- **probes**: Number of clusters to search (default: 10)

### Index Measures

- **cosine_distance**: Best for semantic similarity (default)
- **l2_distance**: Best for absolute distances
- **max_inner_product**: Best for raw dot products

### Pagination

Use `offset` and `limit` for large result sets:

```python
search_settings = {
    "limit": 20,
    "offset": 0
}
```

## Troubleshooting

### Low Relevance Scores

1. Check embedding model alignment
2. Increase search limit
3. Use hybrid search
4. Refine filters

### Slow Search Performance

1. Reduce `ef_search` value
2. Limit result count
3. Use appropriate index type
4. Consider caching frequent queries

### Empty Results

1. Verify documents are ingested
2. Check filter constraints
3. Try broader queries
4. Inspect collection membership

## Resources

- [R2R Search API Reference](https://r2r-docs.sciphi.ai/api/search)
- [RAG API Reference](https://r2r-docs.sciphi.ai/api/rag)
- [Search Configuration Guide](https://r2r-docs.sciphi.ai/configuration/search)
- [LiteLLM Providers](https://docs.litellm.ai/docs/providers)
