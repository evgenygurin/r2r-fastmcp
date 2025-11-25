# R2R Knowledge Graphs

## Overview

R2R's Knowledge Graph capabilities enable automatic extraction, management, and querying of entities and relationships from documents. This structured approach enhances retrieval quality and enables sophisticated multi-hop reasoning across your document corpus.

## Core Concepts

### Entities
Entities represent concepts, objects, or subjects extracted from documents:
- **Name**: The entity identifier
- **Description**: Detailed information about the entity
- **Category**: Type classification (Person, Organization, Concept, etc.)
- **Metadata**: Additional contextual information
- **Embeddings**: Vector representations for semantic search

### Relationships
Relationships define connections between entities:
- **Subject**: The source entity
- **Predicate**: The type of relationship
- **Object**: The target entity
- **Description**: Context about the relationship
- **Weight**: Importance or strength of the relationship
- **Metadata**: Additional relationship information

### Communities
Communities are groups of related entities detected through graph analysis:
- **Name**: Community identifier
- **Summary**: High-level description
- **Findings**: Key insights about the community
- **Rating**: Quality or importance score (1-10)
- **Members**: Entities belonging to the community

## Graph Extraction

### Automatic Extraction from Documents

**Endpoint:** `POST /v3/documents/{id}/extract`

Extract entities and relationships from a document automatically.

#### Request Parameters

- **id** (UUID, required, path): Document ID to extract from
- **run_type** (string, optional): `"estimate"` or `"run"`
- **run_with_orchestration** (boolean, optional): Run asynchronously (default: `true`)

#### Request Body (Optional)

```json
{
  "graph_extraction": "Extract all named entities and their relationships.",
  "entity_types": ["Person", "Organization", "Location"],
  "relation_types": ["works_at", "located_in"],
  "chunk_merge_count": 5,
  "max_knowledge_relationships": 100,
  "max_description_input_length": 65536,
  "generation_config": {
    "model": "gpt-4",
    "temperature": 0.7,
    "max_tokens_to_sample": 500
  }
}
```

#### Response

```json
{
  "extraction_id": "extract-12345",
  "status": "running"
}
```

#### Example: Python

```python
from r2r import R2RClient

client = R2RClient()

# Extract knowledge graph from document
extract_response = client.documents.extract(
    document_id="9fbe403b-...",
    settings={
        "entity_types": ["Person", "Organization", "Technology"],
        "relation_types": ["works_at", "developed", "uses"]
    }
)

print(extract_response)
```

### Collection-Level Extraction

**Endpoint:** `POST /v3/collections/{collection_id}/extract`

Extract entities and relationships from all documents in a collection.

## Entity Management

### Create Entity

**Endpoint:** `POST /v3/graphs/{collection_id}/entities`

Manually create an entity in a collection's knowledge graph.

#### Request Body

```json
{
  "name": "Aristotle",
  "description": "Ancient Greek philosopher and polymath",
  "category": "Person",
  "metadata": {
    "field": "Philosophy",
    "era": "Classical Greece"
  }
}
```

#### Response

```json
{
  "results": {
    "entity_id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Aristotle",
    "description": "Ancient Greek philosopher and polymath",
    "category": "Person"
  }
}
```

### List Entities

**Endpoint:** `GET /v3/graphs/{collection_id}/entities`

Retrieve all entities from a collection's knowledge graph.

#### Example: Python

```python
# List entities in collection graph
entities = client.graphs.list_entities(collection_id)

for entity in entities:
    print(f"Entity: {entity['name']}")
    print(f"Description: {entity['description']}")
    print(f"Category: {entity['category']}")
```

#### Example: cURL

```bash
curl -X GET http://localhost:7272/v3/graphs/${collection_id}/entities \
  -H "Authorization: Bearer YOUR_API_KEY"
```

#### Response Format

