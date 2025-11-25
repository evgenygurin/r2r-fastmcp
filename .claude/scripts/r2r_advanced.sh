#!/usr/bin/env bash
# R2R Advanced API Client
# Comprehensive toolset for R2R API interaction with examples

set -euo pipefail

# Load environment variables from .claude/config/.env
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${CLAUDE_DIR}/config/.env"

if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
fi

R2R_BASE_URL="${R2R_BASE_URL:-https://api.136-119-36-216.nip.io}"
API_KEY="${API_KEY:-}"

if [ -z "$API_KEY" ]; then
    echo "Error: API_KEY not set in .env file" >&2
    exit 1
fi

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# ==================== DOCUMENTS ====================

# List documents with filtering and pagination
docs_list() {
    local offset="${1:-0}"
    local limit="${2:-10}"

    print_header "Listing Documents (offset: $offset, limit: $limit)"

    curl -s -X GET "${R2R_BASE_URL}/v3/documents?offset=${offset}&limit=${limit}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq -r '.results[] |
            "ID: \(.id)\n" +
            "Title: \(.metadata.title // "Untitled")\n" +
            "Status: \(.ingestion_status)\n" +
            "Collections: \(.collection_ids | join(", "))\n" +
            "Created: \(.created_at)\n" +
            "---"'
}

# Get document details
docs_get() {
    local doc_id="$1"

    print_header "Getting Document: $doc_id"

    curl -s -X GET "${R2R_BASE_URL}/v3/documents/${doc_id}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.'
}

# Delete document
docs_delete() {
    local doc_id="$1"

    print_header "Deleting Document: $doc_id"

    curl -s -X DELETE "${R2R_BASE_URL}/v3/documents/${doc_id}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.'

    print_success "Document deleted"
}

# Export documents to CSV
docs_export() {
    local output_file="${1:-documents_export.csv}"

    print_header "Exporting Documents to $output_file"

    curl -s -X POST "${R2R_BASE_URL}/v3/documents/export" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"include_header":true}' \
        > "$output_file"

    print_success "Documents exported to $output_file"
    head -5 "$output_file"
}

# Extract knowledge graph from document
docs_extract() {
    local doc_id="$1"
    local entity_types="${2:-Person,Organization,Technology,Concept}"

    print_header "Extracting Knowledge Graph from Document: $doc_id"
    print_info "Entity types: $entity_types"

    curl -s -X POST "${R2R_BASE_URL}/v3/documents/${doc_id}/extract" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"entity_types\":[\"${entity_types//,/\",\"}\"],\"relation_types\":[\"works_at\",\"developed\",\"uses\",\"part_of\",\"related_to\"]}" \
        | jq '.'

    print_success "Extraction initiated. Use docs_get to check status."
}

# ==================== COLLECTIONS ====================

# List collections
collections_list() {
    local limit="${1:-10}"
    local offset="${2:-0}"

    print_header "Listing Collections"

    curl -s -X GET "${R2R_BASE_URL}/v3/collections?limit=${limit}&offset=${offset}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq -r '.results[] |
            "ID: \(.id)\n" +
            "Name: \(.name)\n" +
            "Description: \(.description // "No description")\n" +
            "Documents: \(.document_count)\n" +
            "Users: \(.user_count)\n" +
            "Graph Status: \(.graph_cluster_status)\n" +
            "---"'
}

# Get collection details
collections_get() {
    local collection_id="$1"

    print_header "Getting Collection: $collection_id"

    curl -s -X GET "${R2R_BASE_URL}/v3/collections/${collection_id}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.'
}

# Create collection
collections_create() {
    local name="$1"
    local description="${2:-}"

    print_header "Creating Collection: $name"

    curl -s -X POST "${R2R_BASE_URL}/v3/collections" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${name}\",\"description\":\"${description}\"}" \
        | jq '.'

    print_success "Collection created"
}

