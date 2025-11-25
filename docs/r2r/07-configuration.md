# R2R Configuration

## Overview

R2R offers extensive configuration options to customize behavior across all system components. Configuration can be managed through server-side settings in `r2r.toml` files or dynamically overridden at runtime via API calls.

## Configuration Methods

### 1. Server-Side Configuration (`r2r.toml`)
Persistent settings that define default behavior for the R2R instance.

### 2. Runtime Overrides
Dynamic adjustments during API calls for specific use cases or testing.

### 3. Environment Variables
System-level configuration for deployment and credentials.

## Configuration File Structure

### Main Configuration File: `r2r.toml`

Location:
- **Docker**: `/app/user_configs/<config>.toml`
- **Local**: `~/.r2r/r2r.toml`

### Set Custom Configuration Path

```bash
# Environment variable
export R2R_CONFIG_PATH=/app/user_configs/my_custom_config.toml

# Docker example
R2R_CONFIG_PATH=/app/user_configs/my_custom_config.toml
```

## Complete Configuration Example

```toml
# ============================================
# Application Settings
# ============================================
[app]
default_max_documents_per_user = 100
default_max_chunks_per_user = 10000
default_max_collections_per_user = 10
default_max_upload_size = 2000000

# File-specific upload limits (bytes)
max_upload_size_by_type = { 
  pdf = 30000000, 
  txt = 2000000, 
  csv = 5000000,
  docx = 10000000,
  pptx = 20000000,
  jpg = 5000000,
  png = 5000000
}

# Model configuration
fast_llm = "openai/gpt-4.1-mini"
quality_llm = "openai/gpt-4.1"
planning_llm = "openai/gpt-4.1"
reasoning_llm = "openai/gpt-4.1"
vlm = "openai/gpt-4.1-vision"
audio_lm = "openai/whisper-1"

# Project metadata
project_name = "R2R Project"

# ============================================
# Agent Configuration
# ============================================
[agent]
rag_agent_static_prompt = "rag_agent"
tools = ["search_file_knowledge"]

  [agent.generation_config]
  model = "openai/gpt-4.1"

# ============================================
# Authentication Settings
# ============================================
[auth]
provider = "r2r"
access_token_lifetime_in_minutes = 60
refresh_token_lifetime_in_days = 7
require_authentication = false
require_email_verification = false
default_admin_email = "admin@example.com"
default_admin_password = "change_me_immediately"

# ============================================
# Completion (LLM) Configuration
# ============================================
[completion]
provider = "litellm"
concurrent_request_limit = 64

  [completion.generation_config]
  model = "openai/gpt-4.1"
  temperature = 0.1
  top_p = 1
  max_tokens_to_sample = 1024
  stream = false
  add_generation_kwargs = { }

# ============================================
# Cryptography Settings
# ============================================
[crypto]
provider = "bcrypt"

# ============================================
# Database Configuration
# ============================================
[database]
provider = "postgres"
default_collection_name = "Default"
default_collection_description = "Your default collection."
batch_size = 256

  # Knowledge Graph Creation
  [database.graph_creation_settings]
  graph_entity_description_prompt = "graph_entity_description"
  entity_types = []
  relation_types = []
  fragment_merge_count = 1
  max_knowledge_relationships = 100
  max_description_input_length = 65536
  
    [database.graph_creation_settings.generation_config]
    model = "openai/gpt-4.1-mini"

  # Knowledge Graph Enrichment
  [database.graph_enrichment_settings]
  max_summary_input_length = 65536
  leiden_params = {}
  
    [database.graph_enrichment_settings.generation_config]
    model = "openai/gpt-4.1-mini"

  # Graph Search Settings
  [database.graph_search_settings]
    [database.graph_search_settings.generation_config]
    model = "openai/gpt-4.1-mini"

  # Rate Limiting
  [database.limits]
  global_per_min = 300
  monthly_limit = 10000

  # Route-Specific Limits
  [database.route_limits]
  "/v3/retrieval/search" = { route_per_min = 120 }
  "/v3/retrieval/rag" = { route_per_min = 30 }

# ============================================
# Embedding Configuration
# ============================================
[embedding]
provider = "litellm"
base_model = "openai/text-embedding-3-small"
base_dimension = 512
batch_size = 128
concurrent_request_limit = 256

  [embedding.quantization_settings]
  quantization_type = "FP32"

# ============================================
# File Storage Configuration
# ============================================
[file]
provider = "postgres"

# ============================================
# Ingestion Configuration
# ============================================
[ingestion]
provider = "r2r"
chunking_strategy = "recursive"
chunk_size = 1024
chunk_overlap = 512
excluded_parsers = []
document_summary_model = "openai/gpt-4.1-mini"

  # Chunk Enrichment
  [ingestion.chunk_enrichment_settings]
  enable_chunk_enrichment = false
  strategies = ["semantic", "neighborhood"]
  forward_chunks = 3
  backward_chunks = 3
  semantic_neighbors = 10
  semantic_similarity_threshold = 0.7
  
    [ingestion.chunk_enrichment_settings.generation_config]
    model = "openai/gpt-4.1-mini"

  # Extra Parsers
  [ingestion.extra_parsers]
  pdf = "zerox"

# ============================================
# Orchestration Configuration
# ============================================
[orchestration]
provider = "simple"

# ============================================
# Prompt Configuration
# ============================================
[prompt]
provider = "r2r"

# ============================================
# Email Configuration
# ============================================
[email]
provider = "console_mock"
```

