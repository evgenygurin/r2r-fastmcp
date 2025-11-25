# R2R Collections

## Overview

Collections in R2R provide a powerful way to organize documents, control access, and manage knowledge graphs. They enable multi-user collaboration, fine-grained permissions, and isolated data management for different projects or teams.

## Core Concepts

### Collections
A collection is a logical grouping of documents that:
- Organizes related documents together
- Controls user access to documents
- Maintains its own knowledge graph
- Enables isolated search and retrieval
- Supports collaborative workflows

### Collection Properties
- **ID**: Unique identifier (UUID)
- **Name**: Human-readable name
- **Description**: Optional description (can be auto-generated)
- **Owner**: User who created the collection
- **Graph Status**: Status of the associated knowledge graph
- **Document Count**: Number of documents in the collection
- **User Count**: Number of users with access

## API Endpoints

### Create Collection

**Endpoint:** `POST /v3/collections`

Create a new collection with a name and optional description.

#### Request Body

```json
{
  "name": "Research Papers",
  "description": "ML research papers with knowledge graph analysis"
}
```

#### Response

```json
{
  "results": {
    "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef"
  }
}
```

#### Example: Python

```python
from r2r import R2RClient

client = R2RClient()

# Create a new collection
collection = client.collections.create(
    name="Research Papers 2024",
    description="Collection of AI research papers from 2024"
)

collection_id = collection["id"]
print(f"Created collection: {collection_id}")
```

### List Collections

**Endpoint:** `GET /v3/collections`

Retrieve a paginated list of collections accessible to the authenticated user.

#### Query Parameters

- **ids** (string, optional): Comma-separated list of collection IDs
- **offset** (integer, optional): Number to skip (default: 0)
- **limit** (integer, optional): Number to return (1-100, default: 100)

#### Response

```json
{
  "results": [
    {
      "id": "collection_id",
      "name": "AI Research Collection",
      "graph_cluster_status": "active",
      "graph_sync_status": "synchronized",
      "created_at": "2024-01-15T09:30:00Z",
      "updated_at": "2024-01-15T09:30:00Z",
      "user_count": 5,
      "document_count": 10,
      "owner_id": "owner_id",
      "description": "A collection of documents related to AI research."
    }
  ],
  "total_entries": 1
}
```

#### Example: cURL

```bash
curl -X GET "https://api.example.com/v3/collections?limit=10" \
     -H "Authorization: Bearer YOUR_API_KEY"
```

#### Example: Python

```python
# List all collections
collections = client.collections.list(limit=10, offset=0)

for collection in collections["results"]:
    print(f"Collection: {collection['name']}")
    print(f"Documents: {collection['document_count']}")
    print(f"Users: {collection['user_count']}")
```

### Get Collection Details

**Endpoint:** `GET /v3/collections/{collection_id}`

Retrieve detailed information about a specific collection.

### Update Collection

**Endpoint:** `PUT /v3/collections/{collection_id}`

Update a collection's name, description, or generate a description.

#### Request Body

```json
{
  "name": "Updated Collection Name",
  "description": "Updated description",
  "generate_description": false
}
```

#### Example: Generate Description

```python
# Auto-generate collection description
client.collections.update(
    collection_id,
    generate_description=True
)
```

### Delete Collection

**Endpoint:** `DELETE /v3/collections/{collection_id}`

Delete a collection. This removes the collection and all associations, but does not delete the documents themselves.

## Document Management

### Add Document to Collection

**Endpoint:** `POST /v3/collections/{collection_id}/documents`

Add a document to a collection.

#### Request Body

```json
{
  "document_id": "your-document-id"
}
```

#### Example: Python

```python
from r2r import R2RClient

client = R2RClient("http://localhost:7272")

document_id = '789g012j-k34l-56m7-n890-123456789012'
collection_id = '123e4567-e89b-12d3-a456-426614174000'

# Add document to collection
result = client.collections.add_document(collection_id, document_id)
print(f"Add result: {result}")
```

### Remove Document from Collection

**Endpoint:** `DELETE /v3/collections/{collection_id}/documents/{document_id}`

Remove a document from a collection. The document itself is not deleted.

#### Example: Python

```python
# Remove document from collection
result = client.collections.remove_document(collection_id, document_id)
print(f"Remove result: {result}")
```

### List Documents in Collection

```python
# List all documents in a collection
docs = client.collections.list_documents(collection_id)

for doc in docs["results"]:
    print(f"Document: {doc['title']}")
    print(f"ID: {doc['id']}")
```

### Get Collections for a Document

