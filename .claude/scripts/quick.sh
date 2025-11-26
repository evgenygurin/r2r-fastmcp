#!/usr/bin/env bash
# R2R Quick Tasks - One-line shortcuts for common operations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# Quick search and ask
quick_ask() {
    local query="$1"
    echo -e "${BLUE}🔍 Searching...${NC}"
    r2r search "$query" -l 3 -q
    echo ""
    echo -e "${BLUE}💬 Asking RAG...${NC}"
    r2r rag "$query"
}

# Quick document status
quick_status() {
    echo -e "${BLUE}📊 R2R Status${NC}"
    echo ""

    echo -e "${YELLOW}Documents:${NC}"
    local doc_count=$(r2r docs list -l 1 --json 2>/dev/null | jq -r '.total_entries // 0')
    echo "  Total: $doc_count"
    echo ""

    echo -e "${YELLOW}Collections:${NC}"
    r2r collections list -l 5 -q
    echo ""

    echo -e "${YELLOW}Recent uploads:${NC}"
    r2r docs list -l 5 -q
}

# Quick upload with auto-extract
quick_up() {
    local file="$1"
    local collection_id="${2:-}"

    echo -e "${BLUE}📤 Uploading: $(basename "$file")${NC}"

    local cmd="r2r docs upload \"$file\""
    [ -n "$collection_id" ] && cmd+=" -c \"$collection_id\""

    local result=$($cmd --json)
    local doc_id=$(echo "$result" | jq -r '.results.document_id')

    if [ -n "$doc_id" ] && [ "$doc_id" != "null" ]; then
        echo -e "${GREEN}✓ Uploaded: $doc_id${NC}"
        echo -e "${BLUE}⏳ Extracting knowledge graph...${NC}"
        sleep 3
        r2r docs extract "$doc_id" -q
        echo -e "${GREEN}✓ Ready to search${NC}"
        echo ""
        echo "Try: r2r search \"$(basename "$file" | sed 's/\.[^.]*$//')\" -l 3"
    else
        echo -e "${RED}✗ Upload failed${NC}"
        return 1
    fi
}

# Quick collection create
quick_col() {
    local name="$1"
    local description="${2:-}"

    echo -e "${BLUE}📁 Creating collection: $name${NC}"
    local result=$(r2r collections create -n "$name" -d "$description" --json)
    local col_id=$(echo "$result" | jq -r '.results.id')

    if [ -n "$col_id" ] && [ "$col_id" != "null" ]; then
        echo -e "${GREEN}✓ Created${NC}"
        echo ""
        echo "Collection ID: $col_id"
        echo ""
        echo "Add documents:"
        echo "  r2r docs upload file.pdf -c $col_id"
        echo ""
        echo "$col_id" > /tmp/.r2r_last_collection
    else
        echo -e "${RED}✗ Failed${NC}"
        return 1
    fi
}

# Quick search last collection
quick_col_search() {
    local query="$1"

    if [ ! -f /tmp/.r2r_last_collection ]; then
        echo -e "${RED}No recent collection. Create one with: quick.sh col \"Name\"${NC}"
        return 1
    fi

    local col_id=$(cat /tmp/.r2r_last_collection)
    echo -e "${BLUE}🔍 Searching in collection: ${col_id:0:8}...${NC}"
    r2r search "$query" -c "$col_id" -l 5
}

# Quick continue conversation
quick_continue() {
    local message="$1"

    if [ ! -f /tmp/.r2r_conversation_id ]; then
        echo -e "${YELLOW}No active conversation. Starting new one...${NC}"
        r2r agent "$message"
    else
        local conv_id=$(head -1 /tmp/.r2r_conversation_id)
        echo -e "${BLUE}💬 Continuing conversation: ${conv_id:0:8}...${NC}"
        r2r agent "$message" -c "$conv_id"
    fi
}

# Quick graph overview
quick_graph() {
    local collection_id="$1"

    echo -e "${BLUE}🕸️  Knowledge Graph Overview${NC}"
    echo ""

    echo -e "${YELLOW}Entities:${NC}"
    r2r graph entities "$collection_id" -l 10 -q
    echo ""

    echo -e "${YELLOW}Relationships:${NC}"
    r2r graph relationships "$collection_id" -l 10 -q
    echo ""

    echo -e "${YELLOW}Communities:${NC}"
    r2r graph communities "$collection_id" -l 5 -q
}

