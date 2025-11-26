#!/usr/bin/env bash
# R2R CLI Examples - Interactive demonstration of common use cases

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# Colors for output
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
NC='\033[0m'

# Print section header
print_section() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Print example with explanation
print_example() {
    local title="$1"
    local command="$2"
    local description="$3"

    echo ""
    echo -e "${BOLD}Example: $title${NC}"
    echo -e "${DIM}$description${NC}"
    echo ""
    echo -e "${CYAN}$ $command${NC}"
}

# Wait for user to continue
wait_continue() {
    echo ""
    read -p "Press Enter to continue or Ctrl+C to exit..."
}

# Run example with confirmation
run_example() {
    local title="$1"
    local command="$2"
    local description="$3"

    print_example "$title" "$command" "$description"

    read -p "Run this example? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        eval "$command"
        wait_continue
    fi
}

# Show help
show_help() {
    cat << EOF
R2R CLI Examples

USAGE:
    examples.sh [category]

CATEGORIES:
    search      Search examples
    rag         RAG examples
    agent       Agent examples
    docs        Document management
    collections Collection management
    graph       Knowledge graph
    workflows   Complete workflows
    all         Show all examples (default)

INTERACTIVE:
    Run without arguments for interactive mode
EOF
}

# Search examples
examples_search() {
    print_section "SEARCH EXAMPLES"

    run_example \
        "Basic Search" \
        "r2r search 'machine learning' -l 3" \
        "Simple search with 3 results"

    run_example \
        "Quiet Mode Search" \
        "r2r search 'transformers' -l 5 -q" \
        "Minimal output for scripting"

    run_example \
        "JSON Output" \
        "r2r search 'RAG systems' -l 2 --json | jq .results" \
        "JSON output for parsing"

    run_example \
        "Collection Search" \
        "r2r search 'AI' -l 5 -c <collection_id>" \
        "Search within specific collection"

    run_example \
        "Graph Search" \
        "r2r search 'entities' --graph -c <collection_id>" \
        "Search knowledge graph"
}

# RAG examples
examples_rag() {
    print_section "RAG EXAMPLES"

    run_example \
        "Basic RAG Query" \
        "r2r rag 'What is RAG?'" \
        "Simple question with default settings"

    run_example \
        "Extended Response" \
        "r2r rag 'Explain transformers in detail' --max-tokens 8000" \
        "Longer, more detailed answer"

    run_example \
        "Show Sources" \
        "r2r rag 'What is FastMCP?' --show-sources" \
        "Display retrieved chunks"

    run_example \
        "Collection-specific RAG" \
        "r2r rag 'Technical question' -c <collection_id> --show-metadata" \
        "RAG with specific collection and metadata"

    run_example \
        "Quiet RAG" \
        "r2r rag 'Quick question' -q" \
        "Minimal output format"
}

# Agent examples
examples_agent() {
    print_section "AGENT EXAMPLES"

    run_example \
        "Research Agent" \
        "r2r agent 'What is DeepSeek R1?'" \
        "Default research mode with advanced reasoning"

    run_example \
        "RAG Agent" \
        "r2r agent 'Simple factual question' --mode rag" \
        "Simple RAG mode for factual queries"

    run_example \
        "Extended Thinking" \
        "r2r agent 'Complex analytical question' --thinking" \
        "4096 token reasoning budget for deep analysis"

    run_example \
        "Continue Conversation" \
        "r2r agent 'Tell me more' -c <conversation_id>" \
        "Multi-turn conversation"

    run_example \
        "Show Tools" \
        "r2r agent 'Research query' --show-tools" \
        "Display tool calls made by agent"
}

# Document management examples
examples_docs() {
    print_section "DOCUMENT MANAGEMENT"

    run_example \
        "List Documents" \
        "r2r docs list -l 10 -q" \
        "List 10 documents in quiet mode"

    run_example \
        "Get Document" \
        "r2r docs get <document_id>" \
        "Get document details"

    run_example \
        "Upload Document" \
        "r2r docs upload path/to/file.pdf -c <collection_id>" \
        "Upload document to collection"

    run_example \
        "Extract Knowledge Graph" \
        "r2r docs extract <document_id>" \
        "Extract entities and relationships"

    run_example \
        "Delete Document" \
        "r2r docs delete <document_id>" \
        "Delete document by ID"
}

