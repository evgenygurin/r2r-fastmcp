# R2R Document Management

## Overview

R2R's Document Management system allows for ingesting, updating, and managing documents within the R2R system. Documents can be uploaded from files, text content, or pre-processed chunks, and their metadata can be managed throughout their lifecycle.

## Core Concepts

### Documents
Documents are the primary unit of content in R2R. Each document:
- Has a unique ID (auto-generated or user-provided)
- Contains text or file content
- Has associated metadata (title, description, custom fields)
- Belongs to one or more collections
- Can be processed asynchronously for extraction and indexing

### Ingestion Modes

R2R supports three ingestion modes:

1. **`hi-res`**: Comprehensive parsing and enrichment, including summaries and thorough parsing
2. **`fast`**: Speed-focused ingestion that skips enrichment steps like summaries
3. **`custom`**: Full control via custom `ingestion_config`

## API Endpoints

### Create Document

**Endpoint:** `POST /v3/documents`

Creates a new document from a file, text content, or pre-processed chunks.

#### Request Parameters

- **file** (binary, optional): The file to ingest
- **raw_text** (string, optional): Raw text content to ingest
- **chunks** (array, optional): Pre-processed text chunks
- **id** (UUID, optional): Document ID (auto-generated if not provided)
- **collection_ids** (array, optional): Collection IDs to associate with the document
- **metadata** (object, optional): Document metadata (title, description, custom fields)
- **ingestion_mode** (enum, optional): `hi-res`, `fast`, or `custom` (default: `custom`)
- **ingestion_config** (object, optional): Custom ingestion settings
- **run_with_orchestration** (boolean, optional): Whether to run asynchronously (default: `true`)

#### Example: Upload File (cURL)

```bash
curl -X POST "https://api.example.com/v3/documents" \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -F "file=@/path/to/document.pdf" \
     -F "metadata=\"{\"title\": \"Sample Document\", \"description\": \"A sample document for ingestion.\"}\""
```

#### Example: Python SDK

```python
from r2r import Client

client = Client()

# Ingest documents from a directory
client.ingest_documents(
    "./my_documents/",
    "my_document_collection"
)
```

#### Example: Ingest from URL (Python)

```python
import os
import tempfile
import requests

# Download content from URL
url = "https://raw.githubusercontent.com/SciPhi-AI/R2R/refs/heads/main/py/core/examples/data/aristotle.txt"
response = requests.get(url)

# Create temporary file
with tempfile.NamedTemporaryFile(delete=False, mode="w", suffix=".txt") as temp_file:
    temp_file.write(response.text)
    temp_path = temp_file.name

# Ingest the file
ingestion_response = client.documents.create(file_path=temp_path)
print(ingestion_response)

# Clean up
os.unlink(temp_path)
```

#### Example: JavaScript SDK

```javascript
const file = { 
    path: "examples/data/raskolnikov.txt", 
    name: "raskolnikov.txt" 
};

console.log("Ingesting file...");
const ingestResult = await client.documents.create({
    file: { 
        path: "examples/data/raskolnikov.txt", 
        name: "raskolnikov.txt" 
    },
    metadata: { title: "raskolnikov.txt" },
});

console.log("Ingest result:", JSON.stringify(ingestResult, null, 2));
```

#### Response

```json
{
  "results": {
    "message": "Document ingestion started.",
    "document_id": "generated_document_id",
    "task_id": "ingestion_task_id"
  }
}
```

### Ingest Pre-Processed Chunks

If you have pre-processed text chunks, you can ingest them directly:

```python
from r2r import Client
from r2r.types import Chunk

client = Client()

chunks = [
    Chunk(text="This is the first chunk.", metadata={"source": "doc1.txt"}),
    Chunk(text="This is the second chunk.", metadata={"source": "doc2.txt"}),
]

client.ingest_chunks(
    chunks,
    "my_chunk_collection"
)
```

### List Documents

**Endpoint:** `GET /v3/documents`

Retrieve a list of all documents with filtering and pagination options.

#### Example (CLI)

```bash
r2r documents list
```

### Get Document Details

**Endpoint:** `GET /v3/documents/{document_id}`

Retrieve detailed information about a specific document.

#### Path Parameters

- **document_id** (UUID, required): The unique identifier of the document

### Update Document

**Endpoint:** `PUT /v3/documents/{document_id}`

Update an existing document's metadata or content.

#### Path Parameters

- **document_id** (UUID, required): The unique identifier of the document

#### Request Body

Contains updated document information such as metadata or content.

### Update Document Metadata

#### Put Metadata (Replace)

**Endpoint:** `PUT /v3/documents/{document_id}/metadata`

Replaces all metadata for a document.

#### Patch Metadata (Append/Update)

**Endpoint:** `PATCH /v3/documents/{document_id}/metadata`

Appends or updates specific metadata fields without replacing all metadata.

### Delete Document

**Endpoint:** `DELETE /v3/documents/{document_id}`

Remove a document from the R2R system. All chunks corresponding to the document are deleted.

**Note:** Deletions do not yet impact the knowledge graph or other derived data. This feature is planned for a future release.

#### Path Parameters

- **document_id** (UUID, required): Document ID

#### Example (cURL)

```bash
curl -X DELETE "https://api.example.com/v3/documents/{document_id}" \
     -H "Authorization: Bearer YOUR_API_KEY"
```

### Delete Documents by Filter

**Endpoint:** `DELETE /v3/documents/by_filter`

Delete documents based on provided filters. Allowed operators include: `$eq`, `$neq`, `$gt`, `$gte`, `$lt`, `$lte`, `$like`, `$ilike`, `$in`, and `$nin`.

**Note:** Deletion requests are limited to a user's own documents.