# Delete collection
collections_delete() {
    local collection_id="$1"

    print_header "Deleting Collection: $collection_id"

    curl -s -X DELETE "${R2R_BASE_URL}/v3/collections/${collection_id}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.'

    print_success "Collection deleted"
}

# Add document to collection
collections_add_document() {
    local collection_id="$1"
    local document_id="$2"

    print_header "Adding Document to Collection"
    print_info "Collection: $collection_id"
    print_info "Document: $document_id"

    curl -s -X POST "${R2R_BASE_URL}/v3/collections/${collection_id}/documents" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"document_id\":\"${document_id}\"}" \
        | jq '.'

    print_success "Document added to collection"
}

# ==================== KNOWLEDGE GRAPHS ====================

# List entities in collection
graph_entities() {
    local collection_id="$1"
    local limit="${2:-20}"

    print_header "Listing Entities in Collection: $collection_id"

    curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities?limit=${limit}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq -r '.results[] |
            "Name: \(.name)\n" +
            "Category: \(.category)\n" +
            "Description: \(.description)\n" +
            "---"'
}

# List relationships in collection
graph_relationships() {
    local collection_id="$1"
    local limit="${2:-20}"

    print_header "Listing Relationships in Collection: $collection_id"

    curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships?limit=${limit}" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq -r '.results[] |
            "\(.subject) -> \(.predicate) -> \(.object)\n" +
            "Description: \(.description)\n" +
            "Weight: \(.weight // "N/A")\n" +
            "---"'
}

# List communities in collection
graph_communities() {
    local collection_id="$1"

    print_header "Listing Communities in Collection: $collection_id"

    curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq -r '.results[] |
            "ID: \(.id)\n" +
            "Name: \(.name)\n" +
            "Summary: \(.summary)\n" +
            "Rating: \(.rating // "N/A")/10\n" +
            "Findings:\n\(.findings | join("\n- "))\n" +
            "---"'
}

# Build communities for collection
graph_build_communities() {
    local collection_id="$1"

    print_header "Building Communities for Collection: $collection_id"

    curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities/build" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"message":"Building communities"}' \
        | jq '.'

    print_success "Community building initiated"
}

# Pull graph data (sync)
graph_pull() {
    local collection_id="$1"

    print_header "Syncing Graph Data for Collection: $collection_id"

    curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/pull" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.'

    print_success "Graph data synchronized"
}

# Create entity
graph_create_entity() {
    local collection_id="$1"
    local name="$2"
    local description="$3"
    local category="${4:-Concept}"

    print_header "Creating Entity: $name"

    curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${name}\",\"description\":\"${description}\",\"category\":\"${category}\"}" \
        | jq '.'

    print_success "Entity created"
}

# Create relationship
graph_create_relationship() {
    local collection_id="$1"
    local subject="$2"
    local predicate="$3"
    local object="$4"
    local description="${5:-}"

    print_header "Creating Relationship"
    print_info "$subject -> $predicate -> $object"

    curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"subject\":\"${subject}\",\"predicate\":\"${predicate}\",\"object\":\"${object}\",\"description\":\"${description}\"}" \
        | jq '.'

    print_success "Relationship created"
}

# ==================== ADVANCED SEARCH ====================

# Search with filters
search_filtered() {
    local query="$1"
    local filter_field="${2:-}"
    local filter_value="${3:-}"
    local limit="${4:-5}"

    print_header "Filtered Search: $query"

    local filter_json="{}"
    if [ -n "$filter_field" ] && [ -n "$filter_value" ]; then
        filter_json="{\"${filter_field}\":{\"\$eq\":\"${filter_value}\"}}"
        print_info "Filter: $filter_field = $filter_value"
    fi

    curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "{\"query\":\"${query}\",\"limit\":${limit},\"search_settings\":{\"use_hybrid_search\":true,\"filters\":${filter_json}}}" \
        | jq -r '.results.chunk_search_results[] |
            "Score: \(.score | tonumber | . * 100 | round / 100)\n" +
            "Doc: \(.metadata.title // "Unknown") [\(.document_id[:8])]\n" +
            "\(.text[:300])...\n" +
            "---"'
}