```json
{
  "entities": [
    {
      "name": "DEEP_LEARNING",
      "description": "A subset of machine learning using neural networks",
      "category": "CONCEPT",
      "id": "ce46e955-ed77-4c17-8169-e878baf3fbb9"
    }
  ]
}
```

### Update Entity

**Endpoint:** `POST /v3/graphs/{collection_id}/entities/{entity_id}`

Update an existing entity's properties.

#### Request Body

```json
{
  "name": "Aristotle",
  "description": "Updated description with more details",
  "category": "Philosopher",
  "metadata": {
    "field": "Philosophy",
    "era": "Classical Greece",
    "influence": "Profound"
  }
}
```

### Delete Entity

**Endpoint:** `DELETE /v3/graphs/{collection_id}/entities/{entity_id}`

Remove an entity from the knowledge graph.

## Relationship Management

### Create Relationship

**Endpoint:** `POST /v3/graphs/{collection_id}/relationships`

Create a new relationship between two entities.

#### Request Body

```json
{
  "subject": "John Doe",
  "subject_id": "entity_id1",
  "predicate": "WorksAt",
  "object": "OpenAI",
  "object_id": "entity_id2",
  "description": "John Doe works at OpenAI.",
  "weight": 1.1,
  "metadata": {
    "department": "Research"
  }
}
```

#### Response

```json
{
  "results": {
    "subject": "John Doe",
    "predicate": "WorksAt",
    "object": "OpenAI",
    "id": "relationship_id",
    "description": "John Doe works at OpenAI.",
    "subject_id": "entity_id1",
    "object_id": "entity_id2",
    "weight": 1.1,
    "chunk_ids": ["chunk_id1", "chunk_id2"],
    "metadata": {
      "department": "Research"
    }
  }
}
```

### List Relationships

**Endpoint:** `GET /v3/graphs/{collection_id}/relationships`

Retrieve all relationships from a collection's knowledge graph.

#### Example: Python

```python
# List relationships in collection graph
relationships = client.graphs.list_relationships(collection_id)

for rel in relationships:
    print(f"{rel['subject']} -> {rel['predicate']} -> {rel['object']}")
```

#### Example: cURL

```bash
curl -X GET http://localhost:7272/v3/graphs/${collection_id}/relationships \
  -H "Authorization: Bearer YOUR_API_KEY"
```

#### Response Format

```json
{
  "relationships": [
    {
      "subject": "DEEP_LEARNING",
      "predicate": "IS_SUBSET_OF",
      "object": "MACHINE_LEARNING",
      "description": "Deep learning is a specialized branch of machine learning"
    }
  ]
}
```

### Update Relationship

**Endpoint:** `POST /v3/graphs/{collection_id}/relationships/{relationship_id}`

Update an existing relationship's properties.

#### Request Body

```json
{
  "subject": "John Doe",
  "predicate": "WorksAt",
  "object": "OpenAI",
  "description": "Updated relationship description",
  "weight": 1.5,
  "metadata": {
    "department": "Engineering"
  }
}
```

### Delete Relationship

**Endpoint:** `DELETE /v3/graphs/{collection_id}/relationships/{relationship_id}`

Remove a relationship from the knowledge graph.

## Community Detection

### Build Communities

**Endpoint:** `POST /v3/graphs/{collection_id}/communities/build`

Analyze the knowledge graph to detect and create community structures.

#### Process Overview

Communities are created through:
1. Analyzing entity relationships and metadata
2. Applying community detection algorithms (e.g., Leiden)
3. Creating hierarchical community structure
4. Generating natural language summaries

#### Example: Python

```python
# Build communities for collection graph
build_response = client.graphs.build_communities(
    collection_id=collection_id,
    graph_enrichment_settings={
        "leiden_params": {},
        "generation_config": {
            "model": "openai/gpt-4.1-mini"
        }
    }
)

print(build_response)
```

#### Example: cURL