```python
# Get all collections containing a document
collections = client.documents.list_collections(document_id)

for collection in collections["results"]:
    print(f"Collection: {collection['name']}")
```

## User Management

### Add User to Collection

**Endpoint:** `POST /v3/collections/{collection_id}/users/{user_id}`

Grant a user access to a collection. Requires admin permissions.

#### Example: Python

```python
user_id = '456e789f-g01h-34i5-j678-901234567890'
collection_id = '123e4567-e89b-12d3-a456-426614174000'

# Add user to collection
result = client.collections.add_user(user_id, collection_id)
print(f"User added: {result}")
```

#### Example: cURL

```bash
curl -X POST "https://api.example.com/v3/collections/collection_id/users/user_id" \
     -H "Authorization: Bearer YOUR_API_KEY"
```

### Remove User from Collection

**Endpoint:** `DELETE /v3/collections/{collection_id}/users/{user_id}`

Revoke a user's access to a collection. Requires admin permissions.

#### Example: Python

```python
# Remove user from collection
result = client.collections.remove_user(user_id, collection_id)
print(f"User removed: {result}")
```

### List Users in Collection

```python
# List all users with access to a collection
users = client.collections.list_users(collection_id)

for user in users["results"]:
    print(f"User: {user['email']}")
    print(f"Role: {user['role']}")
```

### List User's Collections

```python
# Get all collections a user has access to
user_collections = client.users.list_collections(user_id)

for collection in user_collections["results"]:
    print(f"Collection: {collection['name']}")
```

## Knowledge Graph Management

### Collection Graphs

Each collection maintains its own knowledge graph for organizing entities and relationships.

#### Pull Graph Data

**Endpoint:** `POST /v3/graphs/{collection_id}/pull`

Synchronize the collection's knowledge graph with its documents.

```python
# Sync graph with document data
client.graphs.pull(collection_id)
```

#### List Entities

**Endpoint:** `GET /v3/graphs/{collection_id}/entities`

```python
# List entities in collection graph
entities = client.graphs.list_entities(collection_id)

for entity in entities:
    print(f"Entity: {entity['name']}")
    print(f"Category: {entity['category']}")
```

#### List Relationships

**Endpoint:** `GET /v3/graphs/{collection_id}/relationships`

```python
# List relationships in collection graph
relationships = client.graphs.list_relationships(collection_id)

for rel in relationships:
    print(f"{rel['subject']} -> {rel['predicate']} -> {rel['object']}")
```

#### Build Communities

**Endpoint:** `POST /v3/graphs/{collection_id}/communities/build`

Detect and build community structures within the collection's graph.

```python
# Build communities for the collection
client.graphs.build_communities(collection_id)
```

#### List Communities

**Endpoint:** `GET /v3/graphs/{collection_id}/communities`

```python
# List communities in collection graph
communities = client.graphs.list_communities(collection_id)
```

#### Reset Graph

**Endpoint:** `POST /v3/graphs/{collection_id}/reset`

Reset the collection's knowledge graph, removing all graph data.

**Warning:** This is a destructive operation.

```bash
curl -X POST http://localhost:7272/v3/graphs/${collection_id}/reset \
  -H "Authorization: Bearer YOUR_API_KEY"
```

## Export Functions

### Export Collections

**Endpoint:** `POST /v3/collections/export`

Export collections metadata as CSV.

#### Request Parameters

- **columns** (array, optional): Specific columns to export
- **filters** (object, optional): Filters to apply
- **include_header** (boolean, optional): Include headers (default: `true`)

## Access Control

### Permission Levels

Collections support role-based access control:

1. **Owner**: Full control over the collection
2. **Admin**: Can manage users and documents
3. **Member**: Can view and search documents
4. **Viewer**: Read-only access

### Managing Access

```python
# Give user access to collection and its graph
client.collections.add_user(user_id, collection_id)

# Remove access
client.collections.remove_user(user_id, collection_id)

# List users with access
users = client.collections.list_users(collection_id)
```

## Default Collection

Every user has a default collection:
- Automatically created on user registration
- Named "Default" by default
- Used when no collection is specified during document ingestion

### Configuration

Set default collection properties in `r2r.toml`:

```toml
[database]
default_collection_name = "Default"
default_collection_description = "Your default collection."
```

## Collection-Scoped Operations

### Search within Collection

Filter search to a specific collection:

```python
# Search only within a specific collection
results = client.retrieval.search(
    query="What is machine learning?",
    search_settings={
        "filters": {
            "collection_ids": {"$overlap": [collection_id]}
        }
    }
)
```

### RAG with Collection Filtering