# Search with strategy
search_strategy() {
    local query="$1"
    local strategy="${2:-vanilla}"
    local limit="${3:-5}"

    print_header "Search with Strategy: $strategy"
    print_info "Query: $query"

    curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "{\"query\":\"${query}\",\"limit\":${limit},\"search_settings\":{\"use_hybrid_search\":true,\"search_strategy\":\"${strategy}\"}}" \
        | jq -r '.results.chunk_search_results[] |
            "Score: \(.score | tonumber | . * 100 | round / 100)\n" +
            "Text: \(.text[:200])...\n" +
            "---"'
}

# Graph search (entities + relationships)
search_graph() {
    local query="$1"
    local collection_id="${2:-}"
    local limit="${3:-5}"

    print_header "Graph Search: $query"

    local filter_json="{}"
    if [ -n "$collection_id" ]; then
        filter_json="{\"collection_ids\":{\"\$overlap\":[\"${collection_id}\"]}}"
        print_info "Collection: $collection_id"
    fi

    curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "{\"query\":\"${query}\",\"limit\":${limit},\"search_settings\":{\"use_hybrid_search\":true,\"use_graph_search\":true,\"filters\":${filter_json}}}" \
        | jq '.'
}

# ==================== ANALYTICS ====================

# Get collection statistics
analytics_collection() {
    local collection_id="$1"

    print_header "Collection Analytics: $collection_id"

    echo -e "\n${YELLOW}Collection Info:${NC}"
    collections_get "$collection_id" | jq '{
        name,
        document_count,
        user_count,
        graph_cluster_status,
        graph_sync_status,
        created_at,
        updated_at
    }'

    echo -e "\n${YELLOW}Entities Count:${NC}"
    curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities?limit=1" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.total_entries'

    echo -e "\n${YELLOW}Relationships Count:${NC}"
    curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships?limit=1" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.total_entries'

    echo -e "\n${YELLOW}Communities Count:${NC}"
    curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities?limit=1" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq '.total_entries'
}

# Document insights
analytics_document() {
    local doc_id="$1"

    print_header "Document Analytics: $doc_id"

    docs_get "$doc_id" | jq '{
        id,
        title: .metadata.title,
        ingestion_status,
        collection_ids,
        created_at,
        updated_at,
        metadata
    }'
}

# ==================== EXAMPLES & DEMOS ====================

demo_workflow() {
    print_header "R2R Complete Workflow Demo"

    print_info "This demo shows a complete R2R workflow:"
    echo "1. Create collection"
    echo "2. Add documents"
    echo "3. Extract knowledge graph"
    echo "4. Build communities"
    echo "5. Search and analyze"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."

    # Step 1: Create collection
    print_header "Step 1: Creating Collection"
    collection_response=$(curl -s -X POST "${R2R_BASE_URL}/v3/collections" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"name":"Demo Collection","description":"Test collection for workflow demo"}')

    collection_id=$(echo "$collection_response" | jq -r '.results.id')
    print_success "Collection created: $collection_id"

    # Step 2: List existing documents
    print_header "Step 2: Listing Existing Documents"
    docs_list 0 5

    print_info "You can add documents using: docs_create or via Python SDK"

    # Step 3: Graph operations
    print_header "Step 3: Graph Operations"
    print_info "Extracting knowledge graph..."
    print_info "Use: docs_extract <document_id>"

    # Step 4: Search
    print_header "Step 4: Search Examples"
    print_info "Hybrid search:"
    search_filtered "machine learning" "" "" 3

    print_success "Demo complete! Collection ID: $collection_id"
}

