#!/usr/bin/env bash
# R2R Workflows - Automated multi-step workflows

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# Print workflow header
print_workflow() {
    echo ""
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

# Print step
print_step() {
    echo -e "${YELLOW}▶ Step $1: $2${NC}"
}

# Print success
print_success_step() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Workflow 1: Upload and index document
workflow_upload_document() {
    local file_path="$1"
    local collection_id="${2:-}"

    print_workflow "Upload and Index Document"

    # Step 1: Validate file
    print_step "1" "Validating file"
    if [ ! -f "$file_path" ]; then
        print_error "File not found: $file_path"
        return 1
    fi
    print_success_step "File exists: $(basename "$file_path")"

    # Step 2: Upload document
    print_step "2" "Uploading document"
    local upload_cmd="r2r docs upload \"$file_path\""
    [ -n "$collection_id" ] && upload_cmd+=" -c \"$collection_id\""

    local result
    result=$($upload_cmd --json)
    local doc_id=$(echo "$result" | jq -r '.results.document_id')

    if [ -z "$doc_id" ] || [ "$doc_id" = "null" ]; then
        print_error "Upload failed"
        return 1
    fi
    print_success_step "Uploaded: $doc_id"

    # Step 3: Wait for processing
    print_step "3" "Waiting for ingestion (5 seconds)"
    sleep 5
    print_success_step "Processing complete"

    # Step 4: Extract knowledge graph
    print_step "4" "Extracting knowledge graph"
    r2r docs extract "$doc_id" -q
    print_success_step "Knowledge graph extracted"

    # Step 5: Test search
    print_step "5" "Testing search"
    local filename=$(basename "$file_path" | sed 's/\.[^.]*$//')
    r2r search "$filename" -l 1 -q
    print_success_step "Document is searchable"

    echo ""
    echo -e "${GREEN}✓ Workflow completed successfully${NC}"
    echo -e "${BLUE}Document ID: $doc_id${NC}"

    # Return document ID
    echo "$doc_id"
}

# Workflow 2: Create collection and populate
workflow_create_collection() {
    local name="$1"
    local description="${2:-}"
    shift 2
    local files=("$@")

    print_workflow "Create Collection and Populate"

    # Step 1: Create collection
    print_step "1" "Creating collection"
    local result
    result=$(r2r collections create -n "$name" -d "$description" --json)
    local collection_id=$(echo "$result" | jq -r '.results.id')

    if [ -z "$collection_id" ] || [ "$collection_id" = "null" ]; then
        print_error "Collection creation failed"
        return 1
    fi
    print_success_step "Created: $collection_id"

    # Step 2: Upload files
    local total_files=${#files[@]}
    print_step "2" "Uploading $total_files files"

    local uploaded=0
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            r2r docs upload "$file" -c "$collection_id" -q
            ((uploaded++))
            echo -e "${DIM}  [$uploaded/$total_files] $(basename "$file")${NC}"
        fi
    done
    print_success_step "Uploaded $uploaded files"

    # Step 3: Extract knowledge graphs
    print_step "3" "Extracting knowledge graphs"
    sleep 5
    local doc_ids=$(r2r docs list -l 100 --json | jq -r ".results[] | select(.collection_ids | map(select(. == \"$collection_id\")) | length > 0) | .id")

    local extracted=0
    while IFS= read -r doc_id; do
        [ -z "$doc_id" ] && continue
        r2r docs extract "$doc_id" -q 2>/dev/null || true
        ((extracted++))
    done <<< "$doc_ids"
    print_success_step "Extracted $extracted graphs"

    # Step 4: Build communities
    print_step "4" "Building knowledge graph communities"
    r2r graph pull "$collection_id" -q
    r2r graph build-communities "$collection_id" -q
    print_success_step "Communities built"

    echo ""
    echo -e "${GREEN}✓ Collection ready${NC}"
    echo -e "${BLUE}Collection ID: $collection_id${NC}"
    echo -e "${BLUE}Documents: $uploaded${NC}"

    echo "$collection_id"
}

# Workflow 3: Research session
workflow_research_session() {
    local initial_query="$1"
    local mode="${2:-research}"

    print_workflow "Interactive Research Session"

    # Step 1: Start conversation
    print_step "1" "Starting research conversation"
    r2r agent "$initial_query" --mode "$mode"

    # Get conversation ID
    local conv_id=""
    if [ -f /tmp/.r2r_conversation_id ]; then
        conv_id=$(head -1 /tmp/.r2r_conversation_id)
    fi

    if [ -z "$conv_id" ]; then
        print_error "Failed to get conversation ID"
        return 1
    fi
    print_success_step "Conversation started: $conv_id"

    # Step 2: Interactive loop
    echo ""
    echo -e "${YELLOW}Enter follow-up questions (empty to exit):${NC}"

    while true; do
        echo ""
        read -p "Question: " followup
        [ -z "$followup" ] && break

        r2r agent "$followup" -c "$conv_id" --mode "$mode"
    done

    echo ""
    echo -e "${GREEN}✓ Research session complete${NC}"
    echo -e "${BLUE}Conversation ID: $conv_id${NC}"
}

# Workflow 4: Document analysis
workflow_analyze_document() {
    local doc_id="$1"

    print_workflow "Comprehensive Document Analysis"

    # Step 1: Get document info
    print_step "1" "Fetching document metadata"
    local doc_info=$(r2r docs get "$doc_id" --json)
    local title=$(echo "$doc_info" | jq -r '.results.metadata.title // "Untitled"')
    print_success_step "Document: $title"

    # Step 2: Search key topics
    print_step "2" "Identifying key topics"
    r2r search "$title" -l 5 -q

    # Step 3: Extract knowledge graph
    print_step "3" "Extracting knowledge graph"
    r2r docs extract "$doc_id" -q
    print_success_step "Entities extracted"

    # Step 4: Get entities
    print_step "4" "Analyzing entities"
    local collection_ids=$(echo "$doc_info" | jq -r '.results.collection_ids[0] // empty')

    if [ -n "$collection_ids" ]; then
        r2r graph entities "$collection_ids" -l 10 -q
        print_success_step "Top entities identified"
    fi

    # Step 5: RAG analysis
    print_step "5" "Generating summary"
    r2r rag "Summarize the key points from: $title"

    echo ""
    echo -e "${GREEN}✓ Analysis complete${NC}"
}

# Workflow 5: Batch upload directory
workflow_batch_upload() {
    local directory="$1"
    local collection_id="${2:-}"
    local pattern="${3:-*.pdf}"

    print_workflow "Batch Upload Directory"

    # Step 1: Find files
    print_step "1" "Finding files matching: $pattern"
    local files=()
    while IFS= read -r -d $'\0' file; do
        files+=("$file")
    done < <(find "$directory" -name "$pattern" -type f -print0)

    local total=${#files[@]}
    if [ $total -eq 0 ]; then
        print_error "No files found matching pattern: $pattern"
        return 1
    fi
    print_success_step "Found $total files"

    # Step 2: Upload each file
    print_step "2" "Uploading files"
    local uploaded=0
    local failed=0
    local doc_ids=()

    for file in "${files[@]}"; do
        echo -e "${DIM}  [$(($uploaded + $failed + 1))/$total] $(basename "$file")${NC}"

        local result
        if result=$(r2r docs upload "$file" ${collection_id:+-c "$collection_id"} --json 2>/dev/null); then
            local doc_id=$(echo "$result" | jq -r '.results.document_id')
            doc_ids+=("$doc_id")
            ((uploaded++))
        else
            ((failed++))
        fi
    done

    print_success_step "Uploaded: $uploaded, Failed: $failed"

    # Step 3: Extract graphs in batch
    if [ $uploaded -gt 0 ]; then
        print_step "3" "Extracting knowledge graphs (batch)"
        sleep 5

        local extracted=0
        for doc_id in "${doc_ids[@]}"; do
            if r2r docs extract "$doc_id" -q 2>/dev/null; then
                ((extracted++))
            fi
        done
        print_success_step "Extracted: $extracted/$uploaded"
    fi

    echo ""
    echo -e "${GREEN}✓ Batch upload complete${NC}"
    echo -e "${BLUE}Uploaded: $uploaded${NC}"
    echo -e "${BLUE}Failed: $failed${NC}"
}

# Show help
show_help() {
    cat << 'EOF'
R2R Workflows - Automated multi-step workflows

USAGE:
    workflows.sh <workflow> [arguments]

WORKFLOWS:

    upload <file> [collection_id]
        Upload document, extract graph, make searchable
        Example: workflows.sh upload paper.pdf abc123

    create-collection <name> <description> <files...>
        Create collection, upload files, build knowledge graph
        Example: workflows.sh create-collection "Research" "AI papers" *.pdf

    research <query> [mode]
        Start interactive research session
        Example: workflows.sh research "What is RAG?" research

    analyze <document_id>
        Comprehensive document analysis
        Example: workflows.sh analyze abc123-def456

    batch-upload <directory> [collection_id] [pattern]
        Upload all matching files from directory
        Example: workflows.sh batch-upload ./docs abc123 "*.pdf"

OPTIONS:
    -h, --help    Show this help message

EXAMPLES:

    # Quick upload
    workflows.sh upload research-paper.pdf

    # Create and populate collection
    workflows.sh create-collection "ML Papers" "Machine learning research" papers/*.pdf

    # Research session
    workflows.sh research "Explain transformers"

    # Batch upload
    workflows.sh batch-upload ./documents collection123 "*.pdf"
EOF
}

# Main execution
main() {
    case "${1:-help}" in
        upload)
            shift
            workflow_upload_document "$@"
            ;;
        create-collection)
            shift
            workflow_create_collection "$@"
            ;;
        research)
            shift
            workflow_research_session "$@"
            ;;
        analyze)
            shift
            workflow_analyze_document "$@"
            ;;
        batch-upload)
            shift
            workflow_batch_upload "$@"
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            echo "Unknown workflow: $1"
            echo "Run 'workflows.sh help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