# Collection examples
examples_collections() {
    print_section "COLLECTION MANAGEMENT"

    run_example \
        "List Collections" \
        "r2r collections list -l 10 -q" \
        "List all collections"

    run_example \
        "Create Collection" \
        "r2r collections create -n 'Research Papers' -d 'AI research collection'" \
        "Create new collection"

    run_example \
        "Get Collection" \
        "r2r collections get <collection_id>" \
        "Get collection details"

    run_example \
        "Add Document" \
        "r2r collections add-doc -c <collection_id> -d <document_id>" \
        "Add document to collection"

    run_example \
        "Remove Document" \
        "r2r collections remove-doc -c <collection_id> -d <document_id>" \
        "Remove document from collection"
}

# Knowledge graph examples
examples_graph() {
    print_section "KNOWLEDGE GRAPH"

    run_example \
        "List Entities" \
        "r2r graph entities <collection_id> -l 50" \
        "List entities in knowledge graph"

    run_example \
        "List Relationships" \
        "r2r graph relationships <collection_id> -l 30" \
        "List entity relationships"

    run_example \
        "List Communities" \
        "r2r graph communities <collection_id>" \
        "List detected communities"

    run_example \
        "Create Entity" \
        "r2r graph create-entity <collection_id> -n 'Entity Name' -d 'Description'" \
        "Manually create entity"

    run_example \
        "Pull Graph" \
        "r2r graph pull <collection_id>" \
        "Sync knowledge graph from documents"

    run_example \
        "Build Communities" \
        "r2r graph build-communities <collection_id>" \
        "Build community structure"
}

# Workflow examples
examples_workflows() {
    print_section "COMPLETE WORKFLOWS"

    print_example \
        "Upload → Extract → Search Workflow" \
        "# Step 1: Upload document
r2r docs upload paper.pdf -c <collection_id>
# Capture document_id from output

# Step 2: Extract knowledge graph
r2r docs extract <document_id>

# Step 3: Search in document
r2r search 'key concepts' -c <collection_id>

# Step 4: Ask questions
r2r rag 'What are the main findings?' -c <collection_id>" \
        "Complete document processing workflow"
    wait_continue

    print_example \
        "Research Session Workflow" \
        "# Step 1: Start research conversation
r2r agent 'What is the current state of RAG systems?'
# Conversation ID auto-saved to /tmp/.r2r_conversation_id

# Step 2: Deep dive with thinking
r2r agent 'Analyze the architectural trade-offs' --thinking

# Step 3: Continue with follow-up
r2r agent 'Compare with traditional approaches' --show-sources

# Step 4: Get specific examples
r2r agent 'Show me code examples' --show-tools" \
        "Multi-turn research conversation"
    wait_continue

    print_example \
        "Collection Setup Workflow" \
        "# Step 1: Create collection
r2r collections create -n 'ML Research' -d 'Machine learning papers'
# Capture collection_id

# Step 2: Upload multiple documents
for file in papers/*.pdf; do
    r2r docs upload \"\$file\" -c <collection_id>
done

# Step 3: Extract knowledge graphs
r2r docs list -l 100 --json | jq -r '.results[].id' | while read doc_id; do
    r2r docs extract \"\$doc_id\"
done

# Step 4: Build community structure
r2r graph pull <collection_id>
r2r graph build-communities <collection_id>

# Step 5: Explore the knowledge
r2r graph entities <collection_id> -l 100
r2r graph communities <collection_id>" \
        "Complete collection setup and analysis"
    wait_continue
}

# Show all examples
show_all_examples() {
    examples_search
    examples_rag
    examples_agent
    examples_docs
    examples_collections
    examples_graph
    examples_workflows

    print_section "DONE"
    echo "For more information, run: r2r <command> help"
}

# Main execution
main() {
    case "${1:-all}" in
        search)
            examples_search
            ;;
        rag)
            examples_rag
            ;;
        agent)
            examples_agent
            ;;
        docs)
            examples_docs
            ;;
        collections)
            examples_collections
            ;;
        graph)
            examples_graph
            ;;
        workflows)
            examples_workflows
            ;;
        all)
            show_all_examples
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            echo "Unknown category: $1"
            echo "Run 'examples.sh help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