```python
# RAG query scoped to a collection
response = client.retrieval.rag(
    query="Explain neural networks",
    search_settings={
        "filters": {
            "collection_ids": {"$overlap": [collection_id]}
        }
    }
)
```

## Multi-Collection Workflows

### Add Document to Multiple Collections

```python
# Add document to multiple collections
client.collections.add_document(document_id, collection_id_1)
client.collections.add_document(document_id, collection_id_2)

# Update all relevant graphs
client.graphs.pull(collection_id_1)
client.graphs.pull(collection_id_2)
```

### Cross-Collection Search

```python
# Search across multiple collections
results = client.retrieval.search(
    query="AI research",
    search_settings={
        "filters": {
            "collection_ids": {"$overlap": [collection_id_1, collection_id_2]}
        }
    }
)
```

## Best Practices

### 1. Organize by Topic or Project

Create collections for different topics, projects, or teams:

```python
# Create topic-based collections
ml_collection = client.collections.create("Machine Learning Papers")
nlp_collection = client.collections.create("NLP Research")
cv_collection = client.collections.create("Computer Vision")
```

### 2. Use Descriptive Names

Choose clear, descriptive names for easy identification:

```python
# Good: Descriptive and specific
client.collections.create("Q4 2024 Customer Feedback")

# Avoid: Vague or generic
client.collections.create("Collection 1")
```

### 3. Generate Descriptions

Let R2R generate descriptions automatically:

```python
client.collections.update(
    collection_id,
    generate_description=True
)
```

### 4. Regular Graph Synchronization

Keep collection graphs updated:

```python
# After adding documents
client.collections.add_document(collection_id, document_id)
client.graphs.pull(collection_id)
```

### 5. Manage Access Carefully

Regularly review and update user access:

```python
# Audit collection access
users = client.collections.list_users(collection_id)

# Remove inactive users
for user in inactive_users:
    client.collections.remove_user(user["id"], collection_id)
```

### 6. Use Filters for Collection-Scoped Operations

Always filter by collection ID for scoped operations:

```python
search_settings = {
    "filters": {
        "collection_ids": {"$overlap": [collection_id]}
    }
}
```

## Common Workflows

### Workflow 1: Create and Populate Collection

```python
# 1. Create collection
collection = client.collections.create("Research Project")
collection_id = collection["id"]

# 2. Add users
client.collections.add_user(user_id_1, collection_id)
client.collections.add_user(user_id_2, collection_id)

# 3. Ingest documents
for file_path in document_paths:
    doc = client.documents.create(
        file_path=file_path,
        collection_ids=[collection_id]
    )

# 4. Build knowledge graph
client.graphs.pull(collection_id)
client.graphs.build_communities(collection_id)
```

### Workflow 2: Migrate Documents Between Collections

```python
# 1. Add to new collection
client.collections.add_document(document_id, new_collection_id)

# 2. Remove from old collection
client.collections.remove_document(document_id, old_collection_id)

# 3. Update graphs
client.graphs.pull(new_collection_id)
client.graphs.pull(old_collection_id)
```

### Workflow 3: Collaborative Research

```python
# 1. Create shared collection
research_collection = client.collections.create("Team Research")
collection_id = research_collection["id"]

# 2. Add team members
for member in team_members:
    client.collections.add_user(member["id"], collection_id)

# 3. Each member adds documents
for member in team_members:
    # Member uploads their documents
    client.documents.create(
        file_path=member["document"],
        collection_ids=[collection_id]
    )

# 4. Build unified knowledge graph
client.graphs.pull(collection_id)
client.graphs.build_communities(collection_id)

# 5. Team searches within collection
results = client.retrieval.search(
    query="Research findings",
    search_settings={
        "filters": {
            "collection_ids": {"$overlap": [collection_id]}
        }
    }
)
```

## Troubleshooting

### Cannot Add Document to Collection

Verify:
1. Document exists and is ingested
2. You have admin access to the collection
3. Document ID is correct

### User Cannot Access Collection

Check:
1. User is added to the collection
2. User authentication is valid
3. Collection permissions are correct

### Graph Sync Issues

Solutions:
1. Manually trigger graph pull
2. Verify documents are fully ingested
3. Check extraction status

```python
# Force graph sync
client.graphs.pull(collection_id)
```

### Empty Search Results

Ensure:
1. Collection filter is correct
2. Documents are in the collection
3. Search query matches document content

## Resources

- [R2R Collections API Reference](https://r2r-docs.sciphi.ai/api/collections)
- [Access Control Documentation](https://r2r-docs.sciphi.ai/features/access-control)
- [Graph Management Guide](https://r2r-docs.sciphi.ai/features/graphs)
