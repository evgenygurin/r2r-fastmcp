#!/usr/bin/env bash
# R2R Search Command
# Hybrid search with advanced options (filters, strategies, graph search)

source "$(dirname "$0")/../lib/common.sh"

# Print compact search header (single line)
print_search_header() {
    local query="$1"
    local limit="$2"
    local strategy="$3"
    local graph_enabled="$4"
    local collection="$5"

    # Build info parts
    local parts=()
    parts+=("limit:$limit")
    [ "$strategy" != "vanilla" ] && parts+=("strategy:$strategy")
    [ "$graph_enabled" = "true" ] && parts+=("🔗 graph")
    [ -n "$collection" ] && parts+=("📁 ${collection:0:8}")

    # Join with pipes
    local IFS=" | "
    printf "🔍 Search | %s\n" "${parts[*]}"
}

# Print search stats footer (single line)
print_search_stats() {
    local result_count="$1"
    local search_time="$2"

    local parts=()
    parts+=("📄 $result_count results")
    [ -n "$search_time" ] && [ "$search_time" != "0" ] && parts+=("⏱️ ${search_time}ms")

    local IFS=" | "
    echo ""
    echo "${parts[*]}"
}

r2r_search() {
    local query=""
    local limit="$DEFAULT_LIMIT"
    local filter_field=""
    local filter_value=""
    local search_strategy="vanilla"
    local use_graph_search=false
    local collection_id=""
    local generation_model=""
    local json_output=false
    local verbose=false
    local quiet=false
    local show_metadata=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --limit|-l)
                limit="$2"
                shift 2
                ;;
            --filter|-f)
                if [[ "$2" =~ ^([^=]+)=(.+)$ ]]; then
                    filter_field="${BASH_REMATCH[1]}"
                    filter_value="${BASH_REMATCH[2]}"
                    shift 2
                else
                    print_error "--filter requires format 'field=value'"
                    return 1
                fi
                ;;
            --strategy|-s)
                search_strategy="$2"
                shift 2
                ;;
            --graph|-g)
                use_graph_search=true
                shift
                ;;
            --collection|-c)
                collection_id="$2"
                shift 2
                ;;
            --model|-m)
                generation_model="$2"
                shift 2
                ;;
            --verbose|-v)
                verbose=true
                shift
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            --show-metadata)
                show_metadata=true
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                # First positional argument is query
                if [ -z "$query" ]; then
                    query="$1"
                fi
                shift
                ;;
        esac
    done

    # Validation
    if [ -z "$query" ]; then
        print_error "Query required"
        echo "Usage: search <query> [--limit <n>] [options]"
        return 1
    fi

    # Build filters using jq
    local filters=$(jq -n '{}')

    if [ -n "$filter_field" ] && [ -n "$filter_value" ]; then
        filters=$(echo "$filters" | jq \
            --arg field "$filter_field" \
            --arg value "$filter_value" \
            '. + {($field): {"$eq": $value}}')
    fi

    if [ -n "$collection_id" ]; then
        filters=$(echo "$filters" | jq \
            --arg cid "$collection_id" \
            '. + {"collection_ids": {"$overlap": [$cid]}}')
    fi

    # Build search settings using jq
    local use_graph_json="false"
    [ "$use_graph_search" = true ] && use_graph_json="true"

    # For hyde/rag_fusion, require generation model
    if [ "$search_strategy" = "hyde" ] || [ "$search_strategy" = "rag_fusion" ]; then
        if [ -z "$generation_model" ]; then
            generation_model="openai/gpt-4o-mini"
            [ "$quiet" != true ] && print_info "Using default model for $search_strategy: $generation_model"
        fi
    fi

    # Build base search settings
    local search_settings=$(jq -n \
        --arg strategy "$search_strategy" \
        --argjson use_graph "$use_graph_json" \
        --argjson filters "$filters" \
        '{
            use_hybrid_search: true,
            search_strategy: $strategy,
            filters: $filters
        } + (if $use_graph then {use_graph_search: true} else {} end)')

    # Add generation_config for hyde/rag_fusion
    if [ -n "$generation_model" ]; then
        search_settings=$(echo "$search_settings" | jq \
            --arg model "$generation_model" \
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

    # Handle JSON output (bypass all formatting)
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Extract results
    local results=$(echo "$response" | jq -r '.results.chunk_search_results // []')
    local result_count=$(echo "$results" | jq 'length')

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "$response" | jq -r --argjson lim "$limit" '.results.chunk_search_results[:$lim][] |
            "\(.metadata.title // "Unknown") [\(.id[:8])]"'
        return 0
    fi

    # Print header (unless quiet)
    print_search_header "$query" "$limit" "$search_strategy" "$use_graph_search" "$collection_id"
    echo ""

    # Print results
    if [ "$result_count" -eq 0 ]; then
        echo "No results found"
    elif [ "$verbose" = true ]; then
        # Verbose mode: full metadata
        echo "$response" | jq -r --argjson lim "$limit" '.results.chunk_search_results[:$lim][] |
            "Score: \(.score | tonumber | . * 100 | round / 100)\n" +
            "Document ID: \(.document_id)\n" +
            "Chunk ID: \(.id[:8])\n" +
            "Title: \(.metadata.title // "Unknown")\n" +
            "Collection IDs: \(.collection_ids | join(", "))\n" +
            "Text:\n\(.text)\n" +
            "---"'
    else
        # Compact mode: one line per result - [score] title [id] | preview
        echo "$response" | jq -r --argjson lim "$limit" '.results.chunk_search_results[:$lim][] |
            "[\(.score | tonumber | . * 100 | round / 100)] \(.metadata.title // "Unknown")[\(.id[:8])] | \(.text[:100])..."'
    fi

    # Print footer stats
    if [ "$show_metadata" = true ]; then
        print_search_stats "$result_count" "0"
    fi
}