# Show examples
show_examples() {
    cat << 'EOF'
R2R Advanced Client - Usage Examples
====================================

DOCUMENTS:
  # List all documents
  ./r2r_advanced.sh docs-list 0 10

  # Get document details
  ./r2r_advanced.sh docs-get <document_id>

  # Delete document
  ./r2r_advanced.sh docs-delete <document_id>

  # Export documents to CSV
  ./r2r_advanced.sh docs-export my_docs.csv

  # Extract knowledge graph from document
  ./r2r_advanced.sh docs-extract <document_id> "Person,Organization,Technology"

COLLECTIONS:
  # List collections
  ./r2r_advanced.sh collections-list 10

  # Create collection
  ./r2r_advanced.sh collections-create "My Collection" "Description"

  # Get collection details
  ./r2r_advanced.sh collections-get <collection_id>

  # Add document to collection
  ./r2r_advanced.sh collections-add-doc <collection_id> <document_id>

KNOWLEDGE GRAPHS:
  # List entities
  ./r2r_advanced.sh graph-entities <collection_id> 20

  # List relationships
  ./r2r_advanced.sh graph-relationships <collection_id> 20

  # List communities
  ./r2r_advanced.sh graph-communities <collection_id>

  # Build communities
  ./r2r_advanced.sh graph-build-communities <collection_id>

  # Sync graph data
  ./r2r_advanced.sh graph-pull <collection_id>

  # Create entity
  ./r2r_advanced.sh graph-create-entity <collection_id> "Entity Name" "Description" "Category"

  # Create relationship
  ./r2r_advanced.sh graph-create-rel <collection_id> "Subject" "predicate" "Object" "Description"

ADVANCED SEARCH:
  # Search with filters
  ./r2r_advanced.sh search-filtered "query" "title" "specific_title" 5

  # Search with strategy (vanilla, rag_fusion, hyde)
  ./r2r_advanced.sh search-strategy "query" "rag_fusion" 5

  # Graph search
  ./r2r_advanced.sh search-graph "query" <collection_id> 5

ANALYTICS:
  # Collection analytics
  ./r2r_advanced.sh analytics-collection <collection_id>

  # Document insights
  ./r2r_advanced.sh analytics-document <document_id>

DEMO:
  # Run complete workflow demo
  ./r2r_advanced.sh demo

EOF
}

# Main dispatcher
case "${1:-help}" in
    # Documents
    docs-list) docs_list "${2:-0}" "${3:-10}" ;;
    docs-get) docs_get "$2" ;;
    docs-delete) docs_delete "$2" ;;
    docs-export) docs_export "${2:-documents_export.csv}" ;;
    docs-extract) docs_extract "$2" "${3:-Person,Organization,Technology,Concept}" ;;

    # Collections
    collections-list) collections_list "${2:-10}" "${3:-0}" ;;
    collections-get) collections_get "$2" ;;
    collections-create) collections_create "$2" "${3:-}" ;;
    collections-delete) collections_delete "$2" ;;
    collections-add-doc) collections_add_document "$2" "$3" ;;

    # Knowledge Graphs
    graph-entities) graph_entities "$2" "${3:-20}" ;;
    graph-relationships) graph_relationships "$2" "${3:-20}" ;;
    graph-communities) graph_communities "$2" ;;
    graph-build-communities) graph_build_communities "$2" ;;
    graph-pull) graph_pull "$2" ;;
    graph-create-entity) graph_create_entity "$2" "$3" "$4" "${5:-Concept}" ;;
    graph-create-rel) graph_create_relationship "$2" "$3" "$4" "$5" "${6:-}" ;;

    # Advanced Search
    search-filtered) search_filtered "$2" "${3:-}" "${4:-}" "${5:-5}" ;;
    search-strategy) search_strategy "$2" "${3:-vanilla}" "${4:-5}" ;;
    search-graph) search_graph "$2" "${3:-}" "${4:-5}" ;;

    # Analytics
    analytics-collection) analytics_collection "$2" ;;
    analytics-document) analytics_document "$2" ;;

    # Demo
    demo) demo_workflow ;;

    # Help
    examples) show_examples ;;
    help|--help|-h|*)
        show_examples
        ;;
esac