# Quick batch upload current directory
quick_batch() {
    local pattern="${1:-*.pdf}"

    echo -e "${BLUE}📦 Batch upload: $pattern${NC}"

    local files=($(find . -maxdepth 1 -name "$pattern" -type f))
    local total=${#files[@]}

    if [ $total -eq 0 ]; then
        echo -e "${YELLOW}No files found matching: $pattern${NC}"
        return 0
    fi

    echo -e "${YELLOW}Found $total files${NC}"
    read -p "Continue? [y/N] " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 0
    fi

    local uploaded=0
    for file in "${files[@]}"; do
        echo -e "${DIM}[$((uploaded+1))/$total] $(basename "$file")${NC}"
        if r2r docs upload "$file" -q 2>/dev/null; then
            ((uploaded++))
        fi
    done

    echo ""
    echo -e "${GREEN}✓ Uploaded: $uploaded/$total${NC}"
}

# Quick find document
quick_find() {
    local search_term="$1"

    echo -e "${BLUE}🔍 Finding documents matching: $search_term${NC}"
    r2r docs list -l 50 --json | jq -r --arg term "$search_term" \
        '.results[] | select(.metadata.title | test($term; "i")) |
        "\(.id[:8]) | \(.metadata.title) | \(.ingestion_status)"'
}

# Quick cleanup (delete failed documents)
quick_cleanup() {
    echo -e "${BLUE}🧹 Finding failed documents...${NC}"

    local failed_docs=$(r2r docs list -l 100 --json | jq -r \
        '.results[] | select(.ingestion_status == "failed") | .id')

    if [ -z "$failed_docs" ]; then
        echo -e "${GREEN}✓ No failed documents${NC}"
        return 0
    fi

    local count=$(echo "$failed_docs" | wc -l | tr -d ' ')
    echo -e "${YELLOW}Found $count failed documents${NC}"
    read -p "Delete them? [y/N] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        while IFS= read -r doc_id; do
            [ -z "$doc_id" ] && continue
            r2r docs delete "$doc_id" -q
            echo -e "${DIM}  Deleted: $doc_id${NC}"
        done <<< "$failed_docs"
        echo -e "${GREEN}✓ Cleanup complete${NC}"
    fi
}

# Show help
show_help() {
    cat << 'EOF'
R2R Quick Tasks - One-line shortcuts

USAGE:
    quick.sh <task> [arguments]

TASKS:

    ask <query>
        Quick search + RAG answer
        Example: quick.sh ask "What is RAG?"

    status
        Show R2R status (docs, collections, recent uploads)

    up <file> [collection_id]
        Quick upload with auto-extract
        Example: quick.sh up paper.pdf

    col <name> [description]
        Quick create collection
        Example: quick.sh col "Research Papers"

    col-search <query>
        Search in last created collection
        Example: quick.sh col-search "transformers"

    continue <message>
        Continue last agent conversation
        Example: quick.sh continue "Tell me more"

    graph <collection_id>
        Quick graph overview
        Example: quick.sh graph abc123

    batch [pattern]
        Batch upload current directory (default: *.pdf)
        Example: quick.sh batch "*.md"

    find <term>
        Find documents by title
        Example: quick.sh find "machine learning"

    cleanup
        Delete failed documents
        Example: quick.sh cleanup

OPTIONS:
    -h, --help    Show this help

ALIASES:
    q ask         = quick.sh ask
    q up          = quick.sh up
    q st          = quick.sh status

EXAMPLES:

    # Quick Q&A
    quick.sh ask "Explain RAG systems"

    # Upload and extract
    quick.sh up research.pdf

    # Create collection
    quick.sh col "AI Research" "Machine learning papers"

    # Batch upload
    quick.sh batch "*.pdf"

    # Continue conversation
    quick.sh continue "Give me examples"

    # Check status
    quick.sh status
EOF
}

# Main execution
main() {
    case "${1:-help}" in
        ask)
            shift
            quick_ask "$@"
            ;;
        status|st)
            quick_status
            ;;
        up|upload)
            shift
            quick_up "$@"
            ;;
        col|collection)
            shift
            quick_col "$@"
            ;;
        col-search|cs)
            shift
            quick_col_search "$@"
            ;;
        continue|c)
            shift
            quick_continue "$@"
            ;;
        graph|g)
            shift
            quick_graph "$@"
            ;;
        batch|b)
            shift
            quick_batch "$@"
            ;;
        find|f)
            shift
            quick_find "$@"
            ;;
        cleanup)
            quick_cleanup
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            echo "Unknown task: $1"
            echo "Run 'quick.sh help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