# Show help
show_help() {
    cat << 'EOF'
R2R Search Command

USAGE:
    search <query> [options]

REQUIRED:
    <query>                         The search query text

OPTIONS:
    --limit <n>                     Max results to return (default: 3)
    -l <n>                          Short form for --limit
    --filter <field=value>          Filter by metadata field
    -f <field=value>                Short form for --filter
    --strategy <name>               Search strategy (default: vanilla)
    -s <name>                       Short form for --strategy
    --collection <id>               Filter by collection ID
    -c <id>                         Short form for --collection
    --model <name>                  Model for hyde/rag_fusion strategies
    -m <name>                       Short form for --model
    --graph                         Enable graph search (entities + relationships)
    -g                              Short form for --graph

OUTPUT CONTROL:
    Default: Minimalist (header + results only)

    --verbose, -v                   Show full metadata (doc ID, chunk ID, collections)
    --quiet, -q                     Ultra-minimal (just titles)
    --show-metadata                 Show footer stats (result count, time)
    --json                          Output raw JSON response

SEARCH STRATEGIES:
    vanilla (default)               Standard hybrid search (recommended)
    hyde                            Hypothetical Document Embeddings
    rag_fusion                      Multiple queries + RRF reranking

    Note: hyde and rag_fusion require --model (default: openai/gpt-4o-mini)

OUTPUT MODES:
    Default (minimalist) - one line per result:
        🔍 Search | limit:5

        [0.92] Document Title[abc123] | Preview text here first 100 chars...
        [0.85] Another Doc[def456] | More preview text content here...

    Verbose (--verbose):
        🔍 Search | limit:5

        Score: 0.92
        Document ID: full-document-id-here
        Chunk ID: abc12345
        Title: Document Title
        Collection IDs: coll1, coll2
        Text:
        Full matched text content here...
        ---

    Quiet (--quiet):
        Document Title [abc123]
        Another Title [def456]

EXAMPLES:
    # Basic search (minimalist output)
    search "machine learning" --limit 5
    search "AI research" -l 10                  # short form

    # With filters
    search "neural networks" --filter document_type=pdf
    search "transformers" -f category=research  # short form

    # Search strategies
    search "What are LLMs?" --strategy vanilla
    search "Explain RAG" -s hyde                # short form with hyde
    search "AI trends" -s rag_fusion -m openai/gpt-4o

    # Graph search
    search "knowledge graphs" --graph
    search "entity relationships" -g            # short form

    # In specific collection
    search "API docs" --collection abc123
    search "guides" -c abc123                   # short form

    # Output control
    search "query" --verbose                    # full metadata
    search "query" -v                           # short form
    search "query" --quiet                      # minimal output
    search "query" -q                           # short form
    search "query" --show-metadata              # with footer stats
    search "query" --json                       # raw JSON

    # Combined options
    search "deep learning" -l 10 -f type=pdf -s vanilla -g -v
EOF
}

# If executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Check for help flag
    if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi

    # Pass all arguments to main function
    r2r_search "$@"
fi