```bash
curl -X POST http://localhost:7272/v3/graphs/${collection_id}/communities/build \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Initiating community building for graph."
  }'
```

### List Communities

**Endpoint:** `GET /v3/graphs/{collection_id}/communities`

Retrieve all communities from a knowledge graph.

### Create Community (Manual)

**Endpoint:** `POST /v3/graphs/{collection_id}/communities`

Manually create a community with custom groupings.

#### Request Body

```json
{
  "name": "AI Research Community",
  "summary": "A group of entities related to AI research and development",
  "findings": [
    "Focus on deep learning",
    "Strong connections to academic institutions"
  ],
  "rating": 8,
  "rating_explanation": "High-quality community with well-connected entities"
}
```

### Update Community

**Endpoint:** `POST /v3/graphs/{collection_id}/communities/{community_id}`

Update community properties.

### Delete Community

**Endpoint:** `DELETE /v3/graphs/{collection_id}/communities/{community_id}`

Remove a community from the knowledge graph.

## Graph Synchronization

### Pull Graph Data

**Endpoint:** `POST /v3/graphs/{collection_id}/pull`

Synchronize the knowledge graph by pulling data from associated documents.

This operation:
1. Copies document entities to graph-specific tables
2. Copies document relationships to graph-specific tables
3. Merges existing entities/relationships by updating properties
4. Associates documents with the graph

#### Example: Python

```python
# Sync graph with document data
client.graphs.pull(collection_id)
```

### Add Documents to Graph

When documents are added to a collection and graph pull is executed:
- Their entities and relationships are copied to graph tables
- Existing entities/relationships are updated via property merging
- Document IDs are recorded in the graph's document array

```python
# Add document to multiple collections and update graphs
client.collections.add_document(document_id, collection_id_1)
client.collections.add_document(document_id, collection_id_2)

# Update all relevant graphs
client.graphs.pull(collection_id_1)
client.graphs.pull(collection_id_2)
```

## Graph Management

### Update Graph

**Endpoint:** `PUT /v3/graphs/{collection_id}`

Update graph configuration.

#### Request Body

```json
{
  "name": "Updated Graph Name",
  "description": "Updated description of the graph"
}
```

### Reset Graph

**Endpoint:** `POST /v3/graphs/{collection_id}/reset`

Reset the knowledge graph, removing all data. The associated documents remain unchanged.

**Warning:** This operation is destructive and cannot be undone.

```bash
curl -X POST http://localhost:7272/v3/graphs/${collection_id}/reset \
  -H "Authorization: Bearer YOUR_API_KEY"
```

## Export Functions

### Export Entities

**Endpoint:** `POST /v3/graphs/{collection_id}/entities/export`

Export entities as a CSV file.

### Export Relationships

**Endpoint:** `POST /v3/graphs/{collection_id}/relationships/export`

Export relationships as a CSV file.

### Export Communities

**Endpoint:** `POST /v3/graphs/{collection_id}/communities/export`

Export communities as a CSV file.

#### Export Parameters

- **columns** (array, optional): Specific columns to export
- **filters** (object, optional): Filters to apply
- **include_header** (boolean, optional): Include headers (default: `true`)

## Graph-Enhanced Search

### Knowledge Graph Search

Knowledge graphs enhance retrieval through entity and relationship-based search.

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

### Graph Search Settings

```json
{
  "graph_search_settings": {
    "enabled": true,
    "limits": {
      "entity": 20,
      "relationship": 20,
      "community": 20
    }
  }
}
```

## Deduplication

### Deduplicate Entities

**Endpoint:** `POST /v3/documents/{id}/deduplicate`

Automatically deduplicate entities from a document.

```python
# Deduplicate entities in a document
client.documents.deduplicate(
    document_id="9fbe403b-...",
    settings={
        "automatic_deduplication": True
    }
)
```

## Configuration

### Graph Creation Settings

Configure in `r2r.toml`:

