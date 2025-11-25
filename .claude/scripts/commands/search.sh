#!/usr/bin/env bash
# R2R Search Command
# Hybrid search with advanced options (filters, strategies, graph search)

source "$(dirname "$0")/../lib/common.sh"

# Parse search-specific flags
FILTER_FIELD=""
FILTER_VALUE=""
SEARCH_STRATEGY="vanilla"
USE_GRAPH_SEARCH=false
COLLECTION_ID=""
GENERATION_MODEL=""  # For hyde/rag_fusion strategies

r2r_search() {
    local query="$1"
    local limit="${2:-$DEFAULT_LIMIT}"

    # Build filters using jq
    local filters=$(jq -n '{}')

    if [ -n "$FILTER_FIELD" ] && [ -n "$FILTER_VALUE" ]; then
        filters=$(echo "$filters" | jq \
            --arg field "$FILTER_FIELD" \
            --arg value "$FILTER_VALUE" \
            '. + {($field): {"$eq": $value}}')
    fi

    if [ -n "$COLLECTION_ID" ]; then
        filters=$(echo "$filters" | jq \
            --arg cid "$COLLECTION_ID" \
            '. + {"collection_ids": {"$overlap": [$cid]}}')
    fi

    # Build search settings using jq
    # Convert bash boolean to JSON boolean
    local use_graph_json="false"
    [ "$USE_GRAPH_SEARCH" = true ] && use_graph_json="true"

    # For hyde/rag_fusion, require generation model
    if [ "$SEARCH_STRATEGY" = "hyde" ] || [ "$SEARCH_STRATEGY" = "rag_fusion" ]; then
        if [ -z "$GENERATION_MODEL" ]; then
            # Default model for advanced strategies
            GENERATION_MODEL="openai/gpt-4o-mini"
            print_info "Using default model for $SEARCH_STRATEGY: $GENERATION_MODEL"
        fi
    fi

    # Build base search settings
    local search_settings=$(jq -n \
        --arg strategy "$SEARCH_STRATEGY" \
        --argjson use_graph "$use_graph_json" \
        --argjson filters "$filters" \
        '{
            use_hybrid_search: true,
            search_strategy: $strategy,
            filters: $filters
        } + (if $use_graph then {use_graph_search: true} else {} end)')

    # Add generation_config for hyde/rag_fusion
    if [ -n "$GENERATION_MODEL" ]; then
        search_settings=$(echo "$search_settings" | jq \
            --arg model "$GENERATION_MODEL" \
            '. + {generation_config: {model: $model}}')
    fi

    # Build complete payload using jq
    local payload=$(jq -n \
        --arg q "$query" \
        --argjson lim "$limit" \
        --argjson settings "$search_settings" \
        '{query: $q, limit: $lim, search_settings: $settings}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "$payload")

    if [ "$JSON_OUTPUT" = true ]; then
        echo "$response" | jq '.'
        return
    fi

    if [ "$VERBOSE" = true ]; then
        echo "$response" | jq -r '.results.chunk_search_results[] |
            "Score: \(.score | tonumber | . * 100 | round / 100)\n" +
            "Document ID: \(.document_id)\n" +
            "Chunk ID: \(.id[:8])\n" +
            "Title: \(.metadata.title // "Unknown")\n" +
            "Collection IDs: \(.collection_ids | join(", "))\n" +
            "Text:\n\(.text)\n" +
            "---"'
    else
        echo "$response" | jq -r '.results.chunk_search_results[] |
            "Score: \(.score | tonumber | . * 100 | round / 100)\n" +
            "Doc: \(.metadata.title // "Unknown") [\(.id[:8])]\n" +
            "\(.text)\n" +
            "---"'
    fi
}

# Show help
show_help() {
    cat << EOF
R2R Search Command

USAGE:
    search <query> [limit] [options]

OPTIONS:
    --filter field=value        Filter by metadata field
    --strategy <name>           Search strategy (vanilla, hyde, rag_fusion)
    --model <name>              Model for hyde/rag_fusion (default: openai/gpt-4o-mini)
    --graph                     Enable graph search (entities + relationships)
    --collection <id>           Filter by collection ID
    --verbose                   Show detailed metadata
    --json                      Output raw JSON

STRATEGIES:
    vanilla (default)           Standard semantic search (recommended)
    hyde                        Hypothetical Document Embeddings (requires --model)
    rag_fusion                  Multiple queries + RRF (requires --model)

NOTE: hyde and rag_fusion automatically use openai/gpt-4o-mini if --model not specified

EXAMPLES:
    # Basic search
    search "machine learning" 5

    # With filters
    search "neural networks" 10 --filter document_type=pdf

    # With vanilla strategy (explicit)
    search "AI research" --strategy vanilla

    # With hyde strategy (auto-uses default model)
    search "transformers" --strategy hyde

    # With rag_fusion and custom model
    search "deep learning" --strategy rag_fusion --model openai/gpt-4o

    # Graph search in specific collection
    search "transformers" 5 --graph --collection abc123

    # Verbose output
    search "deep learning" --verbose

    # JSON output
    search "RAG" --json
EOF
}

# If executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Parse flags first, they modify global variables
    ARGS=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --filter)
                if [[ "$2" =~ ^([^=]+)=(.+)$ ]]; then
                    FILTER_FIELD="${BASH_REMATCH[1]}"
                    FILTER_VALUE="${BASH_REMATCH[2]}"
                    shift 2
                else
                    echo "Error: --filter requires format 'field=value'" >&2
                    exit 1
                fi
                ;;
            --strategy)
                SEARCH_STRATEGY="$2"
                shift 2
                ;;
            --graph)
                USE_GRAPH_SEARCH=true
                shift
                ;;
            --collection)
                COLLECTION_ID="$2"
                shift 2
                ;;
            --model)
                GENERATION_MODEL="$2"
                shift 2
                ;;
            --json)
                JSON_OUTPUT=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            help|--help|-h)
                show_help
                exit 0
                ;;
            *)
                ARGS+=("$1")
                shift
                ;;
        esac
    done

    # Check if we have positional arguments
    if [ ${#ARGS[@]} -lt 1 ]; then
        show_help
        exit 0
    fi

    r2r_search "${ARGS[@]}"
fi