## Configuration Sections

### 1. Application Configuration

```toml
[app]
default_max_documents_per_user = 100
default_max_chunks_per_user = 10000
default_max_collections_per_user = 10
default_max_upload_size = 2000000

# Model assignments
fast_llm = "openai/gpt-4.1-mini"
quality_llm = "openai/gpt-4.1"
```

**Key Settings:**
- **Resource Limits**: Control per-user resource allocation
- **Upload Limits**: Set file size restrictions
- **Model Selection**: Assign models for different tasks

### 2. Authentication Configuration

```toml
[auth]
provider = "r2r"
access_token_lifetime_in_minutes = 60
refresh_token_lifetime_in_days = 7
require_authentication = true
require_email_verification = true
```

**Key Settings:**
- **Token Lifetimes**: Control session duration
- **Verification**: Enable/disable email verification
- **Default Admin**: Set initial admin credentials

### 3. Completion (LLM) Configuration

```toml
[completion]
provider = "litellm"
concurrent_request_limit = 64

  [completion.generation_config]
  model = "openai/gpt-4.1"
  temperature = 0.1
  max_tokens_to_sample = 1024
```

**Key Settings:**
- **Provider**: LLM provider (litellm supports 100+ providers)
- **Concurrency**: Parallel request limit
- **Generation Config**: Default model parameters

### 4. Database Configuration

```toml
[database]
provider = "postgres"
batch_size = 256

  [database.limits]
  global_per_min = 300
  monthly_limit = 10000
```

**Key Settings:**
- **Provider**: Database type (postgres with pgvector)
- **Batch Size**: Processing batch size
- **Rate Limits**: API rate limiting

### 5. Embedding Configuration

```toml
[embedding]
provider = "litellm"
base_model = "openai/text-embedding-3-small"
base_dimension = 512
batch_size = 128
```

**Key Settings:**
- **Model**: Embedding model
- **Dimension**: Vector dimension
- **Batch Size**: Embedding batch processing

### 6. Ingestion Configuration

```toml
[ingestion]
provider = "r2r"
chunking_strategy = "recursive"
chunk_size = 1024
chunk_overlap = 512
document_summary_model = "openai/gpt-4.1-mini"
```

**Key Settings:**
- **Chunking Strategy**: Text splitting method
- **Chunk Size/Overlap**: Text segmentation parameters
- **Summary Model**: Model for document summaries

**Chunking Strategies:**
- `recursive`: Recursive character-based splitting (default)
- `character`: Simple character splitting
- `basic`: Basic text splitting
- `by_title`: Split by document structure

### 7. Knowledge Graph Configuration

```toml
[database.graph_creation_settings]
entity_types = ["Person", "Organization", "Location"]
relation_types = ["works_at", "located_in"]
max_knowledge_relationships = 100

  [database.graph_creation_settings.generation_config]
  model = "openai/gpt-4.1-mini"

[database.graph_enrichment_settings]
max_summary_input_length = 65536
leiden_params = {}
```

**Key Settings:**
- **Entity/Relation Types**: Constrain extraction
- **Max Relationships**: Limit per chunk
- **Community Detection**: Leiden algorithm parameters

## Runtime Overrides

### RAG Generation Config Override

```python
from r2r import R2RClient

client = R2RClient()

# Override at runtime
response = client.retrieval.rag(
    "Who was Aristotle?",
    rag_generation_config={
        "model": "anthropic/claude-3-haiku-20240307",
        "temperature": 0.7,
        "max_tokens": 2000
    }
)
```

### Search Settings Override

```python
# Override search behavior
response = client.retrieval.search(
    "machine learning",
    search_settings={
        "use_hybrid_search": True,
        "limit": 20,
        "filters": {
            "publication_year": {"$gte": 2020}
        }
    }
)
```

### Custom Search Mode

```python
search_mode = "custom"
search_settings = {
    "use_semantic_search": True,
    "use_fulltext_search": True,
    "hybrid_settings": {
        "full_text_weight": 1.0,
        "semantic_weight": 5.0,
        "full_text_limit": 200,
        "rrf_k": 50
    }
}
```

## Environment Variables

### Essential Variables

```bash
# API Keys
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...

# Configuration
export R2R_CONFIG_PATH=/path/to/config.toml
export R2R_CONFIG_NAME=full

# Database (if not using defaults)
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_DB=r2r
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres

# Service URLs
export R2R_BASE_URL=http://localhost:7272
```