```toml
[database.graph_creation_settings]
graph_entity_description_prompt = "graph_entity_description"
entity_types = []
relation_types = []
fragment_merge_count = 1
max_knowledge_relationships = 100
max_description_input_length = 65536

  [database.graph_creation_settings.generation_config]
  model = "openai/gpt-4.1-mini"
```

### Graph Enrichment Settings

```toml
[database.graph_enrichment_settings]
max_summary_input_length = 65536

  [database.graph_enrichment_settings.generation_config]
  model = "openai/gpt-4.1-mini"

  [database.graph_enrichment_settings.leiden_params]
  # Leiden algorithm parameters
```

## Best Practices

### 1. Specify Entity and Relation Types

Define specific types for better extraction quality:

```python
settings = {
    "entity_types": ["Person", "Organization", "Technology", "Concept"],
    "relation_types": ["works_at", "developed_by", "uses", "related_to"]
}
```

### 2. Use Chunk Merge for Context

Increase `chunk_merge_count` for better context in extraction:

```python
settings = {
    "chunk_merge_count": 4  # Merge 4 chunks for extraction
}
```

### 3. Tune Generation Config

Adjust model parameters for extraction quality vs. cost:

```python
settings = {
    "generation_config": {
        "model": "openai/gpt-4.1-mini",  # Faster, cheaper
        "temperature": 0.1  # More deterministic
    }
}
```

### 4. Regular Graph Synchronization

Keep graphs updated with document changes:

```python
# After document updates
client.graphs.pull(collection_id)
```

### 5. Build Communities Periodically

Refresh community structures as the graph evolves:

```python
# After significant graph changes
client.graphs.build_communities(collection_id)
```

## Common Workflows

### Workflow 1: Extract and Build Communities

```python
# 1. Extract from documents
for doc_id in document_ids:
    client.documents.extract(doc_id)

# 2. Sync graph
client.graphs.pull(collection_id)

# 3. Build communities
client.graphs.build_communities(collection_id)
```

### Workflow 2: Manual Graph Construction

```python
# 1. Create entities
entity1 = client.graphs.create_entity(
    collection_id,
    name="Entity A",
    description="Description A",
    category="Type A"
)

entity2 = client.graphs.create_entity(
    collection_id,
    name="Entity B",
    description="Description B",
    category="Type B"
)

# 2. Create relationship
client.graphs.create_relationship(
    collection_id,
    subject="Entity A",
    subject_id=entity1["id"],
    predicate="relates_to",
    object="Entity B",
    object_id=entity2["id"],
    description="A relates to B"
)
```

### Workflow 3: Graph-Enhanced Search

```python
# 1. Enable graph search
response = client.retrieval.rag(
    query="What are the connections between AI and robotics?",
    search_settings={
        "use_semantic_search": True,
        "graph_settings": {
            "enabled": True,
            "kg_search_type": "local"
        }
    }
)

# 2. Analyze graph results
for result in response["results"]["graph_search_results"]:
    print(f"Entity: {result['content']['name']}")
    print(f"Type: {result['result_type']}")
```

## Troubleshooting

### Extraction Failures

Check document status and re-run:

```python
# Check extraction status
status = client.documents.get(document_id)

# Re-run if failed
if status["extraction_status"] == "failed":
    client.documents.extract(document_id)
```

### Empty Graphs

1. Verify documents are ingested
2. Check extraction settings
3. Ensure LLM API keys are configured

### Poor Entity Quality

1. Use more specific entity/relation types
2. Increase chunk merge count
3. Use higher quality LLM (e.g., GPT-4)

## Resources

- [R2R Knowledge Graph API Reference](https://r2r-docs.sciphi.ai/api/graphs)
- [Graph Configuration Guide](https://r2r-docs.sciphi.ai/configuration/graphs)
- [Community Detection Documentation](https://r2r-docs.sciphi.ai/features/communities)