## Export Documents

**Endpoint:** `POST /v3/documents/export`

Export documents as a downloadable CSV file.

#### Request Parameters

- **columns** (array, optional): Specific columns to export
- **filters** (object, optional): Filters to apply to the export
- **include_header** (boolean, optional): Whether to include column headers (default: `true`)

## Ingestion Configuration

### Configuration Options

```toml
[ingestion]
chunk_size = 1024
chunk_overlap = 200
```

### Custom Ingestion Config Example

When using `ingestion_mode: "custom"`, you can provide detailed configuration:

```json
{
  "file": "@/path/to/document.pdf",
  "ingestion_mode": "custom",
  "ingestion_config": {
    "chunk_size": 512,
    "chunk_overlap": 100,
    "chunking_strategy": "recursive",
    "skip_document_summary": false
  }
}
```

## Checking Ingestion Status

Monitor the progress of asynchronous ingestion:

```bash
r2r documents list
```

This will display the ingestion status of all documents.

## Document-to-Collection Management

### Add Document to Collection

**Endpoint:** `POST /v3/collections/{collection_id}/documents`

```python
from r2r import R2RClient

client = R2RClient("http://localhost:7272")

document_id = '789g012j-k34l-56m7-n890-123456789012'
collection_id = '123e4567-e89b-12d3-a456-426614174000'

# Assign document to collection
assign_result = client.collections.add_document(collection_id, document_id)
print(f"Assign document to collection result: {assign_result}")
```

### Remove Document from Collection

**Endpoint:** `DELETE /v3/collections/{collection_id}/documents/{document_id}`

```python
# Remove document from collection
remove_result = client.collections.remove_document(collection_id, document_id)
print(f"Remove document from collection result: {remove_result}")
```

### List Documents in Collection

```python
# List all documents in a collection
docs_in_collection = client.collections.list_documents(collection_id)
print(f"Documents in collection: {docs_in_collection}")
```

### List Collections for a Document

```python
# Get all collections containing a document
document_collections = client.documents.list_collections(document_id)
print(f"Document's collections: {document_collections}")
```

## Knowledge Graph Extraction

### Extract Entities and Relationships

**Endpoint:** `POST /v3/documents/{id}/extract`

Extract entities and relationships from a document for knowledge graph creation.

#### Path Parameters

- **id** (UUID, required): The Document ID to extract from

#### Query Parameters

- **run_type** (string, optional): "estimate" or "run"
- **run_with_orchestration** (boolean, optional): Run with orchestration (default: `true`)

#### Request Body (Optional)

```json
{
  "graph_extraction": "Extract all named entities and their relationships.",
  "entity_types": ["Person", "Organization", "Location"],
  "relation_types": ["works_at", "located_in"],
  "chunk_merge_count": 5,
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

### Deduplicate Entities

**Endpoint:** `POST /v3/documents/{id}/deduplicate`

Deduplicates entities from a document.

## Export Document Entities and Relationships

### Export Entities

**Endpoint:** `POST /v3/documents/{id}/entities/export`

Export entities from a specific document as CSV.

### Export Relationships

**Endpoint:** `POST /v3/documents/{id}/relationships/export`

Export relationships from a specific document as CSV.

#### Parameters

- **columns** (array, optional): Specific columns to export
- **filters** (object, optional): Filters to apply
- **include_header** (boolean, optional): Include headers (default: `true`)

## Best Practices

### 1. Use Appropriate Ingestion Modes

- **`hi-res`**: For critical documents requiring thorough processing
- **`fast`**: For bulk ingestion where speed is prioritized
- **`custom`**: For fine-tuned control over processing

### 2. Organize with Collections

Group related documents into collections for better organization and access control.

### 3. Add Rich Metadata

Include descriptive metadata (title, description, tags) to improve searchability and context.

### 4. Monitor Ingestion Status

Regularly check ingestion status for long-running operations:

```bash
r2r documents list
```

### 5. Use Filters for Bulk Operations

When deleting or updating multiple documents, use filters effectively:

```python
client.documents.delete_by_filter(
    filters={"category": {"$eq": "outdated"}}
)
```

## Common Workflows

### Workflow 1: Ingest and Extract

```python
# 1. Ingest document
doc_response = client.documents.create(file_path="document.pdf")
document_id = doc_response["document_id"]

# 2. Wait for ingestion to complete
# (check status or use webhooks)

# 3. Extract knowledge graph
extract_response = client.documents.extract(document_id)
```

### Workflow 2: Bulk Ingestion with Collections

```python
# 1. Create collection
collection = client.collections.create("Research Papers 2024")
collection_id = collection["id"]

# 2. Ingest multiple documents
for file_path in document_paths:
    client.documents.create(
        file_path=file_path,
        collection_ids=[collection_id]
    )
```

### Workflow 3: Update and Re-index

```python
# 1. Update metadata
client.documents.patch_metadata(
    document_id,
    metadata={"version": "2.0", "reviewed": True}
)

# 2. Re-extract if needed
client.documents.extract(document_id)
```

## Troubleshooting

### Ingestion Failures

Check ingestion status and logs:

```bash
r2r documents list
```

### Large File Timeouts

For large files, ensure `run_with_orchestration=true` to prevent timeouts.

### Metadata Conflicts

Use `PATCH` instead of `PUT` to update specific fields without overwriting all metadata.

## Resources

- [R2R Documents API Reference](https://r2r-docs.sciphi.ai/api/documents)
- [Python SDK Documentation](https://github.com/sciphi-ai/r2r/tree/main/py/sdk)
- [Ingestion Configuration Guide](https://r2r-docs.sciphi.ai/configuration/ingestion)