### Example: `.env` File

```env
# Copy and edit .env.example
cp .env.example .env

# Edit configuration
nano .env
```

```env
# .env file contents
OPENAI_API_KEY=sk-...
R2R_CONFIG_NAME=full
R2R_BASE_URL=http://localhost:7272
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
```

## Ingestion Modes

Pre-configured ingestion settings:

### Hi-Res Mode
Comprehensive parsing with full enrichment:
```python
client.documents.create(
    file_path="document.pdf",
    ingestion_mode="hi-res"
)
```

### Fast Mode
Quick ingestion, minimal enrichment:
```python
client.documents.create(
    file_path="document.pdf",
    ingestion_mode="fast"
)
```

### Custom Mode
Full control via `ingestion_config`:
```python
client.documents.create(
    file_path="document.pdf",
    ingestion_mode="custom",
    ingestion_config={
        "chunk_size": 512,
        "chunk_overlap": 100,
        "skip_document_summary": True
    }
)
```

## System Settings API

### Get Current Settings

**Endpoint:** `GET /v3/system/settings`

Retrieve current R2R configuration.

```bash
curl -X GET "https://api.example.com/v3/system/settings" \
     -H "Authorization: Bearer YOUR_API_KEY"
```

#### Response

```json
{
  "results": {
    "config": {
      "setting_key": "setting_value"
    },
    "prompts": {
      "prompt_name": "prompt_template"
    },
    "r2r_project_name": "R2R Project"
  }
}
```

## Configuration Best Practices

### 1. Use Environment-Specific Configs

```bash
# Development
export R2R_CONFIG_NAME=dev

# Production
export R2R_CONFIG_NAME=prod

# Testing
export R2R_CONFIG_NAME=test
```

### 2. Secure Sensitive Information

Never commit secrets to version control:

```toml
# ❌ Bad: Hardcoded secrets
default_admin_password = "admin123"

# ✅ Good: Use environment variables
default_admin_password = "${ADMIN_PASSWORD}"
```

### 3. Optimize for Your Use Case

**High-Quality, Low-Volume:**
```toml
[completion.generation_config]
model = "openai/gpt-4.1"
temperature = 0.1

[ingestion]
chunk_size = 2048
```

**Fast, High-Volume:**
```toml
[completion.generation_config]
model = "openai/gpt-4.1-mini"
temperature = 0.5

[ingestion]
chunk_size = 512
```

### 4. Configure Rate Limits

```toml
[database.limits]
global_per_min = 1000

[database.route_limits]
"/v3/retrieval/rag" = { route_per_min = 100 }
"/v3/retrieval/search" = { route_per_min = 500 }
```

### 5. Tune Chunk Settings

```toml
[ingestion]
# Smaller chunks: Better precision
chunk_size = 512
chunk_overlap = 100

# Larger chunks: Better context
chunk_size = 2048
chunk_overlap = 400
```

### 6. Enable Chunk Enrichment (Optional)

```toml
[ingestion.chunk_enrichment_settings]
enable_chunk_enrichment = true
strategies = ["semantic", "neighborhood"]
forward_chunks = 3
backward_chunks = 3
semantic_neighbors = 10
semantic_similarity_threshold = 0.7
```

### 7. Configure Graph Extraction

```toml
[database.graph_creation_settings]
entity_types = ["Person", "Organization", "Technology", "Concept"]
relation_types = ["works_at", "developed", "uses", "related_to"]
max_knowledge_relationships = 200
```

## Monitoring and Debugging

### Enable Debug Logging

```bash
export R2R_LOG_LEVEL=DEBUG
```

### Check Current Configuration

```python
from r2r import R2RClient

client = R2RClient()

# Get system settings
settings = client.system.get_settings()
print(settings)
```

## Migration Between Configurations

### Switching Configurations

```bash
# Stop current instance
docker compose down

# Set new configuration
export R2R_CONFIG_NAME=new_config

# Start with new configuration
docker compose up
```

### Backup Configuration

```bash
# Backup current config
cp ~/.r2r/r2r.toml ~/.r2r/r2r.toml.backup

# Restore if needed
cp ~/.r2r/r2r.toml.backup ~/.r2r/r2r.toml
```

## Troubleshooting

### Configuration Not Loading

Check:
1. File path is correct
2. TOML syntax is valid
3. Environment variables are set
4. Restart the service

### Invalid Configuration Values

Validate TOML syntax:
```bash
# Use TOML validator
toml-validator r2r.toml
```

### Performance Issues

Tune these settings:
- Increase `concurrent_request_limit`
- Adjust `batch_size`
- Optimize `chunk_size`
- Review rate limits

## Resources

- [R2R Configuration Guide](https://r2r-docs.sciphi.ai/configuration)
- [Environment Variables Reference](https://r2r-docs.sciphi.ai/deployment/environment)
- [TOML Specification](https://toml.io/)
- [LiteLLM Providers](https://docs.litellm.ai/docs/providers)
